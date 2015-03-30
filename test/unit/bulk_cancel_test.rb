    require File.expand_path('../../test_helper', __FILE__)

class BulkCancelTest < ActiveSupport::TestCase

  def test_perform_cancellation
    sm = create_and_return_scheduler_metadata('KLE')
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
    language = Language['KLE']
    week_extremes = TimeUtils.week_extremes_for_user
    session = FactoryGirl.create(:local_session, :coach_id => coach.id,:session_start_time => week_extremes[1].beginning_of_hour.utc - 5.hours, :language_identifier => language.identifier)
    FactoryGirl.create(:session_metadata, :action => 'cancel', :coach_session_id => session.id)
    assert_false session.cancelled
    MsBulkModifications::BulkCancel.perform(sm, week_extremes[0].utc, week_extremes[1].utc)
    session = ConfirmedSession.find_by_id(session.id)
    assert_equal 1, sm.completed_sessions
    assert_not_nil session
    assert_true session.cancelled
  end

  def test_perform_cancellation_with_substitution
    sm = create_and_return_scheduler_metadata('KLE')
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
    language = Language['KLE']
    week_extremes = TimeUtils.week_extremes_for_user
    session = FactoryGirl.create(:local_session, :coach_id => coach.id, :session_start_time => week_extremes[1].beginning_of_hour.utc - 5.hours, :language_identifier => language.identifier)
    FactoryGirl.create(:session_metadata, :action => 'cancel', :coach_session_id => session.id)
    session.request_substitute
    assert_false session.cancelled
    assert_false session.substitution.cancelled
    MsBulkModifications::BulkCancel.perform(sm, week_extremes[0].utc, week_extremes[1].utc)
    session = ConfirmedSession.find_by_id(session.id)
    assert_equal 1, sm.completed_sessions
    assert_not_nil session
    assert_true session.cancelled
    assert_true session.substitution.cancelled
  end

end
