class CoachAvailabilityUtils

  def self.eligible_alternate_coaches(session_start_time, language_id, single_number_unit = 0, duration_of_slot = 0 , is_appointment = 'false')
    start_of_week_utc = TimeUtils.beginning_of_week(session_start_time)
    end_of_week_utc = start_of_week_utc + 7.days - 1.minute
    eligible_coaches = [[], []]
    slot_duration = (duration_of_slot == 0) ? Language[language_id].duration_in_seconds : 30.minutes#to facilitate the second call for those 1hr slots marked by two 30min slots
    slot_duration = 30.minutes if is_appointment == true #in case of apointments, the slot duration is always 30 minutes. So do not check other half
    duration = slot_duration - 1.minute 
    language_id = Language.fetch_same_group_appointment_languages(language_id).collect(&:id) if is_appointment == true# passing true to fetch language ids.
    query = "SELECT coach.* FROM (SELECT a.*, q.max_unit FROM accounts a inner join qualifications q on a.id = q.coach_id where a.type = 'Coach'
               and a.active = 1 and q.language_id IN (?) and q.max_unit >= ?) as coach LEFT JOIN coach_sessions cs on coach.id = cs.coach_id
               and cs.cancelled = 0 and cs.session_start_time between ? and ? and cs.session_end_time > ? where cs.id IS NULL order by trim(coach.full_name)"
    coaches = Coach.find_by_sql([query, language_id, single_number_unit, session_start_time.beginning_of_hour - 1.minute, session_start_time + duration, session_start_time])
    coaches.uniq!
    
    coaches_id = coaches.collect(&:id).uniq

    start_of_week = start_of_week_utc.strftime("%F")+" "
    recurring_coaches_id = CoachRecurringSchedule.find_by_sql(["SELECT coach_id,
                (CONCAT(? , start_time) + INTERVAL day_index DAY +
                INTERVAL (fn_GetZoneOffset(CONVERT_TZ(?,'GMT','EST')) - fn_GetZoneOffset(CONVERT_TZ(recurring_start_date,'GMT','EST'))) HOUR +
                INTERVAL (CASE WHEN hour(start_time) < fn_GetZoneOffset(CONVERT_TZ(recurring_start_date,'GMT','EST')) AND day_index = 0 THEN 7 ELSE 0 END) day) AS schedule_time
              FROM coach_recurring_schedules
              WHERE coach_id in (?) AND (recurring_end_date IS NULL OR recurring_end_date > ?) AND recurring_start_date < ?
              having schedule_time = ?;",start_of_week, session_start_time, coaches_id, session_start_time, session_start_time, session_start_time]).collect(&:coach_id).uniq
    if session_start_time.min == 30 
      one_hour_lang_list = AriaLanguage.all.collect(&:id) + TMMLiveLanguage.all.collect(&:id) + TMMMichelinLanguage.all.collect(&:id)
      other_half_time = TimeUtils.return_other_half(session_start_time)
      recurring_coaches_id += CoachRecurringSchedule.find_by_sql(["SELECT coach_id,
                (CONCAT(? , start_time) + INTERVAL day_index DAY +
                INTERVAL (fn_GetZoneOffset(CONVERT_TZ(?,'GMT','EST')) - fn_GetZoneOffset(CONVERT_TZ(recurring_start_date,'GMT','EST'))) HOUR +
                INTERVAL (CASE WHEN hour(start_time) < fn_GetZoneOffset(CONVERT_TZ(recurring_start_date,'GMT','EST')) AND day_index = 0 THEN 7 ELSE 0 END) day) AS schedule_time
              FROM coach_recurring_schedules
              WHERE coach_id in (?) AND (recurring_end_date IS NULL OR recurring_end_date > ?) AND recurring_start_date < ? and language_id in (?)
              having schedule_time = ?;",start_of_week, other_half_time, coaches_id, other_half_time, other_half_time,one_hour_lang_list, other_half_time]).collect(&:coach_id).uniq
    end
    recurring_coaches_id.uniq!

    query_thresold = "SELECT q.coach_id AS coach_id, MAX(t.max_assignment) AS max_assignment, MAX(t.max_grab) AS max_grab FROM qualifications q INNER JOIN language_scheduling_thresholds t ON q.language_id = t.language_id WHERE q.coach_id IN (?) GROUP BY coach_id"
    thresolds = Hash[Qualification.find_by_sql([query_thresold, coaches_id]).collect{|qual|[qual.coach_id, [qual.max_assignment, qual.max_grab]]}]

    grabbed_query = "SELECT count(s.id) as grabbed_count, s.grabber_coach_id FROM substitutions s INNER JOIN coach_sessions cs ON cs.id = s.coach_session_id AND cs.coach_id = s.grabber_coach_id AND cs.cancelled = 0 AND cs.session_start_time between ? and ? WHERE s.grabber_coach_id IN (?) AND (grabbed = 1 or was_reassigned = 1) GROUP BY s.grabber_coach_id"
    substitutions = Hash[Substitution.find_by_sql([grabbed_query, start_of_week_utc, end_of_week_utc, coaches_id]).collect{|sub| [sub.grabber_coach_id, sub.grabbed_count]}]

    session_query = "SELECT count(id) as session_count, coach_id FROM coach_sessions WHERE coach_id IN (?) and session_start_time between ? and ? and cancelled = 0 GROUP BY coach_id"
    sessions = Hash[CoachSession.find_by_sql([session_query, coaches_id, start_of_week_utc, end_of_week_utc]).collect{|session| [session.coach_id, session.session_count]}]
    
    datetime = session_start_time.strftime("%F")+" "+session_start_time.strftime("%T")
    end_datetime = (session_start_time+slot_duration).to_s(:db)
    query1 = %Q(Select avl_coaches.coach_id from (
                Select * from (
                  Select coach_id, template_id, ds, day_index, start_time,
                  CONCAT(?, start_time) + INTERVAL day_index day + INTERVAL ds hour +
          INTERVAL (CASE WHEN hour(start_time) < fn_GetZoneOffset(CONVERT_TZ(template_created_at,'GMT','EST')) AND day_index = 0 THEN 7 ELSE 0 END) DAY AS avl_start_time,
          CASE WHEN TIMESTAMPDIFF(MINUTE,concat('2000-01-01 ', start_time), concat('2000-01-01 ', end_time)) < 0
          THEN 24*60 + TIMESTAMPDIFF(MINUTE,concat('2000-01-01 ', start_time), concat('2000-01-01 ', end_time))
          ELSE TIMESTAMPDIFF(MINUTE,concat('2000-01-01 ', start_time), concat('2000-01-01 ', end_time)) END AS avl_duration
          FROM
            (SELECT
              coach_id, created_at AS template_created_at, id AS template_id ,
              (fn_GetZoneOffset(CONVERT_TZ(?,'GMT','EST')) - fn_GetZoneOffset(CONVERT_TZ(created_at,'GMT','EST'))) as ds
              FROM
              (SELECT * FROM coach_availability_templates
                WHERE effective_start_date <= ? AND status = 1 AND deleted = 0 AND coach_id IN (?)
                ORDER BY coach_id, effective_start_date desc) AS TMP GROUP BY coach_id
              ) tmp
            INNER JOIN coach_availabilities
            ON coach_availability_template_id = template_id ) as avl
            where avl_start_time <= ? AND
            (avl_start_time + INTERVAL avl_duration MINUTE) >= ? )  as avl_coaches
            left join
            (SELECT id, coach_id, language_id, external_village_id, recurring_start_date, updated_at, number_of_seats,
                (CONCAT(? , start_time) + INTERVAL day_index DAY +
                INTERVAL (fn_GetZoneOffset(CONVERT_TZ(? ,'GMT','EST')) - fn_GetZoneOffset(CONVERT_TZ(recurring_start_date,'GMT','EST'))) HOUR +
                INTERVAL (CASE WHEN hour(start_time) < fn_GetZoneOffset(CONVERT_TZ(recurring_start_date,'GMT','EST')) AND day_index = 0 THEN 7 ELSE 0 END) day) AS schedule_time
              FROM coach_recurring_schedules
              WHERE recurring_end_date is NULL AND recurring_start_date <= ?) as rs
                on rs.schedule_time = ? and rs.coach_id = avl_coaches.coach_id
          where rs.id is null)
    available_ids = CoachAvailabilityTemplate.find_by_sql([query1,start_of_week,datetime,datetime,coaches_id,datetime,end_datetime,start_of_week,datetime,datetime,datetime]).collect(&:coach_id).uniq
    udts = UnavailableDespiteTemplate.where(["coach_id IN (?) and approval_status = ? and start_date <= ? and end_date >= ?", coaches_id, true, session_start_time, session_start_time + 30.minutes])
    if slot_duration == 60.minutes
      udts += UnavailableDespiteTemplate.where(["coach_id IN (?) and approval_status = ? and start_date <= ? and end_date >= ?", coaches_id, true, session_start_time + 30.minutes, session_start_time + 60.minutes])
    end    
    udts.uniq!
    available_ids = available_ids - udts.collect(&:coach_id).uniq
    coaches.each do |coach|
      next if Coach.find_by_id(coach.id).nil?
      coach.threshold = Coach.find(coach.id).threshold_reached?(session_start_time)[1]
      next if recurring_coaches_id.include?(coach.id) && !udts.detect{|udt| (udt.coach_id==coach.id && [1,2,4,5].include?(udt.unavailability_type))}
      if available_ids.include?(coach.id)
        eligible_coaches[0] << coach
      else
        eligible_coaches[1] << coach
      end
    end
    eligible_coaches
  end

end