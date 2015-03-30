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
class Coach < Account

  include AppUtils
  attr_accessor :threshold

  has_many :availability_templates, :class_name => 'CoachAvailabilityTemplate', :dependent => :destroy, :conditions => 'deleted = 0', :order => "effective_start_date DESC"
  has_many :availability_modifications, :class_name => 'UnavailableDespiteTemplate', :dependent => :destroy
  has_many :approved_modifications, :class_name => 'UnavailableDespiteTemplate', :conditions => 'approval_status = 1', :order => "updated_at ASC"
  has_many :recurring_schedules, :class_name => 'CoachRecurringSchedule', :dependent => :destroy
  has_many :qualifications, :conditions => 'max_unit > 0', :dependent => :destroy
  has_many :languages, :through => :qualifications
  has_many :dialects, :through => :qualifications
  has_many :substitutions, :class_name => 'Substitution', :dependent => :destroy
  has_many :coach_sessions, :class_name => 'CoachSession', :foreign_key => 'coach_id', :dependent => :destroy
  has_many :confirmed_coach_sessions, :class_name => 'CoachSession', :foreign_key => 'coach_id', :conditions => "cancelled = 0 and type != 'Appointment'", :order => "session_start_time ASC"
  has_one :coach_contact, :dependent => :destroy
  belongs_to :region, :class_name => 'Region'
  belongs_to :manager, :class_name => 'CoachManager'

  validates(:bio, :length => {:maximum => 1000})
  validates :full_name, :format => {:with => /\A[a-zA-Z-'\s]+\z/,
                                    :message => "cannot have numbers or special characters"}
  validates :preferred_name, :format => {:with => /\A[a-zA-Z-'\s]*\z/,
                                         :message => "cannot have numbers or special characters"}

  # managers will also have qualifications, for languages that they can manage, with max_unit as nil
  scope :for_qualification, lambda { |language_id| where("active = 1 and qualifications.language_id = ? and max_unit > ?", language_id, 0).includes(:qualifications).order('trim(full_name)') }
  scope :find_all_active_coaches, lambda { |lang_identifier|
                                  language = Language[lang_identifier]
                                  condition = "accounts.active = 1"
                                  condition += " and qualifications.language_id = #{language.id}" if language.present?
                                  where(condition).joins(:qualifications)
                                }
  default_scope :conditions => "rs_email != '#{FALSE_COACH_EMAIL}'"

  def self.sort_by_name(coaches)
    coaches.blank? ? [] : coaches.sort! { |a, b| a.full_name.strip.downcase <=> b.full_name.strip.downcase }
  end

  def self.orphaned_coaches
    where("manager_id is NULL").order('trim(full_name)').select(&:qualification)
  end

  def is_my_session?(session)
    (self == session.coach)
  end

  def is_only_aria?
    !languages.any? { |lang| lang.is_totale? || lang.is_lotus? }
  end

  def is_aria?
    languages.collect(&:type).include?("AriaLanguage")
  end

  def is_totale_aria?
    languages.collect(&:type).include?("TotaleLanguage") & has_one_hour?
  end

  def is_totale?
    languages.collect(&:type).include?("TotaleLanguage")
  end

  def is_tmm?
    languages.collect(&:type).include?("TMMPhoneLanguage") || languages.collect(&:type).include?("TMMLiveLanguage") || languages.collect(&:type).include?("TMMMichelinLanguage")
  end

  def is_tmm_phone?
    languages.collect(&:type).include?("TMMPhoneLanguage")
  end

  def is_tmm_live?
    languages.collect(&:type).include?("TMMLiveLanguage")
  end

  def is_tmm_michelin?
    languages.collect(&:type).include?("TMMMichelinLanguage")
  end

  def has_one_hour?
    is_aria? || is_tmm_live? || is_tmm_michelin?
  end

  def is_supersaas?
    is_aria? || is_tmm_michelin? || is_tmm_phone?
  end

  def self.substitution_grabbed(coach_id, start_date, end_date, language)
    coach_id = AppUtils.array_to_single_quotes(coach_id)
    language = AppUtils.array_to_single_quotes(language)
    sub_grab_query =" SELECT  coach_id
        ,CASE WHEN status = 'G' THEN count ELSE 0 END AS grabber
        ,CASE WHEN status = 'R' THEN count ELSE 0 END AS requested

        FROM
        ( SELECT c.full_name AS full_name
         ,c.id AS coach_id
         ,COUNT(DISTINCT subs.id) AS count
         , 'R' AS status
         FROM accounts c

         LEFT JOIN substitutions AS subs ON c.id = subs.coach_id
         JOIN coach_sessions cs1 ON subs.coach_session_id = cs1.id

         WHERE c.id IN (#{coach_id})
         AND #{Coach.in_time_range('cs1', start_date, end_date)}
         AND cs1.language_identifier IN(#{language})
         AND subs.was_reassigned != 1
         GROUP BY c.id

        UNION

         SELECT c.full_name AS full_name
         ,c.id AS coach_id
         ,COUNT(DISTINCT grabs.id) AS count
         , 'G' AS status
         FROM accounts c

         LEFT JOIN substitutions AS grabs ON c.id = grabs.grabber_coach_id
         JOIN coach_sessions cs2 ON grabs.coach_session_id = cs2.id

         WHERE c.id IN (#{coach_id})
         AND #{Coach.in_time_range('cs2', start_date, end_date)}
         AND cs2.language_identifier IN(#{language})
         AND grabs.grabbed = 1
         AND grabs.was_reassigned != 1

         GROUP BY c.id
        ) AS subs_grabbed_and_requested"
    find_by_sql(sub_grab_query)
  end

  def self.find_coaches_based_on_lang_and_region(lang_identifier, region = nil)
    lang_identifier = Language.all.collect(&:identifier) if lang_identifier == "all"
    lang_to_string = AppUtils.array_to_single_quotes(lang_identifier)
    region_condition = "AND c.region_id = #{region}" unless region.blank?
    query = "Select distinct c.id as id,c.full_name as full_name FROM accounts c 
             JOIN qualifications q ON c.id = q.coach_id JOIN languages l ON l.id = q.language_id 
             AND c.type = 'Coach' AND c.active = 1 WHERE l.identifier IN (#{lang_to_string}) #{region_condition}"
    Coach.find_by_sql(query)
  end

  #lang_identifier expected is an array region_condition is empty by default
  def self.coach_ids_of_that_language(lang_identifiers, start_date, end_date, region_condition="")
    region_condition = "AND c.region_id = #{region_condition}" unless region_condition.blank?
    lang_identifiers=AppUtils.array_to_single_quotes(lang_identifiers)
    coach_ids_of_that_language = "SELECT distinct c.id AS id, c.full_name AS full_name FROM accounts c
    JOIN qualifications q ON c.id = q.coach_id JOIN languages l ON l.id = q.language_id WHERE l.identifier IN(#{lang_identifiers}) 
    AND c.type = 'Coach' AND q.max_unit IS NOT NULL AND c.active = 1 #{region_condition}
    UNION 
    Select distinct cs.coach_id as id,c.full_name as full_name
    FROM coach_sessions cs JOIN accounts c on cs.coach_id=c.id  where cs.session_start_time >= '#{start_date}'
    AND cs.session_start_time < '#{end_date}' AND cs.language_identifier IN(#{lang_identifiers}) 
    AND cs.cancelled=0 AND cs.coach_id is not null #{region_condition}"
    Coach.find_by_sql(coach_ids_of_that_language)
  end

  def self.time_off(coach_id, start_date, end_date)
    coach_id = AppUtils.array_to_single_quotes(coach_id)
    time_off_query = "SELECT c.full_name AS full_name
      ,c.id AS coach_id
      ,COUNT(DISTINCT req_time_offs.id) AS time_offs_requested
      ,COUNT(DISTINCT CASE WHEN (req_time_offs.approval_status = 1) THEN req_time_offs.id END) AS time_offs_approved
      ,COUNT(DISTINCT CASE WHEN (req_time_offs.approval_status = 2) THEN req_time_offs.id END) AS time_offs_denied
      ,SUM(CASE WHEN (req_time_offs.approval_status = 1) THEN TIME_TO_SEC(TIMEDIFF(LEAST(req_time_offs.end_date,'#{end_date}'), GREATEST(req_time_offs.start_date,'#{start_date}'))) ELSE 0 END ) AS total_time_off

      FROM accounts c

      LEFT JOIN unavailable_despite_templates req_time_offs ON c.id = req_time_offs.coach_id
        AND req_time_offs.unavailability_type = 0
        AND #{Coach.time_off_falls_in('req_time_offs', start_date, end_date)}

      WHERE c.id IN (#{coach_id})
      GROUP BY c.id"
    find_by_sql(time_off_query)
  end

  def self.time_off_falls_in(udt_table_alias, from, to)
    "(#{udt_table_alias}.end_date >= '#{from}' AND #{udt_table_alias}.start_date <= '#{to}')"
  end

  def self.all_qualified_for_language(language_id)
    join = "INNER JOIN qualifications on qualifications.coach_id = accounts.id"
    where("active = 1 and qualifications.language_id = ? and max_unit > ?", language_id, 0).select('accounts.id, full_name').joins(join).order('trim(full_name)')
  end

  def self.in_time_range(table_alias, from, to)
    return "(#{table_alias.to_s}.session_start_time >= '#{from}' AND #{table_alias.to_s}.session_start_time < '#{to}')"
  end

  def self.max_unit(coach_id, language_id)
    qul = Qualification.where('max_unit IS NOT NULL AND coach_id = ? AND language_id = ?', coach_id, language_id).select('max_unit').last
    qul.max_unit if qul
  end

  # don't want to use the association to get one session
  def session_on(start_date, end_date=nil)
    session = sessions_between_time_boundries(start_date, end_date).last
    return session if session
    if has_one_hour? & (start_date.min == 30) # To check aria session starting from previous slot 
      session = sessions_between_time_boundries(start_date - 30.minutes).last
      return session ? (session.is_one_hour? ? session : nil) : nil
    end
  end

  def is_timed_off_at?(datetime)
    time_off_at(datetime).present?
  end

  def time_off_at(datetime)
    UnavailableDespiteTemplate.where('coach_id = ? AND approval_status = 1 AND unavailability_type = 0 AND start_date <= ? AND end_date >=  ?', self.id, datetime, datetime + duration_in_seconds).last
  end

  def update_time_off(session)
    udt = time_off_at(session.session_start_time)
    udt_other_half = time_off_at(TimeUtils.return_other_half(session.session_start_time)) if session.is_one_hour?
    if udt_other_half && udt
      time_off_operations(udt, session.session_start_time, session.session_end_time)
    elsif udt
      time_off_operations(udt, session.session_start_time, session.session_start_time+30.minutes)
    elsif udt_other_half
      #delete the udt if it is just for that second half slot. Else update the start time and leave it
      (udt_other_half.end_date == session.session_end_time) ? udt_other_half.destroy : udt_other_half.update_attribute(:start_date, session.session_end_time)
    end
    udt
  end

  def time_off_operations(udt, start_time, end_time)
    if udt.start_date == start_time && udt.end_date == end_time
      udt.destroy
    elsif udt.start_date == start_time
      udt.update_attribute(:start_date, end_time)
    elsif udt.end_date == end_time
      udt.update_attribute(:end_date, start_time)
    else
      new_udt = udt.clone
      new_udt.start_date = end_time
      udt.update_attribute(:end_date, start_time) if new_udt.save
    end
  end

  def get_affected_session_count(start_date, end_date, approval_status)
    if approval_status != 1
      scheduled_session_count = CoachSession.where("cancelled = 0 and coach_id = ? AND ((session_start_time >= ? AND session_start_time < ?) OR (language_identifier in ('AUS','AUK') AND (session_start_time = ? OR session_end_time = ?))) ", id, start_date, end_date, start_date - 30.minutes, end_date + 30.minutes).count
    else
      cancelled_session_count = CoachSession.where("cancellation_reason = 'Time Off' AND coach_id = ? AND ((session_start_time >= ? AND session_start_time < ?) OR (language_identifier in ('AUS','AUK') AND (session_start_time = ? OR session_end_time = ?))) ", id, start_date, end_date, start_date - 30.minutes, end_date + 30.minutes).count
      query = "select * from substitutions,coach_sessions where coach_sessions.id = substitutions.coach_session_id
    and substitutions.coach_id = #{id} and coach_sessions.session_start_time >= '#{start_date}' and coach_sessions.session_end_time <= '#{end_date}' 
    and substitutions.reason = 'Time Off'"
      one_hour_langs = (AriaLanguage.all + TMMLiveLanguage.all + TMMMichelinLanguage.all).map { |lang| "\'"+lang.identifier+"\'" }.join(",")
      aria_edge_query = "select * from substitutions,coach_sessions where coach_sessions.id = substitutions.coach_session_id
    and substitutions.coach_id = #{id} and coach_sessions.language_identifier in (#{one_hour_langs}) and (coach_sessions.session_start_time = '#{start_date - 30.minutes}' or coach_sessions.session_end_time = '#{end_date + 30.minutes}')
    and substitutions.reason = 'Time Off'" # To include aria sub-requests when time off starts at mid of aria session
      sub_session_count = Substitution.find_by_sql(query).count
      aria_sub_session_count = Substitution.find_by_sql(aria_edge_query).count
    end


    total_affected_session_count = scheduled_session_count.to_i + sub_session_count.to_i + cancelled_session_count.to_i + aria_sub_session_count.to_i
    total_affected_session_count
  end

  def can_create_recurring_session?(datetime, is_one_hour_session, is_one_hour_coach)
    availability = !has_session_between?(datetime) && !is_timed_off_at?(datetime) && having_availability_at?(datetime)
    if availability && is_one_hour_coach
      if is_one_hour_session
        !has_session_between?(TimeUtils.return_other_half(datetime)) && !is_timed_off_at?(TimeUtils.return_other_half(datetime)) && having_availability_at?(TimeUtils.return_other_half(datetime))
      elsif datetime.min == 30
        !sessions_between_time_boundries(TimeUtils.return_other_half(datetime)).first.try(:is_one_hour?)
      else
        availability
      end
    else
      availability
    end
  end

  def create_availability_for_slot(datetime)
    template = active_template_on_the_time(datetime)
    if template
      avail_start_time = datetime + TimeUtils.daylight_shift(template.created_at, datetime)
      av = template.create_availilability(avail_start_time, avail_start_time + duration_in_seconds, true)
      error = av.errors.full_messages.join(',') if !av.errors.blank?
    else
      error = 'This coach has no template. So recurring session cannot be created. Please create a template.'
    end
    error.to_s
  end

  def max_unit
    self['max_unit'] ||= 0
  end

  def next_session
    now = Time.now.utc
    CoachSession.where("coach_id = ? AND session_start_time < ? AND session_start_time >= ? AND cancelled = ? AND session_status = 1", id, now + get_preference.session_alerts_display_time.minutes, now, false).order('session_start_time').first
  end

  def qualification_for_language(lang_id)
    self.qualifications.find_by_language_id(lang_id)
  end

  # If max unit of coach = 10, {:level => 3, :unit => 2 }
  def max_level_unit_qualification_for_language(lang_dentifier)
    qualification = qualification_for_language(Language[lang_dentifier].id)
    CurriculumPoint.level_and_unit_from_single_number_unit(qualification.max_unit)
  end

  def duration_in_seconds
    30.minutes
  end

  def qualification
    qualifications.first
  end

  def all_languages
    @lang_ids ||= self.languages.collect(&:id)
  end

  def all_language_identifier
    @lang_identifier ||= self.languages.collect(&:identifier)
  end

  def aria_language
    self.languages.each do |lang|
      return lang.identifier if lang.is_aria?
    end
  end

  # Helper method to collect coach's languages while calling e-school api. ARIA languages excluded here.
  def all_languages_and_max_unit
    languages_array = []
    self.qualifications(true).each do |qual|
      languages_array << {:language_identifier => qual.language.identifier, :max_unit => qual.max_unit} unless qual.language.is_aria? || qual.language.is_tmm?
    end
    languages_array
  end

  def all_languages_and_max_unit_hash
    languages_hash = {}
    self.qualifications(true).each do |qual|
      languages_hash["#{qual.language.identifier}"] = qual.max_unit.to_s
    end
    languages_hash
  end

  def email
    rs_email
  end

  def check_previous_slot_for_session(time)
    lang_ids = Language.find_all_by_duration(60).collect(&:identifier)
    CoachSession.where(["coach_id = ? and session_start_time = ? and language_identifier in (?) and type != 'appointment'", id, time - 30.minutes, lang_ids]).order("cancelled, id DESC").first if time.min == 30
  end

  def check_previous_slot_for_substitution(time)
    substitution = Substitution.where(["substitutions.coach_id = ? and coach_sessions.session_start_time = ? and substitutions.grabbed = ?", id, time - 30.minutes, false]).joins("INNER JOIN coach_sessions on coach_sessions.id = substitutions.coach_session_id").last if time.min == 30
    return (substitution.try(:coach_session).try(:is_one_hour?) ? substitution : nil)
  end

  def current_session(session_hash, datetime)
    aria_session = @sessions.select { |ses| (ses.session_start_time == (datetime - 30.minutes) && ses.is_one_hour?) }.sort_by { |s| s.updated_at }.reverse.first if datetime.min == 30
    session = (session_hash[datetime.to_i] ? [session_hash[datetime.to_i], false] : nil)
    if aria_session && session
      return aria_session.created_at > session[0].created_at ? [aria_session, true] : session
    else
      return session || [aria_session, true]
    end
  end

  def schedule_details_for_week(date = nil, languages = self.languages)
    week_extremes = TimeUtils.week_extremes_for_user(date)
    start_of_the_week = week_extremes[0].utc
    end_of_the_week = week_extremes[1].utc
    lang_ids = languages.collect { |lang| lang.id }
    appointment_eligible_languages_ids = fetch_eligible_languages(languages).collect(&:id)
    slot_duration = duration_in_seconds
    data = []
    time_offs = []
    sub_sessions = []
    session_hash = {}
    unavailability_hash = {}
    recurrings = CoachRecurringSchedule.where("coach_id = ? and recurring_start_date <= ? and (recurring_end_date IS NULL or recurring_end_date > ?)", self.id, end_of_the_week, start_of_the_week).includes(:language).order('recurring_start_date DESC')
    udts = UnavailableDespiteTemplate.where("unavailability_type != 3 and approval_status = 1 and coach_id = ? and start_date <= ? and end_date >= ?", self.id, end_of_the_week, start_of_the_week).includes(:coach_session).order("updated_at")
    backearly = UnavailableDespiteTemplate.where("unavailability_type = 3 and coach_id = ? and start_date <= ? and end_date >= ?", self.id, end_of_the_week, start_of_the_week).order("updated_at")
    udts.each do |udt|
      if udt.unavailability_type == 0
        time_offs << udt
      elsif udt.coach_session
        sub_sessions << udt.coach_session
        unavailability_hash[udt.coach_session.id] = udt
      end
    end
    sub_sessions.uniq!
    confirmed_sessions = ConfirmedSession.where("coach_id = ? and session_start_time >= ? and session_start_time < ?", self.id, start_of_the_week, end_of_the_week).includes(:language).order("updated_at")
    cancelled_sessions = confirmed_sessions.select { |session| session.cancelled }
    non_cancelled_session = confirmed_sessions - cancelled_sessions
    local_sessions = LocalSession.edited_for_week_and_coach(start_of_the_week, id)
    appointments = Appointment.where("coach_id = ? and session_start_time >= ? and session_start_time < ?", self.id, start_of_the_week, end_of_the_week).includes(:language).order("updated_at")
    solid_sessions = sub_sessions + non_cancelled_session + local_sessions
    @sessions = cancelled_sessions + solid_sessions + appointments
    @sessions.each { |session| session_hash[session.session_start_time.to_i] = session }
    scheduled_hrs = 0
    non_cancelled_session.each do |ncs|
      if Language.find_by_id(ncs.language_id).duration == 30
        scheduled_hrs += 0.5
      else
        scheduled_hrs += 1
      end
    end
    sub_request_session = sub_sessions - cancelled_sessions
    sub_request_cancelled_sessions = []
    sub_request_session.delete_if do |sess| 
      (sub_request_cancelled_sessions << sess if (sess.cancelled && !sess.appointment?)) || (sess.appointment?)
    end
    session_count = {
      :scheduled => non_cancelled_session.size,
      :cancelled => (cancelled_sessions + sub_request_cancelled_sessions).size,
      :sub_requested => sub_request_session.size,
      :scheduled_hours => scheduled_hrs
    }
    unless is_aria? || is_tmm?
      eschool_ids = solid_sessions.collect { |session| session.eschool_session_id if lang_ids.include?(session.language_id) }.compact
      unless eschool_ids.blank?
        es_sessions = ExternalHandler::HandleSession.find_sessions(TotaleLanguage.first, {:ids =>eschool_ids})
        unless es_sessions.blank?
          es_sessions.each do |es|
            csp_session = session_hash[es.start_time.to_time.to_i]
            csp_session.sess = es if csp_session && (csp_session.eschool_session_id == es.eschool_session_id.to_i)
          end
        end
      end
    end
    slot_time = week_extremes[0]
    while slot_time < week_extremes[1]
      slot_details = ["", ""]
      crs = nil
      session_on_slot = nil
      datetime = slot_time.utc
      datetime_end = datetime + slot_duration
      datetime_int = datetime.to_i
      if TimeUtils.daylight_shift(datetime - 1.hour, datetime) != -1.hour #EDT to EST
        if TimeUtils.daylight_shift(datetime-1.minute, datetime) == 1.hour #EST to EDT
          data << {:start_time => (datetime-1.minute).to_i, :end_time => datetime_int, :label => "<b>Daylight Switch</b>", :slot_type => "daylight_switch"}
        end
        time_off = time_offs.detect { |u| u.start_date <= datetime && u.end_date >= datetime_end }
        if time_off
          slot_details[0] = 'Time off'
          slot_details[1] = "cs_time_off_slot"
        else
          session_on_slot, duration_check = current_session(session_hash, datetime)
          unless session_on_slot.blank?
            udt = unavailability_hash[session_on_slot.id]
            if session_on_slot.coach_id == id
              if session_on_slot.is_cancelled?
                slot_details[0] = "Cancelled"
                slot_details[1] = "cs_cancelled"
              else
                datetime_end = datetime + session_on_slot.duration_in_seconds
                if !session_on_slot.appointment? && lang_ids.include?(session_on_slot.language_id)
                  slot_details[0] = session_on_slot.label_for_active_session
                  if session_on_slot.reassigned == true
                    slot_details[1] = "cs_reassigned_session_slot"
                  else
                    slot_details[1] = "cs_solid_session_slot"
                  end
                elsif session_on_slot.appointment? && appointment_eligible_languages_ids.include?(session_on_slot.language_id)
                  slot_details[0] = session_on_slot.label_for_active_session
                  slot_details[1] = (session_on_slot.reassigned == true) ? "cs_reassigned_appointment_session_slot" : "cs_appointment_session_slot"
                else
                  slot_details[0] = "Conflict"
                end
              end
            else
              if udt
                if lang_ids.include?(session_on_slot.language_id)
                  slot_details = session_on_slot.label_for_substitution(UNAVAILABILITY_TYPE[udt.unavailability_type], id)
                else
                  slot_details[0] = "Conflict"
                end
              end
            end
          end
        end

        if slot_details[0].blank? || slot_details[0] == "Cancelled"
          if filter_avail_for_slot(datetime)
            crs = filter_recurring_for_slot(datetime, recurrings)
            if crs && datetime > TimeUtils.end_of_week(crs.language.last_pushed_week)
              if lang_ids.include?(crs.language_id)
                if slot_details[0].blank? || udt.blank? || (slot_details[0] == "Cancelled" && (crs.language != session_on_slot.language || crs.recurring_start_date <= crs.language.last_pushed_week))
                  datetime_end = datetime + (crs.recurring_type != 'recurring_appointment' ? crs.language.duration_in_seconds : 30.minutes)
                  slot_details[0] = crs.label_for_active_recurring
                  slot_details[1] = crs.recurring_type != 'recurring_appointment' ? "cs_recurring_slot" : 'cs_appointment_recurring_session_slot'
                end
              else
                slot_details[0] = "Conflict"
              end
            elsif slot_details[0].blank?
              slot_details[0] = "Available"
              slot_details[1] = "cs_available_slot"
            end
          end
        end
      end
      if !slot_details[0].blank?
        data << {:start_time => datetime_int, :end_time => (datetime_end-1.minute).to_i, :label => slot_details[0], :slot_type => slot_details[1]} if slot_details[0] != "Conflict"
      end
      if session_on_slot && !session_on_slot.is_cancelled? && is_my_session?(session_on_slot)
        slot_time += session_on_slot.duration_in_seconds
      elsif crs
        if (time_offs.detect { |u| u.start_date <= datetime+30.minutes && u.end_date >= datetime_end+30.minutes } && crs.language.duration_in_seconds > slot_duration) ||
            (@sessions.detect { |u| u.session_start_time <= datetime+30.minutes && u.session_end_time >= datetime_end+30.minutes } && crs.language.duration_in_seconds > slot_duration) ||
            (backearly.detect { |u| u.start_date <= datetime+30.minutes && u.end_date >= datetime_end+30.minutes } && crs.language.duration_in_seconds > slot_duration && crs.language.last_pushed_week >= week_extremes[0])
          slot_time += slot_duration
        else
          slot_time += (crs.recurring_type == 'recurring_appointment' ? 30.minutes : crs.language.duration_in_seconds)
        end
      elsif udt
        slot_time += slot_duration
      else
        slot_time += session_on_slot.try(:duration_in_seconds) || slot_duration
      end
    end
    return data, session_count
  end

  def filter_avail_for_slot(datetime)
    template_for_day = active_template_on_the_time(datetime)
    return nil if template_for_day.nil?
    template_for_day.filter_avail_for_slot(datetime)
  end

  def filter_recurring_for_slot(datetime, recurrings)
    recurring = recurrings.detect { |rec| (rec.day_index == datetime.wday) && (rec.start_time == ('2000-01-01 '+datetime.strftime('%T')).to_time) && TimeUtils.daylight_shift(rec.recurring_start_date, datetime) == 0 }
    possible_shift = TimeUtils.possible_daylight_shift(datetime)
    if recurring.nil? && possible_shift != 0
      datetime = datetime + possible_shift
      recurring = recurrings.detect { |rec| (rec.day_index == datetime.wday) && (rec.start_time == ('2000-01-01 '+datetime.strftime('%T')).to_time) && TimeUtils.daylight_shift(rec.recurring_start_date, datetime) == possible_shift }
    end
    return recurring
  end

  def availlbility_for_week(start_of_the_week, language)
    avail_for_week = Hash.new { |hash, key| hash[key] = [] }
    schedule_details_for_week(start_of_the_week).each do |schedule|
      if ["cs_available_slot"].include?(schedule[:slot_type])
        start_time = TimeUtils.time_in_user_zone(schedule[:start_time])
        avail_for_week[start_time.wday] << start_time
        avail_for_week[start_time.wday] << (TimeUtils.time_in_user_zone(schedule[:end_time]) + 1.minute)
      end
    end

    session_details = []
    7.times do |i|
      data = avail_for_week[i].select { |elem| avail_for_week[i].count(elem) == 1 }
      index = 0
      while index < (data.size-1) do
        #For ARIA language in master scheduler, coach availability must show 
        #availabilities only more than or equal to one hour
        if Language.find_by_identifier(language).is_one_hour?
          data[index]+=30.minutes if data[index].min == 30 #change coach availailities, showing start time and end times in hourly durations
          data[index+1]-=30.minutes if data[index+1].min == 30
          if data[index] == data[index+1] #if half hour coach availability, skip it, cos we are checking for aria language here
            index +=2
            next
          end
        end
        session_details << data[index].strftime("%A") + " " + data[index].strftime("%I:%M%p") + " - " + data[index+1].strftime("%I:%M%p")
        index = index + 2
      end
    end
    session_details
  end

  def is_availabile_at_slot?(datetime)
    return false if !having_availability_at?(datetime)
    return false if has_session_between?(datetime)
    return false if has_recurring_at?(datetime)
    return false if is_timed_off_at?(datetime)
    return true
  end

  def has_recurring_at?(datetime)
    !CoachRecurringSchedule.for_coach_and_datetime(self.id, datetime).blank?
  end

  def has_recurring_without_udt?(datetime)
    has_recurring_at?(datetime) && !availability_modifications.between(datetime, datetime+30.minutes).not_denied.approved.present?
  end

  def recurring_conflicts_for_one_hour?(datetime, language)
    crs = CoachRecurringSchedule.for_coach_and_datetime(self.id, TimeUtils.return_other_half(datetime))
    (datetime.min == 30 && crs && crs.language.is_one_hour?) || (language.is_one_hour? && crs) ? true : false
  end

  def has_recurring_schedule_conflict?(datetime, language)
    has_recurring_at?(datetime) || recurring_conflicts_for_one_hour?(datetime, language)
  end

  def can_grab_recurring(datetime, language, session_type = 'ConfirmedSession')
    # this method will check if the coach will be able to grab a substitution, considering the recurrings for the coach
    (!has_recurring_schedule_conflict?(datetime, language)) || (has_recurring_schedule_conflict?(datetime, language) && has_udt_at(datetime, language, session_type))
  end

  def has_udt_at(start_time, language, session_type = 'ConfirmedSession')
    end_time = start_time + (session_type == 'Appointment' ? 30.minutes : language.duration.minutes)
    availability_modifications.between(start_time, end_time).not_denied.approved.present?
  end

  # find availability as per template, doesn't check session or recurring or time off
  def having_availability_at?(datetime)
    !CoachAvailability.for_coach_and_datetime(id, datetime).blank?
  end

  def approved_templates
    self.availability_templates.approved
  end

  def approved_templates_for_language_start_time
    self.availability_templates.approved_for_language_start_time
  end

  def next_active_template(date)
    self.approved_templates.reverse.detect { |t| t.effective_start_date > date }
  end

  # Returns sessions starting from "start date" and ending before "end_date"
  def sessions_between_time_boundries(start_time, end_time = nil)
    end_time = start_time + duration_in_seconds - 1.minute if end_time.nil?
    condition = ["cancelled = ? AND coach_id = ? AND session_start_time >= ? AND session_start_time < ?", false, id, start_time, end_time]
    confirmed_sessions = ConfirmedSession.where(condition).includes(:language)
    confirmed_sessions += Appointment.where(condition).includes(:language)
    condition[0] += " AND action != 'create'"
    confirmed_sessions += LocalSession.where(condition).joins(:session_metadata).includes(:language)
    confirmed_sessions.delete_if { |session| session.is_cancelled? }
    confirmed_sessions.sort_by(&:session_start_time)
  end

  def session_cancelled_at_eschool?(start_time)
    end_time = start_time + duration_in_seconds - 1.minute
    condition = ["cancelled = ? AND coach_id = ? AND session_start_time BETWEEN ? AND ?", false, id, start_time, end_time]
    confirmed_sessions = ConfirmedSession.where(condition).includes(:language)
    confirmed_sessions.select { |session| session.is_cancelled? }
    confirmed_sessions.sort_by(&:session_start_time)
  end

  def has_session_between?(start_date, end_date = nil)
    !sessions_between_time_boundries(start_date, end_date).empty?
  end

  def has_one_hour_session_between?(slot_time, language)
    # has_session_between checks for the conflicts on the other half.
    # Conflict is said to be true in the following cases
    # When called for second half slot, if there is a one hour session covering that slot
    # When called with a one-hour language ( thus always for a first half slot ), if there is a session on the second half
    sessions = sessions_between_time_boundries(TimeUtils.return_other_half(slot_time))
    (slot_time.min == 30 && !sessions.select { |sess| sess.is_one_hour? }.empty?) || (language.is_one_hour? && !sessions.empty?) ? true : false
  end

  def has_session_conflict?(slot_time, language, is_appointment=false)
    ret = has_session_between?(slot_time)
    ret ||= has_one_hour_session_between?(slot_time, language) if !is_appointment
    ret
  end

  def active_template_on_the_time(datetime)
    self.approved_templates.detect { |t| t.effective_start_date.to_time <= TimeUtils.time_in_user_zone(datetime.to_time).end_of_day }
  end

  def valid_user?
    hire_date_not_in_future && email_validations && check_mandatory_fields && good_phone_numbers && validate_mobile_country_code && validate_primary_country_code
    errors.empty? && qualifications.any?
  end

  def is_excluded?(coach_session)
    excluded_list = coach_session.excluded_coaches.collect(&:id)
    excluded_list.include?(self.id)
  end

  def can_grab?(substitution)
    session = substitution.coach_session
    flag = active && !session_on(session.session_start_time, session.session_end_time) && can_grab_recurring(session.session_start_time, session.language, session.type)
    if session.appointment?
      flag && appointment_eligibility?(session.language_identifier, languages.map(&:identifier))
    else
      flag && (session.eschool_session_unit.to_i <= Coach.max_unit(id, session.language_id).to_i) &&
          ((session.session_start_time <= (Time.now.utc + LanguageSchedulingThreshold.get_hours_prior_to_sesssion_override(session.language_id).hours)) ||
              !threshold_reached?(session.session_start_time).detect { |x| x===true })
    end

  end

  def threshold_reached?(start_time)
    start_time = TimeUtils.beginning_of_week(start_time)
    end_time = start_time + 1.week - 1.minute
    subbed_slot_count = get_number_of_slots(Substitution.get_grabbed_uncancelled_substitutions_for_a_coach_within_a_week_for_all_languages(self.id, start_time, end_time))
    confirmed_slot_count = get_number_of_slots(self.confirmed_coach_sessions.where("session_start_time >= ? and session_start_time <= ? ", start_time, end_time))
    #((subbed_slot_count >= thresholds.max_grab) || ( confirmed_slot_count >= thresholds.max_assignment))
    return (subbed_slot_count >= thresholds.max_grab), (confirmed_slot_count >= thresholds.max_assignment)
  end

  def appointment_eligibility?(sub_lang, coach_eligible_lang)
    lang_map = {
        :'1' => %w(TMM-FRA-L TMM-FRA-P TMM-MCH-L),
        :'2' => %w(TMM-NED-L TMM-NED-P),
        :'3' => %w(TMM-ENG-L TMM-ENG-P),
        :'4' => %w(TMM-DEU-L TMM-DEU-P),
        :'5' => %w(TMM-ITA-L TMM-ITA-P),
        :'6' => %w(TMM-ESP-L TMM-ESP-P)
    }

    eligible_lang = nil
    lang_map.each do |k, v|
      eligible_lang = v if v.include?(sub_lang)
      break unless eligible_lang.blank?
    end
    common_lang = eligible_lang & coach_eligible_lang
    !common_lang.blank?
  end

  def get_number_of_slots(sessions)
    count=0
    sessions.each do |sess|
      count += sess.is_one_hour? ? 2 : 1
    end
    return count
  end

  def self.coach_list_for_language_and_region(language="", region="")
    language_condition = language.blank? ? "" : "HAVING LOCATE('#{language}', group_concat(identifier)) > 0"
    region_condition = region.blank? ? "" : "AND r.id = '#{region}'"
    query = %Q(SELECT c.*, r.name as hub_city, group_concat(identifier) as lang_list
                FROM accounts c
                LEFT JOIN qualifications q ON c.id = q.coach_id
                LEFT JOIN languages l ON l.id = q.language_id
                LEFT JOIN regions r ON r.id = c.region_id
                WHERE c.type = 'Coach' AND q.max_unit IS NOT NULL AND c.active = 1 #{region_condition}
                GROUP BY c.id #{language_condition} ORDER BY trim(c.full_name); )
    Coach.find_by_sql(query)
  end

  def detect_availability_change_for_slot_in_future(slot_time)
    next_template = next_active_template(slot_time)
    return false unless next_template
    until slot_time >= next_template.effective_start_date do
      next_time = slot_time + 1.week
      if next_time.to_time.in_time_zone(time_zone).gmt_offset != slot_time.to_time.in_time_zone(time_zone).gmt_offset
        next_time = next_time + 1.week if (slot_time.to_time.in_time_zone(time_zone).hour == 2 && slot_time.to_time.in_time_zone(time_zone).wday == 0)
        slot_time = next_time - (next_time.to_time.in_time_zone(time_zone).gmt_offset - slot_time.to_time.in_time_zone(time_zone).gmt_offset)
      else
        slot_time = next_time
      end
    end
    return (next_time - 1.week) unless CoachAvailability.for_datetime_and_template(slot_time, next_template)
    detect_availability_change_for_slot_in_future(slot_time)
  end

  def thresholds
    LanguageSchedulingThreshold.where(["language_id in (?)", self.qualifications.collect(&:language_id)]).select("MAX(max_assignment) AS max_assignment, MAX(max_grab) AS max_grab").last
  end

  def coach_manager
    coach_contact.coach_manager if coach_contact
  end

  def supervisor
    coach_contact.supervisor if coach_contact
  end

  def update_or_create_qualification(language_id, max_unit, dialect_id = nil)
    qual = qualifications.detect { |q| q.language_id == language_id }
    if qual
      qual.update_max_unit(max_unit) if qual.max_unit != max_unit
      qual.update_attribute(:dialect_id, dialect_id) if dialect_id && (qual.dialect_id != dialect_id)
    else
      qual = qualifications.create(:language_id => language_id, :max_unit => max_unit, :dialect_id => dialect_id)
    end
    qual.errors.to_a.each { |msg| errors.add(:base, msg) }
  end

  def create_or_update_outside_csp(action=nil)
    ExternalHandler::HandleCoach.create_or_update_coach(self, action)
  end

  def has_a_udt?(time_slot, time_duration_in_minutes, options = {})
    if options[:time_off]

    end

  end

  def is_free_in_this_slot?(time_slot, time_duration_in_minutes, options = {})
    # pass time-slot in utc
    !has_session_between?(time_slot, time_slot + time_duration_in_minutes.minutes) &&
        !has_a_udt?(time_slot, time_duration_in_minutes, options = {})
  end

  def is_available_in_this_slot?(time_slot, time_duration_in_minutes, options = {})
    is_free_in_this_slot?(time_slot, time_duration_in_minutes, options) && has_a_marked_availability?
  end
end
