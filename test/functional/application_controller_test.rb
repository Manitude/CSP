require File.expand_path('../../test_helper', __FILE__)

class ApplicationControllerTest < ActionController::TestCase
fixtures :unavailable_despite_templates
  def setup
    login_as_custom_user(AdGroup.coach_manager, 'hello')
  end

  def test_show_application_status_in_text_format
    Community::User.stubs(:find_by_id).returns(true)
    Eschool::Session.stubs(:find).returns(true)
    Eschool::Learner.stubs(:find).returns(true)
    RsManager::User.stubs(:find).returns(true)
    Locos::Lotus.stubs(:find_learners_in_dts).returns(true)

    response = get 'application_status', {:format => 'txt'}
    
    assert_equal(9, response.body.split("\n").size())
  end

  def test_reroute_from_eschool_for_coach
    Coach.any_instance.stubs(:next_session).returns(nil)
    login_as_coach
    get :reroute
    assert_redirected_to({:controller => 'coach_portal', :action =>'calendar_week' })
  end

  def test_reroute_from_eschool_for_support_lead
    login_as_custom_user(AdGroup.support_lead, "supportlead1")
    get :reroute
    assert_redirected_to({:controller => 'extranet/learners'})
  end

  def test_reroute_from_eschool_for_coach_manager
    login_as_custom_user(AdGroup.coach_manager, 'hellos')
    get :reroute
    assert_redirected_to({:controller => 'schedules', :action =>'index' })
  end

  def test_application_configuration_to_show_as_manager
    ApplicationConfiguration.delete_all
    FactoryGirl.create(:application_configuration, :setting_type => 'total_dashboard_row_count', :value => '100', :data_type => 'integer', :display_name => 'Row Count In Dahsboard')
    FactoryGirl.create(:application_configuration, :setting_type => 'ok_to_send_sms', :value => 'Enable', :data_type => 'boolean', :display_name => 'Send SMS')
    get :application_configuration
    assert_response :success
    assert_application_configuration
  end

  def test_application_configuration_to_update_as_manager
    ApplicationConfiguration.delete_all
    app_config1 = FactoryGirl.create(:application_configuration, :setting_type => 'total_dashboard_row_count', :value => '100', :data_type => 'integer', :display_name => 'Row Count In Dahsboard')
    app_config2 = FactoryGirl.create(:application_configuration, :setting_type => 'ok_to_send_sms', :value => 'Enable', :data_type => 'boolean', :display_name => 'Send SMS')
    assert_equal("100", app_config1.value)
    assert_equal("Enable", app_config2.value)
    post :application_configuration, {"total_dashboard_row_count"=>"200", "ok_to_send_sms"=>"Disable"}
    assert_response :success
    app_config1.reload
    app_config2.reload
    assert_equal("200", app_config1.value)
    assert_equal("Disable", app_config2.value)
    assert_application_configuration
  end

  def test_application_configuration_not_as_manager
    Coach.any_instance.stubs(:next_session).returns(nil)
    login_as_coach
    get :application_configuration
    assert_response :redirect
    assert_equal("Sorry, you are not authorized to view the requested page. Please contact the IT Help Desk.", flash[:error])
  end

  def test_changed_by_attribute_for_custom_audit_logger
    login_as_custom_user(AdGroup.led_user, 'test21')
    get :application_configuration
    
    assert_equal CustomAuditLogger.current_changed_by_entity, "test21"
  end
  
  def test_application_status
    signed_out_all_users!
    get :application_status
    assert_response :success
  end

  def test_application_status_as_support_user
    login_as_custom_user(AdGroup.support_user, 'supportUser')
    get :application_status
    assert_response :success
  end

  def test_mark_notification_as_read
    NotificationMessageDynamic.delete_all
    NotificationRecipient.delete_all
    SystemNotification.delete_all
    Account.delete_all
    notif = FactoryGirl.create(:notification, :trigger_event_id => 1, :message => 'A new template for has been submitted for review.', :target_type => 'CoachAvailabilityTemplate')
    coach = FactoryGirl.create(:coach)
    FactoryGirl.create(:account)
    template = FactoryGirl.create(:coach_availability_template, :coach_id => coach.id, :effective_start_date => (Time.now + 5.day).to_date, :label => "test")
    FactoryGirl.create(:notification_recipient, :notification_id => notif.id, :name => 'Coach Manager', :rel_recipient_obj => 'all_managers')
    notif.trigger!(template)
    cm = login_as_custom_user(AdGroup.coach_manager, 'hello')
    get :mark_notification_as_read, {:id => cm.id}
    assert_response 200
  end  

  def test_next_session_start_time
    CoachSession.delete_all
    coach = create_coach_with_qualifications('rajkumar', ['ARA'])
    coach_session   = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :session_start_time => Time.now.utc.beginning_of_hour+1.hour, :language_identifier => "ARA", :eschool_session_id => 343)
    login_as_custom_user(AdGroup.coach, 'rajkumar')
    minutes_left = ((coach_session.session_start_time - Time.now) / 60).ceil
    coach.get_preference
    coach.preference_setting.update_attributes(:session_alerts_display_time => minutes_left)
    get :next_session_start_time
    assert_not_nil response.body.match("(#{minutes_left}<\/span>)")
  end

  def test_get_learner_details
    learner = FactoryGirl.create(:learner, :guid => "13aaf8b0-9083-4ce0-84e9-f8af6a96ba72")
    ExternalHandler::HandleSession.stubs(:find_session).returns(eschool_session_with_learner)
    get :get_learner_details, {:learner_id => learner.id, :id => 123}
    assert_equal 200,response.status
  end 

  def test_sync_eschool_csp_data
    ConfirmedSession.delete_all
    SchedulerMetadata.delete_all
    get :sync_eschool_csp_data
    assert_not_nil @response.body.match("All sessions are updated. No affected session found.")
    coach = create_coach_with_qualifications('rajkumar', ['ENG'])
    coach_session1   = FactoryGirl.create(:coach_session, :type => "ConfirmedSession", :session_start_time => (Time.now.beginning_of_hour.utc + 2.hours), :coach_id => coach.id)
    coach_session2   = FactoryGirl.create(:coach_session, :type => "ConfirmedSession", :session_start_time => (Time.now.beginning_of_hour.utc + 5.hours), :coach_id => coach.id)
    Eschool::Session.stubs(:create).returns(nil)
    response = Net::HTTPOK.new(true,200,"OK")
    ExternalHandler::HandleSession.stubs(:get_session_details).returns(response)
    get :sync_eschool_csp_data
    assert_not_nil @response.body.match("A totale language is being pushed currently. Please try again later")
    response.stubs(:read_body).returns(eschool_sessions_array_without_learner_body)
    Eschool::Session.any_instance.stubs(:external_session_id).returns(coach_session1.id)
    get :sync_eschool_csp_data
    assert_not_nil @response.body.match("2 were affected in CSP and 2 sessions have been updated")
  end  

  def test_reason_for_cancellation
    coach_session = FactoryGirl.create(:coach_session, :type => "ConfirmedSession")
    get :reason_for_cancellation,{:coach_session_id => coach_session.id}
    assert_select "select#reasons option", :count => 10
  end  

  private

  def assert_application_configuration
    app_configs = ApplicationConfiguration.all
    assert_select "tr", :count => app_configs.size + 1
    assert_select "th", :text => "Setting Type", :count => 1
    assert_select "th", :text => "Value", :count => 1
    app_configs.each do |app_config|
      assert_select "td", :text => app_config.display_name, :count => 1
    end
  end

end
