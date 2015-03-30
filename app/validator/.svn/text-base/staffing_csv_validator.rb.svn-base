module Validator
  module StaffingCsvValidator

    def validate_session_slots(datas)
      staffing_file_info = StaffingFileInfo.find(staffing_file_info_id)
      start_of_week = TimeUtils.from_to_time_zone(TimeUtils.format_time(staffing_file_info.start_of_the_week, "%m/%d/%Y %T"), nil, "Seoul")
      end_of_week = daylight_switch(TimeUtils.time_in_user_zone(staffing_file_info.start_of_the_week), start_of_week + 7.day)
      constant_date_time_slots = []
      while start_of_week <= end_of_week do
        constant_date_time_slots << start_of_week.strftime("%m/%d/%y %I:%M %P")
        constant_date_time_slots << start_of_week.strftime("%m/%d/%Y %I:%M %P")
        start_of_week = start_of_week + 30.minutes
      end
      date_and_time_from_csv = datas.keys.map { |e| e.to_time.strftime("%m/%d/%y %I:%M %P") }
      common_slots = constant_date_time_slots & date_and_time_from_csv
      return (date_and_time_from_csv - common_slots).size == 0
    end

    def daylight_switch(start_of_the_week, end_of_week)
      end_of_the_week = (start_of_the_week + 7.day) - 1.hour
      return (end_of_week - 5400.seconds) if !start_of_the_week.dst? && end_of_the_week.dst?
      return (end_of_week + 1800.seconds) if start_of_the_week.dst? && !end_of_the_week.dst?
      return end_of_week - 1800.seconds
    end

    def validate_day_light_switch_week(start_of_the_week)
      end_of_the_week = (start_of_the_week + 7.day) - 1.hour
      !start_of_the_week.dst? && end_of_the_week.dst?
    end

    def validate_data_by_row(row, staffing_file_info, index)
      if index == 0
        unless (row[0].to_s.strip == "Date" && row[1].to_s.strip == "Timeslot" && row[2].to_s.strip == "Num_coaches")
          staffing_file_info.update_attributes(:messages => "Invalid file header.", :status => "Error")
          return false
        else
          return true
        end
      else
        return validate_file_content(row, staffing_file_info, index)
      end
    end

    def validate_file_content(row, staffing_file_info, index)
      begin
        raise "Data Invalid/Missing!" if row.compact.size != 3
        raise "Invalid Number of coaches" unless row[2].to_s.strip =~ /\A[+-]?\d+\Z/
        date_time = "#{row[0]} #{row[1]}"
        begin DateTime.strptime(date_time, '%m/%d/%Y %I:%M %P') rescue raise "Invalid Date/Time format" end
        start_of_week = TimeUtils.time_in_user_zone(staffing_file_info.start_of_the_week)
        date_time =TimeUtils.from_to_time_zone(date_time,"Seoul")
        raise "Date/Time out of Range with the Scheduled Week" unless date_time.utc.between?(start_of_week.utc, (start_of_week + 7.days - 30.minutes).utc)
        return true
      rescue Exception => e
        staffing_file_info.update_attributes(:messages => "#{e.message} at row #{index + 1}", :status => "Error")
        return false
      end
    end

    def validate_time_frame(start_of_week)
      language = Language.find_by_identifier("KLE")
      time_frame = TIME_FRAME[language.session_start_time]
      start_of_week = start_of_week + time_frame.to_i.minutes
    end
  end
end
