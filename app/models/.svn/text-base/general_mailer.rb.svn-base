require 'action_mailer'
# ActionMailer.load_all!

class GeneralMailer < ActionMailer::Base

  default :from => "noreply@rosettastone.com", :content_type   => "multipart/alternative"
  
  def substitutions_email(options)
    preferred_url = substitutions_url({
        :host      => "coachportal.rosettastone.com",
        :coach_id  => options[:user_id],
        :lang_id   => options[:lang_id],
        :duration  => "Upcoming"
      })
    @email_body =  if options[:is_manager]
      "<div>
       To Re-assign/Cancel any listed session, go to the <a href=#{preferred_url}>Customer Success Portal Substitutions Page </a> and select the required action shown besides any of the session(s).
      </div>"
    else
      "<div>
       To grab the session, go to the <a href=#{preferred_url}>Customer Success Portal Substitutions Page </a> and click the 'Grab' button shown beside any of the session(s) you are able to coach.
       The session will then be added to your schedule and you will be responsible for it from that point forward.
    </div>"
    end
    @title      = "Substitutions have been requested for the following:"
    @message    = options[:message]
    mail(
      :to             => options[:recipients],
      :subject        => 'Sub Alert:' + options[:datetime]
    )
  end


  def send_mail_to_coaches(subject,to,body)
     mail(
      :from         => "RSStudioTeam-Supervisors-l@rosettastone.com",
      :to           =>  to,
      :cc           => "RSStudioTeam-Supervisors-l@rosettastone.com",
      :subject      =>  subject,
      :content_type => "text/plain",
      :body         =>  body
      )
   end
  
  def job_not_picked_up_mail
     mail(
      :from         => "noreply@rosettastone.com",
      :to           =>  GlobalSetting.find_by_attribute_name("delayed_job_failure_email_recipients").attribute_value.split(','),
      :subject      =>  'CSP Alert: Delayed Jobs Stalled',
      :content_type => "text/plain",
      :body         =>  'Alert: Delayed Job queued is not completed for more than 2 hours. Please look at http://coachportal.rosettastone.com/homes/admin_dashboard for details'
      )
   end
     
  def send_policy_violation_mails(to,data) 
    @data = data
    mail(
      :to             => to,
      :subject        => "Substitution Policy Violations From #{data["date"].join(" to ")}",
      :template_name  => "email_alert_for_substitution_policy_violation.html.erb"
    )
  end

  def send_timeoff_request_mails(to, data)
    @data = data
    mail(
      :to             => to,
      :subject        => "Pending Time Off Requests as of #{TimeUtils.format_time(Time.now,'%Y-%m-%d')}",
      :template_name  => "timeoff_request_email_alerts_daily.html.erb"
    )
  end
    
  def email_alert_hourly_and_daily(type,sub,msg,recipient,account_type)
    if type == 'sub_alert'
      preferred_url_params = {:host      => "coachportal.rosettastone.com",
                            :coach_id  => msg.first[:coach].id,
                            :lang_id   => msg.first[:language].id,
                            :duration  => "Upcoming"}

      if(account_type == 'Coach')
      preferred_url = substitutions_url(preferred_url_params)
      content = "<div>
         To grab the session, go to the <a href=#{preferred_url}>Customer Success Portal Substitutions Page </a> and click the 'Grab' button shown beside any of the session(s) you are able to coach. <br/>
         The session will then be added to your schedule and you will be responsible for it from that point forward.
      </div>"
      elsif(account_type == 'CoachManager')
        preferred_url = substitutions_url(preferred_url_params)
        content = "<div>
          To Re-assign/Cancel any listed session, go to the <a href=#{preferred_url}>Customer Success Portal Substitutions Page </a> and select the required action shown beside any of the session(s).
        </div>"
      end

      mail_template = "sub_email_alerts_hourly_and_daily.html.erb"
      @data = msg
      @content = content

    elsif type == 'notification'
      mail_template = "notification_email_alerts_hourly_and_daily.html.erb"
      @data = msg
    elsif type == 'event'
      mail_template = "calendar_events_email_alerts_hourly_and_daily.html.erb"
      @data = msg
    end

    mail(
      :to             => recipient,
      :subject        => sub,
      :template_name  => mail_template
    )

  end

  def cm_notifications_email(subject, sessions, recipient, time_pref) 
    @email_obj = sessions 
    @hours     = time_pref 
    mail( 
      :to       => recipient, 
      :subject  => subject 
    ) 
  end 

  def notifications_email(message, recipient)
    @data = [message]
    mail(
      :to             => recipient,
      :subject        => 'Notification Alert:' + Time.now.strftime("%I:%M %p %a %b %d, %Y").to_s ,
      :template_name  => "notification_email_alerts_hourly_and_daily.html.erb"
    )
  end

  def calendar_notifications_email(event, recipient)
    @data = [event]
    mail(
      :to             => recipient,
      :subject        => 'Calendar Alert:' + Time.now.strftime("%I:%M %p %a %b %d, %Y").to_s,
      :template_name  => "calendar_events_email_alerts_hourly_and_daily.html.erb"
    )
  end

  def send_email_notifications_for_cancelled_sessions(recipient, data)
    @data = data
    mail_hash = {
      :to             => recipient,
      :subject        => 'A Session with Scheduled Learners has been Cancelled',
      :template_name  => "email_alert_for_sessions_cancelled_with_learners.html.erb"
    }
    mail_hash.merge!(:cc => data[:cc_to_mail]) unless data[:cc_to_mail].blank?
    mail(mail_hash)
  end

  def send_email_notifications_for_RSA_denied_cancelled_sessions(recipient, data)
    @data = data
    mail_hash = {
      :to             => recipient,
      :subject        => 'ACTION NEEDED: Session(s) not cancelled in RSA',
      :template_name  => "email_alert_for_RSA_denied_cancelled_sessions.html.erb"
    }
    mail(mail_hash)
  end

  def send_email_notifications_to_coach_and_supervisors_if_coach_not_present(data)
    @data = data
    mail(
      :to             => @data[:email_id],
      :cc             => "rsstudioteam-supervisors-l@rosettastone.com",
      :subject        => "Not in Player for #{@data[:time]} #{@data[:language]} Session",
      :template_name  => "email_alert_for_coach_not_present.html.erb"
    )
  end

  def send_all_languages_coach_activity_reports(current_user, file_path, time, start_time, end_time, timeframe)
    @user_time = time
    @time_period = "(#{TimeUtils.format_time(start_time.to_time, "%B %d, %Y %I:%M %p")} - #{TimeUtils.format_time(end_time.to_time, "%B %d, %Y %I:%M %p")})"
    @time_frame = timeframe
    @user_preferred_name  = current_user.preferred_name
    @user_preferred_name  = current_user.full_name if @user_preferred_name.blank?
    attachments["coach_activity_report_for_all_languages.csv"] = File.read(file_path)
    mail(
      :to             => current_user.rs_email,
      :subject        => 'All Language Coach Activity Report',
      :template_name  => "all_languages_coach_activity_reports.html.erb"
    )
  end

  def send_all_languages_substitution_reports(current_user, file_path,start_time,end_time, language, requested_by, grabbed_by, duration)
    attachments["substitutions_report.csv"] = File.read(file_path)
    @lang = language
    @requested_by = requested_by == "" ? "All" : Coach.find_by_id(requested_by).full_name
    @grabbed_by = grabbed_by == "--" ? "All" : Coach.find_by_id(grabbed_by).full_name
    @time_period = duration=="Custom" ? "(#{TimeUtils.format_time(start_time, "%B %d, %Y")} - #{TimeUtils.format_time(end_time, "%B %d, %Y ")})" : duration
    @user_preferred_name  = @user_preferred_name.blank? ? current_user.full_name : current_user.preferred_name
    mail(
      :to             => current_user.rs_email,
      :subject        => 'Substitution Report',
      :template_name  => "all_languages_substitution_reports.html.erb"
    )
  end

  def send_unassigned_phl_session_reports(recipient,records)
    @records = records
    mail(
      :to             => recipient,
      :subject        => "Unassigned PHL Sessions Report for #{Time.zone.now} ",
      :template_name  => "email_alert_for_unassigned_phl_session.html.erb"
    )
  end

end
