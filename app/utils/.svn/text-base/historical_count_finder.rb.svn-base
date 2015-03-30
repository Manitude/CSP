class HistoricalCountFinder

  def find(start_of_week, sessions_hash, language)
    start_time = TimeUtils.beginning_of_week
    end_time = TimeUtils.end_of_week
    historical_sessions = ConfirmedSession.find_historical_sessions_between(start_time - N.weeks, end_time - 1.week, language)
    historical_sessions.each do |session|
      this_week_time = calculate_this_week_time(start_of_week, session.session_start_time)
      sessions_hash[this_week_time.to_i][:historical_sessions_count] = sessions_hash[this_week_time.to_i][:historical_sessions_count] + session.count_of_sessions
    end
    calculate_historical_sessions_per_slot(sessions_hash)
  end

  def calculate_this_week_time(start_of_week, session_start_time)
    this_week_time = TimeUtils.round_beginning_of_week(start_of_week) + session_start_time.wday.days + session_start_time.hour.hours + session_start_time.min.minutes
    if session_start_time == this_week_time || this_week_time < start_of_week
      return this_week_time + 7.days
    end
    this_week_time
  end

  def calculate_historical_sessions_per_slot(sessions_hash)
    historical_sessions_count = 0
    sessions_hash.each do |time, value|
      historical_count_in_slot = (value[:historical_sessions_count]/N.to_f).ceil
      historical_sessions_count = historical_count_in_slot + historical_sessions_count
      value[:historical_sessions_count] = historical_count_in_slot
    end
    historical_sessions_count
  end

end
