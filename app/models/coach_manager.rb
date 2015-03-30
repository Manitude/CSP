# == Schema Information
#
# Table name: accounts
#
#  id                         :integer(4)      not null, primary key
#  user_name                  :string(255)     
#  full_name                  :string(255)     
#  preferred_name             :string(255)     
#  rs_email                   :string(255)     
#  personal_email             :string(255)     
#  skype_id                   :string(255)     
#  primary_phone              :string(255)     
#  secondary_phone            :string(255)     
#  birth_date                 :date            
#  hire_date                  :date            
#  bio                        :text(65535)     
#  manager_notes              :text(65535)     
#  active                     :boolean(1)      default(TRUE), not null
#  manager_id                 :integer(4)      
#  created_at                 :datetime        
#  updated_at                 :datetime        
#  type                       :string(255)     
#  region_id                  :integer(4)      
#  next_session_alert_in      :integer(3)      
#  last_logout                :datetime        
#  country                    :string(255)     
#  native_language            :string(255)     
#  other_languages            :string(255)     
#  address                    :string(255)     
#  lotus_qualified            :boolean(1)      default(TRUE)
#  next_substitution_alert_in :integer(10)     default(24)
#  mobile_phone               :string(255)     
#  is_supervisor              :boolean(1)      
#  mobile_country_code        :string(255)     
#  aim_id                     :string(255)     
#  primary_country_code       :string(255)     
#

class CoachManager < Account

  has_many   :qualifications, :conditions => 'max_unit is NULL', :dependent  => :destroy, :foreign_key => 'coach_id'
  has_many   :languages, :through => :qualifications, :foreign_key => :coach_id
  has_many   :coaches, :class_name => 'Coach', :foreign_key => 'manager_id' ,:conditions => 'active = 1', :order => 'trim(full_name)'
  has_one    :cm_preference, :class_name => 'CmPreference', :foreign_key => 'account_id'
  has_many   :staffing_file_infos, :class_name => 'StaffingFileInfo', :foreign_key => 'manager_id'
  # managers will also have qualifications, for languages that they can manage, with max_unit as nil
  scope :for_qualification, lambda { |language_id| {:include => :qualifications, :conditions => ["qualifications.language_id = ? and max_unit is NULL", language_id]} }

  def self.other_managers(curr_manager)
    self.find(:all, :conditions => ["id != ?", curr_manager.id])
  end

  def is_manager?
    true
  end
  
  # Helper method to collect manager's languages passed to e-school api. ARIA languages excluded here.
  def all_managed_language_identifier
    @lang_identifier ||= self.languages(true).reject { |lang| lang.is_aria? || lang.is_tmm? }.collect(&:identifier)
  end

  def email
    rs_email
  end

  def all_language_id
    @lang_id ||= self.languages.collect(&:id)
  end


  def get_filtered_notifications(params)
    where_part = "where recipient_id = ?"
    allowed_trigger_events = []
    allowed_trigger_events += ["PROCESS_NEW_TEMPLATE", "APPROVE_TEMPLATE", "REJECT_TEMPLATE_WITH_CHANGES", "COACH_ACCEPT_TEMPLATE_CHANGES", "COACH_REJECT_TEMPLATE_CHANGES", "APPROVE_TEMPLATE_WITH_MODIFICATIONS", "TEMPLATE_CHANGED", "POLICY_VIOLATION"] if params[:excludeTemplateChanges].blank?
    allowed_trigger_events += ["REQUEST_TIME_OFF_BY_VIOLATING_POLICY", "REQUEST_TIME_OFF", "ACCEPT_TIME_OFF", "TIME_OFF_CUT_SHORT", "TIME_OFF_EDITED", "TIME_OFF_REMOVED", "TIME_OFF_CANCELLED"] if params[:excludeTimeOffRequests].blank?

    where_part += " and (notification_id in (select id from notifications where trigger_event_id in (select id from trigger_events where name in  (?) )))"
    end_time = TimeUtils.time_in_user_zone.end_of_day
    case params[:postedFrom]
    when 'Yesterday'
      time_before =  1.day
    when 'In the last 7 days'
      time_before =  7.day
    when 'In the last 30 days'
      time_before =  30.day
    when 'In the last 3 months'
      time_before =  3.months
    when 'In the last 6 months'
      time_before =  6.months
    when 'Custom'
      start_time = TimeUtils.time_in_user_zone(params[:fromdate])
      end_time = TimeUtils.time_in_user_zone(params[:todate]).end_of_day
    else
      time_before =  0.minute
    end
    start_time = (end_time.beginning_of_day - time_before) unless start_time
    where_part += " and created_at between ? and ?"
    notifications = SystemNotification.find_by_sql(["select * from system_notifications #{where_part} order by created_at DESC", id, allowed_trigger_events, start_time.utc, end_time.utc])
    notifications = notifications.select{|notification| !notification.message.blank?}
    
    if !params[:coachToShow].blank?
      coach_ids = [params[:coachToShow].to_i]
      notifications = notifications.select{|notification| coach_ids.include?(notification.coach_id)}
    else
      language = Language[params[:langToShow]]
      lang_coach_ids = language.coaches.collect(&:id) if language
      region = Region.find_by_id(params[:regionToShow])
      reg_coach_ids = (Coach.where("region_id is null") + region.coaches).collect(&:id) if region
      coach_ids = [lang_coach_ids.to_a,reg_coach_ids.to_a].reject(&:empty?).reduce(:&) 
      notifications = notifications.select{|notification| coach_ids.include?(notification.coach_id)} unless coach_ids.blank?
    end
    notifications
  end
end
