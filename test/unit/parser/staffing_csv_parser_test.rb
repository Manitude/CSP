require File.expand_path('../../../test_helper', __FILE__)

class StaffingCsvParserTest < ActiveSupport::TestCase
  include Validator::StaffingCsvValidator
  def test_perfom
    staffing_file_info = create_staffing_file_info
    staffing_parser = StaffingCsvParser.new(staffing_file_info, current_user)
    staffing_parser.stubs(:validate_data_by_row).returns(update_status(staffing_file_info))
    staffing_file_info.reload
    assert_equal "Invalid file header.", staffing_file_info.messages
    assert_equal "Error", staffing_file_info.status
  end

  private

  def create_staffing_file_info
    file_value = "\"Date\",\"Timesslot\",\"Num_coaches\"\n\"05/13/12\",\"01:00PM\",12\n\"05/13/12\",\"02:00PM\",12\n\"05/13/12\",\"03:00PM\",12\n\"05/13/12\",\"04:00PM\",12\n\"05/13/12\",\"05:00PM\",12\n\"05/13/12\",\"06:00PM\",12\n\"05/13/12\",\"07:00PM\",12\n\"05/13/12\",\"08:00PM\",12\n\"05/13/12\",\"09:00PM\",12\n\"05/13/12\",\"10:00PM\",12\n\"05/13/12\",\"11:00PM\",12\n\"05/14/12\",\"12:00AM\",12\n\"05/14/12\",\"01:00AM\",12\n\"05/14/12\",\"02:00AM\",12\n\"05/14/12\",\"03:00AM\",12\n\"05/14/12\",\"04:00AM\",12\n\"05/14/12\",\"05:00AM\",12\n\"05/14/12\",\"06:00AM\",12\n\"05/14/12\",\"07:00AM\",12\n\"05/14/12\",\"08:00AM\",12\n\"05/14/12\",\"09:00AM\",12\n\"05/14/12\",\"10:00AM\",12\n\"05/14/12\",\"11:00AM\",12\n\"05/14/12\",\"12:00PM\",12\n\"05/14/12\",\"01:00PM\",12\n\"05/14/12\",\"02:00PM\",12\n\"05/14/12\",\"03:00PM\",12\n\"05/14/12\",\"04:00PM\",12\n\"05/14/12\",\"05:00PM\",12\n\"05/14/12\",\"06:00PM\",12\n\"05/14/12\",\"07:00PM\",12\n\"05/14/12\",\"08:00PM\",12\n\"05/14/12\",\"09:00PM\",12\n\"05/14/12\",\"10:00PM\",12\n\"05/14/12\",\"11:00PM\",12\n\"05/15/12\",\"12:00AM\",12\n\"05/15/12\",\"01:00AM\",12\n\"05/15/12\",\"02:00AM\",12\n\"05/15/12\",\"03:00AM\",12\n\"05/15/12\",\"04:00AM\",12\n\"05/15/12\",\"05:00AM\",12\n\"05/15/12\",\"06:00AM\",12\n\"05/15/12\",\"07:00AM\",12\n\"05/15/12\",\"08:00AM\",12\n\"05/15/12\",\"09:00AM\",12\n\"05/15/12\",\"10:00AM\",12\n\"05/15/12\",\"11:00AM\",12\n\"05/15/12\",\"12:00PM\",12\n\"05/15/12\",\"01:00PM\",12\n\"05/15/12\",\"02:00PM\",12\n\"05/15/12\",\"03:00PM\",12\n\"05/15/12\",\"04:00PM\",12\n\"05/15/12\",\"05:00PM\",12\n\"05/15/12\",\"06:00PM\",12\n\"05/15/12\",\"07:00PM\",12\n\"05/15/12\",\"08:00PM\",12\n\"05/15/12\",\"09:00PM\",12\n\"05/15/12\",\"10:00PM\",12\n\"05/15/12\",\"11:00PM\",12\n\"05/16/12\",\"12:00AM\",12\n\"05/16/12\",\"01:00AM\",12\n\"05/16/12\",\"02:00AM\",12\n\"05/16/12\",\"03:00AM\",12\n\"05/16/12\",\"04:00AM\",12\n\"05/16/12\",\"05:00AM\",12\n\"05/16/12\",\"06:00AM\",12\n\"05/16/12\",\"07:00AM\",12\n\"05/16/12\",\"08:00AM\",12\n\"05/16/12\",\"09:00AM\",12\n\"05/16/12\",\"10:00AM\",12\n\"05/16/12\",\"11:00AM\",12\n\"05/16/12\",\"12:00PM\",12\n\"05/16/12\",\"01:00PM\",12\n\"05/16/12\",\"02:00PM\",12\n\"05/16/12\",\"03:00PM\",12\n\"05/16/12\",\"04:00PM\",12\n\"05/16/12\",\"05:00PM\",12\n\"05/16/12\",\"06:00PM\",12\n\"05/16/12\",\"07:00PM\",12\n\"05/16/12\",\"08:00PM\",12\n\"05/16/12\",\"09:00PM\",12\n\"05/16/12\",\"10:00PM\",12\n\"05/16/12\",\"11:00PM\",12\n\"05/17/12\",\"12:00AM\",12\n\"05/17/12\",\"01:00AM\",12\n\"05/17/12\",\"02:00AM\",12\n\"05/17/12\",\"03:00AM\",12\n\"05/17/12\",\"04:00AM\",12\n\"05/17/12\",\"05:00AM\",12\n\"05/17/12\",\"06:00AM\",12\n\"05/17/12\",\"07:00AM\",12\n\"05/17/12\",\"08:00AM\",12\n\"05/17/12\",\"09:00AM\",12\n\"05/17/12\",\"10:00AM\",12\n\"05/17/12\",\"11:00AM\",12\n\"05/17/12\",\"12:00PM\",12\n\"05/17/12\",\"01:00PM\",12\n\"05/17/12\",\"02:00PM\",12\n\"05/17/12\",\"03:00PM\",12\n\"05/17/12\",\"04:00PM\",12\n\"05/17/12\",\"05:00PM\",12\n\"05/17/12\",\"06:00PM\",12\n\"05/17/12\",\"07:00PM\",12\n\"05/17/12\",\"08:00PM\",12\n\"05/17/12\",\"09:00PM\",12\n\"05/17/12\",\"10:00PM\",12\n\"05/17/12\",\"11:00PM\",12\n\"05/18/12\",\"12:00AM\",12\n\"05/18/12\",\"01:00AM\",12\n\"05/18/12\",\"02:00AM\",12\n\"05/18/12\",\"03:00AM\",12\n\"05/18/12\",\"04:00AM\",12\n\"05/18/12\",\"05:00AM\",12\n\"05/18/12\",\"06:00AM\",12\n\"05/18/12\",\"07:00AM\",12\n\"05/18/12\",\"08:00AM\",12\n\"05/18/12\",\"09:00AM\",12\n\"05/18/12\",\"10:00AM\",12\n\"05/18/12\",\"11:00AM\",12\n\"05/18/12\",\"12:00PM\",12\n\"05/18/12\",\"01:00PM\",12\n\"05/18/12\",\"02:00PM\",12\n\"05/18/12\",\"03:00PM\",12\n\"05/18/12\",\"04:00PM\",12\n\"05/18/12\",\"05:00PM\",12\n\"05/18/12\",\"06:00PM\",12\n\"05/18/12\",\"07:00PM\",12\n\"05/18/12\",\"08:00PM\",12\n\"05/18/12\",\"09:00PM\",12\n\"05/18/12\",\"10:00PM\",12\n\"05/18/12\",\"11:00PM\",12\n\"05/19/12\",\"12:00AM\",12\n\"05/19/12\",\"01:00AM\",12\n\"05/19/12\",\"02:00AM\",12\n\"05/19/12\",\"03:00AM\",12\n\"05/19/12\",\"04:00AM\",12\n\"05/19/12\",\"05:00AM\",12\n\"05/19/12\",\"06:00AM\",12\n\"05/19/12\",\"07:00AM\",12\n\"05/19/12\",\"08:00AM\",12\n\"05/19/12\",\"09:00AM\",12\n\"05/19/12\",\"10:00AM\",12\n\"05/19/12\",\"11:00AM\",12\n\"05/19/12\",\"12:00PM\",12\n\"05/19/12\",\"01:00PM\",12\n\"05/19/12\",\"02:00PM\",12\n\"05/19/12\",\"03:00PM\",12\n\"05/19/12\",\"04:00PM\",12\n\"05/19/12\",\"05:00PM\",12\n\"05/19/12\",\"06:00PM\",12\n\"05/19/12\",\"07:00PM\",12\n\"05/19/12\",\"08:00PM\",12\n\"05/19/12\",\"09:00PM\",12\n\"05/19/12\",\"10:00PM\",12\n\"05/19/12\",\"11:00PM\",12\n\"05/20/12\",\"12:00AM\",12\n\"05/20/12\",\"01:00AM\",12\n\"05/20/12\",\"02:00AM\",12\n\"05/20/12\",\"03:00AM\",12\n\"05/20/12\",\"04:00AM\",12\n\"05/20/12\",\"05:00AM\",12\n\"05/20/12\",\"06:00AM\",12\n\"05/20/12\",\"07:00AM\",12\n\"05/20/12\",\"08:00AM\",12\n\"05/20/12\",\"09:00AM\",12\n\"05/20/12\",\"10:00AM\",12\n\"05/20/12\",\"11:00AM\",12\n\"05/20/12\",\"12:00PM\",300\n"
    staffing_file_info =  FactoryGirl.create(:staffing_file_info, :file => file_value )
    stubs(:current_user).returns(staffing_file_info.coach_manager)
    staffing_file_info
  end

  def update_status(staffing_file_info)
    staffing_file_info.update_attributes(:messages => "Invalid file header.", :status => "Error")
    return false
  end
end