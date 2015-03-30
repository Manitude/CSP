
# == Schema Information
#
# Table name: coach_recurring_schedules
#
#  id                   :integer(4)      not null, primary key
#  coach_id             :integer(4)      not null
#  day_index            :integer(1)      not null
#  start_time           :time            not null
#  recurring_start_date :datetime        not null
#  recurring_end_date   :datetime
#  language_id          :integer(4)      not null
#  external_village_id  :integer(4)
#  created_at           :datetime
#  updated_at           :datetime
#


class CoachRecurringSchedule < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
  self.include_root_in_json = false


  belongs_to :coach
  belongs_to :language
  belongs_to :appointment_type

  before_create :stop_previous_recurring_for_coach_if_any

  scope :by_session_type, lambda { |session_type| where(:recurring_type => session_type) }
  
  def recurring_start_time
    self['recurring_start_time'].to_time
  end

  def count_of_sessions
    self['count_of_sessions'].to_i
  end

  def scheduled_time
    self['schedule_time'].to_time
  end

  def appointment?
    self['recurring_type'] == 'recurring_appointment'
  end

  def display_name_in_upcoming_classes
    if appointment?
      language.display_name_without_type + " - " + AppointmentType.find(appointment_type_id).title
    else
      language.display_name
    end
  end

  def self.for_coach_and_datetime(coach_id, datetime, language_id = nil)
    condition = "coach_id = ? and day_index = ? and start_time = ? and recurring_start_date <= ? and (recurring_end_date IS NULL or recurring_end_date >= ?)"
    condition += " and language_id in (#{language_id.join(',')})" if language_id
    crs = CoachRecurringSchedule.where([condition, coach_id, datetime.wday, datetime.strftime("%T"), datetime, datetime]).order('recurring_start_date').last
    return crs if crs && TimeUtils.daylight_shift(crs.recurring_start_date, datetime) == 0

    possible_shift = TimeUtils.possible_daylight_shift(datetime)
    if possible_shift != 0
      datetime = datetime + possible_shift
      crs = CoachRecurringSchedule.where([condition, coach_id, datetime.wday, datetime.strftime("%T"), datetime, datetime]).order('recurring_start_date').last
      return crs if crs && TimeUtils.daylight_shift(crs.recurring_start_date, datetime) == possible_shift
    end
    return nil
  end

  def stop_previous_recurring_for_coach_if_any
    recurring_schedule = CoachRecurringSchedule.for_coach_and_datetime(coach_id, recurring_start_date)
    recurring_schedule.update_attributes(:recurring_end_date => recurring_start_date - 1.week) if recurring_schedule
  end

  def self.fetch_for(start_time, end_time, language_id, external_village_id_str = 'all')
    language = Language.find_by_id(language_id)
    slot_duration = end_time > AppUtils.wc_release_date ? 30 : 60
    all_coach_ids = language.coaches.map(&:id)
    all_coach_ids_with_template_switch = CoachAvailabilityTemplate.coaches_with_template_switch_in_week(start_time, end_time) & all_coach_ids
    all_coach_ids_without_template_switch = all_coach_ids - all_coach_ids_with_template_switch
    recurring_schedules_for_week = []
    recurring_schedules_for_week += fetch_recurring_schedules(start_time.to_s(:db), end_time.to_s(:db), start_time.strftime("%F") + " ", language_id, external_village_id_str, all_coach_ids_without_template_switch, slot_duration)
    AppUtils.dates_for_the_week(start_time).each do |week_day|
      interval_condition = "AND schedule_time BETWEEN '#{(week_day).to_s(:db)}' AND '#{(week_day + 1.day - 1.minute).to_s(:db)}'"
      recurring_schedules_for_week += fetch_recurring_schedules(start_time.to_s(:db), end_time.to_s(:db), start_time.strftime("%F") + " ", language_id, external_village_id_str, all_coach_ids_with_template_switch, slot_duration, interval_condition)
    end unless all_coach_ids_with_template_switch.empty?
    recurring_schedules_for_week = handle_daylight_switch_week(start_time, end_time, language_id, external_village_id_str, all_coach_ids, slot_duration, recurring_schedules_for_week) if TimeUtils.is_daylight_switch_week?(start_time)
    recurring_schedules_for_week
  end

  def self.handle_daylight_switch_week(start_time, end_time, language_id, external_village_id_str, all_coach_ids, slot_duration, recurring_schedules_for_week)
    recurring_schedules_for_week = recurring_schedules_for_week.reject {|schedule| schedule.schedule_time.to_time < (start_time + 2.hours - 1.minute) }
    interval_condition = "AND schedule_time BETWEEN '#{(start_time).to_s(:db)}' AND '#{(start_time + 2.hours - 1.minute).to_s(:db)}'"
    recurring_schedules_for_week += fetch_recurring_schedules(start_time.to_s(:db), start_time.to_s(:db), start_time.strftime("%F") + " ", language_id, external_village_id_str, all_coach_ids, slot_duration, interval_condition)
  end

  def self.create_for(datetime, coach_id, language_id, no_of_seats = 4, village_id = nil, topic_id = nil, session_type = 'session', appointment_type_id = nil)
        recurring_end_date = Coach.find_by_id(coach_id).detect_availability_change_for_slot_in_future(datetime)
        if Language.find_by_id(language_id).is_one_hour? && session_type == 'session'
          other_half_recurring_end_date = Coach.find_by_id(coach_id).detect_availability_change_for_slot_in_future(TimeUtils.return_other_half(datetime))
          if recurring_end_date && other_half_recurring_end_date
            recurring_end_date = recurring_end_date < other_half_recurring_end_date ? recurring_end_date : other_half_recurring_end_date
          elsif other_half_recurring_end_date
            recurring_end_date = other_half_recurring_end_date
          end
        end
        create({
	 	          :coach_id => coach_id,
	 	          :day_index => datetime.wday,
	 	          :start_time => datetime.strftime("%T"),
	 	          :recurring_start_date => datetime,
	 	          :language_id => language_id,
	 	          :external_village_id => village_id,
	 	          :number_of_seats => no_of_seats,
              :topic_id => topic_id,
              :recurring_end_date => recurring_end_date ? recurring_end_date : nil,
              :recurring_type => session_type == 'session' ? 'recurring_session' : 'recurring_appointment',
              :appointment_type_id => session_type == 'session' ? nil : appointment_type_id
	 	        })
	end

  def self.fetch_recurring_schedules(start_of_week, end_of_week, start_date, language_id, external_village_id_str, coach_ids, slot_duration, interval_condition = "")
    external_village_condition = ""
    if external_village_id_str == 'all'
      external_village_condition = ""
    elsif external_village_id_str == 'none'
      external_village_condition = "AND IFNULL(external_village_id,0) = 0"
    elsif !external_village_id_str.blank?
      external_village_condition = "AND IFNULL(external_village_id,0) = " + external_village_id_str
    end
    lang_identifier = Language.find_by_id(language_id).identifier
    sql = %Q(
      SELECT schedules.* FROM
        (SELECT crs.* FROM
          (SELECT rs.* FROM
            (SELECT id, coach_id, language_id, external_village_id, recurring_start_date, updated_at, number_of_seats, topic_id, recurring_type, appointment_type_id,
                (CONCAT(? , start_time) + INTERVAL day_index DAY +
                INTERVAL (fn_GetZoneOffset(CONVERT_TZ(? ,"GMT","EST")) - fn_GetZoneOffset(CONVERT_TZ(recurring_start_date,"GMT","EST"))) HOUR +
                INTERVAL (CASE WHEN hour(start_time) < fn_GetZoneOffset(CONVERT_TZ(recurring_start_date,"GMT","EST")) AND day_index = 0 THEN 7 ELSE 0 END) day) AS schedule_time
              FROM coach_recurring_schedules
              WHERE language_id = ? AND (recurring_end_date is NULL OR recurring_end_date > '#{start_of_week}') AND recurring_start_date <= ? #{external_village_condition}) AS rs
            LEFT JOIN coach_sessions AS cs ON cs.language_identifier = ? AND cs.coach_id = rs.coach_id AND cs.session_start_time = schedule_time
            WHERE cs.session_start_time is NULL) AS crs
          LEFT JOIN unavailable_despite_templates AS udt ON udt.coach_id = crs.coach_id AND udt.approval_status = 1 AND udt.unavailability_type != 4 AND schedule_time >= udt.start_date AND schedule_time < udt.end_date
          WHERE udt.id IS NULL #{interval_condition}
        ) AS schedules
        INNER JOIN
        (SELECT
          coach_id, template_id, ds, day_index, start_time,
          CONCAT(?, start_time) + INTERVAL day_index day + INTERVAL ds hour +
          INTERVAL (CASE WHEN hour(start_time) < fn_GetZoneOffset(CONVERT_TZ(template_created_at,"GMT","EST")) AND day_index = 0 THEN 7 ELSE 0 END) DAY AS avl_start_time,
          CASE WHEN TIMESTAMPDIFF(MINUTE,concat('2000-01-01 ', start_time), concat('2000-01-01 ', end_time)) < 0
          THEN 24*60 + TIMESTAMPDIFF(MINUTE,concat('2000-01-01 ', start_time), concat('2000-01-01 ', end_time))
          ELSE TIMESTAMPDIFF(MINUTE,concat('2000-01-01 ', start_time), concat('2000-01-01 ', end_time)) END AS avl_duration
          FROM
            (SELECT
              coach_id, created_at AS template_created_at, id AS template_id ,
              (fn_GetZoneOffset(CONVERT_TZ(?,"GMT","EST")) - fn_GetZoneOffset(CONVERT_TZ(created_at,"GMT","EST"))) as ds
              FROM
              (SELECT * FROM coach_availability_templates
                WHERE effective_start_date <= ? AND status = 1 AND deleted = 0 AND coach_id IN (?)
                ORDER BY coach_id, effective_start_date desc) AS TMP GROUP BY coach_id
              ) tmp
            INNER JOIN coach_availabilities
            ON coach_availability_template_id = template_id
        ) AS avl
        ON schedules.coach_id = avl.coach_id AND schedule_time >= avl_start_time AND
          (schedule_time + INTERVAL ? MINUTE) <= (avl_start_time + INTERVAL avl_duration MINUTE)
        ORDER BY schedule_time
      )
    sql_parameters = [sql, start_date, end_of_week, language_id, end_of_week, lang_identifier, start_date, end_of_week, start_of_week, coach_ids, slot_duration]
    find_by_sql(sql_parameters)
  end

  def self.edge_time_condition(table = '')
    "WHEN #{table}#{'.' if table.present?}day_index = 0 AND #{table}#{'.' if table.present?}start_time < ? THEN 7"
  end

  def self.time_condition_checker
    %Q(DATE(?) + INTERVAL (CASE WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?),"GMT","EST")) = "EST" THEN
                            CASE #{edge_time_condition} ELSE day_index END
                            WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?),"GMT","EST")) = "EDT" THEN
                            CASE #{edge_time_condition} ELSE day_index END END) day + INTERVAL hour(start_time) hour + INTERVAL minute(start_time) minute)
  end

  def self.recurring_schedules_for_MS_selected_day_without_availability(start_date,end_date,language_id,language_start_time,external_village_id_str)
    time_frame = TIME_FRAME[language_start_time]
    coach_avail_template_created_at_edt = "00:#{time_frame}:00"
    coach_avail_template_created_at_est = "23:#{time_frame}:00"
    last_slots_array_edt = ["00:#{time_frame}:00","01:#{time_frame}:00","02:#{time_frame}:00","03:#{time_frame}:00"]
    last_slots_array_est = ["00:#{time_frame}:00","01:#{time_frame}:00","02:#{time_frame}:00","03:#{time_frame}:00","04:#{time_frame}:00"]
    start_date = start_date.utc
    end_date = end_date.utc
    external_village_id = external_village_id_str == 'all'? 0 :(external_village_id_str == 'none' ? -1 : external_village_id_str.to_i )
    sql = <<-END1
    SELECT  *
    FROM    ( SELECT  CASE  WHEN fn_GetTimeZone(CONVERT_TZ(crs_tmp.recurring_start_date,"GMT","EST")) = "EST"
            AND   fn_GetTimeZone(CONVERT_TZ(DATE(?) + INTERVAL (CASE WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?),"GMT","EST")) = "EST" THEN
                                                               CASE WHEN day_index = 0 AND start_time IN (?) THEN 7 ELSE day_index END
                                                               WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?),"GMT","EST")) = "EDT" THEN
                                                               CASE WHEN day_index = 0 AND start_time IN (?) THEN 7 ELSE day_index END END) day + INTERVAL hour(crs_tmp.start_time) hour + INTERVAL minute(crs_tmp.start_time) minute,"GMT","EST")) = "EDT" THEN CASE WHEN crs_tmp.start_time < "01:00:00" THEN (crs_tmp.day_index + 7 - 1) % 7 ELSE crs_tmp.day_index END
            WHEN fn_GetTimeZone(CONVERT_TZ(crs_tmp.recurring_start_date,"GMT","EST")) = "EDT"
            AND   fn_GetTimeZone(CONVERT_TZ(DATE(?) + INTERVAL (CASE WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?),"GMT","EST")) = "EST" AND fn_GetTimeZone(CONVERT_TZ(DATE(?) + INTERVAL 7 day ,"GMT","EST")) = "EDT" THEN
                                                               CASE WHEN day_index = 0 AND start_time IN (?) THEN 7 ELSE day_index END
                                                               WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?),"GMT","EST")) = "EST" AND fn_GetTimeZone(CONVERT_TZ(DATE(?) + INTERVAL 7 day ,"GMT","EST")) = "EST" THEN
                                                               CASE WHEN day_index = 0 AND start_time IN (?) THEN 7 ELSE day_index END
                                                               WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?),"GMT","EST")) = "EDT" THEN
                                                               CASE WHEN day_index = 0 AND start_time IN (?) THEN 7 ELSE day_index END END) day + INTERVAL hour(crs_tmp.start_time) hour + INTERVAL minute(crs_tmp.start_time) minute,"GMT","EST")) = "EST" THEN CASE WHEN crs_tmp.start_time >= "23:00:00" THEN (crs_tmp.day_index + 1) % 7 ELSE crs_tmp.day_index END
            ELSE    crs_tmp.day_index END day_index,
            CASE  WHEN fn_GetTimeZone(CONVERT_TZ(crs_tmp.recurring_start_date ,"GMT","EST")) = "EST"
            AND   fn_GetTimeZone(CONVERT_TZ(DATE(?) + INTERVAL (CASE WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?) ,"GMT","EST")) = "EST" THEN
                                                               CASE WHEN day_index = 0 AND start_time IN (?) THEN 7 ELSE day_index END
                                                               WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?),"GMT","EST")) = "EDT" THEN
                                                               CASE WHEN day_index = 0 AND start_time IN (?) THEN 7 ELSE day_index END END) day + INTERVAL hour(crs_tmp.start_time) hour + INTERVAL minute(crs_tmp.start_time) minute,"GMT","EST")) = "EDT" THEN CASE WHEN crs_tmp.start_time < "01:00:00" THEN TIME(?) ELSE SUBTIME(crs_tmp.start_time, "01:00:00") END
            WHEN fn_GetTimeZone(CONVERT_TZ(crs_tmp.recurring_start_date ,"GMT","EST")) = "EDT"
            AND   fn_GetTimeZone(CONVERT_TZ(DATE(?) + INTERVAL (CASE WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?),"GMT","EST")) = "EST" AND fn_GetTimeZone(CONVERT_TZ(DATE(?) + INTERVAL 7 day ,"GMT","EST")) = "EDT" THEN
                                                               CASE WHEN day_index = 0 AND start_time IN (?) THEN 7 ELSE day_index END
                                                               WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?),"GMT","EST")) = "EST" AND fn_GetTimeZone(CONVERT_TZ(DATE(?) + INTERVAL 7 day ,"GMT","EST")) = "EST" THEN
                                                               CASE WHEN day_index = 0 AND start_time IN (?) THEN 7 ELSE day_index END
                                                               WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?),"GMT","EST")) = "EDT" THEN
                                                               CASE WHEN day_index = 0 AND start_time IN (?) THEN 7 ELSE day_index END END) day + INTERVAL hour(crs_tmp.start_time) hour + INTERVAL minute(crs_tmp.start_time) minute,"GMT","EST")) = "EST" THEN CASE WHEN crs_tmp.start_time >= "23:00:00" THEN TIME(?) ELSE SUBTIME(crs_tmp.start_time, "-01:00:00") END
            ELSE    crs_tmp.start_time END start_time,
            crs_tmp.coach_id,
            DATE(?) + INTERVAL (CASE WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?),"GMT","EST")) = "EST" THEN
                                CASE WHEN day_index = 0 AND start_time IN (?) THEN 7 ELSE day_index END
                                WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?),"GMT","EST")) = "EDT" THEN
                                CASE WHEN day_index = 0 AND start_time IN (?) THEN 7 ELSE day_index END END) day + INTERVAL hour(start_time) hour + INTERVAL minute(start_time) minute slot_date,
            MAX(crs_tmp.recurring_start_date) recurring_start_date,
            crs_tmp.language_id,
            crs_tmp.recurring_end_date,
            crs_tmp.external_village_id,
            crs_tmp.id
            FROM  coach_recurring_schedules crs_tmp
            WHERE   crs_tmp.recurring_start_date < ?
            AND     crs_tmp.recurring_end_date IS NULL
            AND     crs_tmp.language_id = ?
            AND   IFNULL(crs_tmp.external_village_id,0) = CASE  WHEN ? =  0/*ALL*/ THEN IFNULL(external_village_id,0)
            WHEN ? = -1/*NULL*/ THEN 0
            ELSE ?
            END
            GROUP BY  CASE  WHEN fn_GetTimeZone(CONVERT_TZ(crs_tmp.recurring_start_date,"GMT","EST")) = "EST"
            AND   fn_GetTimeZone(CONVERT_TZ(DATE(?) + INTERVAL (CASE WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?) ,"GMT","EST")) = "EST" THEN
                                                               CASE WHEN day_index = 0 AND start_time IN (?) THEN 7 ELSE day_index END
                                                               WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?),"GMT","EST")) = "EDT" THEN
                                                               CASE WHEN day_index = 0 AND start_time IN (?) THEN 7 ELSE day_index END END) day + INTERVAL hour(crs_tmp.start_time) hour + INTERVAL minute(crs_tmp.start_time) minute,"GMT","EST")) = "EDT" THEN CASE WHEN crs_tmp.start_time < "01:00:00" THEN (crs_tmp.day_index + 7 - 1) % 7 ELSE crs_tmp.day_index END
            WHEN fn_GetTimeZone(CONVERT_TZ(crs_tmp.recurring_start_date,"GMT","EST")) = "EDT"
            AND   fn_GetTimeZone(CONVERT_TZ(DATE(?) + INTERVAL (CASE WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?) ,"GMT","EST")) = "EST" AND fn_GetTimeZone(CONVERT_TZ(DATE(?) + INTERVAL 7 day ,"GMT","EST")) = "EDT" THEN
                                                               CASE WHEN day_index = 0 AND start_time IN (?) THEN 7 ELSE day_index END
                                                               WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?),"GMT","EST")) = "EST" AND fn_GetTimeZone(CONVERT_TZ(DATE(?) + INTERVAL 7 day ,"GMT","EST")) = "EST" THEN
                                                               CASE WHEN day_index = 0 AND start_time IN (?) THEN 7 ELSE day_index END
                                                               WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?) ,"GMT","EST")) = "EDT" THEN
                                                               CASE WHEN day_index = 0 AND start_time IN (?) THEN 7 ELSE day_index END END) day + INTERVAL hour(crs_tmp.start_time) hour + INTERVAL minute(crs_tmp.start_time) minute,"GMT","EST")) = "EST" THEN CASE WHEN crs_tmp.start_time >= "23:00:00" THEN (crs_tmp.day_index + 1) % 7 ELSE crs_tmp.day_index END
            ELSE  crs_tmp.day_index END,
            CASE  WHEN fn_GetTimeZone(CONVERT_TZ(crs_tmp.recurring_start_date ,"GMT","EST")) = "EST"
            AND   fn_GetTimeZone(CONVERT_TZ(DATE(?) + INTERVAL (CASE WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?) ,"GMT","EST")) = "EST" THEN
                                                               CASE WHEN day_index = 0 AND start_time IN (?) THEN 7 ELSE day_index END
                                                               WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?) ,"GMT","EST")) = "EDT" THEN
                                                               CASE WHEN day_index = 0 AND start_time IN (?) THEN 7 ELSE day_index END END) day + INTERVAL hour(crs_tmp.start_time) hour + INTERVAL minute(crs_tmp.start_time) minute,"GMT","EST")) = "EDT" THEN CASE WHEN crs_tmp.start_time < "01:00:00" THEN TIME(?) ELSE SUBTIME(crs_tmp.start_time, "01:00:00") END
            WHEN fn_GetTimeZone(CONVERT_TZ(crs_tmp.recurring_start_date ,"GMT","EST")) = "EDT"
            AND   fn_GetTimeZone(CONVERT_TZ(DATE(?) + INTERVAL (CASE WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?) ,"GMT","EST")) = "EST" AND fn_GetTimeZone(CONVERT_TZ(DATE(?) + INTERVAL 7 day ,"GMT","EST")) = "EDT" THEN
                                                               CASE WHEN day_index = 0 AND start_time IN (?) THEN 7 ELSE day_index END
                                                               WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?),"GMT","EST")) = "EST" AND fn_GetTimeZone(CONVERT_TZ(DATE(?) + INTERVAL 7 day ,"GMT","EST")) = "EST" THEN
                                                               CASE WHEN day_index = 0 AND start_time IN (?) THEN 7 ELSE day_index END
                                                               WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?) ,"GMT","EST")) = "EDT" THEN
                                                               CASE WHEN day_index = 0 AND start_time IN (?) THEN 7 ELSE day_index END END) day + INTERVAL hour(crs_tmp.start_time) hour + INTERVAL minute(crs_tmp.start_time) minute,"GMT","EST")) = "EST" THEN CASE WHEN crs_tmp.start_time >= "23:00:00" THEN TIME(?) ELSE SUBTIME(crs_tmp.start_time, "-01:00:00") END
            ELSE  crs_tmp.start_time END,
            slot_date,
            crs_tmp.coach_id,
            crs_tmp.language_id,
            crs_tmp.recurring_end_date) crs
    WHERE NOT EXISTS    ( SELECT  1
                        FROM    ( SELECT  TMP1.*, day_index, start_time, end_time
                                 FROM   ( SELECT  AA.coach_id, AA.effective_start_date, BB.effective_start_date - INTERVAL 1 second AS effective_end_date, AA.id, AA.created_time_zone
                                         FROM   (select   A.coach_id,
                                                A.effective_start_date,
                                                fn_GetTimeZone(CONVERT_TZ(A.created_at,"GMT","EST")) created_time_zone,
                                                MAX(A.id) id,count(*) as num
                                                from  coach_availability_templates A
                                                left  outer join coach_availability_templates B
                                                ON    A.coach_id = B.coach_id
                                                and     A.effective_start_date >= B.effective_start_date
                                                WHERE A.effective_start_date < ?
                                                AND   A.effective_start_date >= (SELECT MAX(effective_start_date) from coach_availability_templates where coach_id = A.coach_id AND effective_start_date <= ? AND deleted = 0 AND status = 1 AND language_start_time = ?)
                                                AND   A.deleted = 0
                                                AND     A.status = 1
                                                AND    A.language_start_time = ?
                                         group by A.coach_id, A.effective_start_date ) AA LEFT OUTER JOIN ( select  A.coach_id,
                                                                                                            A.effective_start_date,
                                                                                                            fn_GetTimeZone(CONVERT_TZ(A.created_at,"GMT","EST")) created_time_zone,
                                                                                                            MAX(A.id) id,count(*) as num
                                                                                                            from  coach_availability_templates A
                                                                                                            left  outer join coach_availability_templates B
                                                                                                            ON    A.coach_id = B.coach_id
                                                                                                            and     A.effective_start_date >= B.effective_start_date
                                                                                                            WHERE A.effective_start_date < ?
                                                                                                            AND   A.effective_start_date >= (SELECT MAX(effective_start_date) from coach_availability_templates where coach_id = A.coach_id AND effective_start_date <= ? AND deleted = 0 AND status = 1 AND language_start_time = ?)
                                                                                                            AND   A.deleted = 0
                                                                                                            AND   A.status = 1
                                                                                                            AND   A.language_start_time = ?
                                                                                                            group by A.coach_id, A.effective_start_date ) BB
                                         ON   AA.coach_id = BB.coach_id
                                         AND    AA.num = BB.num - 1)TMP1 JOIN coach_availabilities TMP2
                                 ON   TMP1.id = TMP2.coach_availability_template_id
                                 ORDER  BY TMP1.coach_id,day_index,start_time,end_time
                                 )TMP3
                        WHERE crs.coach_id = TMP3.coach_id
                        AND   CASE  WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?) + INTERVAL (CASE WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?) ,"GMT","EST")) = "EST" AND fn_GetTimeZone(CONVERT_TZ(DATE(?) + INTERVAL 7 day ,"GMT","EST")) = "EDT" THEN
                                                                                       CASE WHEN TMP3.day_index = 0 AND TMP3.start_time IN (?) THEN 7 ELSE TMP3.day_index END
                                                                                       WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?),"GMT","EST")) = "EST" AND fn_GetTimeZone(CONVERT_TZ(DATE(?) + INTERVAL 7 day ,"GMT","EST")) = "EST" THEN
                                                                                       CASE WHEN TMP3.day_index = 0 AND TMP3.start_time IN (?) THEN 7 ELSE TMP3.day_index END
                                                                                       WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?),"GMT","EST")) = "EDT" THEN
                                                                                       CASE WHEN TMP3.day_index = 0 AND TMP3.start_time IN (?) THEN 7 ELSE TMP3.day_index END END) day + INTERVAL hour(TMP3.start_time) hour + INTERVAL minute(TMP3.start_time) minute,"GMT","EST")) = "EST" AND TMP3.created_time_zone = "EDT" THEN CASE WHEN TMP3.start_time >= "23:00:00" THEN (TMP3.day_index  + 1) % 7 ELSE TMP3.day_index  END
                        WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?) + INTERVAL (CASE WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?),"GMT","EST")) = "EST" THEN
                                                                           CASE WHEN TMP3.day_index = 0 AND TMP3.start_time IN (?) THEN 7 ELSE TMP3.day_index END
                                                                           WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?),"GMT","EST")) = "EDT" THEN
                                                                           CASE WHEN TMP3.day_index = 0 AND TMP3.start_time IN (?) THEN 7 ELSE TMP3.day_index END END) day + INTERVAL hour(TMP3.start_time) hour + INTERVAL minute(TMP3.start_time) minute,"GMT","EST")) = "EDT" AND TMP3.created_time_zone = "EST" THEN CASE WHEN TMP3.start_time < "01:00:00" THEN (TMP3.day_index  + 7 - 1) % 7 ELSE TMP3.day_index END
                        ELSE    TMP3.day_index END = crs.day_index
                        AND   CASE  WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?) + INTERVAL (CASE WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?),"GMT","EST")) = "EST" AND fn_GetTimeZone(CONVERT_TZ(DATE(?) + INTERVAL 7 day ,"GMT","EST")) = "EDT" THEN
                                                                                       CASE WHEN TMP3.day_index = 0 AND TMP3.start_time IN (?) THEN 7 ELSE TMP3.day_index END
                                                                                       WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?),"GMT","EST")) = "EST" AND fn_GetTimeZone(CONVERT_TZ(DATE(?) + INTERVAL 7 day ,"GMT","EST")) = "EST" THEN
                                                                                       CASE WHEN TMP3.day_index = 0 AND TMP3.start_time IN (?) THEN 7 ELSE TMP3.day_index END
                                                                                       WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?),"GMT","EST")) = "EDT" THEN
                                                                                       CASE WHEN TMP3.day_index = 0 AND TMP3.start_time IN (?) THEN 7 ELSE TMP3.day_index END END) day + INTERVAL hour(TMP3.start_time) hour + INTERVAL minute(TMP3.start_time) minute,"GMT","EST")) = "EST" AND TMP3.created_time_zone = "EDT" THEN CASE WHEN TMP3.start_time >= "23:00:00" THEN TIME(?) ELSE  SUBTIME(TMP3.start_time, "-01:00:00") END
                        WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?) + INTERVAL (CASE WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?),"GMT","EST")) = "EST" THEN
                                                                           CASE WHEN TMP3.day_index = 0 AND TMP3.start_time IN (?) THEN 7 ELSE TMP3.day_index END
                                                                           WHEN fn_GetTimeZone(CONVERT_TZ(DATE(?),"GMT","EST")) = "EDT" THEN
                                                                           CASE WHEN TMP3.day_index = 0 AND TMP3.start_time IN (?) THEN 7 ELSE TMP3.day_index END END) day + INTERVAL hour(TMP3.start_time) hour + INTERVAL minute(TMP3.start_time) minute,"GMT","EST")) = "EDT" AND TMP3.created_time_zone = "EST" THEN CASE WHEN TMP3.start_time < "01:00:00" THEN TIME(?) ELSE SUBTIME(TMP3.start_time, "01:00:00") END
                        ELSE    TMP3.start_time END = crs.start_time
                        AND   DATE(?) + INTERVAL crs.day_index day + INTERVAL hour(crs.start_time) hour + INTERVAL minute(crs.start_time) minute >= TMP3.effective_start_date
                        AND     (DATE(?) + INTERVAL crs.day_index day + INTERVAL hour(crs.start_time) hour + INTERVAL minute(crs.start_time) minute <= TMP3.effective_end_date OR TMP3.effective_end_date IS NULL)
                        );
    END1
    find_by_sql([sql,start_date,start_date,last_slots_array_est,start_date,last_slots_array_edt,start_date,start_date,start_date,last_slots_array_edt,start_date,start_date,last_slots_array_est,start_date,last_slots_array_edt,start_date,start_date,last_slots_array_est,start_date,last_slots_array_edt,start_date,start_date,start_date,last_slots_array_edt,start_date,start_date,last_slots_array_est,start_date,last_slots_array_edt,start_date,start_date,last_slots_array_est,start_date,last_slots_array_edt,coach_avail_template_created_at_est,start_date,start_date,start_date,last_slots_array_edt,start_date,start_date,last_slots_array_est,start_date,last_slots_array_edt,coach_avail_template_created_at_edt,end_date,start_date,language_start_time,
                 language_start_time,end_date,start_date,language_start_time,language_start_time,start_date,start_date,start_date,last_slots_array_edt,start_date,start_date,last_slots_array_est,start_date,last_slots_array_edt,start_date,start_date,last_slots_array_est,start_date,last_slots_array_edt,start_date,start_date,start_date,last_slots_array_edt,start_date,start_date,last_slots_array_est,start_date,last_slots_array_edt,coach_avail_template_created_at_edt,start_date,start_date,last_slots_array_est,start_date,last_slots_array_edt,coach_avail_template_created_at_est,start_date,start_date
                 ])
  end
  def self.find_all_sessions_with_ids(recurring_ids)
    recurring_ids.blank? ? [] : where(["id in(?)" , recurring_ids]).includes([:coach])
  end
   
   def label_for_active_recurring
    label = (self.language.is_one_hour? && recurring_type != 'recurring_appointment') ? "<br/><br/>Recurring" : "Recurring"
    village = Community::Village.display_name(external_village_id) if external_village_id
    label += "<br/> #{village.slice(0..7).strip + ".. &nbsp; "}" if village
    label += language.is_tmm? ? recurring_type == 'recurring_appointment' ? "<br/>#{language.display_name_without_type}" : "<br/>#{language.display_name}" : "<br>#{language.identifier}"
    label += "<br />" + AppointmentType.find(appointment_type_id).try(:title) if recurring_type == 'recurring_appointment'
    label += " <img class='solo_icon' src='/images/solo.png' alt='solo'>" if number_of_seats == 1 and !(language.is_lotus? || language.is_tmm?)
    label
   end
end
