# == Schema Information
#
# Table name: global_settings
#
#  id              :integer(4)      not null, primary key
#  attribute_name  :string(255)
#  attribute_value :string(255)
#  description     :string(255)
#

class GlobalSetting < ActiveRecord::Base
  @@errors = {}
  class << self

    def dashboard_refresh_seconds
      obj = find_by_attribute_name("seconds_to_refresh_live_sessions_in_dashboard")
      obj ? obj.attribute_value.to_i : 30
    end

    def set_attributes(attributes_hash)
      attributes_hash.each do |attr_name, attr_value|
        setting = self.find_or_initialize_by_attribute_name(attr_name)
        case attr_name
        when "minutes_before_session_for_triggering_sms_alert"
          attr_value = attr_value.to_i
          if attr_value > 0
            set_values(setting, attr_value)
          else
            @@errors[attr_name] = "Please select a valid value for SMS alert if coach is not present."
          end
        when "minutes_before_session_for_sending_email_alert"
          attr_value = attr_value.to_i
          if attr_value > 0
            set_values(setting, attr_value)
          else
            @@errors[attr_name] = "Please select a valid value for email alert if coach is not present."
          end
        when "average_learner_wait_time_threshold"
          if is_valid_number?(attr_value)
            set_values(setting, attr_value)
          else
            @@errors[attr_name] = "Average Learner wait time should be a positive Integer."
          end
        when "learner_coach_ratio_threshold"
          if is_valid_number?(attr_value, 'float')
            set_values(setting, attr_value)
          else
            @@errors[attr_name] = "Learner / Coach ratio should be a valid positive number with a maximum of two digits precision."
          end
        when "seconds_to_refresh_live_sessions_in_dashboard"
          set_values(setting, attr_value)
        when "allow_session_creation_before"
          set_values(setting, attr_value)
        when "allow_session_creation_after"
          set_values(setting, attr_value)
        when "minutes_before_not_to_send_additional_sms"
          set_values(setting, attr_value)
        when "delayed_job_failure_email_recipients"
          set_values(setting, attr_value)
        when "last_time_sms_was_triggered_if_coach_not_present"
          description = "Time when the last time SMS was triggered after the task ccs:trigger_sms_if_coach_not_present was run.
                         (in UTC, converted to_i)"
          set_values(setting, attr_value, description)
        when "last_time_email_was_sent_if_coach_not_present"
          description = "Time when the last time email was sent after the task ccs:send_email_if_coach_not_present was run.
                         (in UTC, converted to_i)"
          set_values(setting, attr_value, description)
          # specify future attribute values and descriptions in this switch-case manner
        end
      end
    end

    def errors
      @@errors
    end

    def reset_errors
      @@errors = {}
    end

    def set_values(object, attribute_value, description = '')
      object.update_attribute(:attribute_value , attribute_value)
      object.update_attribute(:description , description) unless description.blank?
    end

    def is_valid_number?(value, type = 'decimal')
      pattern = nil
      case type
      when 'decimal'
        pattern = /\d+/
      when 'float'
        pattern = /\A\d*\.?\d{1,2}\Z/
      end
      (value.to_s.match(pattern)).to_s == value
    end

    def email_alert_value_saved?
      errors["minutes_before_session_for_sending_email_alert"].blank?
    end
    
    def get_run_timings
      minutes_before_session = find_by_attribute_name("minutes_before_session_for_sending_email_alert")
      first_run = 30 - minutes_before_session.attribute_value.to_i
      second_run = 60 - minutes_before_session.attribute_value.to_i
      return first_run, second_run
    end

    def execute_update_crontab
      output = system "RAILS_ENV=#{RosettaStone::ProductionDetection.could_be_on_production_or_staging? ? "production" : "development"} ./bundle exec whenever --update-crontab coachportal &"
      Delayed::Worker.logger.info "\n******Updating crontab started at #{Time.now}.******\n" if output
    end
    handle_asynchronously :execute_update_crontab, :priority => -1
  end
end
