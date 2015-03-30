require File.expand_path('../../test_helper', __FILE__)

class CoachSchedulerControllerTest < ActionController::TestCase
  fixtures :topics, :accounts, :qualifications, :languages
  def test_coaches_for_given_language
    login_as_custom_user(AdGroup.coach_manager, 'hello')
    Coach.delete_all
    coach = create_coach_with_qualifications
    coach1 = create_coach_with_qualifications('Vishnu', ['ARA', 'FRA'])
    coach2 = create_coach_with_qualifications('Ven', ['KLE', 'FRA'])
    res = post :coaches_for_given_language, {:language => "FRA"}
    json_res = JSON.decode(res.body)
    assert_true  (json_res["text"].include?(coach1.full_name) && json_res["text"].include?(coach2.full_name))
  end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
  def test_index
    coach_mgr = login_as_custom_user(AdGroup.coach_manager, 'hello')
    coach_mgr.stubs(:languages).returns([Language['ENG']])
    get :index
    assert_equal "Coach Schedule", assigns(:page_title)
    assert_response :success
  end

  def test_index_with_date_and_language
    coach_mgr = login_as_custom_user(AdGroup.coach_manager, 'hello')
    coach_mgr.stubs(:languages).returns([Language['KLE']])
    params = {:date => '2012-11-04', :language => 'KLE'}
    get :index, params
    data = assigns(:data) 
    assert_equal data[:language], params[:language]
    assert_equal "Coach Schedule", assigns(:page_title)
    assert_tag :input, :attributes => {:id => 'start_date', :value => 'November 04, 2012'}
    assert_response :success
  end

  def test_index_with_date_language_coach

    FactoryGirl.create(:global_setting)
    coach_mgr = login_as_custom_user(AdGroup.coach_manager, 'hello')
    coach_mgr.stubs(:languages).returns([Language['KLE']])
    coach = create_coach_with_qualifications
    params = {:date => '2012-12-04', :language => 'KLE', :coach => coach, :filter_language => 'KLE'}
    post :index, params 
    data = assigns(:data)
    assert_equal data[:language], params[:language]
    assert_equal "Coach Schedule - newcoach", assigns(:page_title) 
    assert_tag :input, :attributes => {:id => 'start_date', :value => 'December 02, 2012'}
    assert_tag :input, :attributes => {:id => 'selected_coach', :value => coach.id}
    assert_response :success
  end

  def test_index_as_coach
    login_as_custom_user(AdGroup.coach, 'hello1')
    get :index
    assert_equal "Sorry, you are not authorized to view the requested page. Please contact the IT Help Desk.", flash[:error]
    assert_redirected_to login_url
  end

  def test_index_as_tier1_support_lead
    login_as_custom_user(AdGroup.support_lead, 'test21')
    get :index
    assert_equal "Sorry, you are not authorized to view the requested page. Please contact the IT Help Desk.", flash[:error]
    assert_redirected_to login_url
  end

  def test_index_as_tier1_support_user
    login_as_custom_user(AdGroup.support_user, 'test21')
    get :index
    assert_equal "Sorry, you are not authorized to view the requested page. Please contact the IT Help Desk.", flash[:error]
    assert_redirected_to login_url
  end

  def test_index_as_community_moderator
    login_as_custom_user(AdGroup.community_moderator, 'test21')
    get :index
    assert_equal "Sorry, you are not authorized to view the requested page. Please contact the IT Help Desk.", flash[:error]
    assert_redirected_to login_url
  end

  def test_create_session_form_in_coach_scheduler
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    coach = create_coach_with_qualifications('rajkumar', ['KLE', 'HEB','AUK'])
    coach_session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :eschool_session_id => "345698", :language_identifier => "HEB")
    Coach.any_instance.stubs(:threshold_reached?).returns([false,false])
    post :create_session_form_in_coach_scheduler, {:start_time => coach_session.session_start_time, :language => 'KLE', :coach_id => coach.id}
    assert_true assigns(:slot_info)[:error_message].include?("The Coach has a scheduled session in #{coach_session.language.display_name} at ")
    assert_response :success
  end

  def test_create_session_form_in_coach_scheduler_without_overlapping_session
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    coach = create_coach_with_qualifications('rajkumar', ['KLE', 'HEB'])
    Coach.any_instance.stubs(:threshold_reached?).returns([false,false])
    post :create_session_form_in_coach_scheduler, {:start_time => Time.now.beginning_of_hour + 2.days, :language => 'KLE', :coach_id => coach.id, :session_type => 'session'}
    assert_response :success

    Coach.delete_all
    coach = create_coach_with_qualifications('rajkumar', ['KLE', 'HEB'])
    crs = create_recurring_schedule_without_session(coach, Time.now.beginning_of_hour.utc + 1.hours, Language.find_by_identifier('HEB'))
    Coach.any_instance.stubs(:threshold_reached?).returns([false,false])
    post :create_session_form_in_coach_scheduler, {:start_time => Time.now.beginning_of_hour + 1.hours, :language => 'KLE', :coach_id => coach.id, :session_type => 'session'}
    assert_true assigns(:slot_info)[:warning].include?("This Coach is already scheduled to have a recurring session/appointment starting on the following week. You can only schedule a one-off session/appointment during this time.")
    assert_response :success
  end

  def test_create_session_form_in_coach_scheduler_without_overlapping_session_aria
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    coach = create_coach_with_qualifications('rajkumar', ['KLE', 'HEB', 'AUK'])
    Coach.any_instance.stubs(:threshold_reached?).returns([false,false])
    post :create_session_form_in_coach_scheduler, {:start_time => Time.now.beginning_of_hour + 2.days, :language => 'KLE', :coach_id => coach.id, :session_type => 'session'}
    assert_response :success

    Coach.delete_all
    coach = create_coach_with_qualifications('rajkumar', ['KLE', 'HEB', 'AUK'])
    crs = create_recurring_schedule_without_session(coach, Time.now.beginning_of_hour.utc + 1.hours, Language.find_by_identifier('AUK'))
    Coach.any_instance.stubs(:threshold_reached?).returns([false,false])
    post :create_session_form_in_coach_scheduler, {:start_time => Time.now.beginning_of_hour + 1.hours, :language => 'KLE', :coach_id => coach.id, :session_type => 'session'}
    assert_true assigns(:slot_info)[:warning].include?("This Coach is already scheduled to have a recurring session/appointment starting on the following week. You can only schedule a one-off session/appointment during this time.")
    assert_response :success

    Coach.delete_all
    coach = create_coach_with_qualifications('rajkumar', ['KLE', 'HEB', 'AUK'])
    crs = create_recurring_schedule_without_session(coach, Time.now.beginning_of_hour.utc + 1.hours, Language.find_by_identifier('HEB'))
    Coach.any_instance.stubs(:threshold_reached?).returns([false,false])
    post :create_session_form_in_coach_scheduler, {:start_time => Time.now.beginning_of_hour + 1.hours, :language => 'KLE', :coach_id => coach.id, :session_type => 'session'}
    assert_true assigns(:slot_info)[:warning].include?("This Coach is already scheduled to have a recurring session/appointment starting on the following week. You can only schedule a one-off session/appointment during this time.")
    assert_response :success

    Coach.delete_all
    coach = create_coach_with_qualifications('rajkumar', ['KLE', 'HEB', 'AUK'])
    crs = create_recurring_schedule_without_session(coach, Time.now.beginning_of_hour.utc + 1.hours, Language.find_by_identifier('AUK'))
    Coach.any_instance.stubs(:threshold_reached?).returns([false,false])
    post :create_session_form_in_coach_scheduler, {:start_time => Time.now.beginning_of_hour + 1.hours + 30.minutes, :language => 'KLE', :coach_id => coach.id, :session_type => 'session'}
    assert_true assigns(:slot_info)[:warning].include?("This Coach is already scheduled to have a recurring session/appointment starting on the following week. You can only schedule a one-off session/appointment during this time.")
    assert_response :success

  end

  def test_cancel_session_not_present #This test is to check Cancel sessions link is not displayed
    coach_mgr = login_as_custom_user(AdGroup.coach_manager, 'test21')
    coach_mgr.stubs(:languages).returns([Language['ENG']])
    get :index ,{:language => 'ENG'}
    assert_select 'ul.sub_navigation' do
       assert_select 'li.main', { :text => 'Cancel Sessions', :count => 0}
    end
  end

  def test_coach_session_details_create_button_for_subrequested_session

    FactoryGirl.create(:global_setting)
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    coach = create_coach_with_qualifications('rajkumar', ['HEB'])
    coach_session = FactoryGirl.create(:confirmed_session, :eschool_session_id => "345698", :language_identifier => "HEB")
    FactoryGirl.create(:substitution, :coach_session_id => coach_session.id, :coach_id => coach.id)
    post :coach_session_details, {:coach_id => coach.id, :start_time => coach_session.session_start_time }
    assert(true, !(assigns(:coach_session)))
    assert(true, assigns(:substituted))
    assert(true, assigns(:create_button))
    assert_tag :input, :attributes => {:type => 'button', :value => "CREATE NEW"}
    assert_response :success
  end

  def test_coach_session_details_login_as_coachmanager_totale

    FactoryGirl.create(:global_setting)
    ConfirmedSession.any_instance.stubs(:eschool_session).returns eschool_session_with_custom_params({:eschool_session_id => 345698})
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    coach = create_coach_with_qualifications('rajkumar', ['HEB'])
    session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :eschool_session_id => 345698, :language_identifier => "HEB")
    post :coach_session_details, {:start_time => session.session_start_time.to_i, :coach_id => coach.id}
    assert_select 'div[id=eschool_session_id_div]', "Eschool Session Id :#{session.eschool_session_id}"
  end

 def test_coach_session_details_login_as_coachmanager_reflex

    FactoryGirl.create(:global_setting)
    ConfirmedSession.any_instance.stubs(:eschool_session).returns nil
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
    session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :language_identifier => 'KLE')
    post :coach_session_details, {:start_time => session.session_start_time.to_i , :coach_id => coach.id}
    assert_select 'div[id=eschool_session_id_div]', :count => 0
  end

 def test_coach_session_details_login_as_coach_reflex

    FactoryGirl.create(:global_setting)
    ConfirmedSession.any_instance.stubs(:eschool_session).returns nil
    PreferenceSetting.any_instance.stubs(:session_alerts_display_time).returns 20
    coach = login_as_custom_user(AdGroup.coach, 'test21')
    session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :language_identifier => 'KLE')
    post :coach_session_details, {:start_time => session.session_start_time.to_i , :coach_id => coach.id}
    assert_select 'div[id=eschool_session_id_div]', :count => 0
  end
 
 def test_coach_session_details_login_as_coach_totale
  
    FactoryGirl.create(:global_setting)
    ConfirmedSession.any_instance.stubs(:eschool_session).returns eschool_session_with_custom_params({:eschool_session_id => "345698"})
    PreferenceSetting.any_instance.stubs(:session_alerts_display_time).returns 20
    coach = create_coach_with_qualifications('rajkumar', ['HEB'])
    session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :eschool_session_id => 345698, :language_identifier => "HEB")
    login_as_custom_user(AdGroup.coach, coach.user_name)
    post :coach_session_details, {:start_time => session.session_start_time.to_i, :coach_id => coach.id}
    assert_select 'div[id=eschool_session_id_div]', "Eschool Session Id :#{session.eschool_session_id}"
  end

  def test_export_schedules_in_csv
    session_time = Time.now.beginning_of_hour.utc + 2.hours
    coach = create_coach_with_qualifications('vkn', ['ESP', 'ARA', 'KLE'])
    ExternalHandler::HandleSession.stubs(:find_session).returns(eschool_sesson_without_learner)
    Community::Village.stubs(:display_name).returns nil
    session1  = FactoryGirl.create(:confirmed_session, :coach_id=> coach.id, :session_start_time => session_time, :eschool_session_id=> 343, :language_identifier=> 'ESP')
    session2  = FactoryGirl.create(:confirmed_session, :coach_id=> coach.id, :session_start_time => session_time + 1.hour, :eschool_session_id=> 343, :language_identifier=> 'KLE')
    time_off1 = FactoryGirl.create(:unavailable_despite_template, :coach_id=> coach.id, :start_date=> session_time + 8.hours, :end_date => session_time + 10.hours, :approval_status => 1)
    login_as_custom_user(AdGroup.coach, coach.user_name)
    get :export_schedules_in_csv, :start_date_to_export => Time.now.beginning_of_week.to_i
    assert_response :success
    assert_equal 0, @response.body.index("Subject,Start Date,Start Time,End Date,End Time")
    assert_true @response.body.index("Spanish (Latin America) Max L3-U12-LE2,#{TimeUtils.format_time(session_time , "%m/%d/%y")},#{TimeUtils.format_time(session_time , "%I:%M:%S %p")},#{TimeUtils.format_time(session_time , "%m/%d/%y")},#{TimeUtils.format_time(session_time + 30.minutes , "%I:%M:%S %p")}").present?
    assert_true @response.body.index("Advanced English,#{TimeUtils.format_time(session_time + 1.hour , "%m/%d/%y")},#{TimeUtils.format_time(session_time + 1.hour , "%I:%M:%S %p")},#{TimeUtils.format_time(session_time + 1.hour , "%m/%d/%y")},#{TimeUtils.format_time(session_time + 1.hour + 30.minutes , "%I:%M:%S %p")}").present?
    assert_true @response.body.index("Time Off,#{TimeUtils.format_time(session_time + 8.hours , "%m/%d/%y")},#{TimeUtils.format_time(session_time + 8.hours , "%I:%M:%S %p")},#{TimeUtils.format_time(session_time + 10.hours , "%m/%d/%y")},#{TimeUtils.format_time(session_time + 10.hours , "%I:%M:%S %p")}").present?
  end

  def test_export_schedules_in_csv_for_edge_cases
    session_time = Time.now.beginning_of_hour.utc + 2.hours
    coach = create_coach_with_qualifications('vkn', ['ESP', 'ARA', 'KLE'])
    ExternalHandler::HandleSession.stubs(:find_session).returns(eschool_sesson_without_learner)
    Community::Village.stubs(:display_name).returns nil
    session1  = FactoryGirl.create(:confirmed_session, :coach_id=> coach.id, :session_start_time => session_time - 1.hour, :eschool_session_id=> 343, :language_identifier=> 'ESP')
    session2  = FactoryGirl.create(:confirmed_session, :coach_id=> coach.id, :session_start_time => session_time + 2.hour, :eschool_session_id=> 343, :language_identifier=> 'KLE')

    login_as_custom_user(AdGroup.coach, coach.user_name)
    get :export_schedules_in_csv, :start_date_to_export => Time.now.beginning_of_week.to_i
    assert_response :success
    assert_equal 0, @response.body.index("Subject,Start Date,Start Time,End Date,End Time")
    assert_true @response.body.index("Spanish (Latin America) Max L3-U12-LE2,#{TimeUtils.format_time(session_time - 1.hour , "%m/%d/%y")},#{TimeUtils.format_time(session_time - 1.hour , "%I:%M:%S %p")},#{TimeUtils.format_time(session_time - 30.minutes , "%m/%d/%y")},#{TimeUtils.format_time(session_time - 30.minutes , "%I:%M:%S %p")}").present?
    assert_true @response.body.index("Advanced English,#{TimeUtils.format_time(session_time + 2.hour , "%m/%d/%y")},#{TimeUtils.format_time(session_time + 2.hour , "%I:%M:%S %p")},#{TimeUtils.format_time(session_time + 2.hour , "%m/%d/%y")},#{TimeUtils.format_time(session_time + 2.hour + 30.minutes , "%I:%M:%S %p")}").present?
  end

  def test_export_schedules_button_in_my_schedule
    login_as_custom_user(AdGroup.coach, 'hello')

    get :my_schedule
    assert_select 'form' do
      assert_select 'button.export_schedules_button', :count => 1
    end
    get :my_schedule, {:date => Time.now.beginning_of_week}
    assert_select 'form' do
      assert_select 'button.export_schedules_button', :count => 1
    end

    get :my_schedule, {:date => Time.now.beginning_of_week - 5.day}
    assert_select 'button.export_schedules_button', :count => 0

    get :my_schedule, {:date => Time.now + 1.week}
    assert_select 'form' do
      assert_select 'button.export_schedules_button', :count => 1
    end

  end

  def test_my_schedule_for_manager
    login_as_custom_user(AdGroup.coach_manager, 'hello')
    get :my_schedule
    assert_equal "Sorry, you are not authorized to view the requested page. Please contact the IT Help Desk.", flash[:error]
    assert_redirected_to login_url
  end

  def test_topic_for_cefr_and_given_language
    login_as_custom_user(AdGroup.coach_manager, 'hello')
    params = {:cefrLevel => 'B1', :language => Language.find_by_identifier('AUK').id }
    res = get :topic_for_cefr_and_given_language, params
    json_res = JSON.decode(res.body)
    assert_equal 1,json_res.size
  end 

  def test_create_eschool_session_from_coach_scheduler_beyond_current_time
    login_as_custom_user(AdGroup.coach_manager, 'hello')
    coach=create_coach_with_qualifications("ssitoke",[])
    ConfirmedSession.delete_all
    stub_eschool_call_for_creating_one_off_session
    params = { :start_time => TimeUtils.current_slot - 5.hours, 
               :language_id => "ARA",
               :lesson=>1, :level=>1,
               :unit=>1,
               :coach_id=>coach.id,
               :number_of_seats=>4,
               :recurring=>"true",
               :availability=>"unavailable",
               :session_type => 'session'  }
    res = post :create_eschool_session_from_coach_scheduler, params
    assert_response :error
  end

  def test_create_eschool_session_from_coach_scheduler
    login_as_custom_user(AdGroup.coach_manager, 'hello')
    coach=create_coach_with_qualifications("ssitoke",[])
    ConfirmedSession.delete_all
    stub_eschool_call_for_creating_one_off_session
    params = { :start_time => TimeUtils.current_slot + 5.hours, 
               :language_id => "ARA",
               :lesson=>1, :level=>1,
               :unit=>1,
               :coach_id=>coach.id,
               :number_of_seats=>4,
               :availability=>'unavailable',
               :session_type => 'session'  }
    res = post :create_eschool_session_from_coach_scheduler, params
    assert_response :success
  end

  def test_create_eschool_session_from_coach_scheduler_aria
    login_as_custom_user(AdGroup.coach_manager, 'hello')
    coach=create_coach_with_qualifications("ssitoke",[])
    CoachAvailabilityTemplate.delete_all
    create_template_for_coach(coach)
    ConfirmedSession.delete_all
    ExternalHandler::HandleSession.stubs(:create_sessions).returns("12345")
    ConfirmedSession.any_instance.stubs(:supersaas_learner).returns([])
    ConfirmedSession.any_instance.stubs(:supersaas_session).returns(true)
    ConfirmedSession.any_instance.stubs(:supersaas_coach).returns([{:email => coach.rs_email}])
    params = { :start_time => TimeUtils.current_slot + 1.week + 5.hours, 
               :language_id => "AUK",
               :lesson=>1, :level=>1,
               :unit=>1,
               :coach_id=>coach.id,
               :number_of_seats=>4,
               :recurring=>"true",
               :availability=>'unavailable',
               :topic_id => 1,
               :session_type => 'session'  }
    res = post :create_eschool_session_from_coach_scheduler, params
    assert_response :success
  end

  def test_create_eschool_session_from_coach_scheduler_when_creating_one_off_fails
    login_as_custom_user(AdGroup.coach_manager, 'hello')
    coach = Coach.find_by_user_name("ssitoke")
    ConfirmedSession.delete_all
    cs = FactoryGirl.create(:confirmed_session, :coach_id=> coach.id, :session_start_time => TimeUtils.current_slot + 5.hours, :eschool_session_id=> 456, :language_identifier=> 'ARA')
    stub_eschool_call_for_creating_one_off_session
    params = { :start_time => TimeUtils.current_slot + 5.hours, 
               :language_id => "ARA",
               :lesson=>1, :level=>1,
               :unit=>1,
               :coach_id=>coach.id,
               :number_of_seats=>4,
               :recurring=>"true",
               :availability=>"unavailable"  }
    res = post :create_eschool_session_from_coach_scheduler, params
    assert_response :error
  end

  def test_edit_sesion_for_coach
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    coach = create_coach_with_qualifications('rajkumar', ['KLE', 'ARA', 'AUK'])
    ConfirmedSession.delete_all
    coach_session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :eschool_session_id => "345698", :language_identifier => "ARA")
    options = {:coach_id => coach.id, :eschool_session_id => "345698", :language_identifier => "ARA", :learners_signed_up => 0, :wildcard => false}
    ExternalHandler::HandleSession.stubs(:find_session).returns(EschoolResponseParser.new(eschool_sessions_array_without_learner_body_with_custom_params(options).lstrip).parse.first)
    ConfirmedSession.any_instance.stubs(:supersaas_learner).returns([])
    Coach.any_instance.stubs(:threshold_reached?).returns([false,false])
    res = get :edit_session_for_coach, {:coach_session_id => coach_session.id }
    assert_response :success
    assert_select "form input#previous_language[type=hidden][value=ARA]"
    assert_select "form input#is_one_hour_session[type=hidden][value=false]"
    assert_select "form input#start_time[type=hidden][value=#{coach_session.session_start_time.to_i * 1000}]"
    assert_select "select#number_of_seats option", {:count => 10 }
    assert_select "select#unit"
    assert_select "select#lesson"

    coach_session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :eschool_session_id => "1256689", :language_identifier => "AUK", :session_start_time => Time.now.beginning_of_hour+10.hours, :number_of_seats => 6, :topic_id => 1)
    Coach.any_instance.stubs(:threshold_reached?).returns([false,false])
    res = get :edit_session_for_coach, {:coach_session_id => coach_session.id }
    assert_response :success
    assert_select "form input#previous_language[type=hidden][value=AUK]"
    assert_select "form input#is_one_hour_session[type=hidden][value=true]"
    assert_select "form input#start_time[type=hidden][value=#{coach_session.session_start_time.to_i * 1000}]"
    assert_select "select#number_of_seats option", {:count => 1 }
    assert_select "select#cefr"
    assert_select "select#topic"
  end

  def test_update_session_from_cs_same_language_totale_save_one
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    stub_eschool_call_for_bulk_edit_sessions_with_custom_params({})
    coach = create_coach_with_qualifications('rajkumar', ['KLE', 'ARA', 'AUK'])
    ConfirmedSession.delete_all
    coach_session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :eschool_session_id => "345698", :language_identifier => "ARA")
    options = { :action_type => "SAVE", :coach_session_id => coach_session.id, :language_id => "ARA", :unit => coach_session.single_number_unit, :wildcard => true, :number_of_seats => 4, :village_id => nil, :teacher_confirmed => true, :topic_id => nil, :recurring => "true", :availability => "unavailable" }
    res = post :update_session_from_cs, options
    assert_response :success
  end

  def test_update_session_from_cs_same_language_aria_save_one
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    ExternalHandler::HandleSession.stubs(:update_sessions).returns([{},true, ""])    
    ExternalHandler::HandleSession.stubs(:find_session).returns(eschool_sesson_without_learner)
    ConfirmedSession.any_instance.stubs(:supersaas_learner).returns([])
    ConfirmedSession.any_instance.stubs(:supersaas_session).returns(true)
    coach = create_coach_with_qualifications('rajkumar', ['KLE', 'ARA', 'AUK'])
    ConfirmedSession.any_instance.stubs(:supersaas_coach).returns([{:email => coach.rs_email}])
    ConfirmedSession.delete_all
    coach_session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :eschool_session_id => "3445698", :language_identifier => "AUK")
    options = { :action_type => "SAVE", :coach_session_id => coach_session.id, :language_id => "AUK", :unit => coach_session.single_number_unit, :wildcard => false, :number_of_seats => 4, :village_id => nil, :teacher_confirmed => true, :topic_id => 1, :recurring => "true", :availability => "unavailable" }
    res = post :update_session_from_cs, options
    assert_response :success
  end

  def test_update_session_from_cs_other_language_totale_save_one
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    stub_eschool_call_for_bulk_edit_sessions_with_custom_params({})
    stub_eschool_call_for_creating_one_off_session
    ExternalHandler::HandleSession.stubs(:cancel_session).returns(true)
    ConfirmedSession.any_instance.stubs(:learners_signed_up).returns(0)
    coach = create_coach_with_qualifications('rajkumarone', ['KLE', 'ARA', 'DEU', 'AUK'])
    ConfirmedSession.delete_all
    coach_session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :eschool_session_id => "3115698", :language_identifier => "ARA")
    options = { :action_type => "SAVE", :coach_session_id => coach_session.id, :language_id => "DEU", :unit => coach_session.single_number_unit, :wildcard => false, :number_of_seats => 4, :village_id => nil, :teacher_confirmed => true, :topic_id => nil, :recurring => "true", :availability => "available" }
    res = post :update_session_from_cs, options
    assert_response :success
  end

  def test_update_session_from_cs__with_recurrence_same_language_totale
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    stub_eschool_call_for_bulk_edit_sessions_with_custom_params({})
    coach = create_coach_with_qualifications('rajkumar', ['KLE', 'ARA', 'AUK'])
    ConfirmedSession.any_instance.stubs(:learners_signed_up).returns(0)
    ConfirmedSession.delete_all
    ConfirmedSession.any_instance.stubs(:supersaas_learner).returns([])
    ConfirmedSession.any_instance.stubs(:supersaas_session).returns(true)
    ConfirmedSession.any_instance.stubs(:supersaas_coach).returns([{:email => coach.rs_email}])
    crs = create_recurring_schedule_without_session(coach, Time.now.beginning_of_hour + 2.days, Language.find_by_identifier('ARA'))
    coach_session = FactoryGirl.create(:confirmed_session, :session_start_time => Time.now.beginning_of_hour + 2.days, :coach_id => coach.id, :eschool_session_id => "345698", :language_identifier => "ARA", :recurring_schedule_id => crs.id)
    options = { :action_type => "SAVE ALL", :coach_session_id => coach_session.id, :language_id => "ARA", :unit => coach_session.single_number_unit, :wildcard => true, :number_of_seats => 4, :village_id => nil, :teacher_confirmed => true, :topic_id => nil, :recurring => "true", :availability => "unavailable" }
    res = post :update_session_from_cs, options
    assert_response :success
  end

  def test_update_session_from_cs_with_recurrence_same_language_aria
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    ExternalHandler::HandleSession.stubs(:update_sessions).returns([{},true,""])
    coach = create_coach_with_qualifications('rajkumar', ['KLE', 'ARA', 'AUK'])
    ConfirmedSession.delete_all
    ConfirmedSession.any_instance.stubs(:learners_signed_up).returns(0)
    ConfirmedSession.any_instance.stubs(:supersaas_learner).returns([])
    ConfirmedSession.any_instance.stubs(:supersaas_session).returns(true)
    ConfirmedSession.any_instance.stubs(:supersaas_coach).returns([{:email => coach.rs_email}])
    crs = create_recurring_schedule_without_session(coach, Time.now.beginning_of_hour + 2.days, Language.find_by_identifier('AUK'))
    coach_session = FactoryGirl.create(:confirmed_session, :session_start_time => Time.now.beginning_of_hour + 2.days, :coach_id => coach.id, :eschool_session_id => "3445698", :language_identifier => "AUK", :recurring_schedule_id => crs.id)
    options = { :action_type => "SAVE ALL", :coach_session_id => coach_session.id, :language_id => "AUK", :unit => coach_session.single_number_unit, :wildcard => false, :number_of_seats => 4, :village_id => nil, :teacher_confirmed => true, :topic_id => 1, :recurring => "true", :availability => "unavailable" }
    res = post :update_session_from_cs, options
    assert_response :success
  end  

  def test_update_session_from_cs_with_recurrence_other_language_totale
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    stub_eschool_call_for_bulk_edit_sessions_with_custom_params({})
    stub_eschool_call_for_creating_one_off_session
    ExternalHandler::HandleSession.stubs(:cancel_session).returns(true)
    ConfirmedSession.any_instance.stubs(:learners_signed_up).returns(0)
    coach = create_coach_with_qualifications('rajkumarone', ['KLE', 'ARA', 'DEU', 'AUK'])
    ConfirmedSession.delete_all
    ConfirmedSession.any_instance.stubs(:supersaas_learner).returns([])
    ConfirmedSession.any_instance.stubs(:supersaas_session).returns(true)
    ConfirmedSession.any_instance.stubs(:supersaas_coach).returns([{:email => coach.rs_email}])
    crs = create_recurring_schedule_without_session(coach, Time.now.beginning_of_hour + 2.days, Language.find_by_identifier('ARA'))
    coach_session = FactoryGirl.create(:confirmed_session, :session_start_time => Time.now.beginning_of_hour + 2.days, :coach_id => coach.id, :eschool_session_id => "345698", :language_identifier => "ARA", :recurring_schedule_id => crs.id)
    options = { :action_type => "SAVE_ALL", :coach_session_id => coach_session.id, :language_id => "DEU", :unit => coach_session.single_number_unit, :wildcard => false, :number_of_seats => 4, :village_id => nil, :teacher_confirmed => true, :topic_id => nil, :recurring => "false", :availability => "available" }
    res = post :update_session_from_cs, options
    assert_response :success
  end

  def test_cancel_session_from_cs
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    ExternalHandler::HandleSession.stubs(:cancel_session).returns(true)
    ConfirmedSession.any_instance.stubs(:learners_signed_up).returns(0)
    coach = create_coach_with_qualifications('rajkumar', ['KLE', 'ARA', 'AUK'])
    ConfirmedSession.delete_all
    ConfirmedSession.any_instance.stubs(:supersaas_learner).returns([])
    ConfirmedSession.any_instance.stubs(:supersaas_session).returns(true)
    ConfirmedSession.any_instance.stubs(:supersaas_coach).returns([{:email => coach.rs_email}])
    coach_session = FactoryGirl.create(:confirmed_session, :session_start_time => Time.now.beginning_of_hour + 2.days, :coach_id => coach.id, :eschool_session_id => "345698", :language_identifier => "ARA")
    options = { :action_type => "CANCEL", :coach_session_id => coach_session.id, :language_id => "ARA", :unit => coach_session.single_number_unit, :wildcard => true, :number_of_seats => 4, :village_id => nil, :teacher_confirmed => true, :topic_id => nil, :cancellation_reason => "Reason for cancellation" }
    res = post :update_session_from_cs, options
    assert_response :success

    crs = create_recurring_schedule_without_session(coach, Time.now.beginning_of_hour + 2.days, Language.find_by_identifier('ARA'))
    coach_session = FactoryGirl.create(:confirmed_session, :session_start_time => Time.now.beginning_of_hour + 2.days, :coach_id => coach.id, :eschool_session_id => "345698", :language_identifier => "ARA", :recurring_schedule_id => crs.id)
    options = { :action_type => "CANCEL ALL", :coach_session_id => coach_session.id, :language_id => "ARA", :unit => coach_session.single_number_unit, :wildcard => true, :number_of_seats => 4, :village_id => nil, :teacher_confirmed => true, :topic_id => nil, :cancellation_reason => "Reason for cancellation" }
    res = post :update_session_from_cs, options
    assert_response :success
  end

end