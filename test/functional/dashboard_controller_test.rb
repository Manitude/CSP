require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../app/helpers/dashboard_helper'
require File.dirname(__FILE__) + '/../../app/utils/dashboard_utils'
require 'dashboard_controller'
require 'dupe'


class DashboardControllerTest < ActionController::TestCase

  include DashboardHelper

  def setup
    login_as_custom_user(AdGroup.led_user, 'test21')
    App.stubs(:total_dashboard_row_count).returns(100)
  end

  test 'should handle exception when eschool is down with socket error' do
    params = {:support_language_id => 'All', :session_language_id => 'Advanced', :session_start_time_id => 'Live Now'}
    start_time = Time.now
    end_time = Time.now + 1.hour
    dashboard_future_session = true
    DashboardUtils.expects(:calculate_dashboard_values).with(params[:session_start_time_id]).returns({:start_time => start_time, :end_time => end_time, :future_session? => dashboard_future_session})
    Eschool::Session.stubs(:dashboard_data).raises(SocketError.new, '(getaddrinfo: Name or service not known)')
    get :filter_sessions, params
    assert_response 503
  end

  test 'should handle exception when eschool is down with connection refused' do
    params = {:support_language_id => 'All', :session_language_id => 'Advanced', :session_start_time_id => 'Live Now'}
    start_time = Time.now
    end_time = Time.now + 1.hour
    dashboard_future_session = true
    DashboardUtils.expects(:calculate_dashboard_values).with(params[:session_start_time_id]).returns({:start_time => start_time, :end_time => end_time, :future_session? => dashboard_future_session})
    Eschool::Session.stubs(:dashboard_data).raises(Errno::ECONNREFUSED, '(getaddrinfo: Name or service not known)')
    get :filter_sessions, params
    assert_response 503
  end

  test 'filter session if no local session with reflex language' do
    CoachSession.expects(:find_all_by_eschool_session_id).never
    duped_session = Dupe.create :session, :is_reflex => 'true'
    DashboardController.new.filter_session_if_no_local_session duped_session
    assert_equal 'false', duped_session.is_not_present_in_csp
  end

  test 'filter session if no local session with non-reflex language and no session in csp' do
    CoachSession.expects(:find_all_by_eschool_session_id).returns([])
    duped_session = Dupe.create :session, :is_reflex => 'false'
    DashboardController.new.filter_session_if_no_local_session duped_session
    assert_equal 'true', duped_session.is_not_present_in_csp
  end

  test 'filter session if no local session with non-reflex language and session in csp' do
    CoachSession.expects(:find_all_by_eschool_session_id).returns([mock('session')])
    duped_session = Dupe.create :session, :is_reflex => 'false'
    DashboardController.new.filter_session_if_no_local_session duped_session
    assert_equal 'false', duped_session.is_not_present_in_csp
  end

  test 'should render json for filter_session' do
    login_as_custom_user(AdGroup.led_user, 'test21')
    params = {:support_language_id => 'All', :session_language_id => 'Advanced', :session_start_time_id => 'Live Now'}
    start_time = Time.now
    end_time = Time.now + 1.hour
    dashboard_future_session = true
    DashboardUtils.expects(:calculate_dashboard_values).with(params[:session_start_time_id]).returns({:start_time => start_time, :end_time => end_time, :future_session? => dashboard_future_session})
    eschool_sessions = Dupe.create :session, :eschool_sessions => []
    Eschool::Session.expects(:dashboard_data).with('test21', 500, 1, start_time, end_time, 'Advanced', 'All', 'en-US', dashboard_future_session, "false").returns(eschool_sessions)
    get :filter_sessions, params
    assert_response :success
  end

  test 'should render json for filter_session when ADE is chosen session language' do
    login_as_custom_user(AdGroup.led_user, 'test21')
    params = {:support_language_id => 'All', :session_language_id => 'ADE', :session_start_time_id => 'Live Now'}
    start_time = Time.now
    end_time = Time.now + 1.hour
    dashboard_future_session = true
    DashboardUtils.expects(:calculate_dashboard_values).with(params[:session_start_time_id]).returns({:start_time => start_time, :end_time => end_time, :future_session? => dashboard_future_session})
    eschool_sessions = Dupe.create :session, :eschool_sessions => []
    Eschool::Session.expects(:dashboard_data).with('test21', 500, 1, start_time, end_time, 'JLE,KLE', 'All', 'en-US', dashboard_future_session, "false").returns(eschool_sessions)
    get :filter_sessions, params
    assert_response :success
  end

  test 'should pickup second page when page number is 2' do
    login_as_custom_user(AdGroup.led_user, 'test21')
    params = {:support_language_id => 'All', :session_language_id => 'Advanced', :session_start_time_id => 'Starting in next hour', :page_number => '2'}
    start_time = Time.now
    end_time = Time.now + 1.hour
    dashboard_future_session = true
    DashboardUtils.expects(:calculate_dashboard_values).with(params[:session_start_time_id]).returns({:start_time => start_time, :end_time => end_time, :future_session? => dashboard_future_session})
    eschool_sessions = Dupe.create :session, :eschool_sessions => []
    Eschool::Session.expects(:dashboard_data).with('test21', 100, params[:page_number], start_time, end_time, 'Advanced', 'All', 'en-US', dashboard_future_session, "false").returns(eschool_sessions)
    response = get :filter_sessions, params
    assert_response :success
  end

  test "hit dashboard homepage as LED user" do
    # PreferenceSetting.delete_all
    user = login_as_custom_user(AdGroup.led_user, 'test21')
    User.stubs(:authenticate).returns @request.session[:user] #Simulate a success authentication
    @controller = CoachPortalController.new
    post :login, :coach => {:user_name => 'foo', :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    assert_redirected_to dashboard_url
  end

  test "hit dashboard homepage as Tier1 Support User" do
    Eschool::Session.stubs(:dashboard_data).returns []
    login_as_custom_user(AdGroup.support_user, 'test21')
    get :index
    assert_response :success
    assert_equal "Dashboard", assigns(:page_title)
  end

  test "hit dashboard homepage as Tier1 Support Lead" do
    Eschool::Session.stubs(:dashboard_data).returns []
    login_as_custom_user(AdGroup.support_lead, 'test21')
    get :index
    assert_response :success
    assert_equal "Dashboard", assigns(:page_title)
  end

  test "hit dashboard homepage as Coach" do
    Eschool::Session.stubs(:dashboard_data).returns []
    coach = create_coach_with_qualifications
    login_as_custom_user(AdGroup.coach, coach.user_name)
    get :index
    assert_equal "Sorry, you are not authorized to view the requested page. Please contact the IT Help Desk.", flash[:error]
    assert_redirected_to login_url
  end

  test "hit dashboard homepage as Community Moderator" do
    Eschool::Session.stubs(:dashboard_data).returns []
    login_as_custom_user(AdGroup.community_moderator, 'test21')
    get :index
    assert_response :success
  end

  test "hit dashboard homepage as LED user with eschool up and running" do
    Eschool::Session.stubs(:dashboard_data).returns []
    get :index
    assert_response :success
    assert_equal "Dashboard", assigns(:page_title)
  end

  test "hit dashboard homepage as LED user with uncompleted profile" do
    Eschool::Session.stubs(:dashboard_data).returns []
    get :index
    assert_response :success
    assert_equal "Dashboard", assigns(:page_title)
  end

  def test_learner_list_without_display_name
    stub_eschool_for_assist_learner
    post :get_learners_for_session , {:id => 8494, :session_details => [] }
    assert_response :success
    assert_select 'thead>tr>th', :count => 6 do
      assert_select 'th', 'LEARNER'
      assert_select 'th', 'DISPLAY NAME'
      assert_select 'th', 'EMAIL'
      assert_select 'th', 'SUPPORT LANGUAGE'
      assert_select 'th', 'SYSTEM INFORMATION'
      assert_select 'th', 'AUDIO DEVICES'
    end
    assert_select 'tr>td', :count => 6 do
      assert_select 'td', 'Braga Braga'
      assert_select 'td', '--'
      assert_select 'td', '1252005165313registration.com'
      assert_select 'td', 'English'
      assert_select 'td', 'Not available'
    end
  end

  def test_get_aria_learner_info
    coach = create_coach_with_qualifications('rajkumar', ['AUS'])
    t1 = Time.now.beginning_of_hour.utc + 1.hour
    sess = FactoryGirl.create(:confirmed_session, :coach_id=> coach.id, :eschool_session_id => 1234, :language_identifier => 'AUS', :session_start_time => t1)
    ExternalHandler::HandleSession.stubs(:find_session).returns(nil)
    CoachSession.stubs(:find_by_eschool_session_id).returns(sess)
    learner = [{:full_name=>"Adobe Learner Test", :guid=>"81478455-033f-4af4-a99e-5f392ab4d2f5", :email=>"adobeconnectuser@example.com", :booking_id=>15018048}]
    ConfirmedSession.any_instance.stubs(:supersaas_learner).returns(learner)
    adobe_response = '<?xml version="1.0" encoding="UTF-8"?>
    <results>
      <status code="ok"/>
      <report-meeting-attendance>
        <row transcript-id="1277136355" asset-id="1277108371" sco-id="1277055810" principal-id="1276200314" answered-survey="0">
          <login>0c1bd958-105a-4b62-b1c8-36273ba4631c</login>
          <session-name>WebService User</session-name>
          <sco-name>Live Session: m8202271</sco-name>
          <date-created>2014-06-27T03:14:39.520-04:00</date-created>
          <participant-name>WebService User</participant-name>
        </row>
        <row transcript-id="1277108370" asset-id="1277108371" sco-id="1277055810" principal-id="1276863885" answered-survey="0">
          <login>0c1bd958-105a-4b62-b1c8-36273ba4631c</login>
          <session-name>abdularia01 abdularia01</session-name>
          <sco-name>Live Session: m8202271</sco-name>
          <date-created>2014-06-27T03:14:29.557-04:00</date-created>
          <date-end>2014-06-27T03:20:18.673-04:00</date-end>
          <participant-name>abdularia01 abdularia01</participant-name>
        </row>
        <row transcript-id="1277108370" asset-id="1277108371" sco-id="1277055810" principal-id="1276863888" answered-survey="0">
          <login>81478455-033f-4af4-a99e-5f392ab4d2f5</login>
          <session-name>Adobe Learner Test</session-name>
          <sco-name>Live Session: m8202271</sco-name>
          <date-created>2014-06-27T03:14:29.557-04:00</date-created>
          <participant-name>Adobe Learner Test</participant-name>
        </row>
      </report-meeting-attendance>
    </results>'
    
    AdobeConnect::Base.stubs(:one_time_login).returns("a cookie")
    AdobeConnect::Base.stubs(:users_in_meeting_logged_in).returns(adobe_response)
    params = {:id => sess.eschool_session_id, :get_learners_in_room => true}
    get :get_learners_for_session, params
    assert_response :success
    assert_select 'thead>tr>th', :count => 6 do
      assert_select 'th', 'LEARNER'
      assert_select 'th', 'DISPLAY NAME'
      assert_select 'th', 'EMAIL'
      assert_select 'th', 'SUPPORT LANGUAGE'
      assert_select 'th', 'SYSTEM INFORMATION'
      assert_select 'th', 'AUDIO DEVICES'
    end
    assert_select 'tr>td', :count => 6 do
      assert_select 'td', 'Adobe Learner Test'
      assert_select 'td', 'Adobe Learner Test'
      assert_select 'td', 'adobeconnectuser@example.com'
      assert_select 'td', 'English'
      assert_select 'td', ''
    end

  end

  def test_learner_list_with_display_name_and_user_agent
    setup_expectations
    stub_eschool_call_for_find_by_id({:preferred_name => "braga_disp_name", :user_agent => "a virtual machine", :support_language_iso => "en-US"})
    post :get_learners_for_session , {:id => 8494, :session_details => [] }
    assert_response :success
    assert_select 'thead>tr>th', :count => 6 do
      assert_select 'th', 'LEARNER'
      assert_select 'th', 'DISPLAY NAME'
      assert_select 'th', 'EMAIL'
      assert_select 'th', 'SUPPORT LANGUAGE'
      assert_select 'th', 'SYSTEM INFORMATION'
      assert_select 'th', 'AUDIO DEVICES'
    end
    assert_select 'tr>td', :count => 6 do
      assert_select 'td', 'Braga Braga'
      assert_select 'td', 'braga_disp_name'
      assert_select 'td', '1252005165313registration.com'
      assert_select 'td', 'English'
      assert_select 'td', 'a virtual machine'
    end
  end

  def test_learner_list_with_ios_device
    setup_expectations
    stub_eschool_call_for_find_by_id({:audio_input_device => "an iOS device", :support_language_iso => "en-US"})
    post :get_learners_for_session , {:id => 8494, :session_details => [] }
    assert_response :success
    assert_select 'thead>tr>th', :count => 6 do
      assert_select 'th', 'LEARNER'
      assert_select 'th', 'DISPLAY NAME'
      assert_select 'th', 'EMAIL'
      assert_select 'th', 'SUPPORT LANGUAGE'
      assert_select 'th', 'SYSTEM INFORMATION'
      assert_select 'th', 'AUDIO DEVICES'
    end
    assert_select 'tr>td', :count => 6 do
      assert_select 'td', 'Braga Braga'
      assert_select 'td', '--'
      assert_select 'td', '1252005165313registration.com'
      assert_select 'td', 'English'
      assert_select 'td', 'Not available'
      assert_select "td[class='audio_input_device_green'] > span", '(iOS)'
    end
  end

  def test_learner_list_with_ipad_device
    setup_expectations
    stub_eschool_call_for_find_by_id({:audio_input_device => "an iPad device"})
    post :get_learners_for_session , {:id => 8494, :session_details => [] }
    assert_response :success
    assert_select 'thead>tr>th', :count => 6 do
      assert_select 'th', 'LEARNER'
      assert_select 'th', 'DISPLAY NAME'
      assert_select 'th', 'EMAIL'
      assert_select 'th', 'SUPPORT LANGUAGE'
      assert_select 'th', 'SYSTEM INFORMATION'
      assert_select 'th', 'AUDIO DEVICES'
    end
    assert_select 'tr>td', :count => 6 do
      assert_select 'td', 'Braga Braga'
      assert_select 'td', '--'
      assert_select 'td', '1252005165313registration.com'
      assert_select 'td', 'English'
      assert_select 'td', 'Not available'
      assert_select "td[class='audio_input_device_green']" do
        assert_select 'span', :text => '(iOS)', :count => 1
        assert_select 'span', :text => '', :count => 1
      end
    end
  end

  def test_learner_list_without_iOS_device
    setup_expectations
    stub_eschool_call_for_find_by_id({:audio_input_device => "some device"})
    post :get_learners_for_session , {:id => 8494, :session_details => [] }
    assert_response :success
    assert_select 'thead>tr>th', :count => 6 do
      assert_select 'th', 'LEARNER'
      assert_select 'th', 'DISPLAY NAME'
      assert_select 'th', 'EMAIL'
      assert_select 'th', 'SUPPORT LANGUAGE'
      assert_select 'th', 'SYSTEM INFORMATION'
      assert_select 'th', 'AUDIO DEVICES'
    end
    assert_select 'tr>td', :count => 6 do
      assert_select 'td', 'Braga Braga'
      assert_select 'td', '--'
      assert_select 'td', '1252005165313registration.com'
      assert_select 'td', 'English'
      assert_select 'td', 'Not available'
      assert_select 'td'
      assert_select "td[class='audio_input_device_green']" do |elements|
        elements.each do
          assert_select 'span', :text => '', :count => 2
        end
      end
    end
  end

   def test_filter_session_for_nil_attendance_session_as_coach_manager
    a = login_as_custom_user(AdGroup.coach_manager, 'hello')
    #a.update_attribute('time_zone','Eastern Time (US & Canada)')
    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    options = {}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("", e_session["audio"])  # If learners are not there, the status shouldn't be shown.
    assert_equal("false", e_session["can_show_support_links"])
    assert_equal("audio_input_device_unknown_device", e_session["audio_device_status"])
    assert_equal("true", e_session["is_not_present_in_csp"])
    assert_equal("Cancel", e_session["cancel_text"])
    assert_equal("true", e_session["can_view_full_support"])
    assert_equal("French - FRA Level 1 Unit 1, ID 243630 : Mon, Feb  2, 2032 07:30 AM (EST)", e_session["session"])
    assert_equal("true", e_session["can_assign_sub"])
    assert_equal("Assign a Substitute", e_session["assign_substitute_text"])
    assert_equal("Request a Substitute", e_session["request_substitute_text"])
    assert_equal("--", e_session["village_name"])
  end

  def test_filter_session_for_nil_attendance_session_as_support_lead
    login_as_custom_user(AdGroup.support_lead,'rramesh')
    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    options = {}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("", e_session["audio"]) # If learners are not there, the status shouldn't be shown.
    assert_equal("false", e_session["can_show_support_links"])
    assert_equal("audio_input_device_unknown_device", e_session["audio_device_status"])
    assert_equal("true", e_session["is_not_present_in_csp"])
    assert_equal("Cancel", e_session["cancel_text"])
    assert_equal("true", e_session["can_view_full_support"])
    assert_equal("French - FRA Level 1 Unit 1, ID 243630 : Mon, Feb  2, 2032 07:30 AM (EST)", e_session["session"])
    assert_equal("true", e_session["can_assign_sub"])
    assert_equal("Assign a Substitute", e_session["assign_substitute_text"])
    assert_equal("Request a Substitute", e_session["request_substitute_text"])
    assert_equal("--", e_session["village_name"])
  end

  def test_filter_session_for_nil_attendance_session_as_support_user
    login_as_custom_user(AdGroup.support_user,'rramesh')
    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    options = {}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("", e_session["audio"]) # If learners are not there, the status shouldn't be shown.
    assert_equal("false", e_session["can_show_support_links"])
    assert_equal("audio_input_device_unknown_device", e_session["audio_device_status"])
    assert_equal("true", e_session["is_not_present_in_csp"])
    assert_equal("Cancel", e_session["cancel_text"])
    assert_equal("true", e_session["can_view_full_support"])
    assert_equal("French - FRA Level 1 Unit 1, ID 243630 : Mon, Feb  2, 2032 07:30 AM (EST)", e_session["session"])
    assert_equal("true", e_session["can_assign_sub"])
  end

  def test_filter_session_for_nil_attendance_session_as_community_moderator
    login_as_custom_user(AdGroup.community_moderator,'rramesh')
    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    options = {}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("", e_session["audio"]) # If learners are not there, the status shouldn't be shown.
    assert_equal("false", e_session["can_show_support_links"])
    assert_equal("audio_input_device_unknown_device", e_session["audio_device_status"])
    assert_equal("true", e_session["is_not_present_in_csp"])
    assert_equal("Cancel", e_session["cancel_text"])
    assert_equal("false", e_session["can_view_full_support"])
    assert_equal("French - FRA Level 1 Unit 1, ID 243630 : Mon, Feb  2, 2032 07:30 AM (EST)", e_session["session"])
    assert_equal("false", e_session["can_assign_sub"])
  end

  def test_filter_session_for_nil_attendance_session_as_support_concierge
    login_as_custom_user(AdGroup.support_concierge_user,'rramesh')
    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    options = {}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("", e_session["audio"]) # If learners are not there, the status shouldn't be shown.
    assert_equal("false", e_session["can_show_support_links"])
    assert_equal("audio_input_device_unknown_device", e_session["audio_device_status"])
    assert_equal("true", e_session["is_not_present_in_csp"])
    assert_equal("Cancel", e_session["cancel_text"])
    assert_equal("false", e_session["can_view_full_support"])
    assert_equal("French - FRA Level 1 Unit 1, ID 243630 : Mon, Feb  2, 2032 07:30 AM (EST)", e_session["session"])
    assert_equal("false", e_session["can_assign_sub"])

  end

  def test_filter_session_for_nil_attendance_session_as_support_harrisonburg
    login_as_custom_user(AdGroup.support_harrisonburg_user,'rramesh')
    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    options = {}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("", e_session["audio"]) # If learners are not there, the status shouldn't be shown.
    assert_equal("false", e_session["can_show_support_links"])
    assert_equal("audio_input_device_unknown_device", e_session["audio_device_status"])
    assert_equal("true", e_session["is_not_present_in_csp"])
    assert_equal("Cancel", e_session["cancel_text"])
    assert_equal("true", e_session["can_view_full_support"])
    assert_equal("French - FRA Level 1 Unit 1, ID 243630 : Mon, Feb  2, 2032 07:30 AM (EST)", e_session["session"])
    assert_equal("true", e_session["can_assign_sub"])
  end

  def test_filter_session_for_nil_attendance_cancelled_session_as_support_lead
    login_as_custom_user(AdGroup.support_lead,'rramesh')
    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    options = {:cancelled => "true"}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("", e_session["audio"])
    assert_equal(nil, e_session["can_show_support_links"])
    assert_equal("audio_input_device_unknown_device", e_session["audio_device_status"])
    assert_equal("true", e_session["is_not_present_in_csp"])
    assert_equal("CANCELLED", e_session["cancel_text"])
    assert_equal(nil, e_session["can_view_full_support"])
    assert_equal("French - FRA Level 1 Unit 1, ID 243630 : Mon, Feb  2, 2032 07:30 AM (EST)", e_session["session"])
    assert_equal(nil, e_session["can_assign_sub"])
  end

  def test_filter_session_for_nil_attendance_expired_session_as_support_lead
    a = login_as_custom_user(AdGroup.support_lead,'rramesh')
    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    session_time = Time.now.utc + 2.years
    options = {:label => "French - FRA Level 1 Unit 1", :session_time => session_time.to_s}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("", e_session["audio"]) # If learners are not there, the status shouldn't be shown.
    assert_equal("false", e_session["can_show_support_links"])
    assert_equal("audio_input_device_unknown_device", e_session["audio_device_status"])
    assert_equal("true", e_session["is_not_present_in_csp"])
    assert_equal("Cancel", e_session["cancel_text"])
    assert_equal("true", e_session["can_view_full_support"])
    assert_equal("French - FRA Level 1 Unit 1, ID 243630 : #{session_time.in_time_zone(a.time_zone).strftime("%a, %b %e, %Y %I:%M %p (%Z)")}", e_session["session"])
    assert_equal("true", e_session["can_assign_sub"])
  end

  def test_filter_session_for_one_attendance_session_with_possible_problems_as_support_lead
    login_as_custom_user(AdGroup.support_lead,'rramesh')
    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    options = {:audio_device_status => 'audio_input_device_yellow'}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(options, {:audio_device_status => 'audio_input_device_yellow'})
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("Possible Problems", e_session["audio"])
  end

  def test_filter_session_for_one_attendance_session_with_known_problems_as_support_lead
    login_as_custom_user(AdGroup.support_lead,'rramesh')
    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    options = {:audio_device_status => 'audio_input_device_red'}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(options, {:audio_device_status => 'audio_input_device_red'})
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("Known Problems", e_session["audio"])
    assert_equal("View only!", e_session["view_link_text"])
    assert_equal("Full Support!", e_session["full_support_text"])

  end

  def test_filter_session_for_nil_attendance_session_with_unknown_problems_as_support_lead
    login_as_custom_user(AdGroup.support_lead,'rramesh')
    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    options = {:audio_device_status => 'audio_input_device_unknown_device'}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(options, {:audio_device_status => 'audio_input_device_unknown_device'})
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("Unknown", e_session["audio"])
    assert_equal("View only!", e_session["view_link_text"])
    assert_equal("Full Support!", e_session["full_support_text"])

  end

  def test_filter_session_for_can_show_support_links_as_support_lead_with_session_time_now
    login_as_custom_user(AdGroup.support_lead,'rramesh')
    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    options = {:label => "French - FRA Level 1 Unit 1", :session_time => Time.now.utc.to_s}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("true", e_session["can_show_support_links"])
  end

  def test_filter_session_for_can_show_support_links_as_support_lead_with_session_time_50_minutes_before
    login_as_custom_user(AdGroup.support_lead,'rramesh')
    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    options = {:label => "French - FRA Level 1 Unit 1", :session_time => (Time.now.utc- 50.minutes).to_s}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("true", e_session["can_show_support_links"])
  end

  def test_filter_session_for_can_show_support_links_as_support_lead_with_session_time_15_minutes_later
    login_as_custom_user(AdGroup.support_lead,'rramesh')
    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    options = {:label => "French - FRA Level 1 Unit 1", :session_time => (Time.now.utc + 15.minutes).to_s}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("true", e_session["can_show_support_links"])
  end

  def test_filter_session_for_can_show_support_links_as_support_lead_with_session_time_25_minutes_later
    login_as_custom_user(AdGroup.support_lead,'rramesh')
    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    options = {:label => "French - FRA Level 1 Unit 1", :session_time => (Time.now.utc + 25.minutes).to_s}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("false", e_session["can_show_support_links"])
  end

  def test_filter_session_for_can_show_support_links_as_support_lead_with_session_time_65_minutes_before
    login_as_custom_user(AdGroup.support_lead,'rramesh')
    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    options = {:label => "French - FRA Level 1 Unit 1", :session_time => (Time.now.utc - 65.minutes).to_s}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(options)
    post :filter_sessions
    
    e_sessions = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("false", e_sessions["can_show_support_links"])
 end

  def test_filter_session_for_first_seen_at_as_support_lead
    user = login_as_custom_user(AdGroup.support_lead,'rramesh')
    a= Account.find_by_user_name(user.user_name)
    a.update_attribute('native_language','ENG')
    #a.update_attribute('time_zone','Eastern Time (US & Canada)')

    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    teacher_first_seen_at = Time.now.utc
    options = {:session => "French - FRA Level 1 Unit 1, ID 243630 : #{Time.now.strftime("%a, %b %-d, %Y %I:%M %p (%Z)")}", :teacher_first_seen_at => teacher_first_seen_at}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal(teacher_first_seen_at.in_time_zone('Eastern Time (US & Canada)').strftime("%a, %b %-d, %Y %I:%M %p (%Z)"), e_session["teacher_first_seen_at"])

    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    options = {:needs_teacher_now => "needs_teacher_now"}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("needs_teacher_now", e_session["needs_teacher_now"])
  end

  def test_filter_session_for_one_attendance_with_technical_problem_session_as_support_lead
    login_as_custom_user(AdGroup.support_lead,'rramesh')
    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    session_options = {}
    learner_options = {:has_technical_problem => "true"}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(session_options, learner_options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("true", e_session["show_warning"])
  end

  def test_filter_session_for_one_attendance_without_technical_problem_session_as_support_lead
    login_as_custom_user(AdGroup.support_lead,'rramesh')
    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    session_options = {}
    learner_options = {:has_technical_problem => "false"}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(session_options, learner_options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal(nil, e_session["show_warning"])
  end

  def test_filter_session_for_village_name_as_support_lead
    login_as_custom_user(AdGroup.support_lead,'rramesh')

    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    Community::Village.expects(:display_name).with(2).returns("Japanese Kids")
    session_options = {:village_id => 2}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(session_options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("Japanese Kids", e_session["village_name"])

    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    Community::Village.expects(:display_name).with(1).returns("Chinese Kids")
    session_options = {:village_id => 1}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(session_options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("Chinese Kids", e_session["village_name"])

    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    session_options = {}
    stub_eschool_dashboard_data_and_get_one_session_as_specified_witout_village(session_options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("--", e_session["village_name"])
  end

  def test_filter_session_for_attendance_url_as_support_lead
    login_as_custom_user(AdGroup.support_lead,'rramesh')
    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    session_options = {}
    learner_options = {:has_technical_problem => "true", :student_in_room =>  "true"}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(session_options, learner_options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("/dashboard/243630/get_learners_for_session?get_attendance=true&learners_info=true&session_details=French+-+FRA+Level+1+Unit+1%2C+ID+243630+%3A+Mon%2C+Feb++2%2C+2032+07%3A30+AM+%28EST%29&show_assist_link=true", e_session["attendances_url"])
    assert_equal("/dashboard/243630/get_learners_for_session?get_learners_in_room=true&learners_info=true&session_details=French+-+FRA+Level+1+Unit+1%2C+ID+243630+%3A+Mon%2C+Feb++2%2C+2032+07%3A30+AM+%28EST%29&show_assist_link=true", e_session["learners_in_room_url"])
  end

  def test_filter_session_for_attendance_url_as_support_user
    login_as_custom_user(AdGroup.support_user,'rramesh')
    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    session_options = {}
    learner_options = {:has_technical_problem => "true", :student_in_room =>  "true"}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(session_options, learner_options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("/dashboard/243630/get_learners_for_session?get_attendance=true&learners_info=true&session_details=French+-+FRA+Level+1+Unit+1%2C+ID+243630+%3A+Mon%2C+Feb++2%2C+2032+07%3A30+AM+%28EST%29&show_assist_link=true", e_session["attendances_url"])
    assert_equal("/dashboard/243630/get_learners_for_session?get_learners_in_room=true&learners_info=true&session_details=French+-+FRA+Level+1+Unit+1%2C+ID+243630+%3A+Mon%2C+Feb++2%2C+2032+07%3A30+AM+%28EST%29&show_assist_link=true", e_session["learners_in_room_url"])
  end

  def test_filter_session_for_attendance_url_as_community_moderator
    login_as_custom_user(AdGroup.community_moderator,'rramesh')
    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    session_options = {}
    learner_options = {:has_technical_problem => "true", :student_in_room =>  "true"}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(session_options, learner_options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("/dashboard/243630/get_learners_for_session?get_attendance=true&learners_info=true&session_details=French+-+FRA+Level+1+Unit+1%2C+ID+243630+%3A+Mon%2C+Feb++2%2C+2032+07%3A30+AM+%28EST%29&show_assist_link=true", e_session["attendances_url"])
    assert_equal("/dashboard/243630/get_learners_for_session?get_learners_in_room=true&learners_info=true&session_details=French+-+FRA+Level+1+Unit+1%2C+ID+243630+%3A+Mon%2C+Feb++2%2C+2032+07%3A30+AM+%28EST%29&show_assist_link=true", e_session["learners_in_room_url"])
  end

  def test_filter_session_for_attendance_url_as_led_user
    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    session_options = {}
    learner_options = {:has_technical_problem => "true", :student_in_room =>  "true"}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(session_options, learner_options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("/dashboard/243630/get_learners_for_session?get_attendance=true&learners_info=true&session_details=French+-+FRA+Level+1+Unit+1%2C+ID+243630+%3A+Mon%2C+Feb++2%2C+2032+07%3A30+AM+%28EST%29&show_assist_link=true", e_session["attendances_url"])
    assert_equal("/dashboard/243630/get_learners_for_session?get_learners_in_room=true&learners_info=true&session_details=French+-+FRA+Level+1+Unit+1%2C+ID+243630+%3A+Mon%2C+Feb++2%2C+2032+07%3A30+AM+%28EST%29&show_assist_link=true", e_session["learners_in_room_url"])
  end

  def test_filter_session_for_attendance_url_support_concierge
    login_as_custom_user(AdGroup.support_concierge_user,'rramesh')
    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    session_options = {}
    learner_options = {:has_technical_problem => "true", :student_in_room =>  "true"}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(session_options, learner_options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("/dashboard/243630/get_learners_for_session?get_attendance=true&learners_info=true&session_details=French+-+FRA+Level+1+Unit+1%2C+ID+243630+%3A+Mon%2C+Feb++2%2C+2032+07%3A30+AM+%28EST%29&show_assist_link=true", e_session["attendances_url"])
    assert_equal("/dashboard/243630/get_learners_for_session?get_learners_in_room=true&learners_info=true&session_details=French+-+FRA+Level+1+Unit+1%2C+ID+243630+%3A+Mon%2C+Feb++2%2C+2032+07%3A30+AM+%28EST%29&show_assist_link=true", e_session["learners_in_room_url"])
  end

  def test_filter_session_for_attendance_url_as_support_harrisonburg
    login_as_custom_user(AdGroup.support_harrisonburg_user,'rramesh')
    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    session_options = {}
    learner_options = {:has_technical_problem => "true", :student_in_room =>  "true"}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(session_options, learner_options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("/dashboard/243630/get_learners_for_session?get_attendance=true&learners_info=true&session_details=French+-+FRA+Level+1+Unit+1%2C+ID+243630+%3A+Mon%2C+Feb++2%2C+2032+07%3A30+AM+%28EST%29&show_assist_link=true", e_session["attendances_url"])
    assert_equal("/dashboard/243630/get_learners_for_session?get_learners_in_room=true&learners_info=true&session_details=French+-+FRA+Level+1+Unit+1%2C+ID+243630+%3A+Mon%2C+Feb++2%2C+2032+07%3A30+AM+%28EST%29&show_assist_link=true", e_session["learners_in_room_url"])
  end

  def test_filter_session_for_attendance_url_as_coach_manager
    a = login_as_custom_user(AdGroup.coach_manager,'newcoachmanager')
    CoachSession.stubs(:find_by_eschool_session_id).returns(CoachSession.first)
    CoachSession.any_instance.stubs(:coach).returns(Coach.find_by_user_name('rramesh'))
    CoachSession.stubs(:find_all_by_eschool_session_id).returns []
    session_options = {}
    learner_options = {:has_technical_problem => "true", :student_in_room =>  "true"}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(session_options, learner_options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("/dashboard/243630/get_learners_for_session?get_attendance=true&learners_info=true&session_details=French+-+FRA+Level+1+Unit+1%2C+ID+243630+%3A+Mon%2C+Feb++2%2C+2032+07%3A30+AM+%28EST%29&show_assist_link=true", e_session["attendances_url"])
    assert_equal("/dashboard/243630/get_learners_for_session?get_learners_in_room=true&learners_info=true&session_details=French+-+FRA+Level+1+Unit+1%2C+ID+243630+%3A+Mon%2C+Feb++2%2C+2032+07%3A30+AM+%28EST%29&show_assist_link=true", e_session["learners_in_room_url"])
  end


  def test_filter_session_for_is_reflex_as_support_lead
    login_as_custom_user(AdGroup.support_lead,'rramesh')
    options = {:label => "English (American) - JLE Level 1 Unit 1"}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("true", e_session["is_reflex"])

    login_as_custom_user(AdGroup.support_lead,'rramesh')
    options = {:label => "English (American) - KLE Level 1 Unit 1"}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("true", e_session["is_reflex"])

    options = {}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("false", e_session["is_reflex"])
  end

  def test_request_a_sustitute_for_totale_session_as_coach_manager
    a = login_as_custom_user(AdGroup.coach_manager,'newcoachmanager')
    coach = FactoryGirl.create(:coach, :user_name => 'coach')
    ConfirmedSession.any_instance.stubs(:learners_signed_up).returns(1)
    CoachSession.stubs(:find_by_eschool_session_id).returns(CoachSession.first)
    LocalSession.any_instance.stubs(:coach).returns(coach)
    CoachSession.stubs(:find_all_by_eschool_session_id).returns []
    session_options = {}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(session_options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("true", e_session["can_assign_sub"])
    assert_equal("2032-02-02T12:30:00Z", e_session["session_time"])
    assert_equal(coach.id, e_session["coach_id"])
    FactoryGirl.create(:coach_session, :coach_id => e_session["coach_id"], :language_identifier => 'FRA', :session_start_time => e_session["session_time"], :cancelled => 0, :type => 'ConfirmedSession')
    @controller = SubstitutionController.new
    xhr :post, :request_substitute_for_coach,{:current_coach_id => e_session["coach_id"],:time =>  e_session["session_time"], :request_from => 'dashboard'}
    assert_response :success
    assert_equal "Substitute was requested successfully", (JSON.parse(@response.body))["message"]
  end

  def test_filter_session_for_village_name_as_support_lead
    login_as_custom_user(AdGroup.support_lead,'rramesh')

    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    Community::Village.expects(:display_name).with(2).returns("Japanese Kids")
    session_options = {:village_id => 2}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(session_options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("Japanese Kids", e_session["village_name"])

    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    Community::Village.expects(:display_name).with(1).returns("Chinese Kids")
    session_options = {:village_id => 1}
    stub_eschool_dashboard_data_and_get_one_session_as_specified(session_options)
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("Chinese Kids", e_session["village_name"])

    CoachSession.expects(:find_all_by_eschool_session_id).returns []
    session_options = {}
    stub_eschool_dashboard_data_and_get_one_session_as_specified_witout_audio_info(session_options, {:audio_device_status => 'audio_input_device_green'})
    post :filter_sessions
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal("", e_session["audio"])
  end

  def test_filter_completed_sessions
    CoachSession.expects(:find_all_by_eschool_session_id).never
    duped_session = Dupe.create :session, :class_status => 'already_finished'
    sessions = Dupe.create :session, :eschool_sessions => [duped_session]
    sessions=DashboardController.new.filter_completed_sessions sessions
    assert_equal true, sessions.eschool_sessions.blank?
  end
  
  def test_get_audio_value
    login_as_custom_user(AdGroup.led_user, 'test21')
    params = {:support_language_id => 'All', :session_language_id => 'Advanced', :session_start_time_id => 'Starting in next hour', :page_number => '2'}
    start_time = Time.now
    end_time = Time.now + 1.hour
    dashboard_future_session = true
    DashboardUtils.expects(:calculate_dashboard_values).with(params[:session_start_time_id]).returns({:start_time => start_time, :end_time => end_time, :future_session? => dashboard_future_session})
    eschool_sessions = dashboard_response_with_one_session({}, {:audio_input_device => "audio_input_device_red"})
    ExternalHandler::HandleSession.expects(:dashboard_data).with(TotaleLanguage.first, {:dashboard_user_name => 'test21', :records_per_page => 100, :page_num => params[:page_number], :start_time => start_time, :end_time => end_time, :session_language => 'Advanced', :support_language => 'All', :native_language => 'en-US', :dashboard_future_session => dashboard_future_session, :get_non_assistable_sessions => "false"}).returns(eschool_sessions)
    response = get :filter_sessions, params
    e_session = (JSON.parse(@response.body))["sessions"]["eschool_sessions"][0]
    assert_equal"audio_input_device_red", e_session["attendances"][0]["audio_input_device"]
    end

  def test_get_session_time_with_edt
    time_in_utc = DashboardController.new.send(:get_session_time, Dupe.create(:session, :session => "English (American) - KLE Level 1 Unit 1: Wed, Apr 18, 2012 04:04 AM (EDT)"))
    assert_equal "2012-04-18 08:04:00", time_in_utc.to_s(:db)
  end

  def test_get_session_time_with_est
    time_in_utc = DashboardController.new.send(:get_session_time, Dupe.create(:session, :session => "English (American) - KLE Level 1 Unit 1: Wed, Apr 18, 2012 04:04 AM (EST)"))
    assert_equal "2012-04-18 09:04:00", time_in_utc.to_s(:db)
  end

  def test_get_session_time_with_ist
    time_in_utc = DashboardController.new.send(:get_session_time, Dupe.create(:session, :session => "English (American) - KLE Level 1 Unit 1: Wed, Apr 18, 2012 04:04 AM (IST)"))
    assert_equal "2012-04-17 22:34:00", time_in_utc.to_s(:db)
  end

  def test_get_session_time_with_cdt
    time_in_utc = DashboardController.new.send(:get_session_time, Dupe.create(:session, :session => "English (American) - KLE Level 1 Unit 1: Wed, Apr 18, 2012 04:04 AM (CDT)"))
    assert_equal "2012-04-18 09:04:00", time_in_utc.to_s(:db)
  end

  def test_get_aeb_sessions_returns_sessions_filter_by_time
    coach = create_coach_with_qualifications('rajkumar', ['AUS'])
    coach2 = create_coach_with_qualifications('rajkumarTwo', ['AUK'])
    t1 = Time.now.beginning_of_hour.utc + 1.hour
    ConfirmedSession.any_instance.stubs(:supersaas_learner).returns([])
    AdobeConnect::Base.stubs(:one_time_login).returns("a cookie")
    AdobeConnect::Base.stubs(:users_in_meeting_logged_in).returns(nil)
    BigBlueButton::Base.stubs(:determine_server_host).returns([200,"abc.adobeconnect.com"])
    params = {:support_language_id => 'All', :session_language_id => 'AEB', :session_start_time_id => 'Starting in next hour', :page_number => '1'}
    live = FactoryGirl.build(:confirmed_session, :coach_id=> coach.id, :eschool_session_id => 12374, :language_identifier => 'AUS', :language_id => Language['AUS'].id, :session_start_time => t1-1.hour, :session_end_time => t1)
    live.save(:validate => false)
    live = FactoryGirl.build(:confirmed_session, :coach_id=> coach.id, :eschool_session_id => 12374, :language_identifier => 'AUS', :language_id => Language['AUS'].id, :session_start_time => t1-2.hour, :session_end_time => t1-1.hour)
    live.save(:validate => false)
    FactoryGirl.create(:confirmed_session, :coach_id=> coach.id, :eschool_session_id => 1234, :language_identifier => 'AUS', :session_start_time => t1)
    FactoryGirl.create(:confirmed_session, :coach_id=> coach2.id, :eschool_session_id => 13234, :language_identifier => 'AUK', :session_start_time => t1)
    FactoryGirl.create(:confirmed_session, :coach_id=> coach.id, :eschool_session_id => 12334, :language_identifier => 'AUS', :session_start_time => t1+1.hour)
    FactoryGirl.create(:confirmed_session, :coach_id=> coach.id, :eschool_session_id => 12354, :language_identifier => 'AUS', :session_start_time => t1+2.hour)
    FactoryGirl.create(:confirmed_session, :coach_id=> coach.id, :eschool_session_id => 14234, :language_identifier => 'AUS', :session_start_time => t1+3.hour, :cancelled => 1)
    #Starting in next hour Aria all
    response = get :filter_sessions, params
    sessions = JSON.parse(response.body)["sessions"]["session"]["eschool_sessions"]
    assert_equal 3, sessions.count
    #Starting in next hour AUS
    params[:session_language_id] = 'AUS'
    response = get :filter_sessions, params
    sessions = JSON.parse(response.body)["sessions"]["session"]["eschool_sessions"]
    assert_equal 2, sessions.count
    #Live now sessions AUS
    params[:session_start_time_id] = 'Live Now'
    response = get :filter_sessions, params
    sessions = JSON.parse(response.body)["sessions"]["session"]["eschool_sessions"]
    assert_equal 1, sessions.count
    #past 1 hour
    params[:session_start_time_id] = 'One hour old'
    response = get :filter_sessions, params
    sessions = JSON.parse(response.body)["sessions"]["session"]["eschool_sessions"]
    assert_equal 2, sessions.count
  end

  def test_eschool_returns_blank_response
    ExternalHandler::HandleSession.stubs(:dashboard_data).returns([])
    params = {:support_language_id => 'All', :session_language_id => 'ARA', :session_start_time_id => 'Starting in next hour', :page_number => '1'}
    response = get :filter_sessions, params
    assert_equal 'There is some problem please try again.', response.body
  end

  def test_get_aeb_sessions_with_response_from_adobe
    coach = create_coach_with_qualifications('rajkumar', ['AUS'])
    t1 = Time.now.beginning_of_hour.utc + 1.hour
    ExternalHandler::HandleSession.stubs(:find_session).returns(nil)
    learner = [{:full_name=>"Adobe Learner Test", :guid=>"81478455-033f-4af4-a99e-5f392ab4d2f5", :email=>"adobeconnectuser@example.com", :booking_id=>15018048}]
    ConfirmedSession.any_instance.stubs(:supersaas_learner).returns(learner)
    adobe_response = '<?xml version="1.0" encoding="UTF-8"?>
    <results>
      <status code="ok"/>
      <report-meeting-attendance>
        <row transcript-id="1277136355" asset-id="1277108371" sco-id="1277055810" principal-id="1276200314" answered-survey="0">
          <login>0c1bd958-105a-4b62-b1c8-36273ba4631c</login>
          <session-name>WebService User</session-name>
          <sco-name>Live Session: m8202271</sco-name>
          <date-created>2014-06-27T03:14:39.520-04:00</date-created>
          <participant-name>WebService User</participant-name>
        </row>
        <row transcript-id="1277108370" asset-id="1277108371" sco-id="1277055810" principal-id="1276863885" answered-survey="0">
          <login>0c1bd958-105a-4b62-b1c8-36273ba4631c</login>
          <session-name>abdularia01 abdularia01</session-name>
          <sco-name>Live Session: m8202271</sco-name>
          <date-created>2014-06-27T03:14:29.557-04:00</date-created>
          <date-end>2014-06-27T03:20:18.673-04:00</date-end>
          <participant-name>abdularia01 abdularia01</participant-name>
        </row>
        <row transcript-id="1277108370" asset-id="1277108371" sco-id="1277055810" principal-id="1276863888" answered-survey="0">
          <login>81478455-033f-4af4-a99e-5f392ab4d2f5</login>
          <session-name>Adobe Learner Test</session-name>
          <sco-name>Live Session: m8202271</sco-name>
          <date-created>2014-06-27T03:14:29.557-04:00</date-created>
          <participant-name>Adobe Learner Test</participant-name>
        </row>
      </report-meeting-attendance>
    </results>'
    
    AdobeConnect::Base.stubs(:one_time_login).returns("a cookie")
    AdobeConnect::Base.stubs(:users_in_meeting_logged_in).returns(adobe_response)
    BigBlueButton::Base.stubs(:determine_server_host).returns([200,"abc.adobeconnect.com"])
    params = {:support_language_id => 'All', :session_language_id => 'AEB', :session_start_time_id => 'Live Now', :page_number => '1'}
    live = FactoryGirl.build(:confirmed_session, :coach_id=> coach.id, :eschool_session_id => 8202271, :language_identifier => 'AUS', :language_id => Language['AUS'].id, :session_start_time => t1-1.hour, :session_end_time => t1)
    live.save(:validate => false)
    response = get :filter_sessions, params
    sessions = JSON.parse(response.body)["sessions"]["session"]["eschool_sessions"]
    assert_equal 1, sessions.count

  end

  def test_get_aeb_sessions_in_bbb_player
    coach = create_coach_with_qualifications('rajkumar', ['AUS'])
    t1 = Time.now.beginning_of_hour.utc + 1.hour
    ExternalHandler::HandleSession.stubs(:find_session).returns(nil)
    learner = [{:full_name=>"Adobe Learner Test", :guid=>"81478455-033f-4af4-a99e-5f392ab4d2f5", :email=>"adobeconnectuser@example.com", :booking_id=>15018048}]
    ConfirmedSession.any_instance.stubs(:supersaas_learner).returns(learner)
    AdobeConnect::Base.stubs(:one_time_login).returns("a cookie")
    BigBlueButton::Base.stubs(:determine_server_host).returns([200,"abc.bbb.com"])
    params = {:support_language_id => 'All', :session_language_id => 'AEB', :session_start_time_id => 'Live Now', :page_number => '1'}
    live = FactoryGirl.build(:confirmed_session, :coach_id=> coach.id, :eschool_session_id => 8202271, :language_identifier => 'AUS', :language_id => Language['AUS'].id, :session_start_time => t1-1.hour, :session_end_time => t1)
    live.save(:validate => false)
    response = get :filter_sessions, params
    sessions = JSON.parse(response.body)["sessions"]["session"]["eschool_sessions"]
    assert_equal 1, sessions.count
    assert_equal "No Player Information", sessions[0]["eschool_session"]["teacher_first_seen_at"]
    assert_equal "N/A", sessions[0]["eschool_session"]["students_in_room_count"]
  end

  private

  def stub_eschool_dashboard_data_and_get_one_session_as_specified(session_options = {}, attendance_options = nil)
    Eschool::Session.stubs(:dashboard_data).returns dashboard_response_with_one_session(session_options, attendance_options)
  end

  def stub_eschool_dashboard_data_and_get_one_session_as_specified_witout_village(session_options = {}, attendance_options = nil)
    Eschool::Session.stubs(:dashboard_data).returns dashboard_response_with_one_session_with_no_village_id(session_options, attendance_options)
  end

  def stub_eschool_dashboard_data_and_get_one_session_as_specified_witout_audio_info(session_options = {}, attendance_options = nil)
    Eschool::Session.stubs(:dashboard_data).returns dashboard_response_with_one_session_without_audio_info(session_options, attendance_options)
  end

  def setup_expectations
    login_as_custom_user(AdGroup.coach_manager, 'hello')
    real_time_lotus_data
    Eschool::Session.stubs(:dashboard_data).returns(eschool_sessions_with_empty_attribute_values_mock)
    CoachSession.any_instance.stubs(:send_email_to_coaches_and_coach_managers).returns nil # Since this method is called as a separate thread, this method has to be stubbed
  end

  def stub_eschool_for_assist_learner
    setup_expectations
    stub_eschool_call_for_find_by_id({})
  end

  def dashboard_response_with_one_session(options = {}, attendance_options = nil)
    attendances = attendance_options ? dashboard_response_with_one_attendance(attendance_options) : nil

    duped_session = Dupe.create :session,
      :is_reflex                => options[:is_reflex]?  options[:is_reflex] : 'false',
      :attendances              => attendances ? attendances : [],
      :session_id               => options[:session_id]?  options[:session_id] :243630,
      :session_time             => options[:session_time]?  options[:session_time] : "Mon Feb 02 12:30:00 UTC 2032",
      :label                    => options[:label]? options[:label] : "French - FRA Level 1 Unit 1",
      :audio_device_status      => options[:audio_device_status]?  options[:audio_device_status] :"audio_input_device_unknown_device",
      :teacher                  => options[:teacher]?  options[:teacher] :"jramanathan",
      :teacher_id               => options[:teacher_id]?  options[:teacher_id] : 12,
      :attendances_count        => attendances ? attendances.size : 0 ,
      :class_status             => options[:class_status]?  options[:class_status] :"starts_in_future" ,
      :village_id               => options[:village_id]?  options[:village_id] :"-1" ,
      :students_attended_count  => options[:students_attended_count]?  options[:students_attended_count] :"0" ,
      :cancelled                => options[:cancelled]?  options[:cancelled] : "false" ,
      :students_in_room_count   => options[:students_in_room_count]?  options[:students_in_room_count] :"0",
      :teacher_first_seen_at    => options[:teacher_first_seen_at]?  options[:teacher_first_seen_at] : '',
      :needs_teacher_now        => options[:needs_teacher_now]?  options[:needs_teacher_now] : ''

    sessions = Dupe.create :session, :eschool_sessions => [duped_session]
    return sessions
  end

  def dashboard_response_with_one_session_without_audio_info(options = {}, attendance_options = nil)
    attendances = attendance_options ? dashboard_response_with_one_attendance_and_nil_audio_input_device(attendance_options) : nil

    duped_session = Dupe.create :session,
      :is_reflex                => options[:is_reflex]?  options[:is_reflex] : 'false',
      :attendances              => attendances ? attendances : [],
      :session_id               => options[:session_id]?  options[:session_id] :243630,
      :session_time             => options[:session_time]?  options[:session_time] : "Mon Feb 02 12:30:00 UTC 2032",
      :label                    => options[:label]? options[:label] : "French - FRA Level 1 Unit 1",
      :teacher                  => options[:teacher]?  options[:teacher] :"jramanathan" ,
      :teacher_id               => options[:teacher_id]?  options[:teacher_id] : 12,
      :attendances_count        => attendances ? attendances.size : 0 ,
      :class_status             => options[:class_status]?  options[:class_status] :"starts_in_future" ,
      :village_id               => options[:village_id]?  options[:village_id] :"-1" ,
      :students_attended_count  => options[:students_attended_count]?  options[:students_attended_count] :"0" ,
      :cancelled                => options[:cancelled]?  options[:cancelled] : "false" ,
      :students_in_room_count   => options[:students_in_room_count]?  options[:students_in_room_count] :"0",
      :teacher_first_seen_at    => options[:teacher_first_seen_at]?  options[:teacher_first_seen_at] : '',
      :needs_teacher_now        => options[:needs_teacher_now]?  options[:needs_teacher_now] : ''
    sessions = Dupe.create :session, :eschool_sessions => [duped_session]
    return sessions
  end

  def dashboard_response_with_one_session_with_no_village_id(options = {}, attendance_options = nil)
    attendances = attendance_options ? dashboard_response_with_one_attendance(attendance_options) : nil

    duped_session = Dupe.create :session,
      :is_reflex                => options[:is_reflex]?  options[:is_reflex] : 'false',
      :attendances              => attendances ? attendances : [],
      :session_id               => options[:session_id]?  options[:session_id] :243630,
      :session_time             => options[:session_time]?  options[:session_time] : "Mon Feb 02 12:30:00 UTC 2032",
      :label                    => options[:label]? options[:label] : "French - FRA Level 1 Unit 1",
      :audio_device_status      => options[:audio_device_status]?  options[:audio_device_status] :"audio_input_device_unknown_device",
      :teacher                  => options[:teacher]?  options[:teacher] :"jramanathan" ,
      :teacher_id               => options[:teacher_id]?  options[:teacher_id] :  Account.find_by_user_name("jramanathan").id,
      :attendances_count        => attendances ? attendances.size : 0 ,
      :class_status             => options[:class_status]?  options[:class_status] :"starts_in_future" ,
      :students_attended_count  => options[:students_attended_count]?  options[:students_attended_count] :"0" ,
      :cancelled                => options[:cancelled]?  options[:cancelled] : "false" ,
      :students_in_room_count   => options[:students_in_room_count]?  options[:students_in_room_count] :"0",
      :teacher_first_seen_at    => options[:teacher_first_seen_at]?  options[:teacher_first_seen_at] : '',
      :needs_teacher_now        => options[:needs_teacher_now]?  options[:needs_teacher_now] : ''


    sessions = Dupe.create :session, :eschool_sessions => [duped_session]
    return sessions
  end

  def dashboard_response_with_one_attendance(options = nil)
    dupe_learner = Dupe.create :attendance,
      :first_name                 => options[:first_name]?  options[:first_name] : 'David',
      :student_in_room            => options[:student_in_room]?  options[:student_in_room] : "false",
      :last_name                  => options[:last_name]?  options[:last_name] : "Paxon",
      :guid                       => options[:guid]?  options[:guid] :'asdn-sdew-dse4-sdds-rtfg',
      :email                      => options[:email]?  options[:email] :"dpaxon@rs.com",
      :audio_input_device         => options[:audio_input_device]?  options[:audio_input_device] :"" ,
      :audio_output_device        => options[:audio_output_device]?  options[:audio_output_device] :"0" ,
      :audio_input_device_status  => options[:audio_input_device_status]?  options[:audio_input_device_status] : 'NA',
      :has_technical_problem      => options[:has_technical_problem]?  options[:has_technical_problem] : "false"

    return [dupe_learner]
  end

  def dashboard_response_with_one_attendance_and_nil_audio_input_device(options = nil)
    dupe_learner = Dupe.create :attendance,
      :first_name                 => options[:first_name]?  options[:first_name] : 'David',
      :student_in_room            => options[:student_in_room]?  options[:student_in_room] : "false",
      :last_name                  => options[:last_name]?  options[:last_name] : "Paxon",
      :guid                       => options[:guid]?  options[:guid] :'asdn-sdew-dse4-sdds-rtfg',
      :email                      => options[:email]?  options[:email] :"dpaxon@rs.com",
      :audio_output_device        => options[:audio_output_device]?  options[:audio_output_device] :"0" ,
      :audio_input_device         => nil,
      :audio_input_device_status  => options[:audio_input_device_status]?  options[:audio_input_device_status] : 'NA',
      :has_technical_problem      => options[:has_technical_problem]?  options[:has_technical_problem] : "false"

    return [dupe_learner]
  end

end
