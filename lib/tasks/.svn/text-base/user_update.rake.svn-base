namespace :update do
  desc "update the user name and email for alewis"
  task :user_name_and_email => :environment do
    begin
      coach = Coach.find_by_user_name("alewis")
      if coach.valid?
        coach.update_attributes(:user_name => "allewis",:rs_email => "allewis@rosettastone.com") ? (puts "User name and Email has updated succesfully") : (puts "Problem in updation #{coach.errors}")
      else
        puts "Not a Valid Coach -- #{coach.errors}"
      end
    rescue
      puts "Not Able to find the coach"
    end
  end

  desc "removing the duplicate coach entry 'Breske Ashleigh' and moving the related data to 'Ashleigh Breske' "
  task :remove_duplicate_coach => :environment do
    puts "We are going to move all related data from 'Breske Ashleigh(duplicate coach)' to 'Ashleigh Breske'(original coach)"
    puts "Press 'C' to continue"
    if STDIN.gets.chomp == "C"
      begin
        duplicate_coach =  Coach.find_by_full_name( "Breske, Ashleigh" )
        original_coach = Coach.find_by_full_name( "Ashleigh Breske" )
        dependants = [ "availability_templates", "availability_modifications", "approved_modifications", "recurring_schedules", "substitutions", "coach_sessions", "confirmed_coach_sessions", "region", "manager" ]
        dependants.each do | dependant |
          duplicate_entry_values = duplicate_coach.method( dependant ).call
          unless duplicate_entry_values.blank?
            if duplicate_entry_values.class == Array
              puts "Moving #{dependant} to original coach from duplicate coach"
              original_coach.method( dependant ).call << duplicate_entry_values
            else
              duplicate_coach.update_attribute( dependant, nil )
            end
          end
        end
        duplicate_coach.destroy
        puts "All related data has succesfully moved to original coach and duplicate coach has removed"
      rescue Exception => e
        puts "There was an error --> #{e.message}"
      end
    end
  end

  desc "update missing fields for the user"
  task :update_fields_for_user => :environment do
    begin
      ActiveRecord::Base.connection.execute("update accounts set time_zone = 'Eastern Time (US & Canada)', primary_phone = '1234567890',primary_country_code = '1' where user_name = 'eneilsen';")
      puts "Updated successfully"
    rescue Exception => e
      puts "There was an error --> #{e.inspect}"
    end
  end

  desc "reverting missing fields for the user"  
  task :reverting_fields_for_user => :environment do
    begin
      ActiveRecord::Base.connection.execute("update accounts set time_zone = null, primary_phone = null,primary_country_code = null where user_name = 'eneilsen';")
      puts "Reverted successfully"
    rescue Exception => e
      puts "There was an error --> #{e.inspect}"
    end
  end

  desc "update learner username for institutional learners"
  task :update_learner_username => :environment do
    puts "Learner username update started at : #{Time.now}"
    count = 0
    Learner.find_in_batches({:select => "id, guid", :batch_size => 100, :conditions => "user_source_type = 'RsManager::User'"}) do |learners|
      guids  = learners.collect{|l| "'#{l.guid}'"}.join(",")
      cond = " "
      RsManager::User.where("guid IN (#{guids})").select("guid, username").each do |vl|
        cond += "WHEN guid = '#{vl.guid}' THEN CONVERT('#{vl.username.gsub(/[']/, "''")}' USING utf8) "
      end
      if cond != " "
        query = "UPDATE learners SET user_name = (CASE" + cond + "ELSE user_name END) WHERE guid IN (#{guids})"
        ActiveRecord::Base.connection.execute(query)
      end
      count += learners.size
      puts "#{count} records updated."
    end
    puts "Learner username update finished at : #{Time.now}"
  end
  
  desc "update external session id for future sessions in eschool"
  task :update_external_session_id => :environment do
    puts "External session id update started at : #{Time.now}"
    count = 0
    ConfirmedSession.find_in_batches({:batch_size => 100, :conditions => "session_start_time >= '2013-05-01 00:00:00' and language_identifier != 'KLE' "}) do |sessions|
      ids = sessions.collect{|cs| {:external_session_id=> cs.id, :eschool_session_id => cs.eschool_session_id}}
      count += sessions.size
      response = Eschool::Session.get_session_details({:ids => ids })
      
      puts "#{count} records updated."
    end  
    puts "External session id update finished at : #{Time.now}"
  end  

  desc "update coach_availability times to handle timezone issues"
  task :update_availability_times => :environment do
    puts "Availability times update started at : #{Time.now}"
    avls = CoachAvailability.find_by_sql("select avl.id from coach_availabilities avl join coach_availability_templates temp on temp.id = avl.coach_availability_template_id where avl.created_at > '2014-04-29 13:30:00' and ((fn_GetZoneOffset(CONVERT_TZ(avl.created_at,'GMT','EST'))-fn_GetZoneOffset(CONVERT_TZ(temp.created_at,'GMT','EST'))) != 0)")
    avls.collect(&:id).each do |avl|
      x = CoachAvailability.find(avl)
      if x.start_time.hour == 23
        if x.day_index == 6
          x.update_attribute(:day_index,0)
        else
        x.update_attribute(:day_index,x.day_index+1)
        end
      end   
      x.update_attribute(:start_time, x.start_time + 1.hour)
      x.update_attribute(:end_time, x.end_time + 1.hour)
    end
    puts "Availability ids updated : #{avls.collect(&:id)}"
    puts "Availability times update ended at : #{Time.now}"
  end

end