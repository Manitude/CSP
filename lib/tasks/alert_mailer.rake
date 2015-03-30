namespace :mailer do

  desc "to send email for all languages activity reports"
  task :all_languages_coach_activity_reports => :environment do
    puts "inside task"
    report_location = '/tmp/coach_activity_report_for_all_languages.csv'
    coach_manager = CoachManager.last
    GeneralMailer.send_all_languages_coach_activity_reports(coach_manager, report_location).deliver
    puts "email has been sent"
  end
  
  desc "Send email alerts for for substitutions/notifications/events/announcements to the corresponding coaches every one hour."
  task :hourly_email_alert => :environment do
    Cronjob.mutex('hourly_email_alert') do
      begin
        hourly_coaches_for_sub_alerts = get_all_coaches_based_on_content_type_and_frequency('sub_alert',"HOURLY")
        hourly_coaches_for_notifications = get_all_coaches_based_on_content_type_and_frequency('notification',"HOURLY")
        hourly_coaches_for_calendar_events = get_all_coaches_based_on_content_type_and_frequency('calendar_event',"HOURLY")
        final_sub_alert_map = all_coach_details_for_mailing_sub_alerts(hourly_coaches_for_sub_alerts,'hourly')
        final_notification_map = map_notification_with_coach('hourly',hourly_coaches_for_notifications)
        final_calendar_events_map = map_lang_with_coach_for_calendar_events(hourly_coaches_for_calendar_events,'hourly')
        substitution_sub = 'Sub Alert:' + Time.now.strftime("%I:%M %p %a %b %d, %Y").to_s
        mailer_method_for_sub(final_sub_alert_map,substitution_sub)
        notification_sub = 'Notification Alert:' + Time.now.strftime("%I:%M %p %a %b %d, %Y").to_s
        mailer_method_for_notifications(final_notification_map,notification_sub)
        event_sub = 'Calendar Events Alert:' + Time.now.strftime("%I:%M %p %a %b %d, %Y").to_s
        mailer_method_for_events(final_calendar_events_map,event_sub)
      rescue Exception => ex
        notify_hoptoad(ex)
      end
    end
  end

  desc "Send email alerts for for substitutions/notifications/events/announcements to the corresponding coaches every day."
  task :daily_email_alert => :environment do
    Cronjob.mutex('daily_email_alert') do
      begin
        daily_coaches_for_sub_alerts = get_all_coaches_based_on_content_type_and_frequency('sub_alert',"DAILY")
        daily_coaches_for_notifications = get_all_coaches_based_on_content_type_and_frequency('notification',"DAILY")
        daily_coaches_for_calendar_events = get_all_coaches_based_on_content_type_and_frequency('calendar_event',"DAILY")
        final_sub_alert_map = all_coach_details_for_mailing_sub_alerts(daily_coaches_for_sub_alerts,'daily')
        final_notification_map = map_notification_with_coach('daily',daily_coaches_for_notifications)
        final_calendar_events_map = map_lang_with_coach_for_calendar_events(daily_coaches_for_calendar_events,'daily')
        substitution_sub = 'Sub Alert:' + Time.now.strftime("%b %d, %Y").to_s
        mailer_method_for_sub(final_sub_alert_map,substitution_sub)
        notification_sub = 'Notification Alert:' + Time.now.strftime("%b %d, %Y").to_s
        mailer_method_for_notifications(final_notification_map,notification_sub)
        event_sub = 'Calendar Events Alert:' + Time.now.strftime("%b %d, %Y").to_s
        mailer_method_for_events(final_calendar_events_map,event_sub)
        
        # Also using this to send the daily emails to coach managers for policy violation
        coach_manager_list_for_policy_mail = get_all_coaches_based_on_content_type_and_frequency('substitution_policy',"DAILY")
          data = get_substitutions_records_for_policy(Time.now - 1.day,Time.now)
        mailer_method_for_substitution_policy(coach_manager_list_for_policy_mail, data)
      rescue Exception => ex
        notify_hoptoad(ex)
      end
    end
  end

  desc "Send email alerts Timeoff requests to the corresponding coaches every day."
  task :daily_timeoff_request_email_alert => :environment do
    Cronjob.mutex('daily_timeoff_request_email_alert') do
      begin
        # Using this to send daily emails to coach managers mentioning timeoff requests
        coach_manager_list_for_timeoff_request_mail = get_all_coaches_based_on_content_type_and_frequency('timeoff_alert',"DAILY")
        data = get_timeoff_requests
        mailer_method_for_timeoff(coach_manager_list_for_timeoff_request_mail, data)
      rescue Exception => ex
        notify_hoptoad(ex)
      end
    end
  end

  desc "Update mails_sent every day to 0"
  task :update_mails_sent_count => :environment do
    Cronjob.mutex('update_mails_sent_count') do
      begin
        all_preferences = PreferenceSetting.find(:all)
        all_preferences.each do |pref|
          pref.update_attribute(:mails_sent,0)
        end
      rescue Exception => ex
        notify_hoptoad(ex)
      end
    end
  end

  desc "substitution policy mail for week"
  task :weekly_policy_alert => :environment do
    Cronjob.mutex('checking_policy') do
      begin
        coach_manager_list_for_policy_mail = get_all_coaches_based_on_content_type_and_frequency('substitution_policy',"WEEKLY")
          data = get_substitutions_records_for_policy(Time.now - 1.week,Time.now)
        mailer_method_for_substitution_policy(coach_manager_list_for_policy_mail, data)
      rescue Exception => ex
        notify_hoptoad(ex)
      end
    end
  end

  desc "substitution policy mail for month"
  task :monthly_policy_alert => :environment do
    Cronjob.mutex('checking_policy') do
      begin
        coach_manager_list_for_policy_mail = get_all_coaches_based_on_content_type_and_frequency('substitution_policy',"MONTHLY")
          data = get_substitutions_records_for_policy(Time.now - 1.month,Time.now)
        mailer_method_for_substitution_policy(coach_manager_list_for_policy_mail, data)
      rescue Exception => ex
        notify_hoptoad(ex)
      end
    end
  end

  desc "Sends unassigned upcoming PHL sessions Daily"
  task :mail_phl_session_report => :environment do
      #Rails.logger.debug('cron running')
      phl_records     = get_unassigned_phl_session_report
      reporter_email  = 'rsstudioteam-supervisors-l@rosettastone.com'
      if phl_records.count > 0 
        GeneralMailer.send_unassigned_phl_session_reports(reporter_email,phl_records).deliver
      end
  end

  def get_substitutions_records_for_policy(start_date,end_date)
    sql = "select Distinct s.id,s.coach_id from substitutions s join coach_sessions c on s.coach_session_id = c.id join unavailable_despite_templates u where c.type NOT IN ('ExtraSession','Appointment') and s.created_at >'#{start_date.utc.to_s(:db)}' and s.created_at <'#{end_date.utc.to_s(:db)}' and u.coach_session_id=c.id and s.coach_id is not null and (s.coach_id != s.grabber_coach_id OR s.grabber_coach_id is null) and u.unavailability_type in (1,5);"
    result = Substitution.find_by_sql(sql)
    result_hash = Hash.new{|hash, key| hash[key] = []}
    result.each do |rec|
      result_hash[rec.coach_id] << rec.id
    end
    data = []
    result_hash.each { |key,value| data << prepare_data_for_sub_policy(key,value)}
    data.reject!{|sub| sub["subs_in_violation"].blank?}
    {"details" => data, "date" => [TimeUtils.time_in_user_zone(start_date).strftime("%I:%M %p %B %d"),TimeUtils.time_in_user_zone(end_date).strftime("%I:%M %p %B %d")]}
  end  

  def get_timeoff_requests
    result = UnavailableDespiteTemplate.where("unavailability_type = 0 and approval_status = 0 and start_date > ?",Time.now)
    end  

  def prepare_data_for_sub_policy(key,value)
    coach = Coach.find_by_id(key)
    coach_id = key
    substitutions = Substitution.where("id in (?)",value)
    violated_subs = []
    first_sub = []
    substitutions.each do |sub|
      start_time = (TimeUtils.time_in_user_zone(sub.coach_session.session_start_time)).beginning_of_month.utc.to_s(:db)
      end_time = (TimeUtils.time_in_user_zone(sub.coach_session.session_start_time)).end_of_month.utc.to_s(:db)
      sql = "SELECT DISTINCT * FROM substitutions s JOIN coach_sessions c ON s.coach_session_id = c.id JOIN unavailable_despite_templates u WHERE c.type NOT IN ('ExtraSession','Appointment') AND s.coach_id=#{coach_id} AND c.session_start_time >= '#{start_time}' AND c.session_start_time < '#{end_time}' AND u.coach_session_id=c.id AND (s.coach_id != s.grabber_coach_id OR s.grabber_coach_id is null) AND u.unavailability_type IN (1,5) ORDER BY s.created_at LIMIT 1;"
      violation_substitution = Substitution.find_by_sql(sql).first
      if TimeUtils.time_in_user_zone(violation_substitution.coach_session.session_start_time).to_date != TimeUtils.time_in_user_zone(sub.coach_session.session_start_time).to_date
          violated_subs << sub
          first_sub << violation_substitution.coach_session.session_start_time.in_time_zone("Eastern Time (US & Canada)").strftime("%I:%M %p %A %B %d, %Y")
      end  
    end
    violation_data = []
    
    violated_subs.each do | sub |
      sql = "select a.type,a.full_name from accounts a join audit_log_records l on a.user_name=l.changed_by where l.loggable_id=#{sub.id} and l.loggable_type='Substitution' and l.action='create';"
      details = Account.find_by_sql(sql).first
      next unless details
      y = Hash.new{|hash, key| hash[key] = []}
      y["language"] = Language[sub.coach_session.language_identifier].display_name
      y["session_start_time"] = sub.coach_session.session_start_time.in_time_zone("Eastern Time (US & Canada)").strftime("%I:%M %p %A %B %d, %Y")
      y["requester"] = details.full_name
      y["role"] = details.type
      violation_data << y
    end  
    {"coach" => coach.full_name,"permitted_sub_date" => first_sub.uniq, "subs_in_violation" => violation_data }
  end  

  def mailer_method_for_sub(list,subject)
    list.each do |detail|
      mails_sent = PreferenceSetting.find_by_id(detail[:pref_id]).mails_sent
      daily_cap = detail[:daily_cap]
      bool = check_daily_cap_value(mails_sent,daily_cap)
      if (detail[:sub_ids].size > 0 && (detail[:active] == 1) && (detail[:type] == 'Coach' || detail[:type] == 'CoachManager') && bool)
        GeneralMailer.email_alert_hourly_and_daily('sub_alert',subject,detail[:sub_details],detail[:email],detail[:type]).deliver
        p = PreferenceSetting.find_by_id(detail[:pref_id])
        p.update_attribute(:mails_sent,p.mails_sent+1)
      end
    end
  end

  def mailer_method_for_notifications(list,subject)
    list.each do |detail|
      mails_sent = PreferenceSetting.find_by_id(detail[:pref_id]).mails_sent
      daily_cap = detail[:daily_cap]
      bool = check_daily_cap_value(mails_sent,daily_cap)
      if(detail[:notifications].size > 0 && (detail[:active] == 1) && (detail[:type] == 'Coach' || detail[:type] == 'CoachManager') && bool)
        str_array = detail[:notifications].split('#')
        GeneralMailer.email_alert_hourly_and_daily('notification',subject,str_array,detail[:email],detail[:type]).deliver
        p = PreferenceSetting.find_by_id(detail[:pref_id])
        p.update_attribute(:mails_sent,p.mails_sent+1)
      end
    end
  end

  def mailer_method_for_events(list,subject)
    list.each do |detail|
      mails_sent = PreferenceSetting.find_by_id(detail[:pref_id]).mails_sent
      daily_cap = detail[:daily_cap]
      bool = check_daily_cap_value(mails_sent,daily_cap)
      if(detail[:all_events].size > 0 && (detail[:active] == 1) && (detail[:type] == 'Coach' || detail[:type] == 'CoachManager') && bool)
        GeneralMailer.email_alert_hourly_and_daily('event',subject,detail[:all_events],detail[:email],detail[:type]).deliver
        p = PreferenceSetting.find_by_id(detail[:pref_id])
        p.update_attribute(:mails_sent,p.mails_sent+1)
      end
    end
  end

  def mailer_method_for_substitution_policy(list,details)
    list.each do |detail|
      mails_sent = PreferenceSetting.find_by_id(detail[:pref_id]).mails_sent
      daily_cap = detail[:daily_cap]
      bool = check_daily_cap_value(mails_sent,daily_cap)
      if(details["details"].size > 0  && (detail[:active] == 1) && bool)
        GeneralMailer.send_policy_violation_mails(detail[:email],details).deliver
        p = PreferenceSetting.find_by_id(detail[:pref_id])
        p.update_attribute(:mails_sent,p.mails_sent+1)
      end
    end
  end

  def mailer_method_for_timeoff(list,details)
    list.each do |detail|
      mails_sent = PreferenceSetting.find_by_id(detail[:pref_id]).mails_sent
      daily_cap = detail[:daily_cap]
      bool = check_daily_cap_value(mails_sent,daily_cap)
      if(details.present?  && (detail[:active] == 1) && bool)
        GeneralMailer.send_timeoff_request_mails(detail[:email],details).deliver
        p = PreferenceSetting.find_by_id(detail[:pref_id])
        p.update_attribute(:mails_sent,p.mails_sent+1)
      end
    end
  end

  def check_daily_cap_value (mails_sent,daily_cap)
    if daily_cap.nil?
      bool = true
    elsif daily_cap == 0
      bool = false
    else
      bool = (mails_sent < daily_cap)
    end
    bool
  end
  
  def get_all_coaches_based_on_content_type_and_frequency(content_type,frequency) # Queries preference settings and joins with accounts to give a result based on content type and frequency passed.
    main_str1 = 'select accounts.id,accounts.full_name,accounts.type as account_type,accounts.active,'
    main_str3 = 'preference_settings.id as pref_id,preference_settings.account_id,preference_settings.daily_cap,preference_settings.mails_sent,preference_settings.substitution_alerts_email, preference_settings.substitution_alerts_email_type,preference_settings.substitution_alerts_email_sending_schedule,preference_settings.notifications_email, preference_settings.notifications_email_type,preference_settings.notifications_email_sending_schedule,preference_settings.calendar_notices_email, preference_settings.calendar_notices_email_type,preference_settings.calendar_notices_email_sending_schedule, preference_settings.timeoff_request_email, preference_settings.timeoff_request_email_type from accounts,preference_settings where accounts.id = preference_settings.account_id and '
    sub_str1 = 'preference_settings.substitution_alerts_email = 1 '
    sub_str2 = 'and preference_settings.substitution_alerts_email_sending_schedule = ?'
    not_str1 = 'preference_settings.notifications_email = 1 '
    not_str2 = 'and preference_settings.notifications_email_sending_schedule = ?'
    cal_ann_str1 = 'preference_settings.calendar_notices_email = 1 '
    cal_ann_str2 = 'and preference_settings.calendar_notices_email_sending_schedule = ?'
    policy_str1 = 'preference_settings.substitution_policy_email = 1 '
    policy_str2 = 'and preference_settings.substitution_policy_email_sending_schedule = ?'
    toff_str1 = 'preference_settings.timeoff_request_email = 1'

    if content_type == 'sub_alert'
      main_str2 = "IF(substitution_alerts_email_type = 'RS',accounts.rs_email,accounts.personal_email) as email,"
      final_str = main_str1+main_str2+main_str3 + sub_str1 + sub_str2
    elsif content_type == 'notification'
      main_str2 = "IF(notifications_email_type = 'RS',accounts.rs_email,accounts.personal_email) as email,"
      final_str = main_str1+main_str2+main_str3 + not_str1 + not_str2
    elsif content_type == 'calendar_event'
      main_str2 = "IF(calendar_notices_email_type = 'RS',accounts.rs_email,accounts.personal_email) as email,"
      final_str = main_str1+main_str2+main_str3 + cal_ann_str1 + cal_ann_str2
    elsif content_type == 'substitution_policy'
      main_str2 = "IF(substitution_policy_email_type = 'RS',accounts.rs_email,accounts.personal_email) as email,"
      final_str = main_str1+main_str2+main_str3 + policy_str1 + policy_str2
    elsif content_type == 'timeoff_alert'
      main_str2 = "IF(timeoff_request_email_type = 'RS',accounts.rs_email,accounts.personal_email) as email,"
      final_str = main_str1+main_str2+main_str3 + toff_str1
    end
    PreferenceSetting.find_by_sql([final_str,frequency])
  end

  def map_language_identifier_with_sub_ids(type) # Query to map the language_identifiers with the substitution records to make it simpler to map coaches with the sub records.
    str = "SELECT coach_sessions.language_identifier , GROUP_CONCAT(substitutions.id SEPARATOR ',') as id_map FROM substitutions,coach_sessions WHERE substitutions.grabbed = 0 and substitutions.cancelled = 0  and substitutions.coach_session_id = coach_sessions.id and substitutions.created_at <= ? and substitutions.created_at >= ? GROUP BY coach_sessions.language_identifier"
    if(type=='hourly')
      all_substitutions = Substitution.find_by_sql([str,Time.now.utc,Time.now.utc-1.hour])
    elsif(type=='daily')
      all_substitutions = Substitution.find_by_sql([str,Time.now.utc,Time.now.utc-1.day])
    end
    all_substitutions
  end

  def map_notification_with_coach(type,coaches_for_notifications) #maps the coach details with the corresponding notifications for him.
    notifications_hash = {}
    hash_of_coach_with_notifications = []
    not_id1 = TriggerEvent.find_by_name('SUBSTITUTION_GRABBED').id
    not_id2 = TriggerEvent.find_by_name('MANUALLY_REASSIGNED').id
    not_id3 = TriggerEvent.find_by_name('SUBSTITUTE_REQUESTED').id
    not_id4 = TriggerEvent.find_by_name('TIME_OFF_EDITED').id
    not_id5 = TriggerEvent.find_by_name('SUBSTITUTE_REQUESTED_FOR_COACH').id
    all_records = Notification.find(:all , :conditions => ["trigger_event_id in (?)",[not_id1,not_id2,not_id3,not_id4,not_id5]])
    all_ids = all_records.collect(&:id)
    coaches_for_notifications.each do |coach|
      if(type == 'hourly')
        all_notifications = Account.find_by_id(coach.account_id).system_notifications_in_last_hour
      elsif (type == 'daily')
        all_notifications = Account.find_by_id(coach.account_id).system_notifications_in_last_day
      end
      str = ""
      selected_notifications = all_notifications.select{|notification| (!all_ids.include?(notification.notification_id) && !notification.notification_id.nil?) }
      selected_notifications.each do |notification|
        if notification
          msg = notification.message(true)
          str = str + msg if msg
          if notification.require_cta_links?
            tar_obj = notification.target_object
            tar_obj_id = tar_obj.id
            str += "" 
            path1 = "http://coachportal.rosettastone.com/approve-modification/"+tar_obj_id.to_s+"/true?coachToShow=&postedFrom=&showTemplateChanges=1&showTimeOffRequests=1"
            path2 = "http://coachportal.rosettastone.com/approve-modification/"+tar_obj_id.to_s+"/false?coachToShow=&postedFrom=&showTemplateChanges=1&showTimeOffRequests=1"
            str += "<a href = '#{path1}'>"+'Approve'+"</a>" if tar_obj.end_date.utc > Time.now.utc
            str += "         "
            str += "<a href = '#{path2}'>"+'Deny'+"</a>" if tar_obj.end_date.utc > Time.now.utc
          end
          str+= "#" if notification
        end
      end
      notifications_hash = {
        :pref_id => coach.pref_id,
        :id => coach.account_id,
        :name => coach.full_name,
        :email => coach.email,
        :notifications => str,
        :daily_cap => coach.daily_cap,
        :mails_sent => coach.mails_sent,
        :active => coach.active,
        :type => coach.account_type
      }
      hash_of_coach_with_notifications << notifications_hash
    end
    hash_of_coach_with_notifications
  end

  def map_lang_with_coach_for_calendar_events(coaches_for_calendar_events,type) #maps the coach details with the corresponding calendar events for him.
    str = "SELECT IF(languages.identifier!=-1,languages.identifier,'All') as language_identifier,GROUP_CONCAT(events.id SEPARATOR ',') as id_map FROM events LEFT JOIN languages ON (languages.id = events.language_id) WHERE events.created_at <= ? and events.created_at >= ? GROUP BY language_id"
    if(type=='hourly')
      all_events = Event.find_by_sql([str,Time.now.utc,Time.now.utc-1.hour])
    elsif(type=='daily')
      all_events = Event.find_by_sql([str,Time.now.utc,Time.now.utc-1.day])
    end
    map_events_hash = {}
    all_events.each do |map_det|
      map_events_hash[map_det.language_identifier] = map_det.id_map
    end
    array_of_account_event_details = []
    coaches_for_calendar_events.each do |detail|
      event_ids = ''
      lang_identifiers = []
      account = Account.find_by_id(detail.account_id)
      if account.is_coach?
        lang_identifiers = account.languages.collect(&:identifier)
      elsif account.is_manager?
        lang_identifiers = Language.all.collect(&:identifier)
      end
        lang_identifiers.reject!{|lang| lang=="KLE"} #reflex sunset
      event_array =[]
      lang_identifiers.each do |lang|
        event_ids = event_ids + map_events_hash[lang] + ',' if map_events_hash[lang]
      end
      event_ids = event_ids + map_events_hash['All'] if map_events_hash['All']
      id_array = event_ids.split(',')
      account_region = account[:region_id].blank? ? -1 : account[:region_id]
      id_array.each do |id|
        event = Event.find_by_id(id)
        event_array << event if event.region_id == account_region
      end
      account_event_detail = {
        :pref_id => detail.pref_id,
        :id => account.id,
        :name => detail.full_name,
        :email => detail.email,
        :lang_identifiers => lang_identifiers,
        :event_ids =>event_ids,
        :daily_cap => detail.daily_cap,
        :mails_sent => detail.mails_sent,
        :all_events => event_array,
        :active => detail.active,
        :type => detail.account_type
        
      }
      array_of_account_event_details << account_event_detail
    end
    array_of_account_event_details
  end

  def all_coach_details_for_mailing_sub_alerts(preference_array,type) # main method which gives a final hash which contains all the coach details with the sub record id s to email.
    mapped_array_one_hour = map_language_identifier_with_sub_ids(type)
    map_details_hash = {}
    mapped_array_one_hour.each do |map_det|
      map_details_hash[map_det["language_identifier"]] = map_det.id_map
    end
    array_of_account_details = []
    preference_array.each do |detail|
      sub_ids = ''
      lang_identifiers = []
      account = Account.find_by_id(detail.account_id)
      if account.is_coach?
        lang_identifiers = account.languages.collect(&:identifier)
      elsif account.is_manager?
        lang_identifiers = Language.all.collect(&:identifier)
      end
      lang_identifiers.reject! { |lang| lang == "KLE"} #reflex sunset
      lang_identifiers.each do |lang|
        sub_ids = sub_ids + map_details_hash[lang] + ',' if map_details_hash[lang]

      end
      all_sub_details = []
      id_array = sub_ids.split(',')
      all_sub = Substitution.find(:all,:conditions => ["id in (?)",id_array])
      sub_det = nil
      all_sub.each do |each_sub|
        learners = each_sub.coach_session.learners_signed_up
        sub_det = {
          :coach              => each_sub.coach,
          :language           => each_sub.language,
          :subsitution_date   => each_sub.substitution_date,
          :sub_id             => each_sub.id,
          :level              => each_sub.coach_session.single_number_unit ? CurriculumPoint.level_and_unit_from_single_number_unit(each_sub.coach_session.single_number_unit)[:level] : 'N/A',
          :unit               => each_sub.coach_session.single_number_unit ? CurriculumPoint.level_and_unit_from_single_number_unit(each_sub.coach_session.single_number_unit) [:unit] : 'N/A',
          :learners_signed_up => (learners == 0) ? "N/A" : "YES(#{learners})"
        }
        all_sub_details << sub_det
      end
      account_sub_detail = {
        :pref_id => detail.pref_id,
        :id => account.id,
        :name => detail.full_name,
        :email => detail.email,
        :lang_identifiers => lang_identifiers,
        :sub_ids =>sub_ids,
        :sub_details => all_sub_details,
        :daily_cap => detail.daily_cap,
        :mails_sent => detail.mails_sent,
        :active => detail.active,
        :type => detail.account_type
      }

      array_of_account_details << account_sub_detail

    end
    array_of_account_details
  end

  def get_unassigned_phl_session_report

  village_id  = 27 # village id for phl session report todo: get village ID dynamically by passing 'phl'.
  query_str   = "SELECT type , coach_id , session_start_time , language_identifier
                FROM coach_sessions
                WHERE external_village_id = ?
                AND type in ('ExtraSession', 'ConfirmedSession')
                AND cancelled = '0' 
                AND coach_id is NULL
                AND session_start_time > NOW();"
  CoachSession.find_by_sql([query_str,village_id])
  end

end
