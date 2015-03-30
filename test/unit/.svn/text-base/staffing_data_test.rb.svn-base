require File.expand_path('../../test_helper', __FILE__)

class StaffingDataTest < ActiveSupport::TestCase
  
  test 'should return staffing data for a week' do
    FactoryGirl.create(:staffing_data, :slot_time => Time.now.beginning_of_hour)
    FactoryGirl.create(:staffing_data, :slot_time => Time.now.beginning_of_hour + 1.hour)
    FactoryGirl.create(:staffing_data, :slot_time => Time.now.beginning_of_hour + 2.hour)

    result = StaffingData.report_data_for_a_week(1)
    assert_equal result.size, 3
  end

  test 'should return empty array for unknown week' do
    FactoryGirl.create(:staffing_data, :slot_time => Time.now.beginning_of_hour)
    FactoryGirl.create(:staffing_data, :slot_time => Time.now.beginning_of_hour + 1.hour)
    FactoryGirl.create(:staffing_data, :slot_time => Time.now.beginning_of_hour + 2.hour)

    result = StaffingData.report_data_for_a_week(2)
    assert_equal result.size, 0
  end
  
end
