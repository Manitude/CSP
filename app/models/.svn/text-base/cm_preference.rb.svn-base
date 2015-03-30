# == Schema Information
#
# Table name: cm_preferences
#
#  id                                          :integer(4)      not null, primary key
#  account_id                                  :integer(4)      
#  min_time_to_alert_for_session_with_no_coach :integer(4)      default(2)
#  email_alert_enabled                         :boolean(1)      
#  email_preference                            :string(255)     
#  page_alert_enabled                          :boolean(1)      default(TRUE)
#  created_at                                  :datetime        
#  updated_at                                  :datetime
#  receive_reflex_sms_alert                    :integer(4)
#

class CmPreference < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
  belongs_to  :coach_manager
  validate :check_mail, :message => "Please enter a valid email id for Personal mail or select Rosetta mail"
  private
  def check_mail
    if self.email_alert_enabled and self.email_preference == 'PER' and CoachManager.find(self.account_id).personal_email.blank?
      errors.add("email_alert_enabled", "Please enter a valid email id for Personal mail or select Rosetta mail in Display Preferences")
    end
  end
end
