class TimeUtils
  class << self
    
    def round_beginning_of_week(time)
      beginning_of_week = time.beginning_of_week
      next_week = time.next_week
      if (Time.now - beginning_of_week) < (Time.now - next_week)
        return beginning_of_week - 1.day
      else
        next_week - 1.day
      end
    end

    def time_zone
      user = Thread.current[:account]
      user ? user.time_zone : 'Eastern Time (US & Canada)'
    end

    def current_slot(is_aria = false)
      time = time_in_user_zone
      from_time =  time.beginning_of_hour
      from_time += 30.minutes if time.min >= 30 && !is_aria
      from_time.utc
    end

    def return_other_half(time)
      return time - 30.minutes if time.min == 30
      return time + 30.minutes
    end 

    def return_other_half_end_time(time) 
      return time + 30.minutes if time.min == 30
      return time - 30.minutes
    end

    def offset(date = nil)
      time_in_user_zone(date).gmt_offset
    end

    def beginning_of_week(date = nil)
      beginning_of_week_for_user(date).utc
    end

    def end_of_week(date = nil)
      end_of_week_for_user(date).utc
    end

    def beginning_of_week_for_user(date = nil)
      date = time_in_user_zone(date)
      (date - date.wday.day).midnight
    end

    def format_time(date = nil, format = "%b %d, %Y %H:%M %Z")
      time_in_user_zone(date).strftime(format)
    end

    def time_in_user_zone(date = nil)
      if date && !date.is_a?(Time)
        begin
          if date.is_a?(String)
            date = date.to_time.in_time_zone(time_zone)
            date = date - date.gmt_offset
          elsif date.is_a?(Integer)
            date = Time.at(date)
          else
            date = nil
          end
        rescue
          date = nil
        end
      end
      date = Time.now if date.nil?
      date.in_time_zone(time_zone)
    end

    def end_of_week_for_user(date = nil)
      beginning_of_week_for_user(date) + 7.days - 1.minute
    end

    def week_extremes_for_user(date = nil)
      week_start = beginning_of_week_for_user(date)
      [week_start, week_start + 7.days - 1.minute]
    end

    def daylight_shift(created_at, datetime)
      offset(datetime) - offset(created_at)
    end

    def possible_daylight_shift(datetime)
      return 0 if offset("2013-01-15") == offset("2013-07-15")
      time_in_user_zone(datetime).dst? ? 1.hour : -1.hour
    end

    def is_daylight_switch_week?(start_of_week)
      time_in_user_zone(start_of_week).dst? != time_in_user_zone(start_of_week + 1.week).dst?
    end

    def time_zone_map
      MemcacheService.cache('time_zone_mapping', 1.year) do
        mapping =  {}
        ActiveSupport::TimeZone::MAPPING.each{|key, value| mapping[value] = key}
        mapping
      end
    end
  
    # Convert a date from one time zone to other. default zone = current user zone
    def from_to_time_zone(date, from = nil, to = nil)
      date = date.to_time
      offset = date.in_time_zone(from || time_zone).utc_offset
      (date - offset).to_time.in_time_zone(to || time_zone)
    end
  
  end
end
