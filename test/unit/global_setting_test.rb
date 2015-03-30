# To change this template, choose Tools | Templates
# and open the template in the editor.

require File.dirname(__FILE__) + '/../test_helper'

class GlobalSettingTest < ActiveSupport::TestCase

  def test_set_attribute_first_time_sms_alert_attribute
    attribute_hash = {"minutes_before_session_for_triggering_sms_alert" => 12 }
    GlobalSetting.set_attributes(attribute_hash)
    assert_false GlobalSetting.all.empty?
    setting = GlobalSetting.find_by_attribute_name("minutes_before_session_for_triggering_sms_alert")
    assert_equal 12, setting.attribute_value.to_i
  end

  def test_set_attribute_while_updating_existing_setting
    attribute_hash_original = {"minutes_before_session_for_triggering_sms_alert" => 6 }
    GlobalSetting.set_attributes(attribute_hash_original)
    assert_false GlobalSetting.all.empty?
    setting = GlobalSetting.find_by_attribute_name("minutes_before_session_for_triggering_sms_alert")
    assert_equal  6, setting.attribute_value.to_i
    attribute_hash_changed = {"minutes_before_session_for_triggering_sms_alert" => 18 }
    GlobalSetting.set_attributes(attribute_hash_changed)
    same_setting_updated = GlobalSetting.find_by_attribute_name("minutes_before_session_for_triggering_sms_alert")
    assert_equal 18, same_setting_updated.attribute_value.to_i
  end

  def test_set_attribute_with_invalid_values_and_check_records
    default_setting = GlobalSetting.find_by_attribute_name("average_learner_wait_time_threshold")
    attribute_hash = {"average_learner_wait_time_threshold" => '-12', "learner_coach_ratio_threshold" => 'a'}
    GlobalSetting.set_attributes(attribute_hash)
    setting = GlobalSetting.find_by_attribute_name("average_learner_wait_time_threshold")
    assert_equal default_setting, setting
    default_setting = GlobalSetting.find_by_attribute_name("learner_coach_ratio_threshold")
    setting = GlobalSetting.find_by_attribute_name("learner_coach_ratio_threshold")
    assert_equal default_setting, setting
  end

  def test_set_attribute_with_invalid_values_and_check_for_errors
    attribute_hash = {"average_learner_wait_time_threshold" => '-12', "learner_coach_ratio_threshold" => 'a'}
    GlobalSetting.set_attributes(attribute_hash)
    assert_true GlobalSetting.errors.has_key?("learner_coach_ratio_threshold")
    assert_true GlobalSetting.errors.has_key?("average_learner_wait_time_threshold")
  end

  def test_number_validation_default
    invalid_values = ['a5','5a']
    invalid_values.each do |val|
      assert_false GlobalSetting.is_valid_number?(val)
    end
    assert_true GlobalSetting.is_valid_number?('5')
    assert_true GlobalSetting.is_valid_number?('15')
  end

  def test_number_validation_float
    invalid_values = ['17.a', '12..3', '24.']
    invalid_values.each do |val|
      assert_false GlobalSetting.is_valid_number?(val, 'float')
    end
    assert_true GlobalSetting.is_valid_number?('10.10', 'float')
  end

  def test_reset_global_setting_errors
    GlobalSetting.reset_errors
    assert_equal GlobalSetting.errors, {}
  end

  def test_errors
    attribute_hash = {"minutes_before_session_for_triggering_sms_alert" => 0 }
    GlobalSetting.set_attributes(attribute_hash)
    assert_equal "Please select a valid value for SMS alert if coach is not present.", GlobalSetting.errors['minutes_before_session_for_triggering_sms_alert']
    assert_equal GlobalSetting.reset_errors, {}
  end

  def test_set_values
    name = GlobalSetting.find_or_initialize_by_attribute_name("minutes_before_session_for_triggering_sms_alert")
    GlobalSetting.set_values(name, 12, "testing description")
    assert_equal 12, GlobalSetting.find_by_attribute_name("minutes_before_session_for_triggering_sms_alert").attribute_value.to_i
    assert_equal "testing description", GlobalSetting.find_by_attribute_name("minutes_before_session_for_triggering_sms_alert").description
  end

  def test_set_attributes_average_learner_wait_time_threshold
    attribute_hash = {"average_learner_wait_time_threshold" => '12'}
    GlobalSetting.set_attributes(attribute_hash)
    assert_equal GlobalSetting.find_by_attribute_name("average_learner_wait_time_threshold").attribute_value.to_i, 12
    GlobalSetting.set_attributes({"average_learner_wait_time_threshold" => -12})
    assert_equal GlobalSetting.errors["average_learner_wait_time_threshold"], "Average Learner wait time should be a positive Integer."
  end

  def test_set_attributes_learner_coach_ratio_threshold
    attribute_hash = {"learner_coach_ratio_threshold" => '12.1'}
    GlobalSetting.set_attributes(attribute_hash)
    assert_equal 12.1, GlobalSetting.find_by_attribute_name("learner_coach_ratio_threshold").attribute_value.to_f
    GlobalSetting.set_attributes({"learner_coach_ratio_threshold" => -12})
    assert_equal GlobalSetting.errors["learner_coach_ratio_threshold"], "Learner / Coach ratio should be a valid positive number with a maximum of two digits precision."
  end

  def test_set_attributes_seconds_to_refresh_live_sessions_in_dashboard
    attribute_hash = {"seconds_to_refresh_live_sessions_in_dashboard" => '12'}
    GlobalSetting.set_attributes(attribute_hash)
    assert_equal GlobalSetting.find_by_attribute_name("seconds_to_refresh_live_sessions_in_dashboard").attribute_value.to_i, 12
  end

  def test_set_attributes_allow_session_creation_before
    attribute_hash = {"allow_session_creation_before" => '12'}
    GlobalSetting.set_attributes(attribute_hash)
    assert_equal GlobalSetting.find_by_attribute_name("allow_session_creation_before").attribute_value.to_i, 12
  end

  def test_set_attributes_minutes_before_not_to_send_additional_sms
    attribute_hash = {"minutes_before_not_to_send_additional_sms" => '12'}
    GlobalSetting.set_attributes(attribute_hash)
    assert_equal GlobalSetting.find_by_attribute_name("minutes_before_not_to_send_additional_sms").attribute_value.to_i, 12
  end

  def test_set_attributes_last_time_sms_was_triggered_if_coach_not_present
    attribute_hash = {"last_time_sms_was_triggered_if_coach_not_present" => '12'}
    GlobalSetting.set_attributes(attribute_hash)
    assert_equal GlobalSetting.find_by_attribute_name("last_time_sms_was_triggered_if_coach_not_present").attribute_value.to_i, 12
    assert_equal GlobalSetting.find_by_attribute_name("last_time_sms_was_triggered_if_coach_not_present").description, "Time when the last time SMS was triggered after the task ccs:trigger_sms_if_coach_not_present was run.
                         (in UTC, converted to_i)"
  end

  def test_dashboard_refresh_seconds
    object = GlobalSetting.find_or_initialize_by_attribute_name("seconds_to_refresh_live_sessions_in_dashboard")
    GlobalSetting.set_values(object, 12)
    assert_equal 12, GlobalSetting.dashboard_refresh_seconds
    GlobalSetting.delete(object)
    GlobalSetting.dashboard_refresh_seconds
    assert_equal 30, GlobalSetting.dashboard_refresh_seconds
  end

end
