namespace :coach_manager do
  
  desc "Alert CM if a session has no coach within configured time"
  task :alert_cm_for_a_session_with_no_coach_within_configured_time => :environment do
    Cronjob.mutex('alert_cm_for_a_session_with_no_coach_within_configured_time') do
      begin
        # This rake should be run only at the 0th minute of the hour
        hours_array= ALERT_SCHEDULE_FOR_SESSION_WITH_NO_COACH.values.sort
        cs_hash = { 2=>[], 4=>[], 24 =>[]}
        current_time = Time.now.in_time_zone('UTC')
        hours_array.each do |start_time|
          # cs_hash[h] stores all sessions that will start after h hours / h E {2,4,24}
          cs_hash[start_time] = CoachSession.find(:all, :conditions => ["coach_id IS NULL and session_start_time <= ? and session_start_time > ? and cancelled = 0", current_time+start_time.hours, current_time ])
        end
        sessions_by_language = {2=>{},4=>{}, 24=>{}}
        sessions_by_language.keys.each do |key|
          sessions_by_language[key] = find_sessions_by_languages(cs_hash[key])
        end
        #Now the hash will look like {2 => {"ENG"=> [sessions], "FRA" => [sessions]}, 4=> {...}, 24=>{...}}
        CoachManager.all.each do |cm|
          if cm.active?
            # for all cms notify about all cs
            cm_pref = cm.cm_preference
            if cm_pref
              time_pref = cm_pref.min_time_to_alert_for_session_with_no_coach
              email = {}
              email['email_enabled'] = cm_pref.email_alert_enabled
              email['email_pref'] = email['email_enabled'] ? cm_pref.email_preference : nil
              notify_cm(cm,sessions_by_language[time_pref],email,time_pref)
            end
          end
        end
      rescue StandardError, Exception => ex
        HoptoadNotifier.notify(ex)
      end
    end
  end

  private
  def notify_cm(cm, sessions_hash, email,time_pref)
    sessions_hash.keys.each do |key|
      message_skeleton =  "has #{key.to_s == key.to_i.to_s ? 'session(s)' : 'appointment(s)'} with no substitute coach."
      index = [0, 4]   # Based on message in rally
      size = sessions_hash[key].size
      message = create_message(message_skeleton, index, size, key)
      if email['email_enabled']
        mail_id = nil
        case email['email_pref']
        when 'PER'
          mail_id = cm.personal_email
        else
          mail_id = cm.rs_email
        end
        #mail_sub = message.gsub("<a href = 'http://coachportal.rosettastone.com/manager-substitutions'>substitute</a>", "substitute")
        GeneralMailer.cm_notifications_email(message, sessions_hash[key], mail_id, time_pref).deliver #session_hash key is mail object which contains session particulars
      end
    end     
  end

  def create_message(message, index, size, language)
    # modify message here
    language = language.to_s == language.to_i.to_s ? Language.find_by_id(language).display_name + " " : Language.find_by_id(language.to_i).display_name_without_type + " "
    lang_size = language.size
    message.insert(index[0], language)
    index[1] += lang_size    
    message.insert(index[1], size.to_s+' ')
  end

  def find_sessions_by_languages(sessions)
    sess_lang = {}
    sessions.each do |sess|
      next if sess.language.is_lotus? #reflex sunset
      language = sess.language
      next if language.nil?
      id = sess.appointment? ? language.alias_id : language.id 
      sess_lang[id]=[] unless sess_lang.include?(id)
      sess_lang[id] << sess
    end
    sess_lang
  end  
end

