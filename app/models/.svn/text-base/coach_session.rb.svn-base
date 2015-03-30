# == Schema Information
#
# Table name: coach_sessions
#
#  id                  :integer(4)      not null, primary key
#  coach_user_name     :string(255)
#  eschool_session_id  :integer(4)
#  session_start_time  :datetime
#  created_at          :datetime
#  updated_at          :datetime
#  cancelled           :boolean(1)
#  external_village_id :integer(4)
#  language_identifier :string(255)
#  single_number_unit  :integer(4)
#  number_of_seats     :integer(4)
#  attendance_count    :integer(4)
#  coach_showed_up     :boolean(1)
#  seconds_prior_to_session :boolean(1) # seconds before session_start_time the coach launched the session
#  session_status      :integer(4) # 0- if created in coach session but not in eschool 1- created in both and for all reflex sessions.
#  coach_id            :integer
#  language_id         :integer

require File.dirname(__FILE__) + '/../utils/coach_availability_utils'
class CoachSession < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
  self.include_root_in_json = false
  belongs_to :coach, :foreign_key => 'coach_id'
  belongs_to :topic
  has_one :session_metadata, :dependent => :destroy
  has_many :help_requests, :class_name => "HelpRequest", :foreign_key => 'external_session_id', :primary_key => 'eschool_session_id'
  belongs_to :recurring_schedule, :class_name => 'CoachRecurringSchedule'
  belongs_to :language
  has_one :session_details, :dependent => :destroy

  attr_accessor :sess
  validate :manadatory_fields
  validate :teacher_cannot_double_book
  
  scope :for_language, lambda { |language_identifier| {:conditions => ["language_identifier = ? ", language_identifier]} }
  scope :starts_between, lambda { |lower_limit_time, upper_limit_time| {:conditions => ["session_start_time >= ? and session_start_time <= ?", lower_limit_time.utc, upper_limit_time.utc], :order => 'session_start_time'} }
  scope :confirmed, lambda { {:conditions => ["cancelled = 0 "]} }
  scope :coaches, lambda { {:conditions => ["coach_id is not NULL "]} }
  
  after_save :destroy_session_metadata_if_not_local_session

  def eschool_session
    # if condition is to prevent accidental eschool calls for aria sessions or when eschool session id is passed as nil
    self.sess ||= ExternalHandler::HandleSession.find_session(language, {:id => eschool_session_id}) if totale? && !self.eschool_session_id.nil?
  end

  def supersaas_session
    @sess1 ||= ExternalHandler::HandleSession.find_session(language, {:id => eschool_session_id, :number_of_seats => number_of_seats}) ## returns array of bookings
  end

  def supersaas_learner
    @learner ||= supersaas_session.present? ? (supersaas_session.reject{|ses| ses[:email] == get_coach.try(:rs_email)}) : []
  end  

  def fetch_supersaas_slot_description
    @sess2 ||= ExternalHandler::HandleSession.fetch_slot_description(language, {:guid => get_coach.coach_guid, :start_time => session_start_time, :number_of_seats => number_of_seats})
  end

  def is_one_hour?
    !is_a?(Appointment) && language.duration == 60 
  end
    
  def get_coach #method to retrieve coach from substitution if the session is subrequested -- ONLY FOR ARIA
    coach || substitution.coach
  end  

  def supersaas_coach
    supersaas_session.select{|ses| ses[:email] == get_coach.rs_email}
  end

  def substitution
    Substitution.find(:last, :conditions => ["coach_session_id = ?", id])
  end
  
  def stop_recurring
    recurring_schedule.update_attribute(:recurring_end_date, session_start_time - 1.week) if recurring_schedule
  end
  
  def reflex?
    self.language.is_lotus?
  end

  def aria?
    self.language.is_aria?
  end

  def totale?
   self.language.is_totale?
  end

  def tmm_phone?
    self.language.is_tmm_phone?
  end

  def tmm_live?
    self.language.is_tmm_live?
  end

  def tmm_michelin?
    self.language.is_tmm_michelin?
  end

  def tmm?
    self.language.is_tmm_live? || self.language.is_tmm_phone? || self.language.is_tmm_michelin?
  end

  def supersaas?
    (aria? || tmm_michelin? || tmm_phone?) && !appointment?
  end

  def appointment?
    is_a? Appointment
  end

  def details
    session_details ? session_details.details : nil
  end

  def appointment_type_title
    appointment_type ? appointment_type.title : ''
  end

  def is_extra_session?
    self.is_a?(ExtraSession)
  end

  def is_local_session?
    self.is_a?(LocalSession)
  end

  def display_name_in_upcoming_classes
    if appointment?
      language.display_name_without_type + " - " + appointment_type.title
    else
      language.display_name
    end
  end

  def future_recurring_sessions
    recurring_schedule_id ? CoachSession.where(["recurring_schedule_id = ? and session_start_time > ? and cancelled = 0", recurring_schedule_id, session_start_time]) : []
  end

  def cancel_or_subsitute_as_per_language(lang_switch = false)
    #village sessions will not be sub triggered if it is edited from MS
    if learners_signed_up > 0 || external_village_id || tmm_live? || appointment?
      modification = modify_coach_availability(2) unless lang_switch
      enable_substitute!
    else
      modification = modify_coach_availability(4) unless lang_switch
      cancel_session!
    end
    modification
  end

  def cancel_and_stop_recurrence(with_recurrence = true, reason = nil)
    @RSA_denied_list = {}
    if coach
       modify_coach_availability(4)
       cancel_session!
       self.update_attributes(:cancellation_reason => reason) if reason
       coach.system_notifications.create(:raw_message => "Your #{self.language.identifier} Session on #{TimeUtils.format_time(session_start_time, "%B %d, %Y %H:%M %Z")} has been cancelled.")
       if with_recurrence && recurring_schedule_id
          future_recurring_sessions.each do |session|
            session.cancel_or_subsitute_as_per_language(false)
          end
          stop_recurring
       end
    else
      substitution.cancel!
    end
    if @RSA_denied_list.blank? 
      return true , nil, nil
    else
      email_notifications_for_RSA_denied_cancelled_sessions
      return false , @RSA_denied_list[:learner], @RSA_denied_list[:learner_contact_info]
    end
  end

  def get_cancellation_permission?(learners_count)
    if (tmm_phone? || tmm_michelin?) && learners_count > 0
      description = fetch_supersaas_slot_description
      cancellation_url = description["ca"]["u"]
      cancellation_url = 'www.google.co.in'  #TODO:: remove this hardcoded-stuff
     # res = Net::HTTP.get_response(URI("http://#{cancellation_url}"))
     # if res.code == 500
      code = 200
      if code == 500
        @RSA_denied_list = {:start_time => session_start_time.strftime("%B %d, %Y %r UTC"), :language => language.display_name, :coach => coach ? coach.full_name : substitution.coach.full_name, :learner => description["l"].first["n"], :learner_contact_info =>[ContactType[description["l"].first["ml"]["t"]], description["l"].first["ml"]["v"]].reject(&:empty?).join(': ')}
        false
      else
        true
      end
    else
      true
    end
  end
  
  def update_aria_session
    saas_session = ExternalHandler::HandleSession.get_slot_id_for_session(language, {:guid => coach.coach_guid, :start_time => session_start_time, :number_of_seats => number_of_seats})
    if saas_session
      update_attributes(:eschool_session_id => saas_session.slot.id, :session_status => COACH_SESSION_STATUS["Created in Eschool"])
      return ["Session updated successfully",200]
    end
    return ["Session was not updated. Please verify the reservation in SuperSaas and try again.",500]
  end
    
  def create_sessions_till_last_pushed_week(include_current_week = false)
    skipped = false
    if recurring_schedule
      session_date = TimeUtils.time_in_user_zone(session_start_time)
      session_date += week_shift(session_date.utc) unless include_current_week
      # We have to take the lesser of recurring end date and end of pushed week.
      end_of_lpw = [TimeUtils.end_of_week_for_user(language.last_pushed_week),recurring_schedule.recurring_end_date].compact.min
      options = to_hash.except!(:details) #Session details text should not be created for recurring TMM sessions
      is_one_hour_session = language.is_one_hour? && !appointment?
      current_end_date = nil
      while session_date <= end_of_lpw
        session_datetime = session_date.utc
        other_recurring = CoachRecurringSchedule.for_coach_and_datetime(coach, session_datetime)
        if coach.is_totale_aria?
          one_hour_lang_list = AriaLanguage.all.collect(&:id) + TMMLiveLanguage.all.collect(&:id) + TMMMichelinLanguage.all.collect(&:id)
          second_half_recurring = CoachRecurringSchedule.for_coach_and_datetime(coach, TimeUtils.return_other_half(session_datetime)) if is_one_hour_session
          aria_first_half_recurring = CoachRecurringSchedule.for_coach_and_datetime(coach, TimeUtils.return_other_half(session_datetime), one_hour_lang_list) if session_datetime.min == 30
          aria_first_half_recurring = aria_first_half_recurring.recurring_type == 'recurring_appointment' ? nil : aria_first_half_recurring if aria_first_half_recurring
        end
        if (other_recurring && other_recurring.id != recurring_schedule.id) || (other_recurring = second_half_recurring ? second_half_recurring : aria_first_half_recurring)
          recurring_schedule.update_attributes(:recurring_end_date => (current_end_date ? current_end_date.utc : other_recurring.recurring_start_date - 1.week)) 
          break
        elsif coach.can_create_recurring_session?(session_datetime, is_one_hour_session, coach.has_one_hour?)
          options[:start_time] = session_datetime
          if type.eql?("Appointment")
            Appointment.create_one_off(options)
          else
            ConfirmedSession.create_one_off(options)
          end
          current_end_date = nil
        else
          current_end_date = session_date - 1.week if !current_end_date
          skipped = true
        end
        session_date += week_shift(session_datetime)
      end
    end
    skipped
  end

  def week_shift(next_session_start_time)
    datetime = next_session_start_time  + 7.days
    (TimeUtils.daylight_shift(datetime-1.hour, datetime) == 1.hour) ? 14.days : 7.days
  end

  def get_reassigned_coach
    session_metadata.try(:new_coach_id).nil? ? coach_id : session_metadata.new_coach_id
  end

  def to_hash
    session_hash = {}
    session_hash[:external_session_id] = id
    session_hash[:eschool_session_id] = eschool_session_id
    session_hash[:recurring_schedule_id] = recurring_schedule_id
    session_hash[:number_of_seats] = number_of_seats
    session_hash[:external_village_id] = external_village_id
    session_hash[:coach_username] = session_metadata.try(:new_coach_id).nil? ? coach.user_name : Coach.find_by_id(session_metadata.new_coach_id).user_name
    session_hash[:max_unit] = Coach.max_unit(get_reassigned_coach, language_id)
    if single_number_unit.blank?
      session_hash[:wildcard] = "true"
      level_unit_info = CurriculumPoint.level_and_unit_from_single_number_unit(session_hash["max_unit"])
    else
      session_hash[:wildcard] = "false"
      level_unit_info = CurriculumPoint.level_and_unit_from_single_number_unit(single_number_unit)
    end
    session_hash[:lang_identifier] = language_identifier
    session_hash[:lesson] = 4
    session_hash[:level] = level_unit_info[:level]
    session_hash[:unit] = level_unit_info[:unit]
    session_hash[:teacher_id] = get_reassigned_coach
    session_hash[:teacher] = {:user_name => session_hash[:coach_username]}
    session_hash[:start_time] = session_start_time
    session_hash[:duration_in_seconds] = duration_in_seconds
    session_hash[:teacher_confirmed] = session_metadata ? session_metadata.teacher_confirmed : eschool_session ? eschool_session.teacher_confirmed : true
    session_hash[:lesson] = session_metadata ? session_metadata.lessons : 4
    session_hash[:topic_id] = session_metadata ? session_metadata.topic_id : topic_id
    session_hash[:details] = details
    session_hash[:appointment_type_id] = appointment_type_id
    session_hash
  end

  #If level is 3 and unit is 2, the atomic unit is taken as (level-1)*4 + unit which would be equal to 10
  def eschool_session_unit
    CurriculumPoint.single_number_unit_from_level_and_unit(eschool_session.level.to_i, eschool_session.unit.to_i) if eschool_session
  end

  def learners_signed_up
    totale? ? eschool_session.learners_signed_up.to_i : ( supersaas? ? supersaas_learner.size : 0) 
  end

  def cancel_or_subsitute!(unavailability_type = 2)
    if need_sub_trigger?
      modification = modify_coach_availability(unavailability_type)
      enable_substitute!
    else
      modification = modify_coach_availability
      cancel_session!("CSP:Sub-requested and auto-cancelled")
    end
    modification
  end

  def need_sub_trigger?
    tmm_live? || appointment? || reflex? || learners_signed_up > 0 || external_village_id
  end

  # this method is supposed to be called wherever cancel_or_subsitute! is called
  def modify_coach_availability(unavailability_type = 4)
    udt = []
    start_time = session_start_time
    (duration_in_seconds/1800).times do 
      udt << UnavailableDespiteTemplate.create({
        :coach_id             => coach_id,
        :start_date           => start_time,
        :end_date             => start_time + (appointment? ? 30.minutes : language.duration.minutes),
        :approval_status      => 1,
        :comments             => 'Auto Approved - Coach requested Substitute',
        :unavailability_type  => unavailability_type,
        :coach_session_id     => id
      })
      start_time += 30.minutes
    end
    udt.first
  end

  def enable_substitute!(excluded_coaches = [])
    response = ''
    response = ExternalHandler::HandleSession.substitute_session(language, {:remote_session_id => eschool_session_id, :user_name => ''}) if totale?
    # To prevent supersaas call when requesting for a sub.
    if !eschool_session_id || response
      sub = Substitution.create(:coach_id => coach_id, :grabbed => false, :coach_session_id => id)
      self.update_attributes(:coach_id => nil, :recurring_schedule_id => nil)
      send_email_to_coaches_and_coach_managers(excluded_coaches)
    end
    sub
  end

  def eligible_alternate_coaches(check_max_unit = false) #for reassigning a session check_max_unit should be true
    single_number_unit = check_max_unit ? eschool_session ? eschool_session.level ? CurriculumPoint.single_number_unit_from_level_and_unit(eschool_session.level, eschool_session.unit) : eschool_session.unit : 0 : 0
    CoachAvailabilityUtils.eligible_alternate_coaches(session_start_time, language.id, single_number_unit)
  end

  def email_cancelled_session_details
    user = Thread.current[:account]
    data = {
      :language => language.display_name,
      :start_time => TimeUtils.format_time(session_start_time),
      :learners => totale? ? eschool_session.learner_details.collect{ |learner| learner.student_email}.to_sentence : supersaas_learner.collect{|learner| learner[:email]},
      :cancelled_on => TimeUtils.format_time,
      :cancelled_by => user.full_name,
      :role => user.type,
      :village_name => village_name.blank? ? "N/A" : village_name,
      :session_type => number_of_seats.to_i == 1 ? "Solo" : "Group"
    }
    data[:coach] = coach ? coach.full_name : substitution.coach.full_name
    data[:cc_to_mail] = get_coach.try(:email) #Include Coach in cancellation email even when the session is subbed
    GeneralMailer.send_email_notifications_for_cancelled_sessions("rsstudioteam-supervisors-l@rosettastone.com", data).deliver
  end

  def email_notifications_for_RSA_denied_cancelled_sessions
    GeneralMailer.send_email_notifications_for_RSA_denied_cancelled_sessions("rsstudioteam-supervisors-l@rosettastone.com", @RSA_denied_list).deliver
  end

  def cancel_and_email(learners_count = nil)
    learners_count = learners_signed_up if learners_count.blank?
    self.update_attribute(:cancelled, true)
    email_cancelled_session_details if learners_count > 0
  end

  def cancel_session!(cancelled_by = "CSP")
    learners_count = learners_signed_up
    permission = get_cancellation_permission?(learners_count)
    if permission
      if eschool_session_id
          res = ExternalHandler::HandleSession.cancel_session(language, {:remote_session_id => eschool_session_id, :session_start_time => session_start_time, :number_of_seats => number_of_seats, :cancelled_by => cancelled_by})
      end
    end 
    cancel_and_email(learners_count) if !eschool_session_id || res || !permission
  end

  def slot_time
    session_start_time
  end

  def self.sessions_count_for_ms_week(start_time, end_time, language_identifier, is_aria, classroom_type = "all")
      sql = "SELECT session_end_time, session_start_time, COUNT(*) AS sessions_count,
          COUNT(CASE WHEN coach_id IS NULL THEN 1 ELSE null end) AS sub_requested_count"
      select_emergencey_session = ",COUNT(CASE WHEN session_status = 0 THEN 1 ELSE null end) AS emergency_session_count "
      conditions = " FROM coach_sessions
        WHERE cancelled = 0
            AND   session_start_time >= ?
            AND   session_start_time <= ?
            AND   language_identifier = ?
            AND   (type = 'ConfirmedSession' OR type = 'ExtraSession') "
      if classroom_type == "solo"
        conditions = conditions + "AND number_of_seats = 1 "
      elsif classroom_type == "group"
        conditions = conditions + "AND number_of_seats > 1 "
      end 
      conditions = conditions + "GROUP BY session_start_time;"
      sql = sql + select_emergencey_session if is_aria
      sql = sql + conditions
      find_by_sql([sql, start_time, end_time, language_identifier])
  end

  def time_from_now # in minutes
    ((session_start_time - Time.now) / 60).ceil
  end

  def self.get_sessions_made_on_time_off(language, start_of_the_week, end_of_the_week, created_at)
    sql = "SELECT cs.coach_id, cs.session_start_time, cs.language_id, cs.session_end_time 
           FROM coach_sessions cs INNER JOIN unavailable_despite_templates udt 
           ON cs.coach_id = udt.coach_id
           WHERE approval_status = 1 AND unavailability_type = 0 
             AND cs.session_start_time >= udt.start_date 
             AND cs.session_start_time < udt.end_date 
             AND cs.session_start_time <= ? AND cs.session_start_time >= ?
             AND cs.language_identifier = ? AND cs.created_at >= ?"
    CoachSession.find_by_sql([sql, end_of_the_week, start_of_the_week, language.identifier, created_at])
  end

  def self.get_sessions_for_language_and_week(language_identifier,start_time)
    where("language_identifier = ? and session_start_time >= ? and session_start_time <= ? and cancelled = ?",language_identifier,start_time,start_time + 1.week - 1.hour, false)
  end

  def self.get_sessions_for_language_village_and_time(lang_identifier, session_start_time, external_village_id)
    where(["session_start_time = ? AND language_identifier = ? AND type not in ('LocalSession','Appointment')" + village_condition(external_village_id), session_start_time, lang_identifier]).includes([:coach])
  end

  def self.get_pushed_session_totale(session_start_time, lang_identifier, external_village_id, column)
    condition = "type != 'LocalSession' and language_identifier = ?" + village_condition(external_village_id)
    if column == 'all'
      self.find_all_by_session_start_time(session_start_time,:conditions => [condition,lang_identifier ])
    else
      self.find_all_by_session_start_time(session_start_time,:conditions => [condition,lang_identifier ], :select => 'eschool_session_id').collect(&:eschool_session_id)
    end
  end

  def self.find_confirmed_between(from_time,to_time,lang_identifier)
    for_language(lang_identifier).starts_between(from_time, to_time)
  end

  def self.find_coaches_between(from_time, to_time, lang_identifier = 'KLE')
    condition = "session_start_time >= ? and session_start_time < ? and cancelled = ? and coach_id is not NULL"
    condition += " and language_identifier = '#{lang_identifier}'" if lang_identifier
    condition += " and language_identifier not in (" + Language.where("type in('TMMLiveLanguage','TMMPhoneLanguage','TMMMichelinLanguage','AriaLanguage')").map(&:identifier).map(&:inspect).join(',') + ")" unless lang_identifier 
    columns = "coach_sessions.id, accounts.full_name, accounts.user_name,accounts.rs_email,session_metadata.action"
    join = "INNER join accounts on accounts.id = coach_sessions.coach_id LEFT OUTER JOIN session_metadata on coach_sessions.id =  session_metadata.coach_session_id"
    have_cond = "coach_sessions.id having IFNULL(session_metadata.action, '') != 'create' "
    CoachSession.where(condition, from_time, to_time, false).joins(join).select(columns).group(have_cond) 
  end

  def self.find_aria_coaches_between(from_time, to_time, lang_identifier = 'all')
    condition = "session_start_time >= ? and session_start_time < ? and cancelled = ? and coach_id is not NULL"
    condition += lang_identifier == 'all' ? " and language_identifier in ('AUS','AUK')" : " and language_identifier = '#{lang_identifier}'"
    columns = "coach_sessions.id, accounts.full_name, accounts.user_name,accounts.rs_email,session_metadata.action"
    join = "INNER join accounts on accounts.id = coach_sessions.coach_id LEFT OUTER JOIN session_metadata on coach_sessions.id =  session_metadata.coach_session_id"
    have_cond = "coach_sessions.id having IFNULL(session_metadata.action, '') != 'create' "
    CoachSession.where(condition, from_time, to_time, false).joins(join).select(columns).group(have_cond) 
  end

  def request_substitute(is_manager = true)
    modification = cancel_or_subsitute!(1)
    if modification.unavailability_type == 1
      if is_manager
        TriggerEvent['SUBSTITUTE_REQUESTED_FOR_COACH'].notification_trigger!(modification)
      else
        TriggerEvent['SUBSTITUTE_REQUESTED'].notification_trigger!(modification)
      end
    end
    modification
  end

  def send_email_to_coaches_and_coach_managers(excluded_coaches = [])
    excluded_coaches << -1
    datetime = TimeUtils.format_time(session_start_time, "%a %m/%d %l:%M %p (%Z)")
    options = {
      :user_id => coach_id,
      :lang_id => language_id,
      :datetime => datetime,
      :message => "#{display_name_in_upcoming_classes} at #{datetime} (Eastern)"
    }
    # Send E-Mail to Coaches
    options[:recipients] = Coach.email_recipients("substitution_alerts_email", language_id)
    GeneralMailer.substitutions_email(options).deliver if (options[:recipients].any? && !Language.find(options[:lang_id]).is_lotus?) #REFLEX SUNSET
    # Send E-Mail to Managers
    options[:recipients] = CoachManager.email_recipients("substitution_alerts_email", language_id)
    options[:is_manager] = true
    GeneralMailer.substitutions_email(options).deliver if (options[:recipients].any? && !Language.find(options[:lang_id]).is_lotus?) #REFLEX SUNSET
  end

  def sessions_affected_till_last_pushed_week(language)
    last_pushed_week = TimeUtils.beginning_of_week_for_given_date(language.last_pushed_week(true))
    session_date     = session_start_time+7.days
    date_array       = []
    session_utc = session_date.clone
    while session_utc.utc <= last_pushed_week.utc + 7.days
      session_utc = session_date.clone
      date_array << session_utc.utc.to_s(:db)
      session_date  += 7.days
    end
    ConfirmedSession.where("coach_id = ? and language_identifier = ? and session_start_time in (?)",coach_id,language_identifier,date_array ).order("session_start_time")
  end

  def self.get_reflex_session_count_for_a_slot(slot_time)
    self.count('id', :conditions => ["language_identifier = 'KLE' AND session_start_time = ? AND cancelled != 1",slot_time])
  end

  def conflict_reflex_session_on_same_slot?(datetime)
    reflex? && (((session_start_time.to_time - datetime).round/60 < 60) && ((session_start_time.to_time - datetime.to_time).round/60 >= 0) || ((datetime - session_start_time.to_time).round/60 < 60) && ((datetime - session_start_time.to_time).round/60 > 0))
  end

  def duration_in_seconds
    (session_end_time - session_start_time).to_i
  end 

  def is_passed?
    Time.now.utc > session_end_time
  end

  def is_started?
    Time.now.utc > session_start_time
  end

  def confirmed?
    eschool_session.nil? || eschool_session.teacher_confirmed == "true"
  end

  def falls_under_alerts_display_time?
    (session_start_time  - Time.now.utc)  < coach.get_preference.session_alerts_display_time.minutes && !is_passed?
  end

  def number_of_seats
    # totale? is to prevent accidental eschool calls for aria sessions
    (totale? && eschool_session && type == 'ConfirmedSession' ) ?  eschool_session.number_of_seats  :  self['number_of_seats']
  end

  def is_cancelled?
    cancelled || (totale? && eschool_session.try(:cancelled) == "true" ? cancel_in_csp : false)
  end

  def is_substituted?
    (type == 'ConfirmedSession') && coach.nil?
  end

  def cancel_in_csp
    session = CoachSession.find(self.id) #done to prevent read only error since we were not sure of using READ ONLY in active records join
    session.update_attribute(:cancelled, true) 
    session.update_attribute(:cancellation_reason, "Cancelled in Eschool") 
    modify_coach_availability
    return true
  end  

  def village_name  
    Community::Village.display_name(external_village_id) || ""
  end

  def falls_under_20_mins?
    (session_start_time  - Time.now.utc)  < 20.minutes && !is_passed?
  end

  def convert_to_local_session(type, action_type, recurring)
    recurring = (recurring.to_s == "true")
    if session_metadata.blank?
      SessionMetadata.create(:action => action_type, :recurring => recurring, :coach_session_id => id)
    else
      session_metadata.update_attributes(:action => action_type, :recurring => recurring)
    end
    self.update_attribute(:type, type)
  end

  def cancel_totale_session(type, action_type, cancellation_reason)
    if session_metadata.blank?
      SessionMetadata.create(:action => action_type,:coach_session_id => id, :cancellation_reason => cancellation_reason.present? ? cancellation_reason : nil )
    else
      session_metadata.update_attributes(:action => action_type, :cancellation_reason => cancellation_reason.present? ? cancellation_reason : nil )
    end
    self.update_attribute(:type, type)
  end

  def label_for_active_session(udt = nil)
    label = ""
    if appointment?
     label = self.language.display_name_without_type + "<br />" + self.appointment_type.title 
    elsif tmm_live?
      label = udt ? "" : "<br/><br/>" 
      label += self.language.display_name
    elsif reflex?
      label = "REFLEX"
    elsif supersaas?
      label = (udt || tmm_phone?) ? "" : "</br></br>" #udt and tmm_phone are half hour slots, hence dont insert br for alignment
      label += self.language.display_name 
      if supersaas_session
        learners = supersaas_learner
        label += (learners.empty?) ? "<br/> No Learner" : "<br/> #{learners.size} Learner(s)"
        label += "<br/> <font color='red'>Coach not present</font>" if coach && supersaas_coach.first.try(:fetch,:email) != coach.try(:rs_email)
        label += " <img class='solo_icon' src='/images/solo.png' alt='solo'>" if (number_of_seats == 1 && language.is_aria?)
      elsif eschool_session_id.nil?
        label +=  "<br/> <font color='red'>Emergency Session</font>"
      end 
    else
      if eschool_session
        label = eschool_session.language
        if eschool_session.wildcard == "false" || (eschool_session.wildcard == "true" && eschool_session.wildcard_locked == "true")
          unit = CurriculumPoint.single_number_unit_from_level_and_unit(eschool_session.level, eschool_session.unit)
          (session_start_time > AppUtils.wc_release_date) ? label += " L#{eschool_session.level} U#{unit} LE#{eschool_session.lesson}" : label += " L#{eschool_session.level} U#{eschool_session.unit}"
        else
          units = eschool_session.wildcard_units.split(',')
          level_unit = CurriculumPoint.level_and_unit_from_single_number_unit(units.last)
          (session_start_time > AppUtils.wc_release_date) ? label += " Max L#{level_unit[:level]}-U#{units.last}-LE#{eschool_session.lesson}" : label += " Max L#{level_unit[:level]}-U#{level_unit[:unit]}"
        end
        label += "<br/> #{eschool_session.external_village_id && Community::Village.display_name(eschool_session.external_village_id) ? Community::Village.display_name(eschool_session.external_village_id).slice(0..7).strip + ".. &nbsp;" : ''}"
        if eschool_session.start_time.to_time + eschool_session.duration_in_seconds.to_i.seconds < Time.now.utc
          label += "#{eschool_session.students_attended} learners"
        else
          label += "#{eschool_session.learners_signed_up} learners"
        end
        label += "<br/> <font color='red'>Unconfirmed</font>" if eschool_session.teacher_confirmed != "true" && udt !="from_only_sub"
        label += " <img class='solo_icon' src='/images/solo.png' alt='solo'>" if eschool_session.number_of_seats == "1"
      end
    end
    label
  end
  
  def label_for_substitution(unavailability_type, sub_coach_id = nil)
    slot_details = ["", ""]
    sub = Substitution.where("coach_id = ? and coach_session_id = ? ",sub_coach_id,self.id).order("id desc").first
    if coach_id or sub.try(:grabbed)
      slot_details[0] = label_for_active_session( coach_id.nil? ? "from_only_sub" : "Assigned")
      slot_details[0] += "<br/> <span class='substitute-info'>#{(unavailability_type == "Reassigned")? "Reassigned" : "Substituted"}</span>"
      slot_details[1] = "cs_substituted"
    else
      if cancelled
        slot_details[0] = "#{unavailability_type}-Cancelled"
        slot_details[1] = "cs_sub_canl_session_slot"
      elsif eschool_session && eschool_session.cancelled == "true"
        slot_details[0] = "#{unavailability_type}-auto-Cancelled"
        slot_details[1] = "cs_sub_canl_session_slot"
      elsif appointment?
        slot_details[0] = label_for_active_session(unavailability_type)
        slot_details[0] = slot_details[0] + "<br/> #{unavailability_type}"
        slot_details[1] = "cs_sub_needed_appointment_session_slot"
      else
        slot_details[0] = label_for_active_session(unavailability_type)
        br_index = slot_details[0].index("<br/>")
        slot_details[0] = (br_index ? slot_details[0].slice(0...br_index) : slot_details[0]) + "<br/> #{unavailability_type}"
        slot_details[1] = "cs_sub_needed_solid_session_slot"
      end
    end
    slot_details
  end

  def self.village_condition(external_village_id)
    if external_village_id == 'all'
      ""
    elsif external_village_id == 'none'
      " AND external_village_id IS NULL"
    else
      " AND external_village_id = #{external_village_id}"
    end
  end
  
  def label_for_google_calendar
    if appointment?
      label = display_name_in_upcoming_classes
    elsif reflex?
      label = "Advanced English"
    elsif aria? || tmm?
      label = language.display_name
    else
      if eschool_session
        label = Language[eschool_session.language].display_name
        if eschool_session.wildcard == "false" || (eschool_session.wildcard == "true" && eschool_session.wildcard_locked == "true")
          unit = CurriculumPoint.single_number_unit_from_level_and_unit(eschool_session.level, eschool_session.unit)
          (session_start_time > AppUtils.wc_release_date) ? label += " L#{eschool_session.level}-U#{unit}-LE#{eschool_session.lesson}" : label += " L#{eschool_session.level} U#{eschool_session.unit}"
        else
          units = eschool_session.wildcard_units.split(',')
          level_unit = CurriculumPoint.level_and_unit_from_single_number_unit(units.last)
          (session_start_time > AppUtils.wc_release_date) ? label += " Max L#{level_unit[:level]}-U#{units.last}-LE#{eschool_session.lesson}" : label += " Max L#{level_unit[:level]}-U#{level_unit[:unit]}"
        end
        village_name = Community::Village.display_name(eschool_session.external_village_id)
        label += " - #{village_name}" if village_name
      else 
        label = ""
      end
    end
    label
  end
  

  def self.find_confirmed_session_at(session_start_time,coach_id) 
    CoachSession.where(["cancelled = 0 AND coach_id = ? AND session_start_time = ? ", coach_id, session_start_time]).order("updated_at").last 
  end 
  
  private
  
  def teacher_cannot_double_book
    if errors.blank?
      self.session_end_time ||= (session_start_time + language.duration_in_seconds)
      not_self = (self.new_record?)? "" : " AND id <> #{self.id}"
      session = CoachSession.where(["cancelled = 0 AND coach_id = ? AND session_end_time > ? AND session_start_time < ?#{not_self}", coach_id, session_start_time, session_end_time]).order("updated_at").last
      errors.add(:coach, "#{coach.full_name} already has a session scheduled at #{session_start_time}") if session && !session.is_cancelled?
    end
  end

  def manadatory_fields
    if session_start_time.blank?
      errors.add(:session_start_time, "session must have a start time.")
    else
      minutes = session_start_time.strftime("%M")
      errors.add(:session_start_time, "session does not have a valid start time") unless ["00","30"].include?(minutes)
      errors.add(:session_start_time, "session must start in future.") if new_record? && session_start_time < TimeUtils.current_slot
    end
    self.language = Language.find_by_identifier(language_identifier) if language_identifier
    errors.add(:language, "session must have a language_identifier or language_id.") if language.blank?
  end

  def self.no_of_hours_coach_scheduled(coach_id,language_identifier,start_date,end_date)
  sql = <<-END
      SELECT coach_id, 
      COUNT(DISTINCT id) AS hours,
      COUNT(DISTINCT CASE WHEN session_start_time > UTC_TIMESTAMP()
      THEN id ELSE NULL END) AS future_sessions
      from coach_sessions where 
      coach_id in (?) and language_identifier in(?) and 
      session_start_time >= ? and session_start_time <= ? and cancelled = ? group by coach_id
  END
  find_by_sql([sql,coach_id,language_identifier,start_date,end_date,false])
  end

  def destroy_session_metadata_if_not_local_session
    session_metadata.destroy if type != 'LocalSession' && session_metadata
  end

end
