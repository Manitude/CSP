namespace :ccs do
  
  desc "Check Delayed Job status and restart if stopped"
  task :check_delayed_job => :environment do
    Cronjob.mutex('check_delayed_job') do
      delayed_job_status = File.file?("./tmp/pids/delayed_job.pid")
      unless delayed_job_status
        start_time = Time.now.to_s(:db)
        response = `./bundle exec script/delayed_job start production`
        pid = File.open('./tmp/pids/delayed_job.pid', &:readline).strip
        end_time = Time.now.to_s(:db)
        BackgroundTask.create(:referer_id => 99999, :triggered_by => "Cron Job", :job_start_time => start_time, :job_end_time => end_time, :message => "Delayed job was stopped. Restarted with pid : #{pid}")
      end  
    end
  end
  
  desc "Check if any job yet to pick up or takes more time"
  task :check_job_not_picked_up => :environment do
    Cronjob.mutex('check_job_not_picked_up') do
      first_job = DelayedJob.first
      if first_job.present? && (first_job.created_at <= (Time.now.utc - 2.hours))
        GeneralMailer.job_not_picked_up_mail.deliver
      end
    end
  end

  desc "Create talbes for community database for testing purposes. This is one time setup for CI system"
  task :community_test_db => :environment do
    begin
      RosettaStone::FileMutex.protect('create_community_database') do
        logger.info "create community database started at #{Time.now}."
        begin
          ActiveRecord::Base.connection.execute(
            "CREATE Database community_test;")
          ActiveRecord::Base.connection.execute(
            "use community_test;")
          ActiveRecord::Base.connection.execute(
            "CREATE TABLE `villages` (
          `id` int(11) NOT NULL ,
          `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
          `description` text COLLATE utf8_unicode_ci,
          `created_at` datetime DEFAULT NULL,
          `updated_at` datetime DEFAULT NULL,
          `public` tinyint(1) NOT NULL DEFAULT '0',
          `parent_village_id` int(11) DEFAULT NULL);")
        rescue ActiveRecord::StatementInvalid => e
          puts "Probably this script has already been executed as the exception is #{e.class}"
        end
      end
      logger.info "create community database finished at #{Time.now}."
    rescue RosettaStone::FileMutex::Locked
      logger.error("#{Time.now.to_s :db} - create community database: Lock file exists. Exiting.")
    end
  end

  desc "deleting duplicate recurring schedules"
  task :delete_duplicates => :environment do
    ActiveRecord::Base.connection.execute("CREATE TABLE recurring_schedules_backup LIKE coach_recurring_schedules")
    puts "Deleting duplicate recurring schedules..."
    #deleting same time duplicates
    count = 0
    CoachRecurringSchedule.find_by_sql(%Q(SELECT a1.id from
      coach_recurring_schedules a1 inner join
      coach_recurring_schedules a2 where
      a1.start_time = a2.start_time and
      a1.day_index = a2.day_index and
      a1.coach_id = a2.coach_id and
      a1.id < a2.id and a1.recurring_end_date is  null and
      (fn_GetZoneOffset(CONVERT_TZ('2012-10-04 04:00:00' ,'GMT','EST')) - fn_GetZoneOffset(CONVERT_TZ(a1.recurring_start_date,'GMT','EST'))) = (fn_GetZoneOffset(CONVERT_TZ('2012-10-04 04:00:00' ,'GMT','EST')) - fn_GetZoneOffset(CONVERT_TZ(a2.recurring_start_date,'GMT','EST'))))
    ).each do |schedule|
      count += 1
      ActiveRecord::Base.connection.execute("INSERT INTO recurring_schedules_backup (coach_id, day_index , start_time , recurring_start_date , recurring_end_date , language_id, created_at , updated_at, external_village_id) SELECT coach_id, day_index , start_time , recurring_start_date , recurring_end_date , language_id, created_at , updated_at, external_village_id FROM coach_recurring_schedules WHERE id = #{schedule.id}")
      schedule.delete
    end
    puts "Deleted #{count} duplicate records"

    #deleting duplicates due to day light switch
    count = 0
    CoachRecurringSchedule.find_by_sql(%Q(SELECT id, coach_id, language_id,
      (CONCAT("2012-10-14 " , start_time) + INTERVAL day_index DAY +
        INTERVAL (fn_GetZoneOffset(CONVERT_TZ("2012-10-14 04:00:00" ,"GMT","EST")) - fn_GetZoneOffset(CONVERT_TZ(recurring_start_date,"GMT","EST"))) HOUR +
        INTERVAL (CASE WHEN hour(start_time) < fn_GetZoneOffset(CONVERT_TZ(recurring_start_date,"GMT","EST")) AND day_index = 0 THEN 7 ELSE 0 END) day) AS schedule_time ,
      count(*)                FROM coach_recurring_schedules
      WHERE recurring_end_date is NULL GROUP BY coach_id,schedule_time HAVING COUNT(*) > 1)
    ).each do |schedule|
      count += 1
      ActiveRecord::Base.connection.execute("INSERT INTO recurring_schedules_backup (coach_id, day_index , start_time , recurring_start_date , recurring_end_date , language_id, created_at , updated_at, external_village_id) SELECT coach_id, day_index , start_time , recurring_start_date , recurring_end_date , language_id, created_at , updated_at, external_village_id FROM coach_recurring_schedules WHERE id = #{schedule.id}")
      schedule.delete
    end
    puts "Deleted #{count} more duplicate records"
  end

  desc "Updating number of seats for aria sessions"
  task :update_seats_for_aria_sessions => :environment do
    schedule_count = 0
    languages = Language.language_obj(true).map {|l| l.id}.join(',')
    CoachRecurringSchedule.find_by_sql(%Q(SELECT * from coach_recurring_schedules where language_id in (#{languages}) )).each do |schedule|
      schedule_count +=1
      schedule.update_attributes(:number_of_seats => 1)
    end
    puts "Updated #{schedule_count} coach recurring schedules"
    session_count = 0
    ConfirmedSession.find_by_sql(%Q(SELECT * from coach_sessions where language_id in (#{languages}) && (number_of_seats is NULL || number_of_seats = 4))).each do |session|
      session_count += 1
      session.update_attribute(:number_of_seats,1)
    end
    puts "Updated #{session_count} coach sessions"
  end
  
end
