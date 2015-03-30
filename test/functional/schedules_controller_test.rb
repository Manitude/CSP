require File.expand_path('../../test_helper', __FILE__)

class SchedulesControllerTest < ActionController::TestCase
    
    def setup
	    coach_mgr = login_as_custom_user(AdGroup.coach_manager,'test32')
      coach_mgr.stubs(:languages).returns([Language['KLE']])
  	end

    def test_index
    	get :index
    	week_start = TimeUtils.beginning_of_week_for_user
    	data = assigns(:data)
      assert_equal data[:week_extremes][0], week_start
     	assert_equal data[:week_extremes][1], week_start + 7.days - 1.minute
     	assert_equal "Master Scheduler", assigns(:page_title)
    	assert_response :success
    end

    def test_language_schedules_when_sessions_are_being_pushed
      language = create_non_lotus_language("ARA")
      params = {:language => language.identifier, :classroom_type => "group"}
      week_start = TimeUtils.beginning_of_week_for_user
      sm = FactoryGirl.create(:scheduler_metadata, :lang_identifier => params[:language], :total_sessions => 100, :locked => true)

      post :language_schedules , params
      data = assigns(:data)
      assert_equal data[:week_extremes][0], week_start
      assert_equal data[:week_extremes][1], week_start + 7.days - 1.minute
      assert_equal data[:language], params[:language]
      assert_equal data[:is_locked], true
      assert_equal data[:push_status_message], "Currently, sessions are being pushed to eschool for this language. Out of #{sm.total_sessions} sessions, #{sm.completed_sessions}  have been pushed."
      assert_equal "Master Scheduler", assigns(:page_title)
      assert_response :success

      language = create_lotus_language
      params = {:language => language.identifier, :classroom_type => "group"}
      sm = FactoryGirl.create(:scheduler_metadata, :lang_identifier => params[:language], :total_sessions => 100, :locked => true)
      post :language_schedules , params
      data = assigns(:data)
      assert_equal data[:is_locked], true
      assert_equal data[:push_status_message], "Currently, schedules are being committed for this language. Out of #{sm.total_sessions} schedules, #{sm.completed_sessions}  have been committed."

      language = create_aria_language("AUK")
      params = {:language => language.identifier, :classroom_type => "group"}
      sm = FactoryGirl.create(:scheduler_metadata, :lang_identifier => params[:language], :total_sessions => 100, :locked => true)
      post :language_schedules , params
      data = assigns(:data)
      assert_equal data[:is_locked], true
      assert_equal data[:push_status_message], "Currently, sessions are being pushed to SuperSaas for this language. Out of #{sm.total_sessions} sessions, #{sm.completed_sessions}  have been pushed."
    end

    def test_language_schedules_and_sessions
      language = create_non_lotus_language("ARA")
      params = {:language => language.identifier, :classroom_type => "solo"}
      coach = create_coach_with_qualifications
      LocalSession.delete_all
      local_session = FactoryGirl.create(:local_session, :coach_id => coach.id, :session_start_time => (Time.now.beginning_of_hour.utc + 2.hours), 
       :number_of_seats => 1, :language_identifier => language.identifier)
      post :language_schedules , params
      data = assigns(:data)
      assert_equal data[:classroom_type], params[:classroom_type]
      assert_equal data[:village], "all"
      assert_equal data[:removed_sessions], 0
      assert_equal data[:new_sessions], 1 #There is only one local session created.
      assert_equal "Master Schedule - #{language.display_name}", assigns(:page_title)
      assert_response :success
    end

    def test_language_schedules_confirmed_sessions
      language = create_non_lotus_language("ARA")
      params = {:language => language.identifier, :classroom_type => "group"}
      coach = create_coach_with_qualifications
      ConfirmedSession.delete_all
      session_start_time = Time.now.beginning_of_hour.utc + 2.hours
      confirmed_session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :eschool_session_id =>  get_unique_eschool_session_id, :session_start_time => session_start_time, 
       :number_of_seats => 1, :language_identifier => language.identifier)
      extra_session = FactoryGirl.create(:extra_session, :coach_id => nil, :eschool_session_id =>  get_unique_eschool_session_id, :session_start_time => session_start_time, 
       :number_of_seats => 1, :language_identifier => language.identifier)
      eschool_session_object = get_eschool_MS_session(session_start_time, 1, 1)
      session_slots = []
      session_slots << eschool_session_object
      ExternalHandler::HandleSession.stubs(:sessions_count_for_ms_week).returns(session_slots)

      post :language_schedules , params
      assert_response :success      
    end

    def test_language_schedules_local_sessions
      language = create_non_lotus_language("ARA")
      params = {:language => language.identifier, :classroom_type => "solo"}
      coach = create_coach_with_qualifications
      LocalSession.delete_all
      local_session = FactoryGirl.create(:local_session, :coach_id => coach.id, :session_start_time => (Time.now.beginning_of_hour.utc + 2.hours), 
       :number_of_seats => 1, :language_identifier => language.identifier)
      session_metadata = FactoryGirl.create(:session_metadata, :coach_session_id => local_session.id, :recurring => true)
      post :language_schedules , params
      assert_response :success

      SessionMetadata.delete_all
      session_metadata = FactoryGirl.create(:session_metadata, :coach_session_id => local_session.id, 
        :recurring => false, :action => "cancel")
      post :language_schedules , params
      assert_response :success

      SessionMetadata.delete_all
      session_metadata = FactoryGirl.create(:session_metadata, :coach_session_id => local_session.id, 
        :recurring => false, :action => "edit")
      post :language_schedules , params
      assert_response :success

      SessionMetadata.delete_all
      session_metadata = FactoryGirl.create(:session_metadata, :coach_session_id => local_session.id, 
        :recurring => false, :action => "create")
      post :language_schedules , params
      assert_response :success
    end

    def test_language_schedules_recurring_sessions
      language = create_lotus_language
      params = {:language => language.identifier}
      coach = create_coach_with_qualifications
      date = Date.today
      session_start_time = Time.now.beginning_of_hour.utc + 2.hours
      LocalSession.delete_all
      local_session = FactoryGirl.create(:local_session, :coach_id => coach.id, :session_start_time => (Time.now.beginning_of_hour.utc + 2.hours), 
        :session_start_time => (Time.now.beginning_of_hour.utc + 2.hours + 30.minutes), :number_of_seats => 1, :language_identifier => language.identifier)
      recurring_schedule = FactoryGirl.create(:coach_recurring_schedule, :coach_id => coach.id, :language_id => language.id,
      :day_index => date.strftime('%w'), :start_time => session_start_time.strftime('%H:%M:%S'), 
      :recurring_start_date => date - 15.days, :created_at => Time.now.utc)
      confirmed_session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :eschool_session_id =>  get_unique_eschool_session_id, :session_start_time => session_start_time, 
       :number_of_seats => 1, :language_identifier => language.identifier, :recurring_schedule_id => recurring_schedule.id)
      
      recurring_session = create_and_return_recurring_schedule_without_session(coach, Date.today, language)
      post :language_schedules , params
      assert_response :success
    end

    def get_eschool_MS_session(session_start_time, sub_count, session_count)
      Eschool::Session.new(
        "slot_time"=> session_start_time,
        "sub_requested_count"=> sub_count,
        "sessions_count"=>session_count
      )
    end

    def test_slot_info_totale
      language = create_non_lotus_language("ARA")
      coach = create_coach_with_qualifications("CoachA")
      coach2 = create_coach_with_qualifications("CoachB")
      coach3 = create_coach_with_qualifications("CoachC")
      session_start_time = Time.now.beginning_of_hour.utc + 2.hours
      global_setting = FactoryGirl.create(:global_setting, :attribute_name => "allow_session_creation_before",
      :description => "Allowed time in minutes before session start time that a session can be created",
      :attribute_value => "20")

      CoachSession.delete_all
      confirmed_session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :eschool_session_id =>  get_unique_eschool_session_id, :session_start_time => session_start_time, 
       :number_of_seats => 1, :language_identifier => language.identifier, :external_village_id => 22)
      local_session = FactoryGirl.create(:local_session, :coach_id => coach2.id, :eschool_session_id =>  get_unique_eschool_session_id, :session_start_time => session_start_time, 
      :session_end_time => (session_start_time.utc + 30.minutes), :number_of_seats => 1, :language_identifier => language.identifier, :external_village_id => 22)
      session_metadata = FactoryGirl.create(:session_metadata, :coach_session_id => local_session.id, :recurring => true, :new_coach_id => coach3.id, :action => "edit", :teacher_confirmed => false)

      es_array = []
      es_array << eschool_session_with_custom_params({:eschool_session_id => confirmed_session.eschool_session_id, :number_of_seats => confirmed_session.number_of_seats, :teacher_confirmed => true})
      es_array << eschool_session_with_custom_params({:eschool_session_id => local_session.eschool_session_id, :number_of_seats => local_session.number_of_seats})
      ExternalHandler::HandleSession.stubs(:find_sessions).returns(es_array)
     
      params = {:language_id => language.id, :village_id => 22, 
        :start_time => session_start_time.to_i * 1000, :classroom_type => "solo"}
      post :slot_info, params
      slot_info = assigns(:slot_info)
      
      assert_equal slot_info[:session_start_time], session_start_time
      assert_equal slot_info[:language_id], language.id
      assert_equal slot_info[:minutes_to_allow_session_creation], global_setting.attribute_value.to_i
      
      assert_equal slot_info[:shift_details][0][:type], "StandardSession"
      assert_equal slot_info[:shift_details][0][:status], "Active"
      assert_equal slot_info[:shift_details][0][:eschool_session_id], confirmed_session.eschool_session_id
      assert_equal slot_info[:shift_details][0][:teacher_confirmed], true
      assert_equal slot_info[:shift_details][0][:coach_session_id], confirmed_session.id
      assert_equal slot_info[:shift_details][0][:coach_full_name], coach.full_name
      assert_equal slot_info[:shift_details][0][:level_unit_str], "L1 U1"
      assert_equal slot_info[:shift_details][0][:number_of_seats].to_i, confirmed_session.number_of_seats
      assert_equal slot_info[:shift_details][0][:coach_id], coach.id
      
      assert_equal slot_info[:shift_details][1][:type], "LocalSession"
      assert_equal slot_info[:shift_details][1][:status], local_session.session_metadata.action.camelize + "ed"
      assert_equal slot_info[:shift_details][1][:eschool_session_id], local_session.eschool_session_id
      assert_equal slot_info[:shift_details][1][:teacher_confirmed], false
      assert_equal slot_info[:shift_details][1][:coach_session_id], local_session.id
      assert_equal slot_info[:shift_details][1][:coach_full_name], coach3.full_name
      assert_equal slot_info[:shift_details][1][:level_unit_str], "L1 U1 LE"
      assert_equal slot_info[:shift_details][1][:number_of_seats].to_i, local_session.number_of_seats
      assert_equal slot_info[:shift_details][1][:coach_id], coach3.id

      assert_response :success
    end

    def test_slot_info_aria
      language = create_aria_language("AUK")
      coach = create_coach_with_qualifications("CoachA")
      coach2 = create_coach_with_qualifications("CoachB")
      coach3 = create_coach_with_qualifications("CoachC")
      session_start_time = Time.now.beginning_of_hour.utc + 2.hours
      global_setting = FactoryGirl.create(:global_setting, :attribute_name => "allow_session_creation_before",
      :description => "Allowed time in minutes before session start time that a session can be created",
      :attribute_value => "20")

      CoachSession.delete_all
      confirmed_session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :eschool_session_id =>  get_unique_eschool_session_id, :session_start_time => session_start_time, 
       :number_of_seats => 1, :language_identifier => language.identifier)
      local_session = FactoryGirl.create(:local_session, :coach_id => coach2.id, :eschool_session_id =>  get_unique_eschool_session_id, :session_start_time => session_start_time, 
      :session_end_time => (session_start_time.utc + 1.hours), :number_of_seats => 1, :language_identifier => language.identifier)
      session_metadata = FactoryGirl.create(:session_metadata, :coach_session_id => local_session.id, :recurring => true, :new_coach_id => coach3.id, :action => "edit")
      ExternalHandler::HandleSession.stubs(:find_session).returns(nil)

      params = {:language_id => language.id, :village_id => "all", 
        :start_time => session_start_time.to_i * 1000, :classroom_type => "solo"}
      post :slot_info, params
      slot_info = assigns(:slot_info)
      
      assert_equal slot_info[:session_start_time], session_start_time
      assert_equal slot_info[:language_id], language.id
      assert_equal slot_info[:minutes_to_allow_session_creation], global_setting.attribute_value.to_i
      
      assert_equal slot_info[:shift_details][0][:type], "StandardSession"
      assert_equal slot_info[:shift_details][0][:status], "Active"
      assert_equal slot_info[:shift_details][0][:eschool_session_id], confirmed_session.eschool_session_id
      assert_equal slot_info[:shift_details][0][:coach_session_id], confirmed_session.id
      assert_equal slot_info[:shift_details][0][:coach_full_name], coach.full_name
      assert_equal slot_info[:shift_details][0][:number_of_seats].to_i, confirmed_session.number_of_seats
      assert_equal slot_info[:shift_details][0][:coach_id], coach.id
      
      assert_equal slot_info[:shift_details][1][:type], "LocalSession"
      assert_equal slot_info[:shift_details][1][:status], local_session.session_metadata.action.camelize + "ed"
      assert_equal slot_info[:shift_details][1][:eschool_session_id], local_session.eschool_session_id
      assert_equal slot_info[:shift_details][1][:coach_session_id], local_session.id
      assert_equal slot_info[:shift_details][1][:coach_full_name], coach3.full_name
      assert_equal slot_info[:shift_details][1][:number_of_seats].to_i, local_session.number_of_seats
      assert_equal slot_info[:shift_details][1][:coach_id], coach3.id

      assert_response :success
    end

    def test_slot_info_lotus
      language = create_lotus_language
      coach = create_coach_with_qualifications("CoachA")
      coach2 = create_coach_with_qualifications("CoachB")
      coach3 = create_coach_with_qualifications("CoachC")
      session_start_time = Time.now.beginning_of_hour.utc + 2.hours

      CoachSession.delete_all
      confirmed_session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :eschool_session_id =>  get_unique_eschool_session_id, :session_start_time => session_start_time, 
       :number_of_seats => 1, :language_identifier => language.identifier, :cancelled => 1)
      substitution = FactoryGirl.create(:substitution, :grabber_coach_id => nil, :grabbed=>0, :cancelled=>1, :coach_session_id => confirmed_session.id, :coach_id => coach2.id)
      local_session = FactoryGirl.create(:local_session, :coach_id => coach2.id, :eschool_session_id =>  get_unique_eschool_session_id, :session_start_time => session_start_time, 
      :session_end_time => (session_start_time.utc + 1.hours), :number_of_seats => 1, :language_identifier => language.identifier)
      session_metadata = FactoryGirl.create(:session_metadata, :coach_session_id => local_session.id, :recurring => true, :new_coach_id => coach3.id, :action => "edit")
      ExternalHandler::HandleSession.stubs(:find_session).returns(nil)

      params = {:language_id => language.id, :village_id => "all", 
        :start_time => session_start_time.to_i * 1000, :classroom_type => "solo"}
      post :slot_info, params
      slot_info = assigns(:slot_info)

      assert_equal slot_info[:session_start_time], session_start_time
      assert_equal slot_info[:language_id], language.id
      
      assert_equal slot_info[:shift_details][0][:status], "Sub requested - Cancelled"
      assert_equal slot_info[:shift_details][0][:remove_text], "Remove"
      assert_equal slot_info[:shift_details][0][:recurring_text], "Make Recurring"
      assert_equal slot_info[:shift_details][0][:coach_session_id], confirmed_session.id
      assert_equal slot_info[:shift_details][0][:coach_id], coach.id
      assert_equal slot_info[:shift_details][0][:coach_full_name], coach.full_name
      assert_equal slot_info[:shift_details][0][:sub_req_coach_id], substitution.coach.id
      assert_equal slot_info[:shift_details][0][:sub_req_coach], substitution.coach.full_name
      
      assert_equal slot_info[:shift_details][1][:status], "Active"
      assert_equal slot_info[:shift_details][1][:remove_text], "Remove"
      assert_equal slot_info[:shift_details][1][:recurring_text], "Remove Recurrence"
      assert_equal slot_info[:shift_details][1][:coach_session_id], local_session.id
      assert_equal slot_info[:shift_details][1][:coach_id], coach2.id
      assert_equal slot_info[:shift_details][1][:coach_full_name], coach2.full_name

      assert_response :success
    end

    def test_slot_info_local_session_and_recurring
      language = create_lotus_language
      coach = create_coach_with_qualifications("CoachA",['KLE'])
      session_start_time = Time.now.beginning_of_hour.utc + 2.hours
      CoachSession.delete_all
      local_session = FactoryGirl.create(:local_session, :coach_id => coach.id, :eschool_session_id =>  get_unique_eschool_session_id, :session_start_time => session_start_time, 
      :session_end_time => (session_start_time.utc + 1.hours), :number_of_seats => 1, :language_identifier => language.identifier)
      session_metadata = FactoryGirl.create(:session_metadata, :coach_session_id => local_session.id, :recurring => true, :new_coach_id => nil, :action => "create")

      params = {:language_id => language.id, :village_id => "all", 
        :start_time => session_start_time.to_i * 1000, :classroom_type => "solo"}
      post :slot_info, params
      slot_info = assigns(:slot_info)

      assert_equal slot_info[:local_sessions][0][:type], "LocalSession"
      assert_equal slot_info[:local_sessions][0][:classroom_type], "Solo"
      assert_equal slot_info[:local_sessions][0][:status], "Not Active-Recurring"
      assert_equal slot_info[:local_sessions][0][:number_of_seats], 1
      assert_equal slot_info[:local_sessions][0][:session_id], local_session.id
      assert_equal slot_info[:local_sessions][0][:coach_id], coach.id
      assert_equal slot_info[:local_sessions][0][:coach_full_name], coach.full_name
     
      assert_response :success
    end

    def test_edit_confirmed_session
      language = create_non_lotus_language("ARA")
      coach = create_coach_with_qualifications("TotaleCoach")
      session_start_time = Time.now.beginning_of_hour.utc + 2.hours
      CoachSession.delete_all
      confirmed_session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :eschool_session_id =>  get_unique_eschool_session_id, :session_start_time => session_start_time, 
       :number_of_seats => 1, :language_identifier => language.identifier, :external_village_id => 22)
      eschool_session = eschool_session_with_custom_params({:eschool_session_id => confirmed_session.eschool_session_id, :number_of_seats => confirmed_session.number_of_seats, :teacher_confirmed => true})
      ExternalHandler::HandleSession.stubs(:find_session).returns(eschool_session)
      ConfirmedSession.any_instance.stubs(:eligible_alternate_coaches).returns([[],[]])
      params = {:start_time => session_start_time.to_i * 1000, :ext_village_id => "all", :type => "ConfirmedSession",
       :session_id => confirmed_session.eschool_session_id}
      post :edit_session, params
      edit_session = assigns(:edit_session)

      assert_equal edit_session[:coaches][0][0], coach
      assert_equal edit_session[:language], language
      assert_equal edit_session[:recurring_ends_at], false
      assert_equal edit_session[:level], nil
      assert_equal edit_session[:unit], 1
      assert_equal edit_session[:learners_signed_up], 1
      assert_equal edit_session[:recurring], false
      assert_equal edit_session[:recurring_disabled], false
      assert_equal edit_session[:no_of_seats], confirmed_session.number_of_seats.to_s
      assert_equal edit_session[:teacher_confirmed].to_s, eschool_session.teacher_confirmed
      assert_equal edit_session[:ext_village_id], confirmed_session.external_village_id
      assert_equal edit_session[:wildcard], false
      assert_equal edit_session[:type], params[:type]
      assert_equal edit_session[:session_start_time], session_start_time
      assert_equal edit_session[:disable_village], true
      assert_equal edit_session[:session_id], confirmed_session.id
      assert_equal edit_session[:lesson], "4"
    
      assert_response :success
    end

    def test_edit_local_session
      language = create_non_lotus_language("ARA")
      coach = create_coach_with_qualifications("TotaleCoach")
      coach2 = create_coach_with_qualifications("NewCoach")
      session_start_time = Time.now.beginning_of_hour.utc + 2.hours
      CoachSession.delete_all
      local_session = FactoryGirl.create(:local_session, :coach_id => coach.id, :eschool_session_id =>  get_unique_eschool_session_id, :session_start_time => session_start_time, 
      :session_end_time => (session_start_time.utc + 30.minutes), :number_of_seats => 1, :language_identifier => language.identifier, :external_village_id => 22)
      session_metadata = FactoryGirl.create(:session_metadata, :coach_session_id => local_session.id, :recurring => true, :new_coach_id => coach2.id, :action => "edit", :teacher_confirmed => false)

      params = {:start_time => session_start_time.to_i * 1000, :ext_village_id => "all", :type => "LocalSession",
       :session_id => local_session.id}
      post :edit_session, params
      edit_session = assigns(:edit_session)

      assert_equal edit_session[:coaches][0][0], coach2
      assert_equal edit_session[:language], language
      assert_equal edit_session[:recurring_ends_at], false
      assert_equal edit_session[:level], nil
      assert_equal edit_session[:unit], 1
      assert_equal edit_session[:recurring], local_session.session_metadata.recurring
      assert_equal edit_session[:no_of_seats], local_session.number_of_seats
      assert_equal edit_session[:teacher_confirmed], local_session.session_metadata.teacher_confirmed
      assert_equal edit_session[:ext_village_id], local_session.external_village_id
      assert_equal edit_session[:wildcard], false
      assert_equal edit_session[:type], params[:type]
      assert_equal edit_session[:session_start_time], session_start_time
      assert_equal edit_session[:disable_village], false
      assert_equal edit_session[:session_id], local_session.id
      assert_equal edit_session[:lesson], nil

      assert_response :success
    end

    def test_edit_standard_local_session
      language = create_non_lotus_language("ARA")
      coach = create_coach_with_qualifications("TotaleCoach")
      session_start_time = Time.now.beginning_of_hour.utc + 2.hours
      recurring_schedule = FactoryGirl.create(:coach_recurring_schedule, :coach_id => coach.id, :language_id => language.id,
      :day_index => session_start_time.wday, :start_time => session_start_time.strftime('%H:%M:%S'), 
      :recurring_start_date => session_start_time - 15.days)

      params = {:start_time => session_start_time.to_i * 1000, :ext_village_id => "all", :type => "StandardLocalSession",
       :coach_session_id => recurring_schedule.id}
      post :edit_session, params
      edit_session = assigns(:edit_session)

      assert_equal edit_session[:coaches][0][0], coach
      assert_equal edit_session[:language], language
      assert_equal edit_session[:level], nil
      assert_equal edit_session[:unit], 10
      assert_equal edit_session[:recurring], true
      assert_equal edit_session[:no_of_seats], recurring_schedule.number_of_seats
      assert_equal edit_session[:teacher_confirmed], true
      assert_equal edit_session[:ext_village_id], recurring_schedule.external_village_id
      assert_equal edit_session[:type], params[:type]
      assert_equal edit_session[:session_start_time], session_start_time
      assert_equal edit_session[:disable_village], false
      assert_equal edit_session[:session_id], recurring_schedule.id
      assert_equal edit_session[:lesson], 4

      assert_response :success
    end

    def test_edit_extra_session_totale
      language = create_non_lotus_language("ARA")
      coach = create_coach_with_qualifications("TotaleCoach")
      session_start_time = Time.now.beginning_of_hour.utc + 2.hours
      extra_session = FactoryGirl.create(:extra_session, :coach_id => nil, :eschool_session_id =>  get_unique_eschool_session_id, :session_start_time => session_start_time, 
       :number_of_seats => 1, :language_identifier => language.identifier, :external_village_id => 22)
      eschool_session = eschool_session_with_custom_params({:eschool_session_id => extra_session.eschool_session_id, :number_of_seats => extra_session.number_of_seats, :teacher_confirmed => false})
      ExternalHandler::HandleSession.stubs(:find_session).returns(eschool_session)
      CoachAvailabilityUtils.stubs(:eligible_alternate_coaches).returns([[],[]])

      params = {:start_time => session_start_time.to_i * 1000, :ext_village_id => "all", :type => "ExtraSession",
       :session_id => extra_session.eschool_session_id}

      post :edit_extra_session_totale, params
      session_details = assigns(:session_details)

      assert_equal session_details[:type], extra_session.type
      assert_equal session_details[:number_of_seats].to_i, extra_session.number_of_seats
      assert_equal session_details[:session_id], extra_session.id
      assert_equal session_details[:extra_session], extra_session
      assert_equal session_details[:level], nil
      assert_equal session_details[:lesson], "4"
      assert_equal session_details[:session_name], extra_session.name
      assert_equal session_details[:unit], 1
      assert_equal session_details[:ext_village_id], extra_session.external_village_id
      assert_equal session_details[:disable_village], false

      assert_response :success
    end
end
