# == Schema Information
#
# Table name: preference_settings
#
#  id                                         :integer(4)      not null, primary key
#  substitution_alerts_email                  :integer(4)      
#  substitution_alerts_email_type             :string(255)     
#  substitution_alerts_email_sending_schedule :string(255)     
#  substitution_alerts_sms                    :integer(4)      
#  no_of_substitution_alerts_to_display       :integer(4)      
#  substitution_alerts_display_time           :integer(4)      
#  notifications_email                        :integer(4)      
#  notifications_email_type                   :string(255)     
#  notifications_email_sending_schedule       :string(255)     
#  calendar_notices_email                     :integer(4)      
#  calendar_notices_email_type                :string(255)     
#  calendar_notices_email_sending_schedule    :string(255)  
#  substitution_policy_email                     :integer(4)      
#  substitution_policy_email_type                :string(255)     
#  substitution_policy_email_sending_schedule    :string(255)   
#  session_alerts_display_time                :integer(4)      
#  start_page                                 :string(255)     
#  account_id                                 :integer(4)      
#  default_language_for_master_scheduler      :string(255)     
#  no_of_home_announcements                   :integer(4)      
#  no_of_home_events                          :integer(4)      
#  no_of_home_notifications                   :integer(4)      
#  no_of_learner_dashboard_records            :integer(4)      
#  no_of_notifications_to_display             :integer(4)      
#  notifications_display_time                 :integer(4)      
#  no_of_calendar_notices_to_display          :integer(4)      
#  calendar_notices_display_time              :integer(4)      
#  created_at                                 :datetime        
#  updated_at                                 :datetime        
#  no_of_home_substitutions                   :integer(4)      
#  daily_cap                                  :integer(4)      
#  mails_sent                                 :integer(4)      default(0)
#  coach_not_present_alert                    :integer(4)      

#  timeoff_request_email                      :integer(4)
#  timeoff_request_email_type                 :string(255)

class PreferenceSetting < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
  belongs_to    :account
  before_create :update_email
  before_validation :update_email, :on => :update
  validates_numericality_of :daily_cap, :less_than_or_equal_to => 500 , :greater_than_or_equal_to => 0 ,:allow_nil => true, :message => "'Send a maximum of' field should be a positive number between 0 to 500."
  validate :check_mail

  def check_mail
    if ((self.substitution_alerts_email and self.substitution_alerts_email_type == 'PER') || (self.timeoff_request_email and self.timeoff_request_email_type == 'PER') || (self.notifications_email and self.notifications_email_type == 'PER') || (self.calendar_notices_email and self.calendar_notices_email_type == 'PER')) and Account.find(self.account_id).personal_email.blank?
      errors.add("Personal Email:","Please enter a valid email id for Personal mail or select Rosetta mail in Contact Preferences")
    end
  end

  def prefered_mail_id_type(type)
    if self.send(type) == 1 && (self.send(type+'_sending_schedule') == "IMMEDIATELY") && (daily_cap.blank? || daily_cap > mails_sent)
      self.update_attribute(:mails_sent, mails_sent+1)
      self.send(type+'_type')
    end
  end

  def update_email
    if self.substitution_alerts_email == 0
      self.substitution_alerts_email_type = nil
      self.substitution_alerts_email_sending_schedule = nil
    end

    if self.notifications_email == 0
      self.notifications_email_type = nil
      self.notifications_email_sending_schedule = nil
    end

    if self.calendar_notices_email == 0
      self.calendar_notices_email_type = nil
      self.calendar_notices_email_sending_schedule = nil
    end

    if self.substitution_policy_email == 0
      self.substitution_policy_email_type = nil
      self.substitution_policy_email_sending_schedule = nil
    end

    if self.timeoff_request_email == 0
      self.timeoff_request_email_type = nil
    end

  end

  def substitutions_show_count_is_not_zero?
    self.no_of_substitution_alerts_to_display != 0
  end
#** code inside this block will be removed in future after some more optimization of preference setting**
  def no_of_substitution_alerts_to_display
    self['no_of_substitution_alerts_to_display'] ||= COMMON_DISPLAY_COUNT[5]
  end

  def substitution_alerts_display_time
    self['substitution_alerts_display_time'] ||= SUBSTITUTION_DISPLAY_TIMES["24 hours"]
  end

  def no_of_home_substitutions
    self['no_of_home_substitutions'] ||= COMMON_DISPLAY_COUNT[5]
  end

  def no_of_home_notifications
    self['no_of_home_notifications'] ||= COMMON_DISPLAY_COUNT[5]
  end

  def no_of_home_announcements
    self['no_of_home_announcements'] ||= COMMON_DISPLAY_COUNT[5]
  end

  def no_of_home_events
    self['no_of_home_events'] ||= COMMON_DISPLAY_COUNT[5]
  end
#******end of block********************
end