# == Schema Information
#
# Table name: coach_availability_templates
#
#  id                   :integer(4)      not null, primary key
#  coach_id             :integer(4)      not null
#  label                :string(255)
#  effective_start_date :datetime
#  status               :integer(1)      default(0)
#  comments             :text(65535)
#  created_at           :datetime
#  updated_at           :datetime
#  deleted              :boolean(1)
#

class CoachAvailabilityTemplate < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 

  belongs_to    :coach
  has_many      :availabilities, :class_name => 'CoachAvailability'

  scope   :approved, :conditions => ["status = ? and deleted = ?",TEMPLATE_STATUS.index('Approved'),false]
  scope   :starts_before, lambda {|date| {:conditions => ["effective_start_date <= ? and deleted = ?", date.to_date,false]}}
  scope   :approved_for_language_start_time, lambda {{:conditions => [" status = ? and deleted = ?", TEMPLATE_STATUS.index('Approved'),false]}}
  scope   :approved_for_languages_ther_than, lambda {|start_time| {:conditions => ["language_start_time != ? and status = ? and deleted = ?",start_time, TEMPLATE_STATUS.index('Approved'),false]}}

  validates :coach, :label, :effective_start_date, :presence => true
  validate :should_start_in_future , :should_have_unique_start_date_and_label, :on => :create
  validates_length_of :label, :within => 3..40

  def reviewed?
    in_state?('Draft') #|| !(in_state?('Waiting for approval') || in_state?('Draft') || in_state?('Resubmitted for approval'))
  end

  def approved?
    in_state?('Approved')
  end

  def in_state?(status)
    self.status == TEMPLATE_STATUS.index(status)
  end

    #This method is used to get availabilities for a template post Western Consumer Changes to CSP
  def template_availabilities_data(datetime = nil, no_cache = false)
    @availabilities_array = nil if no_cache
    if @availabilities_array.blank?
      @availabilities_array = []
      start_of_the_week = TimeUtils.beginning_of_week(datetime)
      availabilities.each do |avl|
        start_time = ((start_of_the_week + avl.day_index.days).strftime("%F")+" "+avl.start_time.strftime("%T")).to_time
        end_time = ((start_of_the_week + avl.day_index.days).strftime("%F")+" "+avl.end_time.strftime("%T")).to_time
        end_time = end_time + 1.day if end_time < start_time
        #To handle end slots for everything except nov daylight week AND else handles all other slots
        #THIS HANDLES EVERYTHING EXCEPT NOV SWITCH WEEK AS OF NOW !!!
        if start_time <= start_of_the_week && (TimeUtils.daylight_shift(start_of_the_week+2.hours-1.minute,start_of_the_week+2.hours) != 0) && avl.day_index == 0 && avl.start_time.hour < (TimeUtils.offset(created_at)/1.hour).abs
          start_time = start_time + 7.days
          end_time = end_time + 7.days
          end_time = end_time + 1.day if end_time < start_time
          start_time = est_to_edt_balance(start_time,created_at)
           end_time = est_to_edt_balance(end_time,created_at)
          if TimeUtils.time_in_user_zone(start_time) >= TimeUtils.time_in_user_zone(start_of_the_week) + 7.days
            start_time = start_time - 7.days
            end_time = end_time - 7.days
          end
        else  
          if start_time >= start_of_the_week + 7.days
            start_time = start_time - 7.days
            end_time = end_time - 7.days
          end

          if est_to_edt_balance(start_time,created_at) < start_of_the_week
            start_time = start_time + 7.days
            end_time = end_time + 7.days
          end
          start_time = est_to_edt_balance(start_time,created_at)
          end_time = est_to_edt_balance(end_time,created_at)
          
          end_time = end_time + 1.day if end_time < start_time
        end  
        @availabilities_array << {:start_time => start_time.to_i, :end_time => end_time.to_i} if start_time != end_time
      end
    end
    @availabilities_array
  end

  def est_to_edt_balance(datetime,avl_created)
    shift = TimeUtils.daylight_shift(avl_created, datetime)
    if (shift == 1.hour) && (TimeUtils.daylight_shift(datetime-1.hour, datetime) == 1.hour)
      datetime.beginning_of_hour
    elsif (shift == -1.hour) && (TimeUtils.daylight_shift(datetime, datetime+1.hour) == 1.hour)
      datetime.beginning_of_hour + 1.hour
    else
      datetime - shift
    end
  end

  def filter_avail_for_slot(datetime, no_cache = false)
    start_time = datetime.to_i
    end_time = (datetime + coach.duration_in_seconds).to_i
    template_availabilities_data(datetime, no_cache).detect{|avail| avail[:start_time] <= start_time && avail[:end_time] >= end_time}
  end
  
  def affected_sessions 
    next_template = self.coach.next_active_template(effective_start_date)
    condition = "cancelled = ? AND session_start_time >= ?"
    condition = condition + " AND session_start_time < ?" if next_template
    conditions = [condition, false, effective_start_date]
    conditions << next_template.effective_start_date if next_template
    CoachSession.find_all_by_coach_id(coach_id, :conditions => conditions, :order =>"id DESC") 
  end
  
  def trigger_substitutions_for_template_change
    affected_sessions.each do |coach_session|
      slot_available = filter_avail_for_slot(coach_session.session_start_time, true)
      if coach_session.is_one_hour? && slot_available
        slot_available = filter_avail_for_slot(TimeUtils.return_other_half(coach_session.session_start_time), true)
      end
      unless slot_available
        coach_session.cancel_or_subsitute!
        coach_session.substitution.update_attributes(:reason => "Template Change") if !coach_session.cancelled? && coach_session.substitution.present?
      end
    end
  end

  def substitute_required_if_approved?
    affected_sessions.each do |coach_session|
      slot_available = filter_avail_for_slot(coach_session.session_start_time, true)
      if coach_session.is_one_hour? && slot_available
        slot_available = filter_avail_for_slot(TimeUtils.return_other_half(coach_session.session_start_time), true)
      end
      unless slot_available
        return true
      end
    end
    return false
  end

  def find_previous_recurring_schedules
       start_of_the_week = TimeUtils.beginning_of_week(effective_start_date)
       condition = "coach_id = ? and (recurring_end_date is NULL or recurring_end_date >= ?)"
       recurring_schedules = CoachRecurringSchedule.where(condition,coach_id,effective_start_date)      
       recurring_schedules.each do |rs|
          start_time = ((start_of_the_week + rs.day_index.days).strftime("%F")+" "+rs.start_time.strftime("%T")).to_time 
          start_time += 7.days if start_time < effective_start_date
          start_time = start_time - TimeUtils.daylight_shift(rs.recurring_start_date, start_time)
          slot_available = filter_avail_for_slot(start_time, true)
          if rs.language.is_one_hour? && slot_available
            slot_available = filter_avail_for_slot(TimeUtils.return_other_half(start_time), true)
          end
          unless slot_available
              rs.update_attributes(:recurring_end_date => start_time - 1.week)
          end     
       end
  end

  def get_availability_for_slot(date)
    status = "Unavailable"
    start_of_the_week = TimeUtils.beginning_of_week_for_user(date)
    self.availabilities.each do |avl|
      start_time = ((start_of_the_week + avl.day_index.days).strftime("%F")+" "+avl.start_time.strftime("%T")).to_time
      start_time = start_time + 7.days if start_time < start_of_the_week
      end_time = ((start_of_the_week + avl.day_index.days).strftime("%F")+" "+avl.end_time.strftime("%T")).to_time
      end_time = end_time + 7.days if end_time <= start_of_the_week
      start_time = start_time - TimeUtils.daylight_shift(created_at, start_time)
      end_time = end_time - TimeUtils.daylight_shift(created_at, end_time)
      if date >= start_time and date <= end_time
        status = "Available"
        break
      end
    end
    status
  end

  def approve_and_notify(is_manager = false)
    find_previous_recurring_schedules
    self.update_attributes(:status => TEMPLATE_STATUS.index('Approved'))
    if is_manager
      TriggerEvent['CM_CREATED_NEW_TEMPLATE'].notification_trigger!(self)
    else
      TriggerEvent['PROCESS_NEW_TEMPLATE'].notification_trigger!(self)
    end
    send_template_notification_mail
  end
  
  def send_template_notification_mail
    not_ids = TriggerEvent.where("name in (?)", ["CM_CREATED_NEW_TEMPLATE", "PROCESS_NEW_TEMPLATE", "POLICY_VIOLATION", "TEMPLATE_CHANGED","CM_DELETED_TEMPLATE"]).collect(&:id)
    sys_not = SystemNotification.where("notification_id in (?) and target_id = ? ", not_ids , id).first
    managers = CoachManager.where(:active => 1)
    recipients = managers.collect{|manager| manager.get_preferred_mail_id_by_type('notifications_email')}.compact
    GeneralMailer.notifications_email(sys_not.message(true), recipients).deliver if recipients.any?
  end

  def send_template_deleted_notification_mail
    not_ids = TriggerEvent.where("name in (?)", ["CM_DELETED_TEMPLATE"]).collect(&:id)
    sys_not = SystemNotification.where("notification_id in (?) and target_id = ? ", not_ids , id).first
    GeneralMailer.notifications_email(sys_not.message(true), coach.email).deliver
  end

  def create_availability_entries_for_template(availabilities, is_manager)
    self.availabilities.delete_all
    availabilities && availabilities.each do |key, availability|
      create_availability_entry(availability["start"], availability["end"], is_manager)
    end
     self.reload
  end

  def create_availilability(start_of_avl, end_of_avl, is_manager)
    start_of_avl = start_of_avl.utc
    end_of_avl = end_of_avl.utc
    #Fix for dragged availability beyond calendar
    if(TimeUtils.time_in_user_zone(start_of_avl).wday != TimeUtils.time_in_user_zone(end_of_avl - 1.minute).wday)
      end_of_avl = end_of_avl.midnight - TimeUtils.offset
    end

    if start_of_avl.wday != (end_of_avl - 1.minute).wday
      save_availability_entry(is_manager, start_of_avl.strftime("%T"), "00:00:00", start_of_avl.wday)
      save_availability_entry(is_manager, "00:00:00", end_of_avl.strftime("%T"), end_of_avl.wday)
    else
      save_availability_entry(is_manager, start_of_avl.strftime("%T"), end_of_avl.strftime("%T"), start_of_avl.wday)
    end
  end

  def self.coaches_with_template_switch_in_week(start_time, end_time)
    templates = find(:all, :conditions => ["effective_start_date BETWEEN ? AND ?", start_time, end_time])
    templates.map(&:coach_id).uniq
  end

  def removable_info
    return {:status => false, :show_delete_button => true, :message => "The template you are trying to delete is already removed."} if deleted
    return {:status => true, :show_delete_button => true, :message => "DRAFT"} if status == TEMPLATE_STATUS.index('Draft')
    availablity_templates_for_coach = coach.availability_templates
    return {:status => false, :show_delete_button => false, :message => "ONLY AVAILABLE TEMPLATE"} if availablity_templates_for_coach.size == 1
    is_future_template = self.effective_start_date.to_s(:db) > (Time.now+1.day).beginning_of_day.to_s(:db)? true : false
    immediate_next_past_template = availablity_templates_for_coach.reverse.detect { |m| m.approved? && (!m.deleted) && (m.id!=self.id) && m.effective_start_date.to_s(:db) <= Time.now.beginning_of_day.to_s(:db) && m.effective_start_date.to_s(:db) < self.effective_start_date.to_s(:db) } if availablity_templates_for_coach && self.effective_start_date.to_s(:db) < Time.now.beginning_of_day.to_s(:db)
    immediate_next_future_template = availablity_templates_for_coach.reverse.detect { |m| m.approved? && (!m.deleted) && (m.id!=self.id) && m.effective_start_date.to_s(:db) > self.effective_start_date.to_s(:db) } if availablity_templates_for_coach && is_future_template
    is_futuremost_template= true if is_future_template && (!immediate_next_future_template)
    return {:status => false, :show_delete_button => false, :message => "CURRENTLY ACTIVE TEMPLATE"} if self == coach.active_template_on_the_time(Time.now)
    sessions_based_on_past_template = CoachSession.find(:all, :conditions => ["coach_id = ? and session_start_time < ? and session_start_time >= ?", coach_id, immediate_next_past_template.effective_start_date.to_s(:db), self.effective_start_date.to_s(:db)]) if immediate_next_past_template
    sessions_based_on_future_template = CoachSession.find(:all, :conditions => ["coach_id = ? and session_start_time < ? and session_start_time >= ?", coach_id, immediate_next_future_template.effective_start_date.to_s(:db), self.effective_start_date.to_s(:db)]) if immediate_next_future_template
    sessions_based_on_futuremost_template = CoachSession.find(:all, :conditions => ["coach_id = ? and session_start_time >= ?", coach_id, self.effective_start_date.to_s(:db)]) if is_futuremost_template
    return {:status => true, :show_delete_button => true, :message => "inactive template and no sessions based on it"} if immediate_next_past_template && sessions_based_on_past_template.size==0
    return {:status => true, :show_delete_button => true, :message => "future template without active sessions"} if (immediate_next_future_template && sessions_based_on_future_template.size == 0) || (is_futuremost_template && sessions_based_on_futuremost_template.size == 0)
    return {:status => false, :show_delete_button => true, :message => "You have sessions based on this template. So this cannot be deleted."} if (immediate_next_future_template && sessions_based_on_future_template.size > 0) || (is_futuremost_template && sessions_based_on_futuremost_template.size > 0)
    return {:status => true, :show_delete_button => true, :message => ""}
  end


  # notifies the coach whose template was deleted
  #def send_template_deletion_notification
  #  TriggerEvent['CM_DELETED_TEMPLATE'].notification_trigger!(self)
  #  coach = Coach.find_by_id(self.coach_id)
  #  GeneralMailer.send_notification_for_template_deletion(coach).deliver if coach.present?
  #end

  private

  def should_start_in_future
    if effective_start_date <= Time.now
      errors.add(:effective_start_date, 'should be a date in future')
    end
  end

  def should_have_unique_start_date_and_label
    effective_date = effective_start_date.strftime("%d %m %Y")
    CoachAvailabilityTemplate.find_all_by_coach_id_and_deleted(coach_id, false).each do |template|
      errors.add(:effective_start_date, 'already exists for another template') if template.effective_start_date.strftime("%d %m %Y") == effective_date
      errors.add(:label, 'already exists for another template') if template.label == label
    end
  end

  # This method will be used for new Western Consumer changes
  def create_availability_entry(start_time, end_time, is_manager)
    start_of_avl = Time.at(start_time.to_i/1000).utc
    end_of_avl = Time.at(end_time.to_i/1000).utc
    create_availilability(start_of_avl, end_of_avl, is_manager)
  end

  def save_availability_entry(is_manager, start_of_avl, end_of_avl, day)
    CoachAvailability.create({
        :coach_availability_template_id => self.id,
        :availabled_by_manager => is_manager,
        :start_time => start_of_avl,
        :end_time => end_of_avl,
        :day_index => day})
  end

end
