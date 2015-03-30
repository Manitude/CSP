#require File.dirname(__FILE__) + '/../coach_not_arrived_alert'
#include CoachNotArrivedAlert
namespace :ccs do
  desc "If a coach does not arrive for a session before X minutes, X being set from the admin dashboard,"
  desc "trigger an SMS to all the CMs who have wished to receive the coach_not_present_alert SMS"
  task :trigger_sms_if_coach_not_present => :environment do
    Cronjob.mutex('trigger_sms_if_coach_not_present') do
      begin
        if task_rerun_required?
          x = GlobalSetting.find_by_attribute_name("minutes_before_session_for_triggering_sms_alert")
          raise "Value of 'X' is not set. Task cannot run. Please set it from admin dashboard page." if x.blank?

          sessions_in_the_next_x_minutes = Eschool::Session.get_sessions_in_next_x_minutes(x.attribute_value)
          recipients = Account.subscribed_to_coach_not_present_alert
          sessions_in_the_next_x_minutes && sessions_in_the_next_x_minutes.each do |eschool_session|
            if !['JLE', 'KLE', 'BLE', 'CLE'].include?(eschool_session.language) && eschool_session.teacher_arrived == "false"
              message = form_coach_not_present_alert_text(eschool_session)
              send_coach_not_arrived_sms(recipients, message)
              GlobalSetting.set_attributes("last_time_sms_was_triggered_if_coach_not_present" => Time.now.utc.to_i)
            end
          end
        end
      rescue Exception => ex
        HoptoadNotifier.notify(ex)
      end
      logger.info "Trigger sms finished at #{Time.now}."
    end
  end

  # Task needs to be re run if the last SMS triggered was never triggered or triggered long back
  # (more than 'X' minutes before the time right now)
  def task_rerun_required?
    last_run = GlobalSetting.find_by_attribute_name("last_time_sms_was_triggered_if_coach_not_present")
    x        = GlobalSetting.find_by_attribute_name("minutes_before_session_for_triggering_sms_alert")
    !(x && last_run && (last_run.attribute_value.to_i + x.attribute_value.to_i.minutes.to_i > Time.now.utc.to_i))
end

  def send_coach_not_arrived_sms(recipients, text)
    recipients = recipients.to_a unless recipients.is_a?(Array)
    recipients.each do |manager|
      manager.send_sms(text) if manager.get_preference.coach_not_present_alert == 1
    end
  end

  def form_coach_not_present_alert_text(eschool_session)
    teacher = Account.find_by_id(eschool_session.teacher_id)
    language_display_name = Language[eschool_session.language].display_name
    time = eschool_session.start_time.to_time.in_time_zone('Eastern Time (US & Canada)').strftime("%I:%M%p, %m/%d/%Y")
    teacher_name = (teacher && teacher.full_name) || eschool_session.teacher
    text = ""
    if  teacher_name.blank?
      text = "No coach is present for scheduled #{language_display_name} class at #{time}"
    elsif !teacher
       HoptoadNotifier.notify("Coach with user_name: #{teacher_name} missing in CSP.")
    else
      teacher_name = (teacher && teacher.full_name) || eschool_session.teacher
      phone_number = get_phone_no_details(teacher)
      text = "#{teacher_name} #{phone_number}is not present for #{language_display_name} class at #{time}"
    end
    text.size > 160 ? text[0..156]+'...' : text
  end

  def get_phone_no_details(teacher)
    primary_country_code = teacher.primary_country_code 
    primary_phone = teacher.primary_phone 
    !primary_phone.blank? ? ("(Ph: "+(!(primary_country_code.blank?) ? "#{primary_country_code}-" : "") + "#{primary_phone}) ") : ""
  end

end
