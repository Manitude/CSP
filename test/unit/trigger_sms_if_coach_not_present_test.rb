require File.dirname(__FILE__) + '/../test_helper'
require 'rake'
load File.dirname(__FILE__) + '/../../lib/tasks/trigger_sms_if_coach_not_present.rake'

class CoachNotArrivedAlertTest < ActiveSupport::TestCase

  def test_check_task_rerun_required_yes
    value_of_x = {"minutes_before_session_for_triggering_sms_alert" => 10 }
    GlobalSetting.set_attributes(value_of_x)

    last_run_time = (Time.now.utc - 15.minutes).to_i
    last_run_setting = {"last_time_sms_was_triggered_if_coach_not_present" => last_run_time }
    GlobalSetting.set_attributes(last_run_setting)

    assert_true task_rerun_required?
  end

  def test_check_task_rerun_required_no
    value_of_x = {"minutes_before_session_for_triggering_sms_alert" => 10 }
    GlobalSetting.set_attributes(value_of_x)

    last_run_time = (Time.now.utc - 5.minutes).to_i
    last_run_setting = {"last_time_sms_was_triggered_if_coach_not_present" => last_run_time }
    GlobalSetting.set_attributes(last_run_setting)

    assert_false task_rerun_required?
  end

  def test_get_phone_no_details_returns_nothing
    teacher = mock('account')
    teacher.expects(:primary_country_code).returns(nil)
    teacher.expects(:primary_phone).returns(nil)
    assert_blank get_phone_no_details(teacher)
  end

  def test_get_phone_no_details_returns_nothing_when_primary_phone_is_nil
    teacher = mock('account')
    teacher.expects(:primary_country_code).returns('91')
    teacher.expects(:primary_phone).returns(nil)
    assert_blank get_phone_no_details(teacher)
  end

  def test_get_phone_no_details_returns_primary_phone_despite_nil_primary_code
    teacher = mock('account')
    teacher.expects(:primary_country_code).returns(nil)
    teacher.expects(:primary_phone).returns('9999999999')
    assert_equal "(Ph: 9999999999) ", get_phone_no_details(teacher)
  end

  def test_get_phone_no_details_returns_full_details
    teacher = mock('account')
    teacher.expects(:primary_country_code).returns('91')
    teacher.expects(:primary_phone).returns('9999999999')
    assert_equal "(Ph: 91-9999999999) ", get_phone_no_details(teacher)
  end
end
