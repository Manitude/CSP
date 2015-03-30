require File.expand_path('../../test_helper', __FILE__)
require 'ms_utils'

class BulkEditTest < ActiveSupport::TestCase

  def test_editing_nonrecurring_to_recurring
    sm = create_and_return_scheduler_metadata('KLE')
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
    session = FactoryGirl.create(:local_session, :coach_id => coach.id, :session_start_time => Time.now.utc.beginning_of_day + 3.day + 2.hour, :language_identifier => 'KLE')
    FactoryGirl.create(:session_metadata, :coach_session_id => session.id, :action => "edit_one", :recurring => true)
    template = FactoryGirl.create(:coach_availability_template, :effective_start_date => Time.now.utc + 1.day, :coach_id => coach.id)
    FactoryGirl.create(:coach_availability, :start_time => session.session_start_time.strftime("%T"), :end_time => session.session_end_time.strftime("%T"),:coach_availability_template_id => template.id, :day_index => session.session_start_time.wday)
    week_boundries = TimeUtils.week_extremes_for_user(session.session_start_time)
    session.language.update_last_pushed_week((week_boundries[0] + 3.weeks).utc)
    MsBulkModifications::BulkEdit.perform(sm, week_boundries[0].utc, week_boundries[1].utc)
    assert_equal 1, sm.completed_sessions
    session = ConfirmedSession.find_by_id(session.id)
    assert_not_nil session
    assert_not_nil session.recurring_schedule
    assert_equal 3, session.future_recurring_sessions.size
  end

  def test_editing_recurring_to_nonrecurrig
    sm = create_and_return_scheduler_metadata('KLE')
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
    session = FactoryGirl.create(:local_session, :coach_id => coach.id, :session_start_time => Time.now.utc.beginning_of_day + 3.day + 2.hour, :language_identifier => 'KLE')
    FactoryGirl.create(:session_metadata, :coach_session_id => session.id, :action => "edit_one", :recurring => true)
    template = FactoryGirl.create(:coach_availability_template, :effective_start_date => Time.now.utc + 1.day, :coach_id => coach.id)
    FactoryGirl.create(:coach_availability, :start_time => session.session_start_time.strftime("%T"), :end_time => session.session_end_time.strftime("%T"),:coach_availability_template_id => template.id, :day_index => session.session_start_time.wday)
    week_boundries = TimeUtils.week_extremes_for_user(session.session_start_time)
    session.language.update_last_pushed_week((week_boundries[0] + 3.weeks).utc)
    MsBulkModifications::BulkEdit.perform(sm, week_boundries[0].utc, week_boundries[1].utc)
    assert_equal 1, sm.completed_sessions
    session = ConfirmedSession.find_by_id(session.id)
    assert_not_nil session
    assert_not_nil session.recurring_schedule
    assert_equal 3, session.future_recurring_sessions.size
    sm1 = create_and_return_scheduler_metadata('KLE')
    session.update_attribute(:type, 'LocalSession')
    FactoryGirl.create(:session_metadata, :coach_session_id => session.id, :action => "edit_all")
    MsBulkModifications::BulkEdit.perform(sm1, week_boundries[0].utc, week_boundries[1].utc)
    assert_equal 1, sm1.completed_sessions
    session = ConfirmedSession.find_by_id(session.id)
    assert_not_nil session
    assert_nil session.recurring_schedule
    assert_equal 0, session.future_recurring_sessions.size
  end

  
  def test_editing_recurring_to_nonrecurring_and_coach_change
    sm = create_and_return_scheduler_metadata('KLE')
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
    session = FactoryGirl.create(:local_session, :coach_id => coach.id, :session_start_time => Time.now.utc.beginning_of_day + 3.day + 2.hour, :language_identifier => 'KLE')
    FactoryGirl.create(:session_metadata, :coach_session_id => session.id, :action => "edit_one", :recurring => true)
    template = FactoryGirl.create(:coach_availability_template, :effective_start_date => Time.now.utc + 1.day, :coach_id => coach.id)
    FactoryGirl.create(:coach_availability, :start_time => session.session_start_time.strftime("%T"), :end_time => session.session_end_time.strftime("%T"),:coach_availability_template_id => template.id, :day_index => session.session_start_time.wday)
    week_boundries = TimeUtils.week_extremes_for_user(session.session_start_time)
    session.language.update_last_pushed_week((week_boundries[0] + 3.weeks).utc)
    MsBulkModifications::BulkEdit.perform(sm, week_boundries[0].utc, week_boundries[1].utc)
    assert_equal 1, sm.completed_sessions
    session = ConfirmedSession.find_by_id(session.id)
    assert_not_nil session
    assert_not_nil session.recurring_schedule
    assert_equal 3, session.future_recurring_sessions.size
    sm1 = create_and_return_scheduler_metadata('KLE')
    coach1 = create_coach_with_qualifications('rajkumar', ['KLE'])
    session.update_attribute(:type, 'LocalSession')
    session.update_attribute(:coach_id, coach1.id)
    FactoryGirl.create(:session_metadata, :coach_session_id => session.id, :action => "edit_all")
    MsBulkModifications::BulkEdit.perform(sm1, week_boundries[0].utc, week_boundries[1].utc)
    assert_equal 1, sm1.completed_sessions
    session = ConfirmedSession.find_by_id(session.id)
    assert_not_nil session
    assert_nil session.recurring_schedule
    assert_equal 0, session.future_recurring_sessions.size
  end

  def test_editing_recurring_to_recurring_and_coach_change
    sm = create_and_return_scheduler_metadata('KLE')
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
    session = FactoryGirl.create(:local_session, :coach_id => coach.id, :session_start_time => Time.now.utc.beginning_of_day + 3.day + 2.hour, :language_identifier => 'KLE')
    FactoryGirl.create(:session_metadata, :coach_session_id => session.id, :action => "edit_one", :recurring => true)
    template = FactoryGirl.create(:coach_availability_template, :effective_start_date => Time.now.utc + 1.day, :coach_id => coach.id)
    FactoryGirl.create(:coach_availability, :start_time => session.session_start_time.strftime("%T"), :end_time => session.session_end_time.strftime("%T"),:coach_availability_template_id => template.id, :day_index => session.session_start_time.wday)
    week_boundries = TimeUtils.week_extremes_for_user(session.session_start_time)
    session.language.update_last_pushed_week((week_boundries[0] + 3.weeks).utc)
    MsBulkModifications::BulkEdit.perform(sm, week_boundries[0].utc, week_boundries[1].utc)
    assert_equal 1, sm.completed_sessions
    session = ConfirmedSession.find_by_id(session.id)
    assert_not_nil session
    assert_not_nil session.recurring_schedule
    assert_equal 3, session.future_recurring_sessions.size

    prev_recurring = session.recurring_schedule
    sm1 = create_and_return_scheduler_metadata('KLE')
    coach1 = create_coach_with_qualifications('rajkumar', ['KLE'])
    template = FactoryGirl.create(:coach_availability_template, :effective_start_date => Time.now.utc + 2.day, :coach_id => coach1.id)
    FactoryGirl.create(:coach_availability, :start_time => session.session_start_time.strftime("%T"), :end_time => session.session_end_time.strftime("%T"), :coach_availability_template_id => template.id, :day_index => session.session_start_time.wday)
    FactoryGirl.create(:session_metadata, :coach_session_id => session.id, :action => "edit_all", :recurring => true)
    session.update_attribute(:coach_id, coach1.id)
    session.update_attribute(:type, 'LocalSession')
    FactoryGirl.create(:session_metadata, :coach_session_id => session.id, :action => "edit_all", :recurring => true)
    MsBulkModifications::BulkEdit.perform(sm1, week_boundries[0].utc, week_boundries[1].utc)
    assert_equal 1, sm1.completed_sessions
    session = ConfirmedSession.find_by_id(session.id)
    assert_not_nil session
    assert_not_nil session.recurring_schedule
    assert_not_equal prev_recurring.id, session.recurring_schedule.id
    assert_equal 3, session.future_recurring_sessions.size
  end

  def test_editing_lotus
    sm = create_and_return_scheduler_metadata('KLE')
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
    session = FactoryGirl.create(:local_session, :coach_id => coach.id, :session_start_time => Time.now.beginning_of_hour.utc + 8.day, :language_identifier => 'KLE')
    FactoryGirl.create(:session_metadata, :coach_session_id => session.id, :action => "edit_one")
    week_boundries = TimeUtils.week_extremes_for_user(session.session_start_time)
    MsBulkModifications::BulkEdit.perform(sm, week_boundries[0].utc, week_boundries[1].utc)
    assert_equal 1, sm.completed_sessions
    session = ConfirmedSession.find_by_id(session.id)
    assert_not_nil session
    assert_nil session.recurring_schedule
    assert_equal 0, session.future_recurring_sessions.size
  end

  def test_editing_totale
    sm = create_and_return_scheduler_metadata('ARA')
    coach = create_coach_with_qualifications('rajkumar', ['ARA'])
    session = FactoryGirl.create(:local_session, :coach_id => coach.id, :session_start_time => Time.now.beginning_of_hour.utc + 8.day, :language_identifier => 'ARA')
    FactoryGirl.create(:session_metadata, :coach_session_id => session.id, :action => "edit_one")
    Eschool::Session.expects(:bulk_edit_sessions).returns true
    week_boundries = TimeUtils.week_extremes_for_user(session.session_start_time)
    MsBulkModifications::BulkEdit.perform(sm, week_boundries[0].utc, week_boundries[1].utc)
    assert_equal 1, sm.completed_sessions
    session = ConfirmedSession.find_by_id(session.id)
    assert_not_nil session
    assert_nil session.recurring_schedule
    assert_equal 0, session.future_recurring_sessions.size
  end

  def test_editing_totale_with_eschool_fail
    sm = create_and_return_scheduler_metadata('ARA')
    coach = create_coach_with_qualifications('rajkumar', ['ARA'])
    session = FactoryGirl.create(:local_session, :coach_id => coach.id, :session_start_time => Time.now.beginning_of_hour.utc + 8.day, :language_identifier => 'ARA')
    FactoryGirl.create(:session_metadata, :coach_session_id => session.id, :action => "edit_one")
    Eschool::Session.expects(:bulk_edit_sessions).returns false
    Eschool::Session.expects(:get_session_details).returns true
    week_boundries = TimeUtils.week_extremes_for_user(session.session_start_time)
    MsBulkModifications::BulkEdit.perform(sm, week_boundries[0].utc, week_boundries[1].utc)
    assert_equal 1, sm.completed_sessions
    session = ConfirmedSession.find_by_id(session.id)
    assert_not_nil session
    assert_nil session.recurring_schedule
    assert_equal 0, session.future_recurring_sessions.size
  end
  
end
