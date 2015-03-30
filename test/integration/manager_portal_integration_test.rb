require File.expand_path('../../test_helper', __FILE__)
require 'coach_portal_controller'
require 'manager_portal_controller'

class ManagerPortalIntegrationTest  < ActionController::TestCase

  def test_create_a_template_for_coach_and_check_for_notification
    login_as_coach_manager('manager')
    coach = create_a_coach
    language = Language.create(:identifier => 'ESP')
    coach.qualifications.create(:language_id => language.id, :max_unit => 12)

    @controller = ManagerPortalController.new
    post  :view_coach_profiles, :coach_id => coach.id
    assert_response :success
    get :sign_in_as_my_coach, :coach_id => coach.id
    assert_response :redirect
    assert_match "Signed in as", flash[:notice]
  end

  # def test_request_for_substitute_and_check_for_substitution_alert
  #   stub_eschool_call_for_find_by_ids
  #   user = User.new('skumar')
  #   user.groups = [AdGroup.coach_manager]
  #   user.find_or_create_account
  #   @request.session[:user] = user
  #   User.stubs(:authenticate).returns user #Simulate a success authentication
  #   manager = CoachManager.find_by_user_name('skumar')
  #   coach = manager.coaches.detect{|d| d.user_name=='psubramanian'} if manager

  #   if coach
  #     @controller = ManagerPortalController.new
  #     t=Time.now.in_time_zone("Eastern Time (US & Canada)").beginning_of_hour+4.hours
  #     Coach.any_instance.stubs(:qualifications).returns [Qualification.first]
  #     get :sign_in_as_my_coach, :coach_id=>coach.id
  #     assert_response :redirect
  #     assert_match "Signed in as", flash[:notice]
  #     @controller = CoachPortalController.new
  #     get :calendar_week ,:start_date=>t.strftime("%Y-%m-%d")
  #     CoachSession.any_instance.stubs(:learners_signed_up).returns 1
  #     LocalSession.any_instance.stubs(:reflex?).returns false
  #     Eschool::Session.stubs(:substitute).returns nil
  #     Eschool::Session.stubs(:find_by_id).returns nil
  #     # We seem to have several orphaned qualifications
  #     Qualification.any_instance.stubs(:coach_id).returns coach.id
  #     post :request_substitute, :learners_count=>"1",  :time=>t
  #     assert_redirected_to calendar_week_path(:start_date=>t.strftime("%Y-%m-%d"))
  #     assert_response :redirect
  #   end

  # end

  
  def test_start_page_for_coach_manager_with_default_preference_settings
    @controller = CoachPortalController.new
    stub_ldap_authentication_for_coach_manager
    coach_manager = assert_coach_manager_doesnt_have_preference_setting

    post :login, :coach => {:user_name => coach_manager.user_name, :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    assert_redirected_to schedules_url
  end

  def test_start_page_for_coach_with_home_as_start_page_in_preference_settings
    @controller = CoachPortalController.new
    stub_ldap_authentication_for_coach_manager
    coach_manager = assert_coach_manager_doesnt_have_preference_setting
    coach_manager.get_preference.update_attribute(:start_page, COACH_MANAGER_START_PAGES["Home"])
    assert_equal COACH_MANAGER_START_PAGES["Home"], coach_manager.get_preference.start_page

    post :login, :coach => {:user_name => coach_manager.user_name, :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    assert_redirected_to self.send(START_PAGE_URLS[COACH_MANAGER_START_PAGES["Home"]])
  end

  def test_start_page_for_coach_manager_with_announcements_as_start_page_in_preference_settings
    @controller = CoachPortalController.new
    stub_ldap_authentication_for_coach_manager
    coach_manager = assert_coach_manager_doesnt_have_preference_setting
    coach_manager.get_preference.update_attribute(:start_page, COACH_MANAGER_START_PAGES["Announcements"])
    assert_equal COACH_MANAGER_START_PAGES["Announcements"], coach_manager.get_preference.start_page

    post :login, :coach => {:user_name => coach_manager.user_name, :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    assert_redirected_to self.send(START_PAGE_URLS[COACH_MANAGER_START_PAGES["Announcements"]])
  end

  def test_start_page_for_coach_manager_with_events_as_start_page_in_preference_settings
    @controller = CoachPortalController.new
    stub_ldap_authentication_for_coach_manager
    coach_manager = assert_coach_manager_doesnt_have_preference_setting
    coach_manager.get_preference.update_attribute(:start_page, COACH_MANAGER_START_PAGES["Events"])
    assert_equal COACH_MANAGER_START_PAGES["Events"], coach_manager.get_preference.start_page

    post :login, :coach => {:user_name => coach_manager.user_name, :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    assert_redirected_to self.send(START_PAGE_URLS[COACH_MANAGER_START_PAGES["Events"]])
  end

  def test_start_page_for_coach_manager_with_notifications_as_start_page_in_preference_settings
    @controller = CoachPortalController.new
    stub_ldap_authentication_for_coach_manager
    coach_manager = assert_coach_manager_doesnt_have_preference_setting
    coach_manager.get_preference.update_attribute(:start_page, COACH_MANAGER_START_PAGES["Notifications"])
    assert_equal COACH_MANAGER_START_PAGES["Notifications"], coach_manager.get_preference.start_page

    post :login, :coach => {:user_name => coach_manager.user_name, :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    assert_redirected_to self.send(START_PAGE_URLS[COACH_MANAGER_START_PAGES["Notifications"]])
  end

  def test_start_page_for_coach_manager_with_dashboard_as_start_page_in_preference_settings
    @controller = CoachPortalController.new
    stub_ldap_authentication_for_coach_manager
    coach_manager = assert_coach_manager_doesnt_have_preference_setting
    coach_manager.get_preference.update_attribute(:start_page, COACH_MANAGER_START_PAGES["Dashboard"])
    assert_equal COACH_MANAGER_START_PAGES["Dashboard"], coach_manager.get_preference.start_page

    post :login, :coach => {:user_name => coach_manager.user_name, :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    assert_redirected_to self.send(START_PAGE_URLS[COACH_MANAGER_START_PAGES["Dashboard"]])
  end

  def test_start_page_for_coach_manager_with_substitutions_as_start_page_in_preference_settings
    @controller = CoachPortalController.new
    stub_ldap_authentication_for_coach_manager
    coach_manager = assert_coach_manager_doesnt_have_preference_setting
    coach_manager.get_preference.update_attribute(:start_page, COACH_MANAGER_START_PAGES["Substitutions"])
    assert_equal COACH_MANAGER_START_PAGES["Substitutions"], coach_manager.get_preference.start_page
    post :login, :coach => {:user_name => coach_manager.user_name, :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    assert_redirected_to self.send(START_PAGE_URLS[COACH_MANAGER_START_PAGES["Substitutions"]])
  end


  def test_start_page_for_coach_manager_with_master_scheduler_as_start_page_in_preference_settings
    @controller = CoachPortalController.new
    stub_ldap_authentication_for_coach_manager
    coach_manager = assert_coach_manager_doesnt_have_preference_setting
    coach_manager.get_preference.update_attribute(:start_page, COACH_MANAGER_START_PAGES["Master Scheduler"])
    assert_equal COACH_MANAGER_START_PAGES["Master Scheduler"], coach_manager.get_preference.start_page

    post :login, :coach => {:user_name => coach_manager.user_name, :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    assert_redirected_to self.send(START_PAGE_URLS[COACH_MANAGER_START_PAGES["Master Scheduler"]])
  end

 
  def test_start_page_for_support_user_without_preference_settings
    @controller = CoachPortalController.new
    stub_ldap_authentication_for_support_user
    support_user = assert_support_user_doesnt_have_preference_setting

    post :login, :coach => {:user_name => support_user.user_name, :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    assert_redirected_to dashboard_url
  end

  def test_start_page_for_support_user_with_profile_as_start_page_in_preference_settings
    @controller = CoachPortalController.new
    stub_ldap_authentication_for_support_user
    support_user = assert_support_user_doesnt_have_preference_setting
    support_user.get_preference.update_attribute(:start_page, SUPPORT_USER_LEAD_START_PAGES["Profile"])
    assert_equal SUPPORT_USER_LEAD_START_PAGES["Profile"], support_user.get_preference.start_page

    post :login, :coach => {:user_name => support_user.user_name, :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    assert_redirected_to self.send(START_PAGE_URLS[SUPPORT_USER_LEAD_START_PAGES["Profile"]])
  end

  def test_start_page_for_support_user_with_learner_earch_as_start_page_in_preference_settings
    @controller = CoachPortalController.new
    stub_ldap_authentication_for_support_user
    support_user = assert_support_user_doesnt_have_preference_setting
    support_user.get_preference.update_attribute(:start_page, SUPPORT_USER_LEAD_START_PAGES["Learner Search"])
    assert_equal SUPPORT_USER_LEAD_START_PAGES["Learner Search"], support_user.get_preference.start_page

    post :login, :coach => {:user_name => support_user.user_name, :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    assert_redirected_to self.send(START_PAGE_URLS[SUPPORT_USER_LEAD_START_PAGES["Learner Search"]])
  end
  
  def test_start_page_for_support_user_with_dashboard_as_start_page_in_preference_settings
    @controller = CoachPortalController.new
    stub_ldap_authentication_for_support_user
    support_user = assert_support_user_doesnt_have_preference_setting
    support_user.get_preference.update_attribute(:start_page, SUPPORT_USER_LEAD_START_PAGES["Dashboard"])
    assert_equal SUPPORT_USER_LEAD_START_PAGES["Dashboard"], support_user.get_preference.start_page

    post :login, :coach => {:user_name => support_user.user_name, :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    assert_redirected_to self.send(START_PAGE_URLS[SUPPORT_USER_LEAD_START_PAGES["Dashboard"]])
  end

  def test_start_page_for_support_lead_with_default_preference_settings
    @controller = CoachPortalController.new
    stub_ldap_authentication_for_support_lead
    support_lead = assert_support_lead_doesnt_have_preference_setting

    post :login, :coach => {:user_name => support_lead.user_name, :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    assert_redirected_to dashboard_url
  end

  def test_start_page_for_support_lead_with_profile_as_start_page_in_preference_settings
    @controller = CoachPortalController.new
    stub_ldap_authentication_for_support_lead
    support_lead = assert_support_lead_doesnt_have_preference_setting
    support_lead.get_preference.update_attribute(:start_page, SUPPORT_USER_LEAD_START_PAGES["Profile"])
    assert_equal SUPPORT_USER_LEAD_START_PAGES["Profile"], support_lead.get_preference.start_page

    post :login, :coach => {:user_name => support_lead.user_name, :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    assert_redirected_to self.send(START_PAGE_URLS[SUPPORT_USER_LEAD_START_PAGES["Profile"]])
  end

  def test_start_page_for_support_lead_with_learner_earch_as_start_page_in_preference_settings
    @controller = CoachPortalController.new
    stub_ldap_authentication_for_support_lead
    support_lead = assert_support_lead_doesnt_have_preference_setting
    support_lead.get_preference.update_attribute(:start_page, SUPPORT_USER_LEAD_START_PAGES["Learner Search"])
    assert_equal SUPPORT_USER_LEAD_START_PAGES["Learner Search"], support_lead.get_preference.start_page

    post :login, :coach => {:user_name => support_lead.user_name, :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    assert_redirected_to self.send(START_PAGE_URLS[SUPPORT_USER_LEAD_START_PAGES["Learner Search"]])
  end

  def test_start_page_for_support_lead_with_dashboard_as_start_page_in_preference_settings
    @controller = CoachPortalController.new
    stub_ldap_authentication_for_support_lead
    support_lead = assert_support_lead_doesnt_have_preference_setting
    support_lead.get_preference.update_attribute(:start_page, SUPPORT_USER_LEAD_START_PAGES["Dashboard"])
    assert_equal SUPPORT_USER_LEAD_START_PAGES["Dashboard"], support_lead.get_preference.start_page

    post :login, :coach => {:user_name => support_lead.user_name, :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    assert_redirected_to self.send(START_PAGE_URLS[SUPPORT_USER_LEAD_START_PAGES["Dashboard"]])
  end

  def ignore_test_manager_notification_page_filer_selections_presistent_allthrough_the_session
    #ignored because of the change in left nav
    CoachSession.any_instance.stubs(:learners_signed_up).returns 1
    Eschool::Session.stubs(:find_by_id).returns(nil)
    login_as_coach_manager('manager')

    @controller = ManagerPortalController.new

    get :substitutions
    assert_response :success
    assert_select "a[href='manager-notifications?showTemplateChanges=1&amp;showTimeOffRequests=1&amp;postedFrom=&amp;coachToShow=']", 1

    get :notifications, {:showTemplateChanges => "0", :showTimeOffRequests => "1", :postedFrom => "Yesterday", :coachToShow => "26"}
    assert_response :success

    post  :view_coach_profiles
    assert_response :success

    get :substitutions
    assert_select "a[href='manager-notifications?showTemplateChanges=0&amp;showTimeOffRequests=1&amp;postedFrom=Yesterday&amp;coachToShow=26']", 1

  end

  private
  
  def assert_coach_manager_doesnt_have_preference_setting
    coach_manger = CoachManager.find_by_user_name("coachman")
    assert_not_nil coach_manger.get_preference
    return coach_manger
  end

  def assert_support_user_doesnt_have_preference_setting
    support_user = SupportUser.find_by_user_name("supportUser")
    assert_not_nil support_user.get_preference
    return support_user
  end

  def assert_support_lead_doesnt_have_preference_setting
    support_lead = SupportUser.find_by_user_name("supportLead")
    assert_not_nil support_lead.get_preference
    return support_lead
  end

end