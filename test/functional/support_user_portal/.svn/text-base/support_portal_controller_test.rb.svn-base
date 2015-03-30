require File.dirname(__FILE__) + '/../../test_helper'

class SupportUserPortal::SupportPortalControllerTest < ActionController::TestCase

  def test_hit_profile_pages_as_coach
    coach = login_as_coach
    preference_settings = FactoryGirl.create(:preference_setting, :account_id => coach.id, :start_page => 'HOME')
    get :edit_profile
    assert_redirected_to homes_url
    get :view_profile
    assert_redirected_to homes_url
  end

  def test_hit_profile_pages_as_community_moderator
    login_as_custom_user(AdGroup.community_moderator, 'test21')
    get :edit_profile
    assert_response :success
    get :view_profile
    assert_response :success
  end

  def test_hit_profile_pages_as_coach_manager
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    get :edit_profile
    assert_response :success
    get :view_profile
    assert_response :success
  end

  def test_hit_profile_pages_as_support_user
    login_as_custom_user(AdGroup.support_user, 'test21')
    get :edit_profile
    assert_response :success
    get :view_profile
    assert_response :success
  end

  def test_hit_profile_pages_as_support_lead
    login_as_custom_user(AdGroup.support_lead, 'test21')
    get :edit_profile
    assert_response :success
    get :view_profile
    assert_response :success
  end


  def test_hit_profile_pages_as_learner_dashboard_user
    login_as_custom_user(AdGroup.led_user, 'test21')
    get :edit_profile
    assert_response :success
    get :view_profile
    assert_response :success
  end

  def test_submit_support_user_profile
    login_as_custom_user(AdGroup.support_user, 'test21')
    #Without name
    post :edit_profile, :support_user => {:rs_email => "srajgopal@rosttastone.com", :primary_phone => "1234567890", :primary_country_code => "1",:native_language => "en-US", :country => "IN"}, :olang => {"zh-CN"=>"0", "it-IT"=>"0", "ru-RU"=>"0", "de-DE"=>"1", "fr-FR"=>"0", "en-US"=>"1", "pt-BR"=>"0", "ko-KR"=>"1", "es-419"=>"0", "ja-JP"=>"0"}
    assert_response :redirect
    assert_redirected_to view_support_profile_url
    assert_equal _('Profile_updated_successfullyA7192F63'), flash[:notice]
    #Without email
    post :edit_profile, :support_user => {:full_name => "Shyam", :primary_phone => "1234567890", :primary_country_code => "1",:native_language => "en-US", :country => "IN"}, :olang => {"zh-CN"=>"0", "it-IT"=>"0", "ru-RU"=>"0", "de-DE"=>"1", "fr-FR"=>"0", "en-US"=>"1", "pt-BR"=>"0", "ko-KR"=>"1", "es-419"=>"0", "ja-JP"=>"0"}
    assert_response :redirect
    assert_redirected_to view_support_profile_url
    assert_equal _('Profile_updated_successfullyA7192F63'), flash[:notice]
    #Without Timezone
    post :edit_profile, :support_user => {:full_name => "Shyam", :rs_email => "srajgopal@rosttastone.com", :primary_phone => "1234567890", :primary_country_code => "1",  :native_language => "en-US", :country => "IN"}, :olang => {"zh-CN"=>"0", "it-IT"=>"0", "ru-RU"=>"0", "de-DE"=>"1", "fr-FR"=>"0", "en-US"=>"1", "pt-BR"=>"0", "ko-KR"=>"1", "es-419"=>"0", "ja-JP"=>"0"}
    assert_response :redirect
    assert_redirected_to view_support_profile_url
    assert_equal _('Profile_updated_successfullyA7192F63'), flash[:notice]
    #Without Native Language
    post :edit_profile, :support_user => {:full_name => "Shyam", :rs_email => "srajgopal@rosttastone.com", :primary_phone => "1234567890", :primary_country_code => "1", :native_language => "", :country => "IN"}, :olang => {"zh-CN"=>"0", "it-IT"=>"0", "ru-RU"=>"0", "de-DE"=>"1", "fr-FR"=>"0", "en-US"=>"1", "pt-BR"=>"0", "ko-KR"=>"1", "es-419"=>"0", "ja-JP"=>"0"}
    assert_response :redirect
    assert_redirected_to view_support_profile_url
    assert_equal _('Profile_updated_successfullyA7192F63'), flash[:notice]
    #Without Parature Chat URL
    post :edit_profile, :support_user => {:full_name => "Shyam", :rs_email => "srajgopal@rosttastone.com", :primary_phone => "1234567890", :primary_country_code => "1", :native_language => "en-US", :country => "IN"}, :olang => {"zh-CN"=>"0", "it-IT"=>"0", "ru-RU"=>"0", "de-DE"=>"1", "fr-FR"=>"0", "en-US"=>"1", "pt-BR"=>"0", "ko-KR"=>"1", "es-419"=>"0", "ja-JP"=>"0"}
    assert_response :redirect
    assert_redirected_to view_support_profile_url
    assert_equal _('Profile_updated_successfullyA7192F63'), flash[:notice]
    #Complete Profile
    post :edit_profile, :support_user => {:full_name => "Shyam", :rs_email => "srajgopal@rosttastone.com", :primary_phone => "1234567890", :primary_country_code => "1", :native_language => "en-US", :country => "IN"}, :olang => {"zh-CN"=>"0", "it-IT"=>"0", "ru-RU"=>"0", "de-DE"=>"1", "fr-FR"=>"0", "en-US"=>"1", "pt-BR"=>"0", "ko-KR"=>"1", "es-419"=>"0", "ja-JP"=>"0"}
    assert_redirected_to view_support_profile_url
    assert_equal _('Profile_updated_successfullyA7192F63'), flash[:notice]
  end

  def test_submit_support_lead_profile
    login_as_custom_user(AdGroup.support_lead, 'test21')
    #Without name
    post :edit_profile, :support_user => {:rs_email => "srajgopal@rosttastone.com", :primary_phone => "1234567890", :primary_country_code => "1",:native_language => "en-US", :country => "IN"}, :olang => {"zh-CN"=>"0", "it-IT"=>"0", "ru-RU"=>"0", "de-DE"=>"1", "fr-FR"=>"0", "en-US"=>"1", "pt-BR"=>"0", "ko-KR"=>"1", "es-419"=>"0", "ja-JP"=>"0"}
    assert_response :redirect
    assert_redirected_to view_support_profile_url
    assert_equal _('Profile_updated_successfullyA7192F63'), flash[:notice]
    #Without email
    post :edit_profile, :support_user => {:full_name => "Shyam", :primary_phone => "1234567890", :primary_country_code => "1",:native_language => "en-US", :country => "IN"}, :olang => {"zh-CN"=>"0", "it-IT"=>"0", "ru-RU"=>"0", "de-DE"=>"1", "fr-FR"=>"0", "en-US"=>"1", "pt-BR"=>"0", "ko-KR"=>"1", "es-419"=>"0", "ja-JP"=>"0"}
    assert_response :redirect
    assert_redirected_to view_support_profile_url
    assert_equal _('Profile_updated_successfullyA7192F63'), flash[:notice]
    #Without Timezone
    post :edit_profile, :support_user => {:full_name => "Shyam", :rs_email => "srajgopal@rosttastone.com", :primary_phone => "1234567890", :primary_country_code => "1",  :native_language => "en-US", :country => "IN"}, :olang => {"zh-CN"=>"0", "it-IT"=>"0", "ru-RU"=>"0", "de-DE"=>"1", "fr-FR"=>"0", "en-US"=>"1", "pt-BR"=>"0", "ko-KR"=>"1", "es-419"=>"0", "ja-JP"=>"0"}
    assert_response :redirect
    assert_redirected_to view_support_profile_url
    assert_equal _('Profile_updated_successfullyA7192F63'), flash[:notice]
    #Without Native Language
    post :edit_profile, :support_user => {:full_name => "Shyam", :rs_email => "srajgopal@rosttastone.com", :primary_phone => "1234567890", :primary_country_code => "1", :native_language => "", :country => "IN"}, :olang => {"zh-CN"=>"0", "it-IT"=>"0", "ru-RU"=>"0", "de-DE"=>"1", "fr-FR"=>"0", "en-US"=>"1", "pt-BR"=>"0", "ko-KR"=>"1", "es-419"=>"0", "ja-JP"=>"0"}
    assert_response :redirect
    assert_redirected_to view_support_profile_url
    assert_equal _('Profile_updated_successfullyA7192F63'), flash[:notice]
    #Without Parature Chat URL
    post :edit_profile, :support_user => {:full_name => "Shyam", :rs_email => "srajgopal@rosttastone.com", :primary_phone => "1234567890", :primary_country_code => "1", :native_language => "en-US", :country => "IN"}, :olang => {"zh-CN"=>"0", "it-IT"=>"0", "ru-RU"=>"0", "de-DE"=>"1", "fr-FR"=>"0", "en-US"=>"1", "pt-BR"=>"0", "ko-KR"=>"1", "es-419"=>"0", "ja-JP"=>"0"}
    assert_response :redirect
    assert_redirected_to view_support_profile_url
    assert_equal _('Profile_updated_successfullyA7192F63'), flash[:notice]
    #Complete Profile
    post :edit_profile, :support_user => {:full_name => "Shyam", :rs_email => "srajgopal@rosttastone.com", :primary_phone => "1234567890", :primary_country_code => "1", :native_language => "en-US", :country => "IN"}, :olang => {"zh-CN"=>"0", "it-IT"=>"0", "ru-RU"=>"0", "de-DE"=>"1", "fr-FR"=>"0", "en-US"=>"1", "pt-BR"=>"0", "ko-KR"=>"1", "es-419"=>"0", "ja-JP"=>"0"}
    assert_redirected_to view_support_profile_url
    assert_equal _('Profile_updated_successfullyA7192F63'), flash[:notice]
  end

  def test_submit_coach_manager_profile
    stub_eschool_call_for_profile_creation_with_success

    login_as_custom_user(AdGroup.coach_manager, 'test21')
    
    #Complete Profile
    post :edit_profile, :support_user => {:full_name => "Shyam", :rs_email => "srajgopal@rosttastone.com", :primary_phone => "1234567890", :primary_country_code => "1", :native_language => "en-US", :country => "IN"}, :olang => {"zh-CN"=>"0", "it-IT"=>"0", "ru-RU"=>"0", "de-DE"=>"1", "fr-FR"=>"0", "en-US"=>"1", "pt-BR"=>"0", "ko-KR"=>"1", "es-419"=>"0", "ja-JP"=>"0"}
    assert_redirected_to view_support_profile_url
  end

  def test_submit_led_user_profile
    login_as_custom_user(AdGroup.led_user, 'test21')
    #Without name
    post :edit_profile, :support_user => {:rs_email => "srajgopal@rosttastone.com", :primary_phone => "1234567890", :primary_country_code => "1",:native_language => "en-US", :country => "IN"}, :olang => {"zh-CN"=>"0", "it-IT"=>"0", "ru-RU"=>"0", "de-DE"=>"1", "fr-FR"=>"0", "en-US"=>"1", "pt-BR"=>"0", "ko-KR"=>"1", "es-419"=>"0", "ja-JP"=>"0"}
    assert_response :redirect
    assert_redirected_to view_support_profile_url
    assert_equal _('Profile_updated_successfullyA7192F63'), flash[:notice]
    #Without email
    post :edit_profile, :support_user => {:full_name => "Shyam", :primary_phone => "1234567890", :primary_country_code => "1",:native_language => "en-US", :country => "IN"}, :olang => {"zh-CN"=>"0", "it-IT"=>"0", "ru-RU"=>"0", "de-DE"=>"1", "fr-FR"=>"0", "en-US"=>"1", "pt-BR"=>"0", "ko-KR"=>"1", "es-419"=>"0", "ja-JP"=>"0"}
    assert_response :redirect
    assert_redirected_to view_support_profile_url
    assert_equal _('Profile_updated_successfullyA7192F63'), flash[:notice]
    #Without Timezone
    post :edit_profile, :support_user => {:full_name => "Shyam", :rs_email => "srajgopal@rosttastone.com", :primary_phone => "1234567890", :primary_country_code => "1",  :native_language => "en-US", :country => "IN"}, :olang => {"zh-CN"=>"0", "it-IT"=>"0", "ru-RU"=>"0", "de-DE"=>"1", "fr-FR"=>"0", "en-US"=>"1", "pt-BR"=>"0", "ko-KR"=>"1", "es-419"=>"0", "ja-JP"=>"0"}
    assert_response :redirect
    assert_redirected_to view_support_profile_url
    assert_equal _('Profile_updated_successfullyA7192F63'), flash[:notice]
    #Without Native Language
    post :edit_profile, :support_user => {:full_name => "Shyam", :rs_email => "srajgopal@rosttastone.com", :primary_phone => "1234567890", :primary_country_code => "1", :native_language => "", :country => "IN"}, :olang => {"zh-CN"=>"0", "it-IT"=>"0", "ru-RU"=>"0", "de-DE"=>"1", "fr-FR"=>"0", "en-US"=>"1", "pt-BR"=>"0", "ko-KR"=>"1", "es-419"=>"0", "ja-JP"=>"0"}
    assert_response :redirect
    assert_redirected_to view_support_profile_url
    assert_equal _('Profile_updated_successfullyA7192F63'), flash[:notice]
    #Without Parature Chat URL
    post :edit_profile, :support_user => {:full_name => "Shyam", :rs_email => "srajgopal@rosttastone.com", :primary_phone => "1234567890", :primary_country_code => "1", :native_language => "en-US", :country => "IN"}, :olang => {"zh-CN"=>"0", "it-IT"=>"0", "ru-RU"=>"0", "de-DE"=>"1", "fr-FR"=>"0", "en-US"=>"1", "pt-BR"=>"0", "ko-KR"=>"1", "es-419"=>"0", "ja-JP"=>"0"}
    assert_response :redirect
    assert_redirected_to view_support_profile_url
    assert_equal _('Profile_updated_successfullyA7192F63'), flash[:notice]
    #Complete Profile
    post :edit_profile, :support_user => {:full_name => "Shyam", :rs_email => "srajgopal@rosttastone.com", :primary_phone => "1234567890", :primary_country_code => "1", :native_language => "en-US", :country => "IN"}, :olang => {}
    assert_redirected_to view_support_profile_url
    assert_equal _('Profile_updated_successfullyA7192F63'), flash[:notice]
  end

  def test_profile_page_as_coach_manager_it_should_show_is_supervisor_info
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    get :view_profile
    assert_select "label[name='is_supervisor_label']"
    get :edit_profile
    assert_select "input[id='support_user_is_supervisor']"
  end

  def test_hit_profile_pages_as_support_user_should_not_show_is_supervisor_info
    login_as_custom_user(AdGroup.support_user, 'test21')
    get :view_profile
    assert_no_tag 'label', :attributes => {:name => 'is_supervisor_label'}
    get :edit_profile
    assert_no_tag 'input', :attributes => {:id => 'support_user_is_supervisor'}
  end

  def test_hit_profile_pages_as_support_lead_should_not_show_is_supervisor_info
    login_as_custom_user(AdGroup.support_lead, 'test21')
    get :view_profile
    assert_no_tag 'label', :attributes => {:name => 'is_supervisor_label'}
    get :edit_profile
    assert_no_tag 'input', :attributes => {:id => 'support_user_is_supervisor'}
  end

  def test_hit_profile_pages_as_learner_dashboard_user_should_not_show_is_supervisor_info
    login_as_custom_user(AdGroup.led_user, 'test21')
    get :view_profile
    assert_no_tag 'label', :attributes => {:name => 'is_supervisor_label'}
    get :edit_profile
    assert_no_tag 'input', :attributes => {:id => 'support_user_is_supervisor'}
  end

  def test_submit_coach_manager_profile_with_is_supervisor_as_1
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    stub_eschool_call_for_profile_creation_with_success
    post :edit_profile, :support_user => {:full_name => "ShyamAsSupervisor", :rs_email => "srajgopal@rosttastone.com", :primary_phone => "1234567890", :primary_country_code => "1", :native_language => "en-US", :country => "IN", :is_supervisor => 1}, :olang => {"zh-CN"=>"0", "it-IT"=>"0", "ru-RU"=>"0", "de-DE"=>"1", "fr-FR"=>"0", "en-US"=>"1", "pt-BR"=>"0", "ko-KR"=>"1", "es-419"=>"0", "ja-JP"=>"0"}
    assert_redirected_to view_support_profile_url
    account = Account.find_all_by_full_name("ShyamAsSupervisor").first
    assert_equal(true, account.is_supervisor)
  end

  def test_submit_coach_manager_profile_with_is_supervisor_as_0
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    stub_eschool_call_for_profile_creation_with_success
    post :edit_profile, :support_user => {:full_name => "ShyamNotAsSupervisor", :rs_email => "srajgopal@rosttastone.com", :primary_phone => "1234567890", :primary_country_code => "1", :native_language => "en-US", :country => "IN", :is_supervisor => 0}, :olang => {"zh-CN"=>"0", "it-IT"=>"0", "ru-RU"=>"0", "de-DE"=>"1", "fr-FR"=>"0", "en-US"=>"1", "pt-BR"=>"0", "ko-KR"=>"1", "es-419"=>"0", "ja-JP"=>"0"}
    assert_redirected_to view_support_profile_url
    account = Account.find_all_by_full_name("ShyamNotAsSupervisor").first
    assert_equal(false, account.is_supervisor)
  end

  def test_view_profile_page_layout_for_support_user
    login_as_custom_user(AdGroup.support_user, 'test21')
    response = get :view_profile
    assert_response :success
    assert_html_header_layout_tags
  end

  def test_view_profile_page_html_tags_for_support_user
    login_as_custom_user(AdGroup.support_user, 'test21')
    response = get :view_profile
    assert_response :success
    options = {:role => "SupportUser", :is_coach_manager => false}
    assert_view_profile_html_field_tags(options)
  end


  def test_view_profile_page_layout_for_support_lead
    login_as_custom_user(AdGroup.support_user, 'test21')
    get :view_profile
    assert_response :success
    assert_html_header_layout_tags
  end


  def test_view_profile_page_html_tags_for_support_lead
    login_as_custom_user(AdGroup.led_user, 'test21')
    get :view_profile
    assert_response :success
    options = {:role => "LedUser", :is_coach_manager => false}
    assert_view_profile_html_field_tags(options)
  end

  def test_view_profile_page_layout_for_coach_manager
    login_as_custom_user(AdGroup.support_user, 'test21')
    get :view_profile
    assert_response :success
    assert_html_header_layout_tags
  end

  def test_view_profile_page_html_tags_for_coach_manager
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    get :view_profile
    assert_response :success
    options = {:role => "CoachManager", :is_coach_manager => true}
    assert_view_profile_html_field_tags(options)
  end


  def test_edit_profile_page_layout_for_support_user
    login_as_custom_user(AdGroup.support_user, 'test21')
    get :edit_profile
    assert_response :success
    assert_html_header_layout_tags
  end

  def test_edit_profile_page_html_tags_for_support_user
    login_as_custom_user(AdGroup.support_user, 'test21')
    get :edit_profile
    assert_response :success
    options = {:is_coach_manager => false}
    assert_edit_profile_html_field_tags(options)
  end

  def test_edit_profile_page_layout_for_support_lead
    login_as_custom_user(AdGroup.led_user, 'test21')
    get :edit_profile
    assert_response :success
    assert_html_header_layout_tags
  end

  def test_edit_profile_page_html_tags_for_support_lead
    login_as_custom_user(AdGroup.led_user, 'test21')
    get :edit_profile
    assert_response :success
    options = {:is_coach_manager => false}
    assert_edit_profile_html_field_tags(options)
  end

  def test_edit_profile_page_layout_for_coach_manager
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    get :edit_profile
    assert_response :success
    assert_html_header_layout_tags
  end


  def test_edit_profile_page_html_tags_for_coach_manager
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    get :edit_profile
    assert_response :success
    options = {:is_coach_manager => true}
    assert_edit_profile_html_field_tags(options)
  end

  def test_login_as_cm_and_check_for_default_cm_preference_in_ui
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    get :preference_settings
    assert_response :success
    cm = CoachManager.find_by_user_name('test21')
    if cm.is_manager?
      cm_pref = cm.cm_preference
      if cm_pref
        assert_cm_pref cm_pref
      else
        assert_cm_pref
      end
    end
  end

  def test_login_as_cm_and_create_preference_and_check_for_cm_preference_in_ui
    user = login_as_custom_user(AdGroup.support_user, 'test21')
    CmPreference.create(:account_id => user.id, :min_time_to_alert_for_session_with_no_coach => 2, :email_alert_enabled => true)
    get :preference_settings
    assert_response :success
    if user.is_manager?
      cm_pref = user.account.cm_preference
      if cm_pref
        assert_cm_pref cm_pref
      end
    end
  end

  def test_login_as_cm_and_check_how_the_values_get_assigned
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    cm = CoachManager.find_by_user_name('test21')
    get :preference_settings
    assert_response :success
    assert_equal nil, assigns(:cm_preference_setting)
    CoachManager.any_instance.stubs(:update_attributes).returns(CoachManager.new)
    CmPreference.any_instance.stubs(:save).returns(nil)
    PreferenceSetting.any_instance.stubs(:save).returns(true)
    post :preference_settings, :commit=>"Save Preferences", :preference_setting=>{:no_of_home_announcements=>"5", :min_time_to_alert_for_session_with_no_coach=>"2", :substitution_alerts_email=>"0", :start_page=>"CM_MS", :calendar_notices_email=>"0", :account=>{:rs_email=>"test21@rs.com", :aim_id=>"", :native_language=>"en-US", :primary_country_code=>"", :personal_email=>"", :mobile_country_code=>"", :mobile_phone=>"", :skype_id=>"", :primary_phone=>"1234567890"}, :account_id=>"1", :orphaned_session_alert_screen=>"1", :notifications_email=>"0", :no_of_home_events=>"5", :orphaned_session_alert_email=>"0", :no_of_substitution_alerts_to_display=>"3", :substitution_alerts_display_time=>"259200", :no_of_home_notifications=>"5", :receive_reflex_sms_alert => "0"}, :one_time_locale=>"en-US"
    cm_pref_obj = assigns(:cm_preference_setting)
    assert_cm_pref_values(cm,cm_pref_obj)
    PreferenceSetting.any_instance.stubs(:new_record?).returns(false)
    post :preference_settings, :commit=>"Save Preferences", :preference_setting=>{:no_of_home_announcements=>"5", :min_time_to_alert_for_session_with_no_coach=>"2", :substitution_alerts_email=>"0", :start_page=>"CM_MS", :calendar_notices_email=>"0", :account=>{:rs_email=>"test21@rs.com", :aim_id=>"", :native_language=>"en-US", :primary_country_code=>"", :personal_email=>"", :mobile_country_code=>"", :mobile_phone=>"", :skype_id=>"", :primary_phone=>"1234567890"}, :account_id=>"1", :orphaned_session_alert_screen=>"1", :notifications_email=>"0", :no_of_home_events=>"5", :orphaned_session_alert_email=>"0", :no_of_substitution_alerts_to_display=>"3", :substitution_alerts_display_time=>"259200", :no_of_home_notifications=>"5", :receive_reflex_sms_alert => "0"}, :one_time_locale=>"en-US"
    cm_pref_obj = assigns(:cm_preference_setting)
    assert_cm_pref_values(cm,cm_pref_obj)
    cm_pref = CmPreference.create(:account_id => cm.id, :min_time_to_alert_for_session_with_no_coach => 2, :email_alert_enabled => true)
    CmPreference.stubs(:find_by_account_id).returns(cm_pref)
    post :preference_settings, :commit=>"Save Preferences", :preference_setting=>{:no_of_home_announcements=>"5", :min_time_to_alert_for_session_with_no_coach=>"2", :substitution_alerts_email=>"0", :start_page=>"CM_MS", :calendar_notices_email=>"0", :account=>{:rs_email=>"test21@rs.com", :aim_id=>"", :native_language=>"en-US", :primary_country_code=>"", :personal_email=>"", :mobile_country_code=>"", :mobile_phone=>"", :skype_id=>"", :primary_phone=>"1234567890"}, :account_id=>"1", :orphaned_session_alert_screen=>"1", :notifications_email=>"0", :no_of_home_events=>"5", :orphaned_session_alert_email=>"0", :no_of_substitution_alerts_to_display=>"3", :substitution_alerts_display_time=>"259200", :no_of_home_notifications=>"5", :receive_reflex_sms_alert => "0"}, :one_time_locale=>"en-US"
    cm_pref_obj = assigns(:cm_preference_setting)
    assert_cm_pref_values(cm,cm_pref_obj)
  end

  def test_login_as_cm_and_check_how_cm_preference_validation_works
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    cm = CoachManager.find_by_user_name('test21')
    CoachManager.any_instance.stubs(:update_attributes).returns(cm)
    post :preference_settings, :commit=>"Save Preferences", :preference_setting=>{:no_of_home_announcements=>"5", :min_time_to_alert_for_session_with_no_coach=>"2", :substitution_alerts_email=>"0", :start_page=>"CM_MS", :calendar_notices_email=>"0", :account=>{:rs_email=>"test21@rs.com", :aim_id=>"", :native_language=>"en-US", :primary_country_code=>"", :personal_email=>"", :mobile_country_code=>"", :mobile_phone=>"", :skype_id=>"", :primary_phone=>"1234567890"}, :orphaned_session_alert_screen=>"1", :notifications_email=>"0", :no_of_home_events=>"5", :orphaned_session_alert_email=>"1", :orphaned_session_alert_email_type => "PER", :no_of_substitution_alerts_to_display=>"3", :substitution_alerts_display_time=>"259200", :no_of_home_notifications=>"5"}, :one_time_locale=>"en-US"
    assert_match /Please enter a valid email id for Personal mail or select Rosetta mail in Display Preferences/, flash[:error]
    PreferenceSetting.any_instance.stubs(:new_record?).returns(false)
    post :preference_settings, :commit=>"Save Preferences", :preference_setting=>{:no_of_home_announcements=>"5", :min_time_to_alert_for_session_with_no_coach=>"2", :substitution_alerts_email=>"0", :start_page=>"CM_MS", :calendar_notices_email=>"0", :account=>{:rs_email=>"test21@rs.com", :aim_id=>"", :native_language=>"en-US", :primary_country_code=>"", :personal_email=>"", :mobile_country_code=>"", :mobile_phone=>"", :skype_id=>"", :primary_phone=>"1234567890"}, :orphaned_session_alert_screen=>"1", :notifications_email=>"0", :no_of_home_events=>"5", :orphaned_session_alert_email=>"1", :orphaned_session_alert_email_type => "PER", :no_of_substitution_alerts_to_display=>"3", :substitution_alerts_display_time=>"259200", :no_of_home_notifications=>"5"}, :one_time_locale=>"en-US"
    assert_match /Please enter a valid email id for Personal mail or select Rosetta mail in Display Preferences/, flash[:error]
    post :preference_settings, :commit=>"Save Preferences", :preference_setting=>{:no_of_home_announcements=>"5", :min_time_to_alert_for_session_with_no_coach=>"2", :substitution_alerts_email=>"0", :start_page=>"CM_MS", :calendar_notices_email=>"0", :account=>{:rs_email=>"test21@rs.com", :aim_id=>"", :native_language=>"en-US", :primary_country_code=>"", :personal_email=>"", :mobile_country_code=>"", :mobile_phone=>"", :skype_id=>"", :primary_phone=>""}, :orphaned_session_alert_screen=>"1", :notifications_email=>"0", :no_of_home_events=>"5", :orphaned_session_alert_email=>"1", :orphaned_session_alert_email_type => "PER", :no_of_substitution_alerts_to_display=>"3", :substitution_alerts_display_time=>"259200", :no_of_home_notifications=>"5", :receive_reflex_sms_alert => "1"}, :one_time_locale=>"en-US"
    assert_match /Please enter a valid mobile number first to enable SMS alert features/, flash[:error]
    post :preference_settings, :commit=>"Save Preferences", :preference_setting=>{:no_of_home_announcements=>"5", :min_time_to_alert_for_session_with_no_coach=>"2", :substitution_alerts_email=>"0", :start_page=>"CM_MS", :calendar_notices_email=>"0", :account=>{:rs_email=>"test21@rs.com", :aim_id=>"", :native_language=>"en-US", :primary_country_code=>"", :personal_email=>"", :mobile_country_code=>"", :mobile_phone=>"", :skype_id=>"", :primary_phone=>""}, :orphaned_session_alert_screen=>"1", :notifications_email=>"0", :no_of_home_events=>"5", :orphaned_session_alert_email=>"1", :orphaned_session_alert_email_type => "PER", :no_of_substitution_alerts_to_display=>"3", :substitution_alerts_display_time=>"259200", :no_of_home_notifications=>"5", :coach_not_present_alert => "1"}, :one_time_locale=>"en-US"
    assert_match /Please enter a valid mobile number first to enable SMS alert features/, flash[:error]
  end

  def test_login_as_coach_and_check_for_sub_sms_schedule
    login_as_custom_user(AdGroup.coach, 'test21')
    user = Account.find_by_user_name 'test21'
    user.update_attribute(:mobile_phone, '9999999999')
    PreferenceSetting.delete_all
    get :preference_settings
    assert_response :success
    assert_select 'select[id = "preference_setting_substitution_alerts_sms_sending_schedule"]', 0
    assert_select "input[id= 'preference_setting_substitution_alerts_sms'][type= 'checkbox'][checked='checked'][value= '1']"
  end

  def test_login_as_cm_and_check_for_default_cm_preference_in_ui
    login_as_custom_user(AdGroup.coach, 'test21')
    get :preference_settings
    assert_response :success
    assert_not_cm_pref
  end

  def test_preference_settings_page_layout_for_coach
    Coach.any_instance.stubs(:qualifications).returns [Qualification.first]
    login_as_custom_user(AdGroup.coach, 'test21')
    get :preference_settings
    assert_response :success
    assert_html_header_layout_tags
  end

  def test_start_page_for_coach_without_preference_settings
    Coach.any_instance.stubs(:qualifications).returns [Qualification.first]
    login_as_custom_user(AdGroup.coach, 'test21')
    get :preference_settings
    assert_response :success
    assert_preference_settings_html_field_tags
  end

  private

  def assert_html_header_layout_tags
    assert_select 'head'        , :count => 1
    assert_select 'head>link'   , :count => 18
    assert_select 'head>script' 
  end

  def assert_view_profile_html_field_tags(options)
    assert_select 'div[id="content"]>div[id="content-header"]>div'
    assert_select 'h2', :text => "My Profile"

    assert_select 'span[class = "left-space"]>a[href="/support_user_portal/edit-profile"]', :text => "Edit"
    assert_select 'div[class="justclear"]' #single line div
      
    assert_select 'div[id="profile"]' do
      assert_select 'p[class="header"][style="border-bottom: 2px solid gray;"]'
      assert_select 'div[id="general"]' do
        assert_select 'ul[class="col1"]' do
          assert_select 'li>label', "External Id"
          assert_select 'span'    , @request.session[:user].account.id.to_s
          assert_select 'li>label', "Full Name"
          assert_select 'span'    , "N/A"
          assert_select 'li>label', "AD Name"
          assert_select 'span'    , "test21"
          assert_select 'li>label', "Preferred Name"
          assert_select 'span'    , "N/A"
          assert_select 'li>label', "Rosetta Email"
          assert_select 'span'    , "N/A"
          assert_select 'li>label', "Skype ID"
          assert_select 'span'    , "N/A"
          assert_select 'li>label', "AIM ID"
          assert_select 'span'    , "N/A"
          assert_select 'li>label', "Primary Phone"
          assert_select 'span'    , "N/A"
          assert_select 'li>label', "Mobile phone number"
          assert_select 'span'    , "N/A"
          assert_select 'li>label', "Address"
          assert_select 'span'    , "N/A"
          assert_select 'li>label',"Country"
          assert_select 'span'    , "N/A"
          assert_select 'span'    , "N/A"
          assert_select 'span'    , "N/A"
        end
        assert_select 'ul[class="col2"]' do
          assert_select 'li>label'                           , "Role"
          assert_select 'span'                               , options[:role]
          assert_select 'li>label'                           , "Display Language"
          assert_select 'span'                               , @request.session[:user].account.type
          assert_select 'li>label'                           , "Other Language"
          assert_select 'span[style="float:left"]'           , "N/A"
          if options[:is_coach_manager]
            assert_select 'label[name="is_supervisor_label"]', "Is Supervisor?"
            assert_select 'span'                             , "No"
          end
          assert_select 'li>fieldset[class = "profile-fieldset"]>legend>span>div[class = "about_me"]', "About Me"
        end
      end

      assert_select 'div' do
        assert_select 'div[class = "left-space birthdate"]' do
          assert_select 'span[class = "bold-font"]' , "Birthdate"
          assert_select 'span[class = "left-space"]', "N/A"
        end
        assert_select 'div[class = "left-space top_bottom_space"]' #Single line div
      end
    end
  end
    
  def assert_edit_profile_html_field_tags(options)
    assert_select 'div[id="content"]>div[id="content-header"]>div'
    assert_select 'h2', :text => "Edit Profile"

    assert_select 'span[class = "left-space"]>a[href="/support_user_portal/view-profile"]', :text => "Return to My Profile"
    assert_select 'div[class="justclear"]' #single line div

    assert_select 'form[action="/support_user_portal/edit-profile"][id="profile-form"][method="post"][name="profileform"]' do
      assert_select 'div[id="profile"]' do

        assert_select 'p[class="header"][style="border-bottom: 2px solid gray;"]'
        assert_select 'div[id="general"][class="pad-top-20 edit_profile"][style="float:left;"]'
        assert_select 'ul[class="col1"]' do
          if options[:is_coach_manager]
            assert_select 'li>label[for="support_user_full_name"]', "Full Name*"
          else
            assert_select 'li>label[for="support_user_full_name"]', "Full Name"
          end
          assert_select "input[id='support_user_full_name'][name='support_user[full_name]'][size='30'][type='text']"
          assert_select 'li>label[for="support_user_preferred_name"]', "Preferred Name"
          assert_select "input[id='support_user_preferred_name'][name='support_user[preferred_name]'][size='30'][type='text']"
          assert_select 'li>label[for="support_user_address"]', "Address"
          assert_select "textarea[cols='45'][id='support_user_address'][name='support_user[address]'][rows='3']"
          if options[:is_coach_manager]
            assert_select 'li>label[for="support_user_country"]', "Country*"
          else
            assert_select 'li>label[for="support_user_country"]', "Country"
          end
          assert_select "select[id='support_user_country'][name='support_user[country]']" do
            assert_select 'option', :count => 240
          end

          assert_select 'li>label[for="support_user_other_languages"]', "Other Languages"
          assert_select 'input[id="olang-button"][name="olang-button"][type="button"][value="Show"][style="cursor:pointer;"][onclick="otherLangs();"]'
          assert_select 'br[style="clear:both"]'
          assert_select 'label'
          assert_select 'div[id="olang-div"][style="display:none; border:1px solid gray;float:left; padding:5px;"]' do

            assert_select "input[name= 'olang[en-US]'][type= 'hidden'][value='0']"
            assert_select "input[id='olang_en-US'][name='olang[en-US]'][type='checkbox'][value='1']"
            assert_select 'label[for="language_English"]', "English"
            assert_select 'br[style="clear:both"]'

          end

          assert_select 'li>label[for="support_user_bio"]', "About Me"
          assert_select "textarea[cols='45'][id='support_user_bio'][name='support_user[bio]'][rows='3']"
          if options[:is_coach_manager]
            assert_select 'li>label[for="support_user_birth_date"]', "Birthdate*"
          else
            assert_select 'li>label[for="support_user_birth_date"]', "Birthdate"
          end
          assert_select "select[id='support_user_birth_date_1i'][name='support_user[birth_date(1i)]']" do
            assert_select 'option', :count => 61
          end

          assert_select "select[id='support_user_birth_date_2i'][name='support_user[birth_date(2i)]']" do
            assert_select 'option', :count => 12
          end

          assert_select "select[id='support_user_birth_date_3i'][name='support_user[birth_date(3i)]']" do
            assert_select 'option', :count => 31
          end

          assert_select "li>input[id='one_time_locale'][name='one_time_locale'][type='hidden'][value='en-US']"

          if options[:is_coach_manager]
            assert_select "li>label[for='support_user_is_supervisor']", "Is Supervisor?"
            assert_select "input[name='support_user[is_supervisor]'][type='hidden'][value='0']"
            assert_select "input[id='support_user_is_supervisor'][name='support_user[is_supervisor]'][type='checkbox'][value='1']"
          end

          assert_select 'li>div[id="profile-save"]' do
            assert_select 'input[id="support_user_submit"][name="commit"][type="submit"][value="Save"]'
          end

        end
      end
    end
  end

  def assert_cm_pref(cm_pref = nil)
    if cm_pref
      assert_select 'input[id = "preference_setting_orphaned_session_alert_email"][value = "1"]' if cm_pref.email_alert_enabled
      assert_select 'input[id = "preference_setting_orphaned_session_alert_screen"][value = "1"]' if cm_pref.page_alert_enabled
      min_time = cm_pref.min_time_to_alert_for_session_with_no_coach
      assert_select 'select[id = "preference_setting_min_time_to_alert_for_session_with_no_coach"]' do
        assert_select 'option', :count =>3 do
          assert_select 'option[value="'+min_time.to_s+'"][selected="selected"]', :count => 1
        end
      end
    else
      assert_select 'input[id = "preference_setting_orphaned_session_alert_screen"][value = "1"]'
      assert_select 'select[id = "preference_setting_min_time_to_alert_for_session_with_no_coach"]' do
        assert_select 'option', :count =>3 do
          assert_select 'option[value="2"][selected="selected"]', :count => 1
        end
      end
    end
  end

  def assert_cm_pref_values(cm, cm_pref_obj)
    assert_equal cm.id, cm_pref_obj.account_id
    assert_equal false, cm_pref_obj.email_alert_enabled
    assert_equal nil, cm_pref_obj.email_preference
    assert_equal 2, cm_pref_obj.min_time_to_alert_for_session_with_no_coach
    assert_equal true, cm_pref_obj.page_alert_enabled
    assert_equal false, cm_pref_obj.receive_reflex_sms_alert
  end

  def assert_preference_settings_html_field_tags
    assert_select 'div[id="content"]>div[id="content-header"]>div'
    assert_select 'h2', :text => "Contact Preferences"

    assert_select 'span[class = "left-space"]>a[href="/view-profile"]', :text => "Return to My Profile"
    assert_select 'div[class="justclear"]' #single line div

    assert_select 'p[class="header preference-border"]'
    assert_select 'div[id="preference-settings"]' do
      assert_select 'form[action="/support_user_portal/preference-settings"][id="preference-form"][method="post"][name="preferenceform"]'

      assert_select 'fieldset[class = "profile-fieldset"]'
      assert_select 'legend[class = "big-font bold-font legend_border"]', "Contact Preferences"

      assert_select 'table[id="preference-settings-user-table"][class="user_settings"]' do
        assert_select 'tr' do
          assert_select "td[class = 'label_space']>span[class = 'space bold-font']", "Rosetta Email*"
          assert_select "td[class = 'field_space']>input[id='preference_setting_account_rs_email'][name='preference_setting[account][rs_email]'][size='30'][type='text']"
          assert_select "td>span[class = 'space bold-font']", "Mobile phone number"
          assert_select "td"  do
            assert_select "input[id='preference_setting_account_mobile_country_code'][name='preference_setting[account][mobile_country_code]'][size='3'][type='text']"
            assert_select "input[id='preference_setting_account_mobile_phone'][name='preference_setting[account][mobile_phone]'][size='10'][type='text']"
          end
          assert_select "td>span[class = 'space bold-font']", "Skype ID"
          assert_select "td>input[id='preference_setting_account_skype_id'][name='preference_setting[account][skype_id]'][size='30'][type='text']"
        end
      end
    end
  end

  def assert_not_cm_pref
    assert_select 'input[id = "preference_setting_orphaned_session_alert_sms"]', 0
    assert_select 'input[id = "preference_setting_orphaned_session_alert_email"]', 0
    assert_select 'input[id = "preference_setting_orphaned_session_alert_screen"]', 0
    assert_select 'select[id = "preference_setting_min_time_to_alert_for_session_with_no_coach"]', 0
  end

end
