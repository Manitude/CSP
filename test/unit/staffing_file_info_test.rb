require File.expand_path('../../test_helper', __FILE__)

class StaffingFileInfoTest < ActiveSupport::TestCase
  
  test 'should return available weeks' do
    file_info = FactoryGirl.create(:staffing_file_info, :start_of_the_week => '2025-05-27 10:00:00', :status => 'Success')
    result = StaffingFileInfo.get_all_available_weeks
    
    assert_equal 1, result.size
    assert_equal file_info.id, result[0]['id']
    assert_equal file_info.start_of_the_week, result[0]['start_of_the_week']
  end

  test 'should not fetch weeks earlier than four weeks' do
    FactoryGirl.create(:staffing_file_info, :start_of_the_week => '2011-05-27 10:00:00', :status => 'Success')
    result = StaffingFileInfo.get_all_available_weeks

    assert_equal 0, result.size
  end

  test 'should only fetch details with success status' do
    FactoryGirl.create(:staffing_file_info, :start_of_the_week => '2025-05-27 10:00:00', :status => 'Error')
    FactoryGirl.create(:staffing_file_info, :start_of_the_week => '2025-02-27 10:00:00', :status => 'Success')
    result = StaffingFileInfo.get_all_available_weeks

    assert_equal 1, result.size
  end

  test 'should fetch success file for a week' do
    FactoryGirl.create(:staffing_file_info, :start_of_the_week => '2025-02-27 10:00:00'.to_time, :status => 'Success')
    FactoryGirl.create(:staffing_file_info, :start_of_the_week => '2025-04-23 10:00:00'.to_time, :status => 'Success')

    result = StaffingFileInfo.find_success_file_for_a_week('2025-04-23 10:00:00'.to_time)
    assert_equal 1, result.size
  end
  
end
