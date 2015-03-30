require File.dirname(__FILE__) + '/../../app/utils/lotus_real_time_data'
namespace :sms do
  
  desc "Send sms alerts to coach managers when the average learner wait time is over X minutes and/or the ratio between learner:coach exceeds X:1."
  task :reflex_alert => :environment do
    Cronjob.mutex('reflex_alert') do
      begin
        ActiveRecord::Base.connection_pool.with_connection do
          time_to_wait_before_next_sms = GlobalSetting.find_by_attribute_name("minutes_before_not_to_send_additional_sms").attribute_value.to_i
          if run_required?(time_to_wait_before_next_sms)
            lotus_real_time_data = LotusRealTimeData.lotus_real_time_data
              text=''
              avg_wait_time = GlobalSetting.find_by_attribute_name("average_learner_wait_time_threshold").attribute_value.to_i
              learner_coach_ratio = GlobalSetting.find_by_attribute_name("learner_coach_ratio_threshold").attribute_value.to_f
              avg_wait_time_sms = "ReFLEX average wait time has exceeded #{avg_wait_time} minutes, "
              learner_coach_ratio_sms = "ReFLEX learner/coach ratio has exceeded #{learner_coach_ratio}, "
              text = avg_wait_time_sms if ((lotus_real_time_data["learners_waiting"].size > 0) && ((lotus_real_time_data["average_learners_waiting_time_sec_for_both"]/60) >= avg_wait_time))
              text += learner_coach_ratio_sms if learner_coach_ratio_threshold_reached?(learner_coach_ratio, lotus_real_time_data)
              send_sms_to_managers("#{text}at #{Time.now.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d/%y %I:%M %p")} Eastern Time (US & Canada)") if !text.blank?
          end
        end
      rescue Exception => ex
        HoptoadNotifier.notify(ex)
      end
    end
  end

private

  def send_sms_to_managers(text)
    CoachManager.where("active = 1").each do |coach_manager|
      cm_pref = coach_manager.cm_preference
      coach_manager.send_sms(text)  if cm_pref && cm_pref.receive_reflex_sms_alert
    end
    set_last_run#this only will be considered successful so that rake runs that don't send sms will not be counted while next run
  end

  def run_required?(time_to_wait_before_next_sms)
    task_tracer_record = TaskTracer.find_or_initialize_by_task_name('reflex_alert')
    last_run = task_tracer_record.last_successful_run if task_tracer_record
    !last_run || time_to_wait_before_next_sms <= ((Time.now.utc - last_run.utc)/60) # running after the time set by admin
  end

  def learner_coach_ratio_threshold_reached?(learner_coach_ratio, lotus_real_time_data)
    learner_in_player = lotus_real_time_data["skills_or_rehearsal"].size.to_f + lotus_real_time_data["learners_waiting"].size.to_f #Learners not in session
    return true if lotus_real_time_data["total_in_player"].size.to_f == 0 && learner_in_player != 0
    current_learner_coach_ratio = learner_in_player / lotus_real_time_data["total_in_player"].size.to_f
    return current_learner_coach_ratio > learner_coach_ratio
  end

  def set_last_run
    task_tracer_record = TaskTracer.find_or_initialize_by_task_name('reflex_alert')
    task_tracer_record.update_attributes(:last_successful_run => Time.now) if task_tracer_record
  end
end