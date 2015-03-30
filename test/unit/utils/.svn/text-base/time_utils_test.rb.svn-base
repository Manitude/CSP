require File.expand_path('../../../test_helper', __FILE__)
require 'ostruct'

class TimeUtilsTest < ActiveSupport::TestCase

  def setup
    Thread.stubs(:current).returns(:current_user => OpenStruct.new(:time_zone => 'America/New_York'))
  end

  def test_should_round_week
    assert_equal('2012-08-19 00:00:00 UTC'.to_time, TimeUtils.round_beginning_of_week('2012-08-19 04:00:00 UTC'.to_time))
  end

  def test_should_return_start_of_week_when_date_is_not_provided
    offset = Time.now.in_time_zone('America/New_York').gmt_offset
    assert_equal(Time.now.utc.beginning_of_week - 1.day - offset, TimeUtils.beginning_of_week)
  end

  def test_should_return_start_of_week_when_date_is_provided
    offset = '2012-08-12'.to_time.in_time_zone('America/New_York').gmt_offset
    assert_equal('2012-08-05'.to_time - offset, TimeUtils.beginning_of_week('2012-08-12'.to_time))
  end

  def test_should_return_end_of_week_when_date_is_provided
    offset = '2012-08-12'.to_time.in_time_zone('America/New_York').gmt_offset
    assert_equal('2012-08-12'.to_time - offset - 1.minute, TimeUtils.end_of_week('2012-08-12'.to_time))
  end

  def test_should_return_end_of_week_when_date_is_not_provided
    offset = Time.now.in_time_zone('America/New_York').gmt_offset
    assert_equal(Time.now.utc.beginning_of_week + 6.days - 1.minute - offset, TimeUtils.end_of_week)
  end

  def test_should_return_start_of_week_when_stringified_date_is_provided
    offset = '2012-08-12'.to_time.in_time_zone('America/New_York').gmt_offset
    assert_equal('2012-08-12'.to_time - offset, TimeUtils.beginning_of_week('2012-08-12'))
  end

  def test_should_return_end_of_week_when_stringified_date_is_provided
    offset = '2012-08-19'.to_time.in_time_zone('America/New_York').gmt_offset
    assert_equal('2012-08-19'.to_time - offset - 1.minute, TimeUtils.end_of_week('2012-08-12'))
  end

  def test_is_daylight_switch_week_for_switch_week(start_of_week)
    start_of_week = "2012-11-11 04:00:00".to_time
    assert_false TimeUtils.is_daylight_switch_week?(start_of_week)
  end

  def test_is_daylight_switch_week_for_non_switch_week(start_of_week)
    start_of_week = "2012-09-04 04:00:00".to_time
    assert_true TimeUtils.is_daylight_switch_week?(start_of_week)
  end

  def test_user_offset
    offset = Time.now.in_time_zone('America/New_York').gmt_offset
    assert_equal TimeUtils.offset, offset
  end

  def test_time_zone_map
    assert_equal 'Eastern Time (US & Canada)', TimeUtils.time_zone_map["America/New_York"]
    assert_equal 'Pacific Time (US & Canada)', TimeUtils.time_zone_map["America/Los_Angeles"]
  end

end
