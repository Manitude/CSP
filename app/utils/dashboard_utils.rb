class DashboardUtils

  def self.future_time_frames
    ['Live Now', 'Next Two Weeks', 'Starting in next hour', 'Starting in 3 hours' ,'Upcoming sessions in 12 hours', 'Upcoming sessions in 24 hours']
  end

  def self.past_time_frames
    ['One hour old', '3 hours old', 'Up to 24 hours old', 'Up to 7 days old', 'Up to 30 days old']
  end

  def self.calculate_dashboard_values(time_frame)
    res = {:future_session? => future_time_frames.include?(time_frame)}
    res[:start_time] = TimeUtils.current_slot
    res[:end_time] = res[:start_time]
    
    case time_frame
    when "Next Two Weeks"
      res[:end_time] += 2.week
    when "Starting in next hour"
      res[:end_time] += 1.hour
    when "Starting in 3 hours"
      res[:end_time] += 3.hour
    when "Upcoming sessions in 12 hours"
      res[:end_time] += 12.hour
    when "Upcoming sessions in 24 hours"
      res[:end_time] += 24.hour
    when "One hour old"
      res[:start_time] -= 1.hour
    when "3 hours old"
      res[:start_time] -= 3.hour
    when "Up to 24 hours old"
      res[:start_time] -= 24.hour
    when "Up to 7 days old"
      res[:start_time] -= 7.days
    when "Up to 30 days old"
      res[:start_time] -= 30.days
    else
      res[:end_time] += 29.minutes
    end

    res
  end

end
