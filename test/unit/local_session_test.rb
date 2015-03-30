require File.expand_path('../../test_helper', __FILE__)

class LocalSessionTest <  ActiveSupport::TestCase

  def test_create_one_off
    coach = create_coach_with_qualifications('rajkumar', ['HEB'])
    params = {:coach_id => coach.id, :session_start_time => Time.now.utc.beginning_of_hour + 1.days, :session_end_time => Time.now + 1.days + 30.minutes ,:number_of_seats => 4,:single_number_unit => 1,:recurring => true, :teacher_confirmed=> true, :lessons => 1, :language_identifier => "HEB"}
    local_session = LocalSession.create_one_off(params)
    assert_equal 4, local_session.number_of_seats
    assert_equal 1, local_session.single_number_unit
    assert_equal true, local_session.session_metadata.recurring
    assert_equal true, local_session.session_metadata.teacher_confirmed
    assert_equal 1,local_session.session_metadata.lessons
  end

  def test_create_session_hash
    coach = create_coach_with_qualifications('rajkumar', ['ARA'])
    session = FactoryGirl.create(:local_session,:coach_id => coach.id, :session_start_time => Time.now.utc.beginning_of_hour + 2.days, :language_identifier => 'ARA', :eschool_session_id => 12345)
    session_metadata = FactoryGirl.create(:session_metadata, :coach_session_id => session.id,:action => "edit", :lessons => 2)
    session_hash = session.to_hash
    assert_equal session_hash[:start_time], session.session_start_time
    assert_equal session_hash[:teacher_id], coach.id
    assert_equal session_hash[:lang_identifier], session.language_identifier
    assert_equal session_hash[:coach_username], coach.user_name
    assert_equal session_hash[:lesson], session_metadata.lessons
  end

  def test_convert_to_standard_session
    coach = create_coach_with_qualifications('rajkumar', ['ARA'])
    session = FactoryGirl.create(:local_session,:coach_id => coach.id, :session_start_time => Time.now.utc.beginning_of_hour + 2.days, :language_identifier => 'ARA', :eschool_session_id => 12345)
    session_metadata = FactoryGirl.create(:session_metadata, :coach_session_id => session.id,:action => "edit", :lessons => 2)
    assert_true session.convert_to_standard_session
    assert_not_nil ConfirmedSession.find_by_id(session.id)
    assert_nil SessionMetadata.find_by_id(session_metadata.id)
  end
 
end
