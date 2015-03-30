require File.expand_path('../../../test_helper', __FILE__)

class StaffingHelperTest < ActionView::TestCase
  
  test "options for available weeks" do
    FactoryGirl.create(:staffing_file_info, :start_of_the_week => '2025-05-27 10:00:00', :status => 'Success')
    result = options_for_available_weeks
    
    assert_true result.include? "05/27/2025 - 06/02/2025"
    assert_equal result.scan(/<option/).length, 2
  end

  test "get week range" do
    result = get_week_range('2012-05-27 10:00:00'.to_time)
    assert_equal result, "05/27/2012 - 06/02/2012"
  end
  
end
