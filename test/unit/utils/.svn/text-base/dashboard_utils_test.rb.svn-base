require File.expand_path('../../../test_helper', __FILE__)
require File.expand_path('../../../../app/utils/dashboard_utils', __FILE__)

class DashboardUtilsTest < Test::Unit::TestCase
  
  def test_calculate_dashboard_values
    now_in_user_zone = TimeUtils.current_slot

  	time_frame_hash = DashboardUtils.calculate_dashboard_values("Next Two Weeks")
    assert_equal now_in_user_zone,  time_frame_hash[:start_time]
    assert_equal now_in_user_zone + 2.week, time_frame_hash[:end_time]
    assert_true time_frame_hash[:future_session?]

    time_frame_hash = DashboardUtils.calculate_dashboard_values("Live Now")
    assert_equal now_in_user_zone,  time_frame_hash[:start_time]
    assert_equal now_in_user_zone + 29.minutes, time_frame_hash[:end_time]
    assert_true time_frame_hash[:future_session?]

    time_frame_hash = DashboardUtils.calculate_dashboard_values("Starting in next hour")
    assert_equal now_in_user_zone,  time_frame_hash[:start_time]
    assert_equal now_in_user_zone + 1.hour, time_frame_hash[:end_time]
    assert_true time_frame_hash[:future_session?]

    time_frame_hash = DashboardUtils.calculate_dashboard_values("Starting in 3 hours")
    assert_equal now_in_user_zone,  time_frame_hash[:start_time]
    assert_equal now_in_user_zone + 3.hour, time_frame_hash[:end_time]
    assert_true time_frame_hash[:future_session?]

    time_frame_hash = DashboardUtils.calculate_dashboard_values("Upcoming sessions in 12 hours")
    assert_equal now_in_user_zone,  time_frame_hash[:start_time]
    assert_equal now_in_user_zone + 12.hour, time_frame_hash[:end_time]
    assert_true time_frame_hash[:future_session?]

    time_frame_hash = DashboardUtils.calculate_dashboard_values("Upcoming sessions in 24 hours")
    assert_equal now_in_user_zone,  time_frame_hash[:start_time]
    assert_equal now_in_user_zone + 24.hour, time_frame_hash[:end_time]
    assert_true time_frame_hash[:future_session?]

    time_frame_hash = DashboardUtils.calculate_dashboard_values("One hour old")
    assert_equal now_in_user_zone - 1.hour,  time_frame_hash[:start_time]
    assert_equal now_in_user_zone, time_frame_hash[:end_time]
    assert_false time_frame_hash[:future_session?]

    time_frame_hash = DashboardUtils.calculate_dashboard_values("3 hours old")
    assert_equal now_in_user_zone - 3.hour,  time_frame_hash[:start_time]
    assert_equal now_in_user_zone, time_frame_hash[:end_time]
    assert_false time_frame_hash[:future_session?]

    time_frame_hash = DashboardUtils.calculate_dashboard_values("Up to 24 hours old")
    assert_equal now_in_user_zone - 24.hour,  time_frame_hash[:start_time]
    assert_equal now_in_user_zone, time_frame_hash[:end_time]
    assert_false time_frame_hash[:future_session?]

    time_frame_hash = DashboardUtils.calculate_dashboard_values("Up to 7 days old")
    assert_equal now_in_user_zone - 7.days,  time_frame_hash[:start_time]
    assert_equal now_in_user_zone, time_frame_hash[:end_time]
    assert_false time_frame_hash[:future_session?]

    time_frame_hash = DashboardUtils.calculate_dashboard_values("Up to 30 days old")
    assert_equal now_in_user_zone - 30.days,  time_frame_hash[:start_time]
    assert_equal now_in_user_zone, time_frame_hash[:end_time]
    assert_false time_frame_hash[:future_session?]
  end
  
end

