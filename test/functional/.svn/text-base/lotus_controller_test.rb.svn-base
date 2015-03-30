require File.dirname(__FILE__) + '/../test_helper'
require 'app/utils/lotus_real_time_data'

class LotusControllerTest < ActionController::TestCase

  def setup
    login_as_coach_manager
    real_time_lotus_data
    MemcacheService.clear_all
  end

  def test_learners_waiting_details_with_error
    Eschool::StudentQueue.expects(:learners_waiting_details).returns(nil)
    get :learners_waiting_details
    assert_response :success
    assert_select "div", :text => "There are no learners waiting.", :count => 1
  end

  def test_learners_waiting_details_with_no_learner_in_queue
    Eschool::StudentQueue.expects(:learners_waiting_details).returns({"waiting_students" => []})
    get :learners_waiting_details
    assert_response :success
    assert_select "div", :text => "There are no learners waiting.", :count => 1
  end

  def test_learners_waiting_details_with_one_learner_in_queue
    Eschool::StudentQueue.expects(:learners_waiting_details).returns({"waiting_students"=>[{"waiting_duration"=>"10.52", "display_name"=>"Alexie"}]})
    get :learners_waiting_details
    assert_response :success
    assert_select "div", :text => "There are no learners waiting.", :count => 0
    assert_select 'div[class="learners_header_container"]' do
      assert_select 'span[class="learner_header"]', :text => "Learner Name", :count => 1
      assert_select 'span[class="learner_long_header"]', :text => "Waiting Duration(in minutes)", :count => 1
    end
    assert_select 'div[class="learners_names_list"]' do
      assert_select 'span[class="learner_name"]', :text => "Alexie", :count => 1
      assert_select 'span[class="learner_long_attribute"]', :text => "10.52", :count => 1
    end
  end

  def test_lotus_real_time_data
    time = Time.now.utc
    response = {"conversations"=> [], "paused"=> [], "teaching"=> [], "longest_learners_waiting_time_sec_for_both"=> 0.0, "total_in_player"=> [], "initializing"=> [], "polling"=> [], "teachers_scheduled"=> [], "calibrating"=> [], "time"=> time, "skills_or_rehearsal"=> [], "not_teaching"=> [], "skills"=> [], "teachers_scheduled_in_next_hour"=> [], "learners_waiting"=> [], "time_for_average_wait_time"=> time, "in_support"=> [], "average_learners_waiting_time_sec_for_both"=> 0.0}
    LotusRealTimeData.stubs(:lotus_real_time_data).returns(response)
    get :lotus_real_time_data
    assert_response :success
    assert_select "span#coaches_scheduled", :text => 0
    assert_select "span#coaches_scheduled_in_the_next_hour", :text => 0
    assert_select 'div[class="right_half_element"]', :count => 7
    assert_select 'span[class="right_ele_attr"]', :count => 6 do
      assert_select 'span[class="right_ele_attr"]', :text => 0
    end
    assert_select 'span#skills', :text => 0
    assert_select 'span#skills_rehearsals', :text => 0
    assert_select 'span#rehearsals', :text => 0
  end
  
  def test_coach_scheduled_in_reflex_coach_details_when_one_coach_is_scheduled_and_one_coach_has_requested_sub
    mock_now(Time.now.utc)
    Coach.find_by_user_name
    coach=create_coach_with_qualifications("jramanathan",[])
    session_start_time =  TimeUtils.current_slot
    FactoryGirl.create(:confirmed_session,:coach_id => coach.id, :session_start_time =>session_start_time, :language_identifier => 'KLE' )
    FactoryGirl.create(:confirmed_session,:coach_id => nil, :session_start_time =>session_start_time, :language_identifier => 'KLE' )
    get :reflex_coach_details, :details_for => 'teachers_scheduled'
    assert_response :success
    assert_no_tag "div#message"
    assert_select 'div[class="coach_element"]', :count => 1, :text => 'Jramanathan'
  end


  def test_coach_scheduled_in_reflex_coach_details_when_no_coaches_are_scheduled
    CoachSession.delete_all
    get :reflex_coach_details, :details_for => 'teachers_scheduled'
    assert_response :success
    assert_select "div#message", :text => 'No coaches available'
  end

  def test_coach_scheduled_in_reflex_coach_details_when_one_coach_is_scheduled
    coach = FactoryGirl.create(:account, :type => 'Coach', :full_name => "#{4.random_letters}", :user_name => "#{4.random_letters}", :rs_email => "#{4.random_letters}@rs.com")
    FactoryGirl.create(:coach_session, :session_start_time => TimeUtils.current_slot, :coach_id => coach.id, :language_identifier => "KLE",:type => "ConfirmedSession")

    get :reflex_coach_details, :details_for => 'teachers_scheduled'
    assert_response :success    
    assert_no_tag "div#message"
    assert_select('div[class="coach_element"]', :count => 1, :text => coach.full_name)
  end

  def test_highlight_coaches_who_are_not_scheduled_but_in_player
    coach1 = create_coach_with_qualifications
    FactoryGirl.create(:coach_session, :session_start_time => TimeUtils.current_slot, :coach_id => coach1.id, :language_identifier => "KLE",:type => "ConfirmedSession")
    coach2 = FactoryGirl.create(:account, :type => 'Coach', :full_name => "redcoach", :user_name => "redcoach", :rs_email => "#{4.random_letters}@rs.com")
    real_time_lotus_data("2","100",[{'external_coach_id' => "#{coach1.id}", 'status' => 'teaching', 'language_id' => 'KLE'},{'external_coach_id' => "#{coach2.id}", 'status' => 'calibrating', 'language_id' => 'KLE'} ],"1.1")
    get :reflex_coach_details, :details_for => 'total_in_player'
    assert_response :success
    assert_select 'div[class="coach_element"]', :count => 2
    assert_select 'div[class="coach_element"]', :text => coach1.full_name
    assert_select 'div[class="coach_element"]', :text => coach2.full_name
    assert_select 'div[style = "color: red"]', :text => coach2.full_name
  end

  def test_coach_scheduled_in_reflex_coach_details_when_one_coach_is_scheduled_and_one_coach_has_cancelled_session
    coach1 = FactoryGirl.create(:account, :type => 'Coach', :full_name => "#{4.random_letters}", :user_name => "#{4.random_letters}", :rs_email => "#{4.random_letters}@rs.com")
    coach2 = FactoryGirl.create(:account, :type => 'Coach', :full_name => "#{4.random_letters}", :user_name => "#{4.random_letters}", :rs_email => "#{4.random_letters}@rs.com")
    session_start_time =  TimeUtils.current_slot
    FactoryGirl.create(:coach_session, :session_start_time => session_start_time, :coach_id => coach1.id, :language_identifier => "KLE",:type => "ConfirmedSession")
    FactoryGirl.create(:coach_session, :session_start_time => session_start_time, :coach_id => coach2.id, :language_identifier => "KLE", :cancelled => true,:type => "ConfirmedSession")

    get :reflex_coach_details, :details_for => 'teachers_scheduled'
    assert_response :success
    assert_no_tag "div#message"
    assert_select 'div[class="coach_element"]', :count => 1, :text => coach1.full_name
  end

  def test_reflex_coach_details
    coach1 = FactoryGirl.create(:account, :type => 'Coach', :full_name => "#{4.random_letters}", :user_name => "#{4.random_letters}", :rs_email => "#{4.random_letters}@rs.com")
    coach2 = FactoryGirl.create(:account, :type => 'Coach', :full_name => "#{4.random_letters}", :user_name => "#{4.random_letters}", :rs_email => "#{4.random_letters}@rs.com")
    coach3 = FactoryGirl.create(:account, :type => 'Coach', :full_name => "#{4.random_letters}", :user_name => "#{4.random_letters}", :rs_email => "#{4.random_letters}@rs.com")
    FactoryGirl.create(:reflex_activity, :coach_id => coach2.id, :event => "coach_paused", :timestamp => Time.now.utc - 5.minutes)
    real_time_lotus_data("2","100",[{'external_coach_id' => "#{coach1.id}", 'status' => 'teaching', 'language_id' => 'KLE'},{'external_coach_id' => "#{coach2.id}", 'status' => 'paused', 'language_id' => 'JLE'},{'external_coach_id' => "#{coach3.id}", 'status' => 'calibrating', 'language_id' => 'KLE'}],"1.1")
    get :reflex_coach_details, :details_for => 'teaching'
    assert_response :success
    assert_no_tag "div#message"
    assert_select 'div[class="coach_element"]', :count => 1, :text => coach1.full_name

    get :reflex_coach_details, :details_for => 'polling'
    assert_response :success
    assert_select "div#message", :text => 'No coaches available'

    get :reflex_coach_details, :details_for => 'not_teaching'
    assert_response :success
    assert_select 'div[class="coach_element"]', :count => 2
    assert_select 'div[class="coach_element"]', :text => coach2.full_name
    assert_select 'div[class="coach_element"]', :text => coach3.full_name

    FactoryGirl.create(:reflex_activity, :coach_id => coach2.id, :timestamp => Time.now-10.minutes, :event => 'coach_paused')
    get :reflex_coach_details, :details_for => 'paused'
    assert_response :success
    assert_tag :table , :attributes => {:id => 'popup_coach_list_entries'}
    assert_true @response.body.include?(coach2.full_name)

    get :reflex_coach_details, :details_for => 'calibrating'
    assert_response :success
    assert_select 'div[class="coach_element"]', :text => coach3.full_name

    get :reflex_coach_details, :details_for => 'in_support'
    assert_response :success
    assert_select "div#message", :text => 'No coaches available'

    get :reflex_coach_details, :details_for => 'initializing'
    assert_response :success
    assert_select "div#message", :text => 'No coaches available'

    get :reflex_coach_details, :details_for => 'total_in_player'
    assert_response :success
    assert_select 'div[class="coach_element"]', :count => 3
    assert_select 'div[class="coach_element"]', :text => coach3.full_name
    assert_select 'div[class="coach_element"]', :text => coach2.full_name
    assert_select 'div[class="coach_element"]', :text => coach1.full_name
  end

  def test_reflex_learner_details_with_one_learner_in_gridtime_and_one_in_none
    learner1 = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '1111111111')
    Locos::Lotus.stubs(:find_active_session_details_by_activity).returns({"skills"=>[{"user_guid"=> learner1.guid}], "conversations"=>[]})
    get :reflex_learner_details, :details_for => 'skills'
    assert_response :success
    assert_select 'div[class="learners_header_container"]', :count => 1
    assert_select 'div[class="learners_names_list"]', :count => 1
    assert_select 'span[class="learner_name"]', :text => learner1.first_name
    assert_select 'span[class="learner_name"]', :text => learner1.last_name
    assert_select 'span[class="learner_name"]', :text => learner1.preferred_name
  end

  def test_reflex_learner_details_two_learners_in_skills
    learner1 = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '1111111111')
    learner2 = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '2222222222')
    Locos::Lotus.stubs(:find_active_session_details_by_activity).returns(
      {"skills"=>[{"user_guid"=> learner1.guid}, {"user_guid"=> learner2.guid}] , "conversations"=>[]})
    get :reflex_learner_details, :details_for => 'skills'
    assert_response :success
    assert_select 'div[class="learners_header_container"]', :count => 1
    assert_select 'div[class="learners_names_list"]', :count => 2
    assert_select 'span[class="learner_name"]', :text => learner1.first_name
    assert_select 'span[class="learner_name"]', :text => learner1.last_name
    assert_select 'span[class="learner_name"]', :text => learner1.preferred_name
    assert_select 'span[class="learner_name"]', :text => learner2.first_name
    assert_select 'span[class="learner_name"]', :text => learner2.last_name
    assert_select 'span[class="learner_name"]', :text => learner2.preferred_name
  end

  def test_reflex_learner_details_zero_learners_anywhere
    Locos::Lotus.stubs(:find_active_session_details_by_activity).returns(
      {"skills"=>[], "conversations"=>[]})
    get :reflex_learner_details, :details_for => 'skills'
    assert_response :success
    assert_select 'div#message', :text => "No learners available"
  end
  
  def test_reflex_coach_scheduled_details
    time = Time.now.utc
    response = {"conversations"=> [], "paused"=> [], "teaching"=> [], "longest_learners_waiting_time_sec_for_both"=> 0.0, "total_in_player"=> ["sharmila","ESPscheduled","Dranjit"], "initializing"=> [], "polling"=> [], "teachers_scheduled"=> ["adv coachkle2","testcoach","Dranjit"], "calibrating"=> [], "time"=> time, "skills_or_rehearsal"=> [], "not_teaching"=> [], "skills"=> [], "teachers_scheduled_in_next_hour"=> [], "learners_waiting"=> [], "time_for_average_wait_time"=> time, "in_support"=> [], "average_learners_waiting_time_sec_for_both"=> 0.0}
    LotusRealTimeData.stubs(:lotus_real_time_data).returns(response)
    get :reflex_coach_scheduled_details
    assert_response :success
  end

  def test_last_5_logins
    time = Time.now.utc
    coach = FactoryGirl.create(:account, :user_name => 'coach', :type => 'Coach')
    reflex_activity = FactoryGirl.create(:reflex_activity,:coach_id => coach.id, :timestamp => time, :event =>'coach_initialized')
    get :last_5_logins    
    assert_response :success
  end  

  def test_about_lotus_data
     get :about_lotus_data
     assert_response :success
  end 



end
