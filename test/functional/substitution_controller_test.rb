require File.expand_path('../../test_helper', __FILE__)

class SubstitutionControllerTest < ActionController::TestCase
  fixtures :trigger_events

  def test_request_substitute_for_coach_returning_success_response
    login_as_coach_manager
    coach = create_coach_with_qualifications("TestCoach")
    start_time = (Time.now.beginning_of_hour + 2.hour).utc
    coach_session = FactoryGirl.create(:coach_session, :coach_id => coach.id, :session_start_time => start_time,
        :session_end_time => (start_time + 30.minutes), :cancelled => "0", :language_identifier => "KLE", :language_id => 32, :type => "ConfirmedSession")   
    xhr :post, :request_substitute_for_coach,{:current_coach_id => coach.id, :time => coach_session.session_start_time, :reason => "No show"}
    assert_response :success
    response_json = ActiveSupport::JSON.decode(@response.body)
    assert_equal "Substitute was requested successfully", response_json['message']
    assert_equal ["REFLEX<br/> Substitute Requested", "cs_sub_needed_solid_session_slot"], response_json['label']
    assert_equal coach_session.session_start_time, Time.at(response_json['start_time']).utc
    assert_equal coach_session.session_end_time, Time.at(response_json['end_time']).utc
  end
  
  def test_open_sub_page_and_check_for_trigger_sms_button
    coach_mgr = login_as_custom_user(AdGroup.coach_manager, 'test21')
    Community::Village.stubs(:all).returns([])
    coach_mgr.stubs(:languages).returns([Language['KLE']])
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
    session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :language_identifier => 'KLE')
    session.request_substitute
    post :substitutions
    assert_equal 1, assigns(:substitutions)[:data].size
    assert_false @response.body.include?("Trigger SMS")
    post :substitutions, :lang_id => session.language.id.to_s
    assert_equal 1, assigns(:substitutions)[:data].size
    assert_true @response.body.include?("Trigger SMS")
  end


  def test_trigger_sms_and_check_if_it_redirects
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    create_substituion_within(2.hour, 'ESP')
    create_substituion_within(3.hour, 'ESP')
    post :trigger_sms, :lang_id => Language['ESP'].id
    assert_equal @response.body, 'SMS Triggered Successfully.'
    CoachSession.destroy_all
    post :trigger_sms, :lang_id => Language['ESP'].id
    assert_equal @response.body, 'There are no substitute requested sessions/appointments to be started in the next 24 hours.'
  end
  
  def test_request_substitute_for_coach_returning_failure_response
    login_as_coach_manager
    coach = create_coach_with_qualifications("TestCoach")
    Coach.any_instance.stubs(:request_substitute).returns("base End date of time off cannot be a date in the past. base Start date of time off cannot be a date in the past.")
    xhr :post, :request_substitute_for_coach,{:current_coach_id => coach.id,:time => "2010-09-06 11:00:00",:lang_identifier => 'ARA'}
    assert_response 500
    assert_equal "Something went wrong, please try again.", @response.body
  end

  def test_request_substitute_for_coach_returning_success_response_for_dashboard_page
    login_as_coach_manager
    coach = create_coach_with_qualifications("TestCoach")
    start_time = (Time.now.beginning_of_hour + 2.hour).utc
    coach_session = FactoryGirl.create(:coach_session, :coach_id => coach.id, :session_start_time => start_time,
        :session_end_time => (start_time + 30.minutes), :cancelled => "0", :language_identifier => "KLE", :language_id => 32, :type => "ConfirmedSession")   
    xhr :post, :request_substitute_for_coach,{:current_coach_id => coach.id, :time => coach_session.session_start_time, :reason => "Electricity Outage"}
    assert_response :success
    response_json = ActiveSupport::JSON.decode(@response.body)
    assert_equal "Substitute was requested successfully", response_json['message']
    assert_equal ["REFLEX<br/> Substitute Requested", "cs_sub_needed_solid_session_slot"], response_json['label']
    assert_equal coach_session.session_start_time.utc, Time.at(response_json['start_time']).utc
    assert_equal coach_session.session_end_time.utc, Time.at(response_json['end_time']).utc
  end

  def test_request_substitute_for_coach_returning_failure_response_for_dashboard_page
    login_as_coach_manager
    coach = create_coach_with_qualifications("TestCoach")
    Coach.any_instance.stubs(:request_substitute).returns("base End date of time off cannot be a date in the past. base Start date of time off cannot be a date in the past.")
    xhr :post, :request_substitute_for_coach,{:current_coach_id => coach.id,:time => "2010-09-06 11:00:00",:lang_identifier => 'ARA', :request_from => 'dashboard'}
    assert_response 500
    assert_equal "Something went wrong, please try again.", @response.body
  end


  def test_substitutions_alert_for_coach_manager_with_warning_icon
    login_as_coach_manager
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
    session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :session_start_time => Time.now.beginning_of_hour + 1.hour, :language_identifier => 'KLE')
    session.request_substitute
    get :substitutions_alert
    assert_response :success
    assert_equal(1, assigns(:substitution_data).size)
    assert_select 'table[id="sub_data"]', :count => 1 do
      assert_select 'tr', :count => 1
      assert_select 'img[class = "warning_icon" ]', :count => 1
    end
  end

  def test_substitutions_alert_for_coach_manager_without_warning_icon
    login_as_coach_manager
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
    session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :session_start_time => Time.now.beginning_of_hour + 4.hour, :language_identifier => 'KLE')
    session.request_substitute
    get :substitutions_alert, :closed => "false"
    assert_response :success
    assert_equal(1, assigns(:substitution_data).size)
    assert_select 'table[id="sub_data"]', :count => 1 do
      assert_select 'tr', :count => 1
      assert_select 'img[class = "warning_icon" ]', :count => 0
    end
  end

  def test_substitutions_alert_for_coach
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
    coach = login_as_custom_user(AdGroup.coach, coach.user_name)
    LanguageSchedulingThreshold.stubs(:get_hours_prior_to_sesssion_override).returns(5)
    session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :session_start_time => Time.now.beginning_of_hour + 4.hour, :language_identifier => 'KLE')
    session.request_substitute
    get :substitutions_alert
    assert_response :success
    sub_data = assigns(:substitution_data)
    assert_equal(1, sub_data.size)
    assert_select 'table[id="sub_data"]', :count => 1 do
      assert_select 'tr', :count => 1
    end
    assert_false sub_data[0][:grab_disable]
  end

  def test_no_records_should_show_filters_for_coach
    Community::Village.stubs(:all).returns([])
    login_as_coach_manager
    get :substitutions
    assert_response :success
    assert_select 'table', :count => 1 do
      assert_select 'td[colspan="7"]', :text => "There are no substitutions to display for the selected search filters."
    end
  end

  def test_check_sub_policy_violation
    start_time = (Time.now.beginning_of_hour).utc
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
    coach = login_as_custom_user(AdGroup.coach, coach.user_name)
    CoachSession.stubs(:find_by_eschool_session_id).returns(CoachSession.all)
    coach_session = FactoryGirl.create(:confirmed_session, :eschool_session_id => "345698", :language_identifier => "KLE")
    FactoryGirl.create(:substitution, :coach_session_id => coach_session.id, :coach_id => coach.id)
    xhr :post, :check_sub_policy_violation, {:start_time => start_time, :coach_id => coach.id}
    assert_response :success

  end

  def test_assign_substitute_for_coach
    coach = create_coach_with_qualifications('rajkumar', ['ARA'])
    CoachSession.stubs(:find_by_eschool_session_id).returns(CoachSession.all)
    coach_session   = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :session_start_time => Time.now.utc.beginning_of_hour+1.hour, :language_identifier => "ARA", :eschool_session_id => 343)
    FactoryGirl.create(:substitution, :coach_id => coach.id, :grabbed => false, :coach_session_id => coach_session.id, :reason => "Electricity Outage")
    coach_mgr = login_as_coach_manager
    coach_mgr.stubs(:languages).returns([Language['ARA'],Language['AUS']])
    post :assign_substitute_for_coach, {:assigned_coach => coach.id, :coach_session_id => coach_session.id, :coach_id => coach.id}
    assert_response :success
    assert_not_nil response.body.match("assigned successfully")
    coach2 = create_coach_with_qualifications('Check', ['AUS'])
    FactoryGirl.create(:substitution, :coach_id => coach.id, :grabber_coach_id => coach.id, :grabbed => 1, :coach_session_id => coach_session.id)
    post :assign_substitute_for_coach, {:assigned_coach => coach2.id, :coach_session_id => coach_session.id}
    assert_response :success
  end

  def test_cancel_substitution
    login_as_coach_manager
    ConfirmedSession.any_instance.stubs(:learners_signed_up).returns(0)
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
   # CoachSession.stubs(:find_by_eschool_session_id).returns(CoachSession.all)
    coach_session = FactoryGirl.create(:confirmed_session, :eschool_session_id => "345698", :language_identifier => "KLE")
    sub = FactoryGirl.create(:substitution, :coach_id => coach.id, :grabbed => false, :cancelled => false, :coach_session_id => coach_session.id, :reason => "Electricity Outage")
    get :cancel_substitution, {:sub_id => sub.id, :notice => true, :reason => sub.reason}
    assert_response :success
    coach2 = create_coach_with_qualifications('Ven', ['ARA'])
    session = FactoryGirl.create(:confirmed_session, :coach_id => coach2.id, :eschool_session_id => "989648", :language_identifier => "KLE")
    FactoryGirl.create(:substitution, :coach_id => coach.id, :grabbed => false, :cancelled => 1, :coach_session_id => session.id, :reason => "Electricity Outage")
    get :cancel_substitution, {:session_id => session.eschool_session_id}
    assert_response :error
  end

  def test_fetch_available_coaches
    login_as_coach_manager
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
  #  coach = login_as_custom_user(AdGroup.coach, coach.user_name)
  #  CoachSession.stubs(:find_by_eschool_session_id).returns(CoachSession.all)
    coach_session = FactoryGirl.create(:confirmed_session, :eschool_session_id => "345698", :language_identifier => "HEB")
    sub = FactoryGirl.create(:substitution, :coach_id => coach.id, :grabbed => false, :cancelled => false, :coach_session_id => coach_session.id, :reason => "Electricity Outage")
    xhr :post, :fetch_available_coaches, {:fetch_reason => true, :sub_id => sub.id }
    assert_template "substitution/_fetch_available_coaches"

    coach2 = create_coach_with_qualifications('Ven', ['ARA'])
    coach_session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :eschool_session_id => "345777", :language_identifier => "HEB")
    sub = FactoryGirl.create(:substitution, :coach_id => coach2.id, :grabbed => false, :cancelled => 1, :coach_session_id => coach_session.id, :reason => "Electricity Outage")
    xhr :post, :fetch_available_coaches, {:fetch_reason => true, :sub_id => sub.id }
    assert_template "substitution/_fetch_available_coaches"

    xhr :post, :fetch_available_coaches, {:session_id => coach_session.eschool_session_id}
    assert_template "substitution/_fetch_available_coaches"
  end

  def test_reason_for_sub_request
    login_as_coach_manager
    xhr :post, :reason_for_sub_request
    assert_template "substitution/_reason_for_sub_request"
  end

  def test_grab_substitution
    user = login_as_custom_user(AdGroup.coach, 'test21')
    user.update_attribute('created_at', Time.now.utc)
    User.stubs(:authenticate).returns @request.session[:user] #user is present in LDAP
    coach = create_coach_with_qualifications('rajkumar', ['ARA'])
    CoachSession.stubs(:find_by_eschool_session_id).returns(CoachSession.all)
    coach_session = FactoryGirl.create(:confirmed_session, :eschool_session_id => "345698", :language_identifier => "ARA")
    sub = FactoryGirl.create(:substitution, :coach_id => coach.id, :grabbed => false, :cancelled => false, :coach_session_id => coach_session.id, :reason => "Electricity Outage")
  #  get :grab_substitution, {:sub_id => sub.id}
  #  assert_template "shared/_success_failure"

    Substitution.stubs(:find_by_id).returns(sub)
    ConfirmedSession.any_instance.stubs(:has_session_between?).returns(false)
    ConfirmedSession.any_instance.stubs(:eschool_session_unit).returns(-1)
    Coach.any_instance.stubs(:threshold_reached?).returns([false,false])
    Substitution.any_instance.stubs(:perform_substitution).returns("doesnt matter")
    get :grab_substitution
    sub = JSON.parse(@response.body)
    assert_not_nil sub['message'].match("You are now scheduled to substitute for this session.")

    Coach.any_instance.stubs(:threshold_reached?).returns([true,true])
    LanguageSchedulingThreshold.stubs(:get_hours_prior_to_sesssion_override).returns(0)
    get :grab_substitution
    sub = JSON.parse(@response.body)
    assert_not_nil sub['error'].match("You have reached or exceeded the maximum number of sessions")
    
    ConfirmedSession.any_instance.stubs(:is_extra_session?).returns(true)
    Coach.any_instance.stubs(:is_excluded?).returns(true)
    get :grab_substitution
    sub = JSON.parse(@response.body)
    assert_not_nil sub['error'].match("You are not allowed to teach this session.")

  #  sub = FactoryGirl.create(:substitution, :coach_id => coach.id, :grabbed => false, :cancelled => false, :was_reassigned => 1, :coach_session_id => coach_session.id, :reason => "Electricity Outage")
  #  get :grab_substitution, {:sub_id => sub.id}
  #  assert_template "shared/_success_failure"

    get :grab_substitution
    sub = JSON.parse(@response.body)
    assert_equal false, sub['is_appointment']
  end

  def test_show_reason_in_sub_report
    login_as_coach_manager
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
    coach_session = FactoryGirl.create(:confirmed_session, :eschool_session_id => "345698", :language_identifier => "HEB")
    sub = FactoryGirl.create(:substitution, :coach_id => coach.id, :grabber_coach_id => coach.id, :grabbed => 1, :coach_session_id => coach_session.id, :reason => "Electricity Outage")
    get :show_reason_in_sub_report, {:id => sub.id }
    assert_template "substitution/_show_reason_in_sub_report"
    sub = FactoryGirl.create(:substitution, :coach_id => coach.id, :grabber_coach_id => coach.id, :grabbed => 1, :coach_session_id => coach_session.id)
    get :show_reason_in_sub_report, {:id => sub.id }
    assert_template "substitution/_show_reason_in_sub_report"
  end
end