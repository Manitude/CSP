if defined?(ActiveSupport::TimeZone) # Rails 2.0 doesn't have this

  # In javascript (and maybe Actionscript) clients, it is easier to find the
  #  utc offset than the timezone name, so this lets us use the offset we get from
  #  a client to access some of the awesome methods on Time
  class RosettaStone::TimeWithOffset
    include Comparable
    attr_reader :utc_time, :offset_seconds

    def initialize(time, offset_seconds)
      @utc_time = time.utc
      @offset_seconds = offset_seconds
    end

    def utc
      utc_time
    end

    def <=>(other_time_with_offset)
      raise "Can't compare #{self.class} with #{other_time_with_offset.class}" unless other_time_with_offset.is_a?(self.class)
      utc <=> other_time_with_offset.utc
    end

    def - (arg)
      if arg.is_a?(Numeric)
        return self + -(arg)
      else
        return self.utc - arg.utc
      end
    end

    def + (number_of_seconds)
      RosettaStone::TimeWithOffset.new(utc_time + number_of_seconds, offset_seconds)
    end

    # Returns the numeric hour of the day, which needs to be between 0-23.
    # Adding the offset_hours might make the number > 23, so that's why it's
    # adjusted by subtracting (24*day_offset).
    def hour
      utc_time.hour + offset_hours - 24*day_offset
    end

    def offset_hours
      offset_seconds.to_f / 1.hour
    end

    def midnight
      # could implement it this way if we defined minute and second:
      #  self - (self.hour*1.hour + 1.minute*self.minute + self.second)
      self.class.new(utc_time.midnight + day_offset.days - offset_seconds, offset_seconds)
    end
    alias_method :start_of_day, :midnight
    alias_method :beginning_of_day, :midnight

    def end_of_day
      midnight - 1.second + 1.day
    end

    # is the offset time
    # - the same day as the corresponding utc time: 0
    # - the day before the corresponding utc time: -1
    # - the day after the corresponding utc time: 1
    def day_offset
      return year_offset unless year_offset == 0
      return month_offset unless month_offset == 0
      (utc_time + offset_seconds).day - utc_time.day
    end

    # is the offset time
    # - the same month as the corresponding utc time: 0
    # - the month before the corresponding utc time: -1
    # - the month after the corresponding utc time: 1
    def month_offset
      return year_offset unless year_offset == 0
      (utc_time + offset_seconds).month - utc_time.month
    end

    # is the offset time
    # - the same year as the corresponding utc time: 0
    # - the year before the corresponding utc time: -1
    # - the year after the corresponding utc time: 1
    def year_offset
      (utc_time + offset_seconds).year - utc_time.year
    end

    # weekday
    def wday
      value = utc_time.wday + day_offset
      if value == -1
        6
      elsif value == 7
        0
      else
        value
      end
    end

  end
end