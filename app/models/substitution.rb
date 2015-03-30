# == Schema Information
#
# Table name: substitutions
#
#  id               :integer(4)      not null, primary key
#  coach_id         :integer(4)      
#  grabber_coach_id :integer(4)      
#  grabbed          :boolean(1)      
#  lang_id          :integer(4)      
#  coach_session_id :integer(4)      
#  created_at       :datetime        
#  updated_at       :datetime        
#  grabbed_at       :datetime        
#  cancelled        :boolean(1)      
#  was_reassigned   :boolean(1)      
#
require File.dirname(__FILE__) + '/../utils/substitution_utils'
class Substitution < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
  belongs_to :coach
  #belongs_to :language, :foreign_key => 'lang_id'
  belongs_to :coach_session
  belongs_to :grabber_coach, :class_name => 'Coach'
  has_one :language, :through => :coach_session
  
  attr_writer :substitution_date # just for Backward compatibility

  validates :coach_session_id, :presence  => true
  validate :coach_id_not_null_for_standard_session

  delegate :language_identifier, :to => :coach_session
  delegate :session_start_time, :to => :coach_session

  scope :get_grabbed_substitutions_for_a_coach_within_a_week, lambda { |coach_id, lang_identifier, start_date, end_date| 
      where(["substitutions.coach_id = ? and coach_sessions.language_identifier in (?) and (grabbed = 1 or was_reassigned = 1) and coach_sessions.session_start_time >= ? and coach_sessions.session_start_time <= ?",coach_id, lang_identifier, start_date, end_date]).includes(:coach_session).order("coach_sessions.session_start_time") }

  scope :get_grabbed_uncancelled_substitutions_for_a_coach_within_a_week_for_all_languages, lambda { |coach_id, start_date, end_date| 
      where(["grabber_coach_id = ?  and (grabbed = 1 or was_reassigned = 1) and grabber_coach_id = coach_sessions.coach_id and coach_sessions.cancelled = 0 and coach_sessions.type != 'Appointment' and coach_sessions.session_start_time >= ? and coach_sessions.session_start_time <= ?",coach_id, start_date, end_date]).includes(:coach_session) }

  def self.check_dup_substitution?( sess_id )
    self.where("coach_session_id =? and grabbed = ?", 1, false).first
  end

  def self.get_distinct_grabbed_uncancelled_substitutions_for_a_coach_within_a_week_for_all_languages(coach_id, start_date, end_date)
    sub_str = "select distinct(substitutions.grabber_coach_id) from substitutions,coach_sessions where substitutions.coach_session_id = coach_sessions.id and coach_sessions.cancelled = 0 and coach_sessions.session_start_time >= ? and coach_sessions.session_start_time <= ? and (substitutions.grabbed = 1 or substitutions.was_reassigned = 1) and coach_sessions.coach_id = ?"
    Substitution.find_by_sql([sub_str, start_date, end_date, coach_id])
  end

  def session_unit
    @session_unit ||= coach_session.eschool_session_unit.to_i if coach_session.eschool_session_unit
  end

  def is_one_hour?
    coach_session.is_a?(Appointment) ? false : language.duration.eql?(60)
  end
  
  def qualified_for?(other_coach,sub_language)#should be changed for multiple language for coach- method not used as of now so fix not put
    #return false if self.coach_id == other_coach.id
    qualification_for_sub = Qualification.find_by_language_id_and_coach_id(sub_language.id,other_coach.id)
    qualification_for_sub.max_unit.to_i >= session_unit.to_i
  end

  def eligible_coaches
    self.language.coaches.select { |coach| self.qualified_for?(coach,self.language) }
  end

  def substitution_date
     @substitution_date ||= coach_session.session_start_time
  end

  def cancel_session
    self.update_attributes(:cancelled => true)
  end

  def cancel!(notice = false)
    coach_session.cancel_session!("CSP:Sub-requested and then cancelled")
    self.update_attributes(:cancelled => true)
    if coach && notice
      coach.system_notifications.create({
        :raw_message => "Your <b>#{language.display_name}</b> session on #{TimeUtils.format_time(substitution_date, "%b %d, %Y %H:%M %Z")} has been canceled.",
        :notification_id=>TriggerEvent.find_by_name("SESSION_CANCELLED").id
      })
    end
  end

  def has_grabbed?
    grabbed
  end

  def has_canceled?
    cancelled
  end
  
  def has_reassigned?
    was_reassigned
  end

  def is_in_same_block?(substituted_coach_session)
    times = [TimeUtils.time_in_user_zone(substituted_coach_session.session_start_time),TimeUtils.time_in_user_zone(coach_session.session_start_time)].sort!
    from = times[0]
    to = times[1]
    sessions = CoachSession.where("session_start_time > ? and session_start_time < ? and coach_id = ? and cancelled = 0",from,to,coach_id)
    from += ((substituted_coach_session.session_start_time == from) ? substituted_coach_session.duration_in_seconds : coach_session.duration_in_seconds )
    ((from-to).abs/30.minutes) ==  (sessions.size + sessions.select{|ses| ses.is_one_hour? }.size)
  end  

  def perform_substitution(coach, was_reassigned = false, trigger_event_type = 'MANUALLY_REASSIGNED')
    self.update_attributes(:grabber_coach_id => coach.id, :grabbed => true, :grabbed_at => Time.now, :was_reassigned => was_reassigned)
    coach_session.update_attributes(:coach_id => coach.id, :recurring_schedule_id => nil)
    #do not set the reassigned flag to true if the session is reassigned back to the same coach who has requested subs
    coach_session.update_attributes(:reassigned => true) if self.grabber_coach_id != self.coach_id
    if coach_session.is_extra_session?
      if coach_session.supersaas?
          response = ExternalHandler::HandleSession.substitute_session(coach_session.language, {:session => coach_session, :remote_session_id => coach_session.eschool_session_id, :coach => Coach.unscoped.find_by_rs_email(FALSE_COACH_EMAIL), :grabber_coach => coach})
          coach_session.update_attribute(:type, 'ConfirmedSession') && self.grabber_coach.update_time_off(coach_session) if response
      else
          response = ExternalHandler::HandleSession.assign_extra_session(coach_session.language, {:remote_session_id => coach_session.eschool_session_id, :coach_id => coach.id}) if !coach_session.reflex?
          (coach_session.update_attribute(:type, 'ConfirmedSession') && self.grabber_coach.update_time_off(coach_session) ) if coach_session.reflex? || response
      end
    else
      response = ExternalHandler::HandleSession.substitute_session(coach_session.language, {:session => coach_session, :remote_session_id => coach_session.eschool_session_id, :coach => Coach.find_by_id(self.coach_id), :grabber_coach => coach, :user_name => coach.user_name})
      self.grabber_coach.update_time_off(coach_session) if coach_session.reflex? || coach_session.tmm? || coach_session.appointment? || response || (coach_session.supersaas? && self.grabber_coach_id == self.coach_id)
    end

    if(trigger_event_type == 'MANUALLY_REASSIGNED' || trigger_event_type == 'SUBSTITUTION_GRABBED')
      TriggerEvent[trigger_event_type].notification_trigger!(self)
    else
      coach.system_notifications.create(:raw_message => "You have been assigned a <b>#{coach_session.language.display_name}</b> session on <b>#{TimeUtils.format_time(coach_session.session_start_time, "%B %d, %Y %I:%M %p")}</b>.")
    end
  end
  
  def self.get_future_alerts(current_user)
    preference = current_user.get_preference
    if preference.substitutions_show_count_is_not_zero?
      current_user_show_sub = ShownSubstitutions.find_by_coach_id(current_user.id)
      last_seen = current_user_show_sub[:updated_at] if current_user_show_sub
      
      condition = "coach_sessions.session_start_time >= ? and coach_sessions.session_start_time <= ? and coach_sessions.session_end_time > ?"
      condition = condition + " and substitutions.grabbed = 0 and substitutions.cancelled = 0 and substitutions.coach_id IS NOT NULL" 
      condition = condition + " and substitutions.updated_at >= ?" if last_seen
      condition = condition + " and qualifications.coach_id = ?" if current_user.is_coach?
    
      conditions = [condition, TimeUtils.current_slot(true), Time.now.utc + preference.substitution_alerts_display_time.seconds, Time.now]
      conditions << last_seen if last_seen
      conditions << current_user.id if current_user.is_coach?
     
      join = "LEFT OUTER JOIN (coach_sessions"
      join = join + ", qualifications, languages" if current_user.is_coach?
      join = join + ")"
      join = join + " on (coach_sessions.id = substitutions.coach_session_id"
      join = join + " and languages.identifier = coach_sessions.language_identifier and languages.id = qualifications.language_id" if current_user.is_coach?
      join = join + ")"
      
      where(conditions).select("substitutions.*").joins(join).order("coach_sessions.session_start_time").group("substitutions.id")
    else
      []
    end
  end

  def coach_id_not_null_for_standard_session
    #for extra session coach_id is null. So, substitution without coach_id is valid, if it is an ExtraSession
    unless (coach_session.is_extra_session? || coach_id)
      errors.add( :substitution,"coach id cannot be null")
    end
  end

  def self.for_language(identifiers, duration = nil)
    start_time = TimeUtils.time_in_user_zone.beginning_of_hour
    if duration == "Today"
      end_time = start_time.end_of_day
    elsif duration == "Tomorrow"
      start_time = start_time.beginning_of_day + 1.day
      end_time = start_time + 1.day
    elsif duration == "Upcoming Week"
      end_time = start_time + 1.week
    end
    
    condition = ["coach_sessions.language_identifier IN (?) AND coach_sessions.session_start_time >= ?", identifiers, start_time.utc - EXTENDED_SUBSTITUTE_REQUEST_TIME]
    if end_time
      condition[0] += " AND coach_sessions.session_start_time < ?"
      condition << end_time.utc
    end
    condition[0] += " AND substitutions.cancelled = 0 AND grabbed = 0"
    subs = where(condition).includes([:coach_session, :coach, :language]).order("coach_sessions.session_start_time")
    subs.reject!{|s| s.coach_session.is_passed? }
    subs
  end

  def to_hash
    lang = coach_session.appointment? ? coach_session.display_name_in_upcoming_classes : language.sort_display_name
    eachsub = {
      :coach              => coach_session.name.blank? ? "Extra Session" : "Extra Session - #{coach_session.name}",
      :coach_id           => "Extra Session",
      :subsitution_date   => substitution_date,
      :sub_id             => id,
      :language           => lang,
      :level_unit_lession => "N/A",
      :village            => "N/A",
      :learners_signed_up => "N/A",
      :extra_session      => coach_session.is_extra_session?
    }

    if coach
      eachsub[:coach] = coach.display_name
      eachsub[:coach_id] = coach.id
    end
    eachsub[:learners_signed_up] = coach_session.learners_signed_up.to_i unless coach_session.reflex? || coach_session.tmm_live? || coach_session.appointment?
    eachsub[:level_unit_lession] = "L#{coach_session.eschool_session.level},U#{coach_session.eschool_session.unit},LE#{coach_session.eschool_session.lesson}" if coach_session.eschool_session
    eachsub
  end
  
end
