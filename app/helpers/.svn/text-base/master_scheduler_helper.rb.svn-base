module MasterSchedulerHelper
  
  def utc_time(day,hour)
    (@start_of_selected_week + (day.days + hour.hours+((@start_time - 1) * 15).minutes)).utc
  end

  def add_appropriate_classes(day,hour)
    str = ""
    str += (@data[day][hour][:actual_sessions].to_i < @data[day][hour][:historical_sessions].to_i ? "actuals_less_than_historical " :"")
    str += @data[day][hour][:actual_sessions].to_i > 0? "pushed_to_eschool ":""
    str += @data[day][hour][:extra_sessions].to_i > 0? "extra_session ":""
    str += @data[day][hour][:recurring_sessions].to_i > 0? "initial_recurring ":"" unless @view_draft
    str
  end

  def has_sub_req?(day,hour)
    if @data[day][hour][:sub_requested].to_i > 0
      return true
    else
      return false
    end
  end

  def add_thick_border_if_today(day)
    str = ""
    if day == Time.now.wday && (@start_of_selected_week + day.days).today?
      str += " right_border_at_right_side "
    end
    str
  end

  def session_details_title
    WEEKDAY_NAMES[@session_start_time.in_time_zone(Time.zone).wday].upcase + " " + (@session_start_time.in_time_zone(Time.zone)).strftime("%m/%d/%y" ) + " " + (@session_start_time.in_time_zone(Time.zone)).strftime("%I:%M%p")
  end

  def lotus_shift_details_title
    time = @session_start_time.to_time
    WEEKDAY_NAMES[time.in_time_zone(Time.zone).wday].slice(0,3).upcase + " " + (time.in_time_zone(Time.zone)).strftime("%m/%d/%y" ) + " SHIFT"
  end
  
  def time_in_popup_format_for_lotus(time)
    time = time.to_time
    WEEKDAY_NAMES[time.in_time_zone(Time.zone).wday].slice(0,3).upcase + " " + (time.in_time_zone(Time.zone)).strftime("%m/%d/%y" ) + " " + (time.in_time_zone(Time.zone)).strftime("%I:%M%p")
  end

  def level_unit
    if @session_details.wildcard == "false" || (@session_details.wildcard == "true" && @session_details.wildcard_locked == "true")
      str = "Level #{@session_details.level},Unit #{@session_details.unit}"
    else
      units = @session_details.wildcard_units.split(',')
      length =units.length.to_i
      str = "Level #{((units[0].to_f)/4).ceil }-#{((units[length-1].to_f)/4).ceil},Unit #{units[0]}-#{units[length -1]}"
    end
    str
  end

  def coach_full_name
    !@session_details.teacher.blank? ? ((Coach.find_by_user_name(@session_details.teacher)) ? Coach.find_by_user_name(@session_details.teacher).full_name : "---") : "---"
  end

  def sub_cancelled?
    s= Substitution.find_by_coach_session_id(CoachSession.find_by_eschool_session_id(@session_details.eschool_session_id).id)
    if s && s.cancelled
      return Coach.find(Substitution.find_by_coach_session_id(CoachSession.find_by_eschool_session_id(@session_details.eschool_session_id).id).coach_id).user_name
    else
      return nil
    end
  end

  def is_wildcard?
    @session_details.wildcard == "true" && @session_details.wildcard_locked != "true"
  end

  def specific_level_and_unit?
    if !has_learners?
      return @session_details.wildcard == "false" || (@session_details.wildcard == "true" && @session_details.wildcard_locked == "true")
    else
      return false
    end
  end

  def has_learners?
    !@learners.empty?
  end

  def push_to_eschool_confirm(enable_view_draft_link,view_draft,is_lotus)
    message = ""
    if enable_view_draft_link && !view_draft
      message += is_lotus ? 'This will commit all changes you did and create/modify/remove shifts accordingly. There is a draft for this week, you will lose all the changes saved as draft if you commit shifts from actual schedule.' :
        'This will push all changes you did to eSchool and create/modify/cancel sessions accordingly. There is a draft for this week, you will lose all the changes saved as draft if you push the sessions to eschool from actual schedule.'
    else
      message += is_lotus ? 'This will push all changes you did and create/modify/remove shifts accordingly.' :
        'This will push all changes you did to eSchool and create/modify/cancel sessions accordingly.'
    end

    message += " Do you wish to continue?"
  end

  def is_selected_week_out_of_sequence?(start_of_selected_week, last_pushed_week)
    (start_of_selected_week.to_date - last_pushed_week.to_date).to_i > 7
  end

  def is_selected_week_before_last_pushed_week?(last_pushed_week, start_of_selected_week)
    ((start_of_selected_week.to_date - last_pushed_week.to_date) <= 0 )
  end

end
