require File.expand_path('../../test_helper', __FILE__)
require 'timeoff_controller'

class TimeoffControllerTest < ActionController::TestCase

	def setup
	    login_as_custom_user(AdGroup.coach,'coach22')
  	end

	def test_list_timeoff
		coach = create_coach_with_qualifications
		udt1 = FactoryGirl.create(:unavailable_despite_template, :coach_id => coach.id, :start_date => Time.now.beginning_of_hour.utc + 2.hours,
		 :end_date => Time.now.beginning_of_hour.utc + 4.hours, :approval_status => 0)
		udt2 = FactoryGirl.create(:unavailable_despite_template, :coach_id => coach.id, :start_date => Time.now.beginning_of_hour.utc + 5.hours,
		 :end_date => Time.now.beginning_of_hour.utc + 6.hours, :approval_status => 1)
		post :list_timeoff
		assert_response :success
	end

	def test_edit_timeoff
		post :edit_timeoff
		assert_response :success
	end

	def test_create_timeoff
		post :create_timeoff
		assert_response :success
	end

	def test_save_timeoff
		coach = create_coach_with_qualifications
		udt1 = FactoryGirl.create(:unavailable_despite_template, :coach_id => coach.id, :start_date => Time.now.beginning_of_hour.utc + 2.hours,
		 :end_date => Time.now.beginning_of_hour.utc + 4.hours, :approval_status => 0)
		udt2 = FactoryGirl.create(:unavailable_despite_template, :coach_id => coach.id, :start_date => Time.now.beginning_of_hour.utc + 5.hours,
		 :end_date => Time.now.beginning_of_hour.utc + 6.hours, :approval_status => 1)
		post :save_timeoff, {:start_date => Time.now.beginning_of_hour.utc + 2.hours, :end_date => Time.now.beginning_of_hour.utc + 6.hours, 
		:comments => "Testing", :timeoff_id => udt1.id }
		assert_response :success
		post :save_timeoff
		assert_response :error
	end

	def test_cancel_approved_time_off_before_start
		coach = create_coach_with_qualifications('coach22')
		udt1 = FactoryGirl.build(:unavailable_despite_template, :coach_id => coach.id, :start_date => Time.now.beginning_of_hour.utc + 4.hours,
		 :end_date => Time.now.beginning_of_hour.utc + 6.hours, :approval_status => 1, :unavailability_type => 0)
		udt1.save(:validate => false)
		post :cancel_timeoff, {:timeoff_id => udt1.id}
		assert_response :success
		assert_equal "Your time-off has been cancelled successfully.", @response.body
		assert_equal 5, UnavailableDespiteTemplate.find_by_id(udt1.id).status
		udt1.delete
		post :cancel_timeoff, {:timeoff_id => udt1.id}
		assert_response :error
	end

	def test_cancel_approved_time_off_working_as_back_early_within_first_slot
		coach = create_coach_with_qualifications('coach22')
		udt1 = FactoryGirl.build(:unavailable_despite_template, :coach_id => coach.id, :start_date => TimeUtils.current_slot.utc,
		 :end_date => Time.now.beginning_of_hour.utc + 2.hours, :approval_status => 1, :unavailability_type => 0)
		udt1.save(:validate => false)
		FactoryGirl.create(:trigger_event, :name => "TIME_OFF_REMOVED", :description => "Coach is back early from his/her requested time off.")
		post :cancel_timeoff, {:timeoff_id => udt1.id}
		assert_response :success
		assert_equal "You are back and available to teach now.", @response.body
		assert_nil UnavailableDespiteTemplate.find_by_id(udt1.id)
	end

	def test_cancel_approved_time_off_working_as_back_early_after_first_slot
		coach = create_coach_with_qualifications('coach22')
		udt1 = FactoryGirl.build(:unavailable_despite_template, :coach_id => coach.id, :start_date => Time.now.beginning_of_hour.utc - 1.hours,
		 :end_date => Time.now.beginning_of_hour.utc + 2.hours, :approval_status => 1, :unavailability_type => 0)
		udt1.save(:validate => false)
		post :cancel_timeoff, {:timeoff_id => udt1.id}
		assert_response :success
		assert_equal "You are back and available to teach now.", @response.body
	end

	def test_cancel_pending_time_off
		coach = create_coach_with_qualifications('coach22')
		udt1 = FactoryGirl.build(:unavailable_despite_template, :coach_id => coach.id, :start_date => Time.now.beginning_of_hour.utc - 1.hours,
		 :end_date => Time.now.beginning_of_hour.utc + 2.hours, :approval_status => 0, :unavailability_type => 0)
		udt1.save(:validate => false)
		post :cancel_timeoff, {:timeoff_id => udt1.id}
		assert_response :success
		assert_equal "Your time-off has been cancelled successfully.", @response.body
		assert_equal 5, UnavailableDespiteTemplate.find_by_id(udt1.id).status
	end

	def test_check_policy_violation_for_availability_modification
		post :check_policy_violation_for_availability_modification
		assert_response :success
		coach = create_coach_with_qualifications('coach22')
		udt1 = FactoryGirl.create(:unavailable_despite_template, :coach_id => coach.id, :start_date => Time.now.beginning_of_hour.utc + 2.hours,
		 :end_date => Time.now.beginning_of_hour.utc + 8.hours, :approval_status => 0)
		post :check_policy_violation_for_availability_modification, {:start_date => Time.now.beginning_of_hour.utc + 4.hours, 
			:end_date => Time.now.beginning_of_hour.utc + 6.hours}
		assert_response :error
	end

	def test_approve_modification
		coach = create_coach_with_qualifications
		start_of_hour = Time.now.beginning_of_hour.utc
		Eschool::Session.stubs(:find_by_id).returns(eschool_sesson_without_learner)
		Eschool::Session.stubs(:cancel).returns true
		FactoryGirl.create(:trigger_event, :name => "ACCEPT_TIME_OFF", :description => "Coach Manager approves a new template.")
		udt1 = FactoryGirl.create(:unavailable_despite_template, :coach_id => coach.id, :start_date => start_of_hour + 2.hours,
		 :end_date => start_of_hour + 4.hours)
    	local_session = FactoryGirl.create(:local_session, :coach_id => coach.id, :session_start_time => start_of_hour + 3.hours, :language_identifier => "ENG")
    	FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :session_start_time => start_of_hour + 3.hours + 30.minutes, :eschool_session_id => 1234, :language_identifier => "ENG")
   		FactoryGirl.create(:session_metadata, :action => 'create', :coach_session_id => local_session.id)
		post :approve_modification, :id => udt1.id, :status => 'true'
		assert_response :success
	end

	def test_approve_modification_with_status_false
		coach = create_coach_with_qualifications
		udt1 = FactoryGirl.create(:unavailable_despite_template, :coach_id => coach.id, :start_date => Time.now.beginning_of_hour.utc + 2.hours,
		 :end_date => Time.now.beginning_of_hour.utc + 4.hours, :approval_status => 0)
		post :approve_modification, :id => udt1.id, :status => 'false'
		assert_response :success
	end

	def test_approve_modification_approved_timeoff
		coach = create_coach_with_qualifications
		udt2 = FactoryGirl.create(:unavailable_despite_template, :coach_id => coach.id, :start_date => Time.now.beginning_of_hour.utc + 5.hours,
		 :end_date => Time.now.beginning_of_hour.utc + 6.hours, :approval_status => 1)
		post :approve_modification, :id => udt2.id, :status => 'false', :mail => true
		assert_response :redirect
	end

	def test_approve_modification_without_udt
		post :approve_modification, :id => -1343, :status => 'false'
		assert_response :success
	end

	def test_authenticate
		login_as_custom_user(AdGroup.coach_manager,'test32')
		post :list_timeoff
  		assert_equal "Sorry, you are not authorized to view the requested page. Please contact the IT Help Desk.", flash[:error]
		xhr :post, :list_timeoff
		assert_response :error
	end
	
end