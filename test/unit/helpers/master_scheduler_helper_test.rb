require File.expand_path('../../../test_helper', __FILE__)

class MasterSchedulerHelperTest < ActionView::TestCase
  
  def test_is_selected_week_out_of_sequence_for_improper_dates
    assert_true is_selected_week_out_of_sequence?("2025-12-29 00:00:00","2025-12-15 00:00:00")
  end

  def test_is_selected_week_out_of_sequence_for_proper_dates
    assert_false is_selected_week_out_of_sequence?("2025-12-22 00:00:00","2025-12-15 00:00:00")
  end

  def test_push_to_eschool_confirm_message_for_non_lotus
    assert_equal "This will push all changes you did to eSchool and create/modify/cancel sessions accordingly. Do you wish to continue?", push_to_eschool_confirm(true,true,false)
  end
  
  def test_push_to_eschool_confirm_message_for_lotus
    assert_equal "This will push all changes you did and create/modify/remove shifts accordingly. Do you wish to continue?", push_to_eschool_confirm(true,true,true)
  end

  def test_is_selected_week_before_last_pushed_week?
    assert_true is_selected_week_before_last_pushed_week?("2025-12-22 00:00:00","2025-12-15 00:00:00")
    assert_true is_selected_week_before_last_pushed_week?("2025-12-22 00:00:00","2025-12-22 05:00:00")
    assert_false is_selected_week_before_last_pushed_week?("2025-12-22 00:00:00","2025-12-29 00:00:00")
  end
end
