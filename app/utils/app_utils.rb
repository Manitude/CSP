module AppUtils

  class << self
    def array_to_single_quotes(array_to_string)
      return "''" if array_to_string.blank?
      array_to_string.map { |element| "'"+element.to_s+"'"}.join(',')

    end

    def dates_for_the_week(start_of_the_week)
      dates = []
      7.times do
        dates << start_of_the_week
        start_of_the_week += 1.day
      end
      dates
    end

    def divide_datetime_array_into_chunks(time_array)
      time_array.inject([]) {|result, time| result += [time, time + 15.minutes, time + 30.minutes, time + 45.minutes] }
    end

    def escape_single_quotes(string_value)
      string_value && string_value.gsub(/[']/, '\\\\\'')
    end

    def form_level_unit(unit)
      unit = unit.to_i
      level = (Float(unit)/Float(4)).ceil
      new_unit = unit > 4 ? (((unit % 4) == 0 ) ? 4 : unit % 4) : unit
      {:level => level, :unit => new_unit}
    end

    def wc_release_date
      TimeUtils.time_in_user_zone("2012-10-14").utc
    end
  end
end
