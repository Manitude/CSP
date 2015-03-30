require 'faster_csv'
require File.expand_path('../../validator/staffing_csv_validator', __FILE__)


  class StaffingCsvParser < Struct.new(:staffing_file_info_id, :current_user_id)

    include Validator::StaffingCsvValidator

    def perform
      staffing_file_info = StaffingFileInfo.find(staffing_file_info_id)
      current_user = CoachManager.find(current_user_id)
      begin
        start_week = TimeUtils.time_in_user_zone(staffing_file_info.start_of_the_week)
        @parsed_file = FasterCSV.parse(staffing_file_info.file)
        count = 0
        datas = {}
        @parsed_file.each  do |row|
          if !(validate_data_by_row(row, staffing_file_info, count))
            break
          end
          if datas.has_key?("#{row[0].strip} #{row[1].strip}".downcase)
            staffing_file_info.update_attributes(:messages => "Duplicate Session slots at row no.#{count + 1}", :status => "Error")
            break
          else
            datas["#{row[0].strip} #{row[1].strip}".downcase] = row[2] if count > 0
          end
          count += 1
        end
        unless staffing_file_info.status == "Error"
          datas_size = validate_day_light_switch_week(start_week) ? 334 : 336
          datas.size == datas_size ? (validate_session_slots(datas) ? create_or_update_staffing_data(datas) : staffing_file_info.update_attributes(:messages => "Invalid session slots", :status => "Error") ) : (datas.size != 0 ? staffing_file_info.update_attributes(:messages => "More/less data in CSV file", :status => "Error") : staffing_file_info.update_attributes(:messages => "No/Empty data ", :status => "Error"))
        end
      rescue Exception => e
        puts "Error #{e.message} \n #{e.backtrace}"
        staffing_file_info.update_attributes(:messages => "#{e.message}", :status => "Error")
      end
    end

    def create_or_update_staffing_data(datas)
      staffing_file_info = StaffingFileInfo.find(staffing_file_info_id)
      datas.each do |date_time, number_of_coaches|
        datetime = TimeUtils.from_to_time_zone(date_time,"Seoul")
        options = {:number_of_coaches => number_of_coaches, :staffing_file_info_id => staffing_file_info.id}
        staffing_data = StaffingData.find_or_create_by_slot_time(datetime)
        staffing_data.update_attributes(options)
      end
      puts "updating status"
      staffing_file_info.update_attributes(:status => "Success", :records_created => staffing_file_info.staffing_datas.size)
      old_staffing_file_info = StaffingFileInfo.where("id != ? and status = ? and start_of_the_week =?", staffing_file_info.id, "Success", staffing_file_info.start_of_the_week).first
      old_staffing_file_info.delete if old_staffing_file_info
    end
  end
