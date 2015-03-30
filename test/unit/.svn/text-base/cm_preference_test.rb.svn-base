require File.expand_path('../../test_helper', __FILE__)

class CmPreferenceTest < ActiveSupport::TestCase
  fixtures :accounts
  # Replace this with your real tests.
  def test_create_record_and_check_for_default
    cm = CoachManager.find_by_user_name('skumar')
    cm_pref = CmPreference.create(:account_id => cm.id)
    assert_true cm_pref.page_alert_enabled
    assert_false cm_pref.receive_reflex_sms_alert
    assert_equal 2, cm_pref.min_time_to_alert_for_session_with_no_coach
  end

  def test_create_a_record_and_check_for_validation
    cm = CoachManager.find_by_user_name('skumar')
    cm_pref = CmPreference.create(:account_id => cm.id, :email_alert_enabled => true, :email_preference => 'PER')
    assert_false cm_pref.save
  end
end
