require File.dirname(__FILE__) + '/../test_helper'
require 'rake'
load File.dirname(__FILE__) + '/../../lib/tasks/alert_sms.rake'

class AlertSmsReflexAlertTest < ActionController::TestCase

  def test_should_not_send_sms_for_inactive_cm
    CoachManager.delete_all
    FactoryGirl.create(:account, :active => false)
    CoachManager.any_instance.expects(:send_sms).never
    send_sms_to_managers("Test msg")
  end

  def test_should_not_send_sms_for_unsubscribed_cm
    CoachManager.delete_all
    FactoryGirl.create(:account)
    CoachManager.any_instance.expects(:send_sms).never
    send_sms_to_managers("Test msg")
  end

  def test_send_sms
    cm = FactoryGirl.create(:account)
    FactoryGirl.create(:cm_preference, :account_id => cm.id, :receive_reflex_sms_alert => true)
    CoachManager.any_instance.expects(:send_sms).with(instance_of String).returns(true)
    send_sms_to_managers("Test msg")
  end

  def test_run_required_yes_coz_it_never_ran
    assert_true run_required?(1), "Task neve ran. So run is required."
  end

  def test_run_required_returns_no_coz_it_just_ran
    set_last_run
    assert_false run_required?(1), "Task ran just now. Run should not be required."
  end

  def test_run_required_returns_no_or_yes_depending_on_time_to_wait
    reflex_alert_sms = TaskTracer.find_or_initialize_by_task_name 'reflex_alert'
    reflex_alert_sms.update_attributes(:last_successful_run => Time.now - 5.minutes)
    assert_true run_required?(1)
    assert_false run_required?(10)
  end
end
