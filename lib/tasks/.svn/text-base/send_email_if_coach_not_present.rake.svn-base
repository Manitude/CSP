#require File.dirname(__FILE__) + '/../coach_not_arrived_alert'
#include CoachNotArrivedAlert
namespace :ccs do
  desc "If a coach does not arrive for a session before X minutes, X being set from the admin dashboard,"
  desc "send an email to the coach and to the coach supervisors team"
  task :send_email_if_coach_not_present => :environment do
    Cronjob.mutex('send_email_if_coach_not_present') do
      begin
        x = GlobalSetting.find_by_attribute_name("minutes_before_session_for_sending_email_alert")
        raise "Value of 'X' is not set. Task cannot run. Please set it from admin dashboard page." if x.blank?
        sessions_in_the_next_x_minutes = Eschool::Session.get_sessions_in_next_x_minutes(x.attribute_value)
        sessions_in_the_next_x_minutes && sessions_in_the_next_x_minutes.each do |eschool_session|
          if !['JLE', 'KLE', 'BLE', 'CLE'].include?(eschool_session.language) && eschool_session.teacher_arrived == "false"
            data = get_coach_and_session_details(eschool_session)
            GeneralMailer.send_email_notifications_to_coach_and_supervisors_if_coach_not_present(data).deliver if data
            GlobalSetting.set_attributes("last_time_email_was_sent_if_coach_not_present" => Time.now.utc.to_i)
          end
        end
      rescue Exception => ex
        HoptoadNotifier.notify(ex)
      end
      logger.info "Sending of Coach Not Present emails finished at #{Time.now}."
    end
  end

  def get_coach_and_session_details(eschool_session)
    teacher = Account.find_by_id(eschool_session.teacher_id)
    language_display_name = Language[eschool_session.language].display_name
    time = eschool_session.start_time.to_time.in_time_zone('Eastern Time (US & Canada)').strftime("%I:%M%p, %m/%d/%Y")
    
    if teacher.blank?
       # It is sub-requested session.
       return nil
    else
      teacher_name = (teacher && teacher.full_name) || eschool_session.teacher
      email_id = teacher.rs_email
    end
    data = {
      :coach_name => teacher_name,
      :email_id => email_id,
      :language => language_display_name,
      :time => time
    }
  end

end
