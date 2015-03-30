require 'app/utils/lotus_real_time_data'
require File.expand_path('../../../test_helper', __FILE__)

class LotusRealTimeDataTest < ActiveSupport::TestCase

  def setup
    real_time_lotus_data
    MemcacheService.clear_all
  end

  def test_lotus_real_time_data_when_no_coaches_are_scheduled
    response = LotusRealTimeData.lotus_real_time_data
    CoachSession.delete_all
    assert_equal 0, response["teachers_scheduled"].size
    assert_equal 0, response["teachers_scheduled_in_next_hour"].size
  end

  def test_lotus_real_time_data_when_one_coach_is_scheduled_and_one_coach_has_requested_sub
    CoachSession.delete_all
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
    session_start_time =  TimeUtils.current_slot
    FactoryGirl.create(:confirmed_session, :session_start_time => session_start_time, :coach_id => coach.id, :language_identifier => "KLE")
    FactoryGirl.create(:confirmed_session, :session_start_time => session_start_time, :coach_id => nil, :language_identifier => "KLE")
    response = LotusRealTimeData.lotus_real_time_data
    assert_equal 1, response["teachers_scheduled"].size
    assert_equal 0, response["teachers_scheduled_in_next_hour"].size
  end

  def test_lotus_real_time_data_when_two_coach_is_scheduled
    CoachSession.delete_all
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
    session_start_time =  TimeUtils.current_slot
    FactoryGirl.create(:confirmed_session, :session_start_time => session_start_time, :coach_id => coach.id, :language_identifier => "KLE")
    FactoryGirl.create(:confirmed_session, :session_start_time => session_start_time + 30.minutes, :coach_id => coach.id, :language_identifier => "KLE")
    response = LotusRealTimeData.lotus_real_time_data
    assert_equal 1, response["teachers_scheduled"].size
    assert_equal 1, response["teachers_scheduled_in_next_hour"].size
  end

  def test_lotus_real_time_data_when_two_coach_is_scheduled_in_next_hour
    CoachSession.delete_all
    coach1 = create_coach_with_qualifications('rajkumar', ['KLE'])
    coach2 = create_coach_with_qualifications('rajkumartwo', ['KLE'])
    session_start_time =  TimeUtils.current_slot
    FactoryGirl.create(:confirmed_session, :session_start_time => session_start_time, :coach_id => coach1.id, :language_identifier => "KLE")
    FactoryGirl.create(:confirmed_session, :session_start_time => session_start_time, :coach_id => coach2.id, :language_identifier => "KLE")
    FactoryGirl.create(:confirmed_session, :session_start_time => session_start_time + 30.minutes, :coach_id => coach1.id, :language_identifier => "KLE")
    FactoryGirl.create(:confirmed_session, :session_start_time => session_start_time + 30.minutes, :coach_id => coach2.id, :language_identifier => "KLE")
    response = LotusRealTimeData.lotus_real_time_data
    assert_equal 2, response["teachers_scheduled"].size
    assert_equal 2, response["teachers_scheduled_in_next_hour"].size
  end

  def test_lotus_real_time_data_with_two_learner_in_skills_and_zero_in_rehearsals
    learner1 = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '1111111111')
    learner2 = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '2222222222')
    Locos::Lotus.stubs(:find_active_session_details_by_activity).returns(
      {"skills"=>[{"user_guid" => learner1.guid}, {"user_guid" => learner2.guid}], "conversations"=>[]})
    response = LotusRealTimeData.lotus_real_time_data
    assert_equal 2, response["skills"].size
    assert_equal 0, response["conversations"].size
    assert_equal 2, response["skills_or_rehearsal"].size
  end

  def test_lotus_real_time_data_with_zero_learner_in_skills_and_two_in_rehearsals
    learner1 = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '1111111111')
    learner2 = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '2222222222')
    Locos::Lotus.stubs(:find_active_session_details_by_activity).returns(
      {"conversations"=>[{"user_guid" => learner1.guid}, {"user_guid" => learner2.guid}], "skills"=>[]})
    response = LotusRealTimeData.lotus_real_time_data
    assert_equal 0, response["skills"].size
    assert_equal 2, response["conversations"].size
    assert_equal 2, response["skills_or_rehearsal"].size
  end

  def test_lotus_real_time_data_with_two_learner_in_skills_and_two_in_rehearsals
    learner1 = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '1111111111')
    learner2 = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '2222222222')
    Locos::Lotus.stubs(:find_active_session_details_by_activity).returns(
      {"conversations" => [{"user_guid" => learner1.guid}, {"user_guid" => learner2.guid}],
        "skills" => [{"user_guid" => learner1.guid}, {"user_guid" => learner2.guid}]})
    response = LotusRealTimeData.lotus_real_time_data
    assert_equal 2, response["skills"].size
    assert_equal 2, response["conversations"].size
    assert_equal 4, response["skills_or_rehearsal"].size
  end

  def test_learners_waiting_details_with_error
    Eschool::StudentQueue.expects(:learners_waiting_details).returns(nil)
    response = LotusRealTimeData.lotus_real_time_data
    assert_equal 0, response["learners_waiting"].size
  end

  def test_learners_waiting_details_with_no_learner_in_queue
    Eschool::StudentQueue.expects(:learners_waiting_details).returns({"waiting_students" => []})
    response = LotusRealTimeData.lotus_real_time_data
    assert_equal 0, response["learners_waiting"].size
  end

  def test_learners_waiting_details_with_one_learner_in_queue
    Eschool::StudentQueue.expects(:learners_waiting_details).returns({"waiting_students"=>[{"waiting_duration"=>"10.52", "display_name"=>"Alexie"}]})
    response = LotusRealTimeData.lotus_real_time_data
    assert_equal 1, response["learners_waiting"].size
  end
end
