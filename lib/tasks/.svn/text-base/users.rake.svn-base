namespace :users do

  desc "Initial Setup of users. Inserts the profile info and updates all the license information"
  task :initial_setup => :environment do
    Rake::Task['users:initial_profile_info_insert'].invoke
    Rake::Task['users:initial_license_info_update'].invoke
  end

  desc "Cold starts the license infor update for the first time"
  task :initial_license_info_update => [:environment] do
    begin
      RosettaStone::FileMutex.protect('users_update') do
        Learner.licensing_info_for_cold_start
      end
    rescue RosettaStone::FileMutex::Locked
      logger.error("#{Time.now.to_s :db} - Learners Update: Lock file exists. Exiting.")
    end
  end

  desc "Updates / adds Learners from diff application and updates the index"
  task :update => [:environment] do
    begin
      Cronjob.mutex('update') do
        puts "Start of Rake task to update/insert learners"
        Learner.update_profile_info
        puts "End of Rake task to update/insert learners"
        puts "Start of Rake task to update learner details from license server."
        Learner.update_product_rights_detail
        puts "end of Rake task to update learner details from license server."
      end
    end
  end

  desc "Populate village id for learners for the first time"
  task :initial_population_of_village_id_for_learners => [:environment] do
    begin
      RosettaStone::FileMutex.protect('users_update') do
        puts "Start of Rake task to populate village id for learners."
        Learner.initial_population_of_village_id
        puts "end of Rake task to populate village id for learners."
      end
    rescue RosettaStone::FileMutex::Locked
      logger.error("#{Time.now.to_s :db} - Learners Update: Lock file exists. Exiting.")
    end
  end

  desc "removes duplicate learners"
  task :remove_duplicate_learners => [:environment] do
    begin
      RosettaStone::FileMutex.protect('users_filter') do
        puts "Start of Rake task to removes duplicate learners."
        Learner.remove_duplication_of_records
        puts "end of Rake task to removes duplicate learners."
      end
    rescue RosettaStone::FileMutex::Locked
      logger.error("#{Time.now.to_s :db} - Learners Update: Lock file exists. Exiting.")
    end
  end
  
  desc "Updates the Learner's subscription type"
  task :update_license_info => [:environment] do
    begin
      Cronjob.mutex('update_license_info') do
        Learner.update_license_info
      end
    end
  end

  desc "Updates the previous license identifiers from the license server"
  task :update_previous_license_identifiers => [:environment] do
    begin
      RosettaStone::FileMutex.protect('users_update') do
        Learner.update_license_identifiers_change_info
      end
    rescue RosettaStone::FileMutex::Locked
      logger.error("#{Time.now.to_s :db} - Learners Update: Lock file exists. Exiting.")
    end
  end

  desc "Makes Community users with no product right as rworld Learners"
  task :rworld_user_cleanup => :environment do
    conditions = {:user_source_type => "Community::User", :totale => false, :rworld => false, :osub => false}
    users = Learner.find(:all, :conditions => conditions, :select => "id")
    return if users.blank?
    user_ids = users.map(&:id)
    puts "Updating users"
    User.update_all({:rworld => 1}, conditions)
    puts "Updated Users and updating search index"
    User.bulk_index(user_ids)
    puts "Updated search index and now syncing with app boxes"
    Rake::Task['users:rsync_index_files'].invoke
    puts "Complete"
  end

  desc "Update language info for users"
  task :update_language_info => :environment do
    start_time = Time.now
    users = Learner.find(:all, :conditions => ['email != ""'], :select => 'email')
    return if users.blank?
    user_emails = users.map(&:email)
    puts "Total learners = " + users.size.to_s
    completed = 0
    new_count = 0
    update_count = 0
    user_emails.each do |user_email|
      user = Community::User.all(:select=>"id", :conditions => {:email => user_email}, :limit => 1)[0]
      if user
        user_id = user[:id]
        user_language_competencies = Community::LanguageCompetencies.find_all_by_user_id(user_id) if user_id
        user_languages = []
        user_language_competencies.each do |user_language_competency|
          user_languages << Community::Language.find_by_id(user_language_competency.language_id).identifier
        end
        local_user_language_entry = UserLanguage.find_by_user_mail_id(user_email)
        if local_user_language_entry && local_user_language_entry.language_identifier != user_languages.join(',')
          unless user_languages.empty?
            local_user_language_entry.update_attribute(:language_identifier, user_languages.join(','))
            update_count += 1
          end
        elsif local_user_language_entry.nil?
          UserLanguage.create(:language_identifier => user_languages.join(','), :user_mail_id => user_email)
          new_count += 1
        end
      end
      completed += 1
      puts "Total completed #{completed} out of #{users.size} (#{new_count} added : #{update_count} updated : #{Time.now - start_time} seconds elapsed)" if completed%10000 == 0 || completed == users.size
    end
    end_time = Time.now
    duration_minutes = (end_time - start_time)/60
    puts "Time taken to complete update_language_info task = #{duration_minutes} minutes!"
  end

  desc "Update village info for users"
  task :update_village_info => :environment do
    start_time = Time.now
    tt_record = TaskTracer.find_by_task_name 'update_village_info'
    users = Learner.find(:all, :select => "email")
    return if users.blank?
    puts "Total learners to be updated : #{users.size}"
    user_emails = users.map(&:email)
    completed = 0
    new_count = 0
    update_count = 0
    updated = false
    tt_record = TaskTracer.create(:task_name => 'update_village_info') if tt_record.nil?
    unless tt_record.is_running_now
      tt_record.update_attribute(:is_running_now, true)
      last_run = tt_record.last_successful_run.nil?? Time.now - 1.week : tt_record.last_successful_run
      puts 'last run ' + last_run.to_s
      updated_audit_recs = Community::AuditLogRecord.find_by_sql(["select MAX(timestamp) as max_val ,new_value ,email from audit_log_records,users where users.id = loggable_id and timestamp >= ? and loggable_type = 'User' and attribute_name = 'village_id' group by loggable_id", last_run])
      puts updated_audit_recs.inspect
      puts "Updating values from audit logs"
      updated_audit_recs.any? && updated_audit_recs.each do |rec|
        mail = rec.email
        if user_emails.include?(mail)
          village_id = rec.new_value
          unless village_id.nil?
            user_village_record= UserVillage.find_by_user_mail_id(mail)
            if user_village_record
              if user_village_record.village_id != village_id
                user_village_record.update_attribute(:village_id,village_id)
                update_count += 1
              end
            else
              UserVillage.create(:village_id=>village_id, :user_mail_id=>mail)
              new_count += 1
            end
          end
        end
        completed += 1
        puts "Total completed #{completed} out of #{users.size} (#{new_count} added : #{update_count} updated : #{Time.now - start_time} seconds elapsed)" if completed%10000 == 0 || completed == users.size
      end
      puts "\nUpdating values from user-village table"
      update_count = new_count = 0
      updated_user_table_recs = Community::UserVillages.find_by_sql(["select email, GROUP_CONCAT(village_id) as village_ids from users, user_villages where user_id = users.id and user_villages.updated_at >= ? group by email",last_run])
      puts "Records found = #{updated_user_table_recs.size}"
      updated_user_table_recs.any? and updated_user_table_recs.each do |rec|
        mail = rec.email        
        if user_emails.include?(mail)
          village_id = rec.village_ids
          unless village_id.nil? or village_id.blank?
            user_village_record= UserVillage.find_by_user_mail_id(mail)
            if user_village_record
                current_village_id = user_village_record.village_id
                village_id += ","+current_village_id
                village_id = (village_id.split(',').uniq).join(',') # forming all into one record "4,5" += "," "5,6,7" = "4,5,6,7"
                user_village_record.update_attribute(:village_id,village_id)
                update_count += 1
            else
              UserVillage.create(:village_id=>village_id, :user_mail_id=>mail)
              new_count += 1
            end
            completed += 1
          end
        end
        puts "Total completed #{completed} out of #{users.size} (#{new_count} added : #{update_count} updated : #{Time.now - start_time} seconds elapsed)" if completed%10000 == 0 || completed == users.size
      end
      updated = true
      tt_record.update_attributes(:is_running_now => false, :last_successful_run => Time.now)
    end
    end_time = Time.now
    duration_minutes = (end_time - start_time)/60
    unless updated
      puts "Cannot update. Please try again later"
    else
      puts "Time taken to complete update_village_info task = #{duration_minutes} minutes!"
    end
  end

end
