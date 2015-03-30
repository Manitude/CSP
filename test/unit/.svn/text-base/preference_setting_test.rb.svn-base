require 'test_helper'

class PreferenceSettingTest < ActiveSupport::TestCase
  fixtures :accounts, :preference_settings

  def setup
    PreferenceSetting.destroy_all
    assert_equal 0, PreferenceSetting.count
  end

  def test_substitution_alerts_email_dependencies_with_value_when_it_is_nil
    options = {
      :record_params                       => "params_without_check_box_selected_or_value",
      :primary_check_box                   => "substitution_alerts_email",
      :primary_check_box_expected          => 0,
      :primary_check_box_dep_1             => "substitution_alerts_email_type",
      :primary_check_box_dep_1_expected    => nil,
      :primary_check_box_dep_2             => "substitution_alerts_email_sending_schedule",
      :primary_check_box_dep_2_expected    => nil
    }
    assert_preference_settings_record_creation(options)
  end

  def test_substitution_alerts_email_dependencies_with_value_when_it_is_not_nil
    options = {
      :record_params                       => "params_with_check_box_selected_or_value",
      :primary_check_box                   => "substitution_alerts_email",
      :primary_check_box_expected          => 1,
      :primary_check_box_dep_1             => "substitution_alerts_email_type",
      :primary_check_box_dep_1_expected    => "RS",
      :primary_check_box_dep_2             => "substitution_alerts_email_sending_schedule",
      :primary_check_box_dep_2_expected    => "IMMEDIATELY"
    }
    assert_preference_settings_record_creation(options)
  end

  def test_notifications_email_dependencies_with_value_when_it_is_nil
    options = {
      :record_params                       => "params_without_check_box_selected_or_value",
      :primary_check_box                   => "notifications_email",
      :primary_check_box_expected          => 0,
      :primary_check_box_dep_1             => "notifications_email_type",
      :primary_check_box_dep_1_expected    => nil,
      :primary_check_box_dep_2             => "notifications_email_sending_schedule",
      :primary_check_box_dep_2_expected    => nil
    }
    assert_preference_settings_record_creation(options)
  end

  def test_notifications_email_dependencies_with_value_when_it_is_not_nil
    options = {
      :record_params                       => "params_with_check_box_selected_or_value",
      :primary_check_box                   => "notifications_email",
      :primary_check_box_expected          => 1,
      :primary_check_box_dep_1             => "notifications_email_type",
      :primary_check_box_dep_1_expected    => "RS",
      :primary_check_box_dep_2             => "notifications_email_sending_schedule",
      :primary_check_box_dep_2_expected    => "IMMEDIATELY"
    }
    assert_preference_settings_record_creation(options)
  end

  def test_calendar_notices_email_dependencies_with_value_when_it_is_nil
    options = {
      :record_params                       => "params_without_check_box_selected_or_value",
      :primary_check_box                   => "calendar_notices_email",
      :primary_check_box_expected          => 0,
      :primary_check_box_dep_1             => "calendar_notices_email_type",
      :primary_check_box_dep_1_expected    => nil,
      :primary_check_box_dep_2             => "calendar_notices_email_sending_schedule",
      :primary_check_box_dep_2_expected    => nil
    }
    assert_preference_settings_record_creation(options)
  end

  def test_calendar_notices_email_dependencies_with_value_when_it_is_not_nil
    options = {
      :record_params                       => "params_with_check_box_selected_or_value",
      :primary_check_box                   => "calendar_notices_email",
      :primary_check_box_expected          => 1,
      :primary_check_box_dep_1             => "calendar_notices_email_type",
      :primary_check_box_dep_1_expected    => "RS",
      :primary_check_box_dep_2             => "calendar_notices_email_sending_schedule",
      :primary_check_box_dep_2_expected    => "IMMEDIATELY"
    }
    assert_preference_settings_record_creation(options)
  end

  def test_substitution_alerts_sms_dependencies_with_value_when_it_is_nil
    options = {
      :record_params                       => "params_without_check_box_selected_or_value",
      :primary_check_box                   => "substitution_alerts_sms",
      :primary_check_box_expected          => 0,
      :primary_check_box_dep_1             => nil,
      :primary_check_box_dep_1_expected    => nil,
      :primary_check_box_dep_2             => nil
    }
    assert_preference_settings_record_creation(options)
  end

  def test_substitution_alerts_sms_dependencies_with_value_when_it_is_not_nil
    options = {
      :record_params                       => "params_with_check_box_selected_or_value",
      :primary_check_box                   => "substitution_alerts_sms",
      :primary_check_box_expected          => 1,
      :primary_check_box_dep_1             => nil,
      :primary_check_box_dep_1_expected    => nil,
      :primary_check_box_dep_2             => nil
    }
    assert_preference_settings_record_creation(options)
  end


  def test_coach_not_present_alert_with_value_when_it_is_nil
    options = {
      :record_params                       => "params_without_check_box_selected_or_value",
      :primary_check_box                   => "coach_not_present_alert",
      :primary_check_box_expected          => 0
    }
    assert_preference_settings_record_creation(options)
  end


  def test_coach_not_present_alert_with_value_when_it_is_not_nil
    options = {
      :record_params                       => "params_with_check_box_selected_or_value",
      :primary_check_box                   => "coach_not_present_alert",
      :primary_check_box_expected          => 1
    }
    assert_preference_settings_record_creation(options)
  end

  def test_substitution_alerts_sms_dependencies_with_value_when_it_is_not_nil
    options = {
      :record_params                       => "params_with_check_box_selected_or_value",
      :primary_check_box                   => "substitution_alerts_sms",
      :primary_check_box_expected          => 1,
      :primary_check_box_dep_1             => nil,
      :primary_check_box_dep_1_expected    => nil,
      :primary_check_box_dep_2             => nil
    }
    assert_preference_settings_record_creation(options)
  end

   test "create a preference setting record and check for validation" do
    cm = CoachManager.find_by_user_name('skumar')
    cm_pref = PreferenceSetting.create(:account_id => cm.id, :substitution_alerts_email => true, :substitution_alerts_email_type => 'PER')
    assert_false cm_pref.save
  end

  private

  def params_with_check_box_selected_or_value
    coach = create_coach_with_qualifications("dutchfellow",[])
    { "notifications_email"                         =>  "1",
      "notifications_email_type"                    =>  "RS",
      "notifications_email_sending_schedule"        =>  "IMMEDIATELY",
      "substitution_alerts_email"                   =>  "1",
      "substitution_alerts_email_type"              =>  "RS",
      "substitution_alerts_email_sending_schedule"  =>  "IMMEDIATELY",
      "calendar_notices_email"                      =>  "1",
      "calendar_notices_email_type"                 =>  "RS",
      "calendar_notices_email_sending_schedule"     =>  "IMMEDIATELY",
      "substitution_alerts_sms"                     =>  "1",
      "coach_not_present_alert"                     =>  "1",
      "account_id"                                  =>  coach.id}
  end

  def params_without_check_box_selected_or_value
    coach = create_coach_with_qualifications("dutchfellow",[])
    { "notifications_email"                         =>  "0",
      "notifications_email_type"                    =>  "RS",
      "notifications_email_sending_schedule"        =>  "IMMEDIATELY",
      "substitution_alerts_email"                   =>  "0",
      "substitution_alerts_email_type"              =>  "RS",
      "substitution_alerts_email_sending_schedule"  =>  "IMMEDIATELY",
      "calendar_notices_email"                      =>  "0",
      "calendar_notices_email_type"                 =>  "RS",
      "calendar_notices_email_sending_schedule"     =>  "IMMEDIATELY",
      "substitution_alerts_sms"                     =>  "0",
      "coach_not_present_alert"                     =>  "0",
      "account_id"                                  =>  coach.id }
  end

  def assert_preference_settings_record_creation(options)
    assert_difference 'PreferenceSetting.count' do
      @preference_settings = PreferenceSetting.create(self.send(options[:record_params]))
      assert_true @preference_settings.errors.empty?
    end
    assert_equal   options[:primary_check_box_expected], @preference_settings.send(options[:primary_check_box])
    unless options[:primary_check_box_dep_1].nil?
      assert_equal options[:primary_check_box_dep_1_expected], @preference_settings.send(options[:primary_check_box_dep_1])
    end
    unless options[:primary_check_box_dep_2].nil?
      assert_equal options[:primary_check_box_dep_2_expected], @preference_settings.send(options[:primary_check_box_dep_2])
    end
  end

end
