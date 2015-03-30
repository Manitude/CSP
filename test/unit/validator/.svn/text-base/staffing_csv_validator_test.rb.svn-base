require File.expand_path('../../../test_helper', __FILE__)

class StaffingCsvValidatorTest < ActiveSupport::TestCase
  include Validator::StaffingCsvValidator
  def test_validate_data_by_row_with_valid_header
    row = ["Date", "Timeslot", "Num_coaches"]
    staffing_file_info = create_staffing_file_info
    index = 0
    assert_equal true, validate_data_by_row(row, staffing_file_info, index)
  end

  def test_validate_data_by_row_with_invalid_header
    row = ["Date", "Timeslot"]
    staffing_file_info = create_staffing_file_info
    index = 0
    assert_equal false, validate_data_by_row(row, staffing_file_info, index)
    assert_equal "Invalid file header.", staffing_file_info.messages
    assert_equal "Error", staffing_file_info.status
  end

  def test_validate_data_by_row_with_missing_data
    row = ["05/07/2012","12:00AM"]
    staffing_file_info = create_staffing_file_info
    index = 1
    assert_equal false, validate_data_by_row(row, staffing_file_info, index)
    assert_equal "Data Invalid/Missing! at row #{index + 1}", staffing_file_info.messages
    assert_equal "Error", staffing_file_info.status
  end

  def test_validate_data_by_row_with_invalid_date_data
    row = ["05/07","12:00AM", 12]
    staffing_file_info = create_staffing_file_info
    index = 1
    assert_equal false, validate_data_by_row(row, staffing_file_info, index)
    assert_equal "Invalid Date/Time format at row #{index + 1}", staffing_file_info.messages
    assert_equal "Error", staffing_file_info.status
  end

  def test_validate_data_by_row_with_invalid_time_data
    row = ["05/07/2012","12:00", 12]
    staffing_file_info = create_staffing_file_info
    index = 1
    assert_equal false, validate_data_by_row(row, staffing_file_info, index)
    assert_equal "Invalid Date/Time format at row #{index + 1}", staffing_file_info.messages
    assert_equal "Error", staffing_file_info.status
  end


  def test_validate_data_by_row_with_nil_values
    row = ["05/07/2012","12:00 am", 12]
    staffing_file_info = create_staffing_file_info
    index = 1
    assert_equal false, validate_data_by_row(row, staffing_file_info, index)
    assert_equal "Date/Time out of Range with the Scheduled Week at row #{index + 1}", staffing_file_info.messages
    assert_equal "Error", staffing_file_info.status
  end

  def test_validate_data_by_row_with_invalid_num_of_coaches
    row = ["05/07/2012","12:00 am", "sangeeth"]
    staffing_file_info = create_staffing_file_info
    index = 1
    assert_equal false, validate_data_by_row(row, staffing_file_info, index)
    assert_equal "Invalid Number of coaches at row #{index + 1}", staffing_file_info.messages
    assert_equal "Error", staffing_file_info.status
  end

  def test_validate_data_by_row_with_out_of_date_range
    row = [nil,nil,nil]
    staffing_file_info = create_staffing_file_info
    index = 1
    assert_equal false, validate_data_by_row(row, staffing_file_info, index)
    assert_equal "Data Invalid/Missing! at row #{index + 1}", staffing_file_info.messages
    assert_equal "Error", staffing_file_info.status
  end

  def test_validate_session_slots
    start_time = "05/20/2012 01:00 pm".to_time
    datas = {}
    (2 * 24 * 7).times{|i|
      datas[start_time.strftime("%m/%d/%Y %I:%M %P") ] = "12"
      start_time = start_time + 30.minutes
    }
    datas.delete("05/22/2012 01:00 pm")
    staffing_file_info = create_staffing_file_info
    staffing_file_info.update_attributes(:start_of_the_week => TimeUtils.beginning_of_week("05/20/2012 01:00 pm"))
    assert_true validate_session_slots(datas)
  end

  def test_validate_session_slots_invalid_slots
    datas = {"05/26/2012 06:00 am"=>"12", "05/28/2012 06:00 am"=>"12"}
    staffing_file_info = create_staffing_file_info
    staffing_file_info.update_attributes(:start_of_the_week => TimeUtils.beginning_of_week(datas.keys[0]))
    assert_false validate_session_slots(datas)
  end

  private

  def create_staffing_file_info
    user = FactoryGirl.create(:account, :user_name => "rajkumar")
    staffing_file_info =  FactoryGirl.create(:staffing_file_info, :manager_id => user.id)
    stubs(:current_user_id).returns(staffing_file_info.coach_manager.id)
    stubs(:staffing_file_info_id).returns(staffing_file_info.id)
    staffing_file_info
  end

end
