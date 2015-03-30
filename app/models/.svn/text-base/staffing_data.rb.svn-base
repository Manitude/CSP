class StaffingData < ActiveRecord::Base
  set_table_name :staffing_datas
  belongs_to :staffing_file_info 

  def self.report_data_for_a_week(week_id)
    find_all_by_staffing_file_info_id(week_id, :order => 'slot_time')
  end
  
end
