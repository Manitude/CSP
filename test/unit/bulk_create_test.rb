require File.dirname(__FILE__) + '/../test_helper'
require 'ms_utils'


class BulkCreateTest < ActiveSupport::TestCase

  def test_aaaaaaa_this_test_should_be_run_first_to_create_the_function_for_time_zone
    run_time_zone_fn
  end  

  def test_create_session_nonrecurring
    sm = create_and_return_scheduler_metadata('KLE')
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
    session = FactoryGirl.create(:local_session, :coach_id => coach.id, :session_start_time => Time.now.utc.beginning_of_day + 3.day + 2.hour, :language_identifier => 'KLE')
    FactoryGirl.create(:session_metadata, :coach_session_id => session.id, :action => "create")
    week_boundries = TimeUtils.week_extremes_for_user(session.session_start_time)
    session.language.update_last_pushed_week((week_boundries[0] + 3.weeks).utc)
    MsBulkModifications::BulkCreate.perform(sm, week_boundries[0].utc, week_boundries[1].utc)
    assert_equal 1, sm.completed_sessions
    session = ConfirmedSession.where(:coach_id => session.coach_id, :session_start_time => session.session_start_time, :language_id => session.language_id).last
    assert_not_nil session
    assert_nil session.recurring_schedule
    assert_equal 0, session.future_recurring_sessions.size
  end

  def test_create_session_recurring
    sm = create_and_return_scheduler_metadata('KLE')
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
    session = FactoryGirl.create(:local_session, :coach_id => coach.id, :session_start_time => Time.now.utc.beginning_of_day + 3.day + 2.hour, :language_identifier => 'KLE')
    FactoryGirl.create(:session_metadata, :coach_session_id => session.id, :action => "create", :recurring => true)
    template = FactoryGirl.create(:coach_availability_template, :effective_start_date => Time.now.utc + 1.day, :coach_id => coach.id)
    FactoryGirl.create(:coach_availability, :start_time => session.session_start_time.strftime("%T"), :end_time => session.session_end_time.strftime("%T"),:coach_availability_template_id => template.id, :day_index => session.session_start_time.wday)
    week_boundries = TimeUtils.week_extremes_for_user(session.session_start_time)
    session.language.update_last_pushed_week((week_boundries[0] + 3.weeks).utc)
    MsBulkModifications::BulkCreate.perform(sm, week_boundries[0].utc, week_boundries[1].utc)
    assert_equal 1, sm.completed_sessions
    session = ConfirmedSession.where(:coach_id => session.coach_id, :session_start_time => session.session_start_time, :language_id => session.language_id).last
    assert_not_nil session
    assert_not_nil session.recurring_schedule
    assert_equal 3, session.future_recurring_sessions.size
  end

  def test_create_from_recurring
    sm = create_and_return_scheduler_metadata('KLE')
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
    language = Language['KLE']
    datetime = Time.now.utc.beginning_of_day + 7.days + 2.hours
    template = FactoryGirl.create(:coach_availability_template, :effective_start_date => Time.now.utc + 1.day, :coach_id => coach.id)
    FactoryGirl.create(:coach_availability, :start_time => datetime.strftime("%T"), :end_time => (datetime+30.minute).strftime("%T"), :coach_availability_template_id => template.id, :day_index => datetime.wday)
    recurring = FactoryGirl.create(:coach_recurring_schedule, :coach_id => coach.id, :language_id => language.id, :start_time => datetime.strftime("%T"), :day_index => datetime.wday)
    week_boundries = TimeUtils.week_extremes_for_user(datetime)
    language.update_last_pushed_week((week_boundries[0] - 1.weeks).utc)
    MsBulkModifications::BulkCreate.perform(sm, week_boundries[0].utc, week_boundries[1].utc)
    assert_equal 1, sm.completed_sessions
    session = ConfirmedSession.where(:coach_id => coach.id, :language_id => language.id).last
    assert_not_nil session
    assert_not_nil session.recurring_schedule
    assert_equal recurring.id, session.recurring_schedule.id
    assert_equal 0, session.future_recurring_sessions.size
  end

  def test_create_from_edited_recurring
    sm = create_and_return_scheduler_metadata('KLE')
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
    language = Language['KLE']
    datetime = Time.now.utc.beginning_of_day + 7.days + 2.hours
    template = FactoryGirl.create(:coach_availability_template, :effective_start_date => Time.now.utc + 1.day, :coach_id => coach.id)
    FactoryGirl.create(:coach_availability, :start_time => datetime.strftime("%T"), :end_time => (datetime+30.minute).strftime("%T"), :coach_availability_template_id => template.id, :day_index => datetime.wday)
    recurring = FactoryGirl.create(:coach_recurring_schedule, :coach_id => coach.id, :language_id => language.id, :start_time => datetime.strftime("%T"), :day_index => datetime.wday)
    session = FactoryGirl.create(:local_session, :external_village_id => 2, :number_of_seats => 5, :coach_id => coach.id, :session_start_time => datetime, :language_identifier => 'KLE', :recurring_schedule_id => recurring.id)
    FactoryGirl.create(:session_metadata, :coach_session_id => session.id, :action => "create", :recurring => true)
    week_boundries = TimeUtils.week_extremes_for_user(datetime)
    language.update_last_pushed_week((week_boundries[0] + 2.weeks).utc)
    MsBulkModifications::BulkCreate.perform(sm, week_boundries[0].utc, week_boundries[1].utc)
    assert_nil recurring.external_village_id
    assert_equal 4, recurring.number_of_seats
    assert_equal 1, sm.completed_sessions
    session = ConfirmedSession.where(:coach_id => coach.id, :language_id => language.id).last
    recurring.reload
    assert_not_nil session
    assert_not_nil session.recurring_schedule
    assert_equal recurring.id, session.recurring_schedule.id
    assert_equal 0, session.future_recurring_sessions.size
    assert_equal 2, recurring.external_village_id
    assert_equal 5, recurring.number_of_seats
    assert_nil recurring.recurring_end_date
  end

  def test_create_from_edited_recurring_stop
    sm = create_and_return_scheduler_metadata('KLE')
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
    language = Language['KLE']
    datetime = Time.now.utc.beginning_of_day + 7.days + 2.hours
    template = FactoryGirl.create(:coach_availability_template, :effective_start_date => Time.now.utc + 1.day, :coach_id => coach.id)
    FactoryGirl.create(:coach_availability, :start_time => datetime.strftime("%T"), :end_time => (datetime+30.minute).strftime("%T"), :coach_availability_template_id => template.id, :day_index => datetime.wday)
    recurring = FactoryGirl.create(:coach_recurring_schedule, :coach_id => coach.id, :language_id => language.id, :start_time => datetime.strftime("%T"), :day_index => datetime.wday)
    session = FactoryGirl.create(:local_session, :external_village_id => 2, :number_of_seats => 5, :coach_id => coach.id, :session_start_time => datetime, :language_identifier => 'KLE', :recurring_schedule_id => recurring.id)
    FactoryGirl.create(:session_metadata, :coach_session_id => session.id, :action => "create")
    week_boundries = TimeUtils.week_extremes_for_user(datetime)
    language.update_last_pushed_week((week_boundries[0] + 2.weeks).utc)
    MsBulkModifications::BulkCreate.perform(sm, week_boundries[0].utc, week_boundries[1].utc)
    assert_nil recurring.external_village_id
    assert_equal 4, recurring.number_of_seats
    assert_equal 1, sm.completed_sessions
    session = ConfirmedSession.where(:coach_id => coach.id, :language_id => language.id).last
    recurring.reload
    assert_not_nil session
    assert_nil session.recurring_schedule
    assert_equal 2, recurring.external_village_id
    assert_equal 5, recurring.number_of_seats
    assert_not_nil recurring.recurring_end_date
  end

end