$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'lib/coach_activation_job'
require File.dirname(__FILE__) + '/../test_helper'

class CoachActivationJobTest < ActiveSupport::TestCase

  def test_get_message
    assert_equal 'Activating', CoachActivationJob.new(1,'true', 'ks',10).get_message
    assert_equal 'Inactivating', CoachActivationJob.new(1,'false', 'ks',10).get_message
  end
  
  def test_activate_or_inactivate_flow_for_inactivating
    coach = create_coach_with_qualifications('rajkumar', [])
    bg_task = BackgroundTask.create(:referer_id => coach.id, :triggered_by => 'KS', :background_type => "Coach Activation", :state => "Queued", :locked => true, :job_start_time => Time.now.utc, :message => "Task enqueued.")
    coach_activation_job = CoachActivationJob.new(coach.id, 'false', 'KS',bg_task.id)
    CoachActivationJob.any_instance.expects(:end_recurring_schedules).once
    CoachActivationJob.any_instance.expects(:remove_templates).once
    CoachActivationJob.any_instance.expects(:handle_affected_sessions).once
    CoachActivationJob.any_instance.expects(:change_status_in_eschool).once
    coach_activation_job.activate_or_inactivate
    coach.reload
    assert_false coach.active
  end

  def test_activate_or_inactivate_flow_for_activating
    coach = create_coach_with_qualifications('rajkumar', [])
    bg_task = BackgroundTask.create(:referer_id => coach.id, :triggered_by => 'KS', :background_type => "Coach Activation", :state => "Queued", :locked => true, :job_start_time => Time.now.utc, :message => "Task enqueued.")
    coach_activation_job = CoachActivationJob.new(coach.id, 'true', 'KS',bg_task.id)
    CoachActivationJob.any_instance.expects(:end_recurring_schedules).never
    CoachActivationJob.any_instance.expects(:remove_templates).never
    CoachActivationJob.any_instance.expects(:handle_affected_sessions).never
    CoachActivationJob.any_instance.expects(:change_status_in_eschool).once
    coach_activation_job.activate_or_inactivate
    coach.reload
    assert_true coach.active
  end
  
  def test_remove_templates
    coach = create_coach_with_qualifications('rajkumar', [])
    bg_task = BackgroundTask.create(:referer_id => coach.id, :triggered_by => 'KS', :background_type => "Coach Activation", :state => "Queued", :locked => true, :job_start_time => Time.now.utc, :message => "Task enqueued.")
    template = CoachAvailabilityTemplate.create(:coach_id => coach.id, :effective_start_date => Time.now + 1.day, :label => 'Test Template')
    coach_activation_job = CoachActivationJob.new(coach.id, 'false', 'KS',bg_task.id)
    assert_false template.deleted
    coach_activation_job.remove_templates
    template.reload
    assert_true template.deleted    
  end

  def test_end_recurring_schedules
    coach = create_coach_with_qualifications('psubramanian', [])
    bg_task = BackgroundTask.create(:referer_id => coach.id, :triggered_by => 'KS', :background_type => "Coach Activation", :state => "Queued", :locked => true, :job_start_time => Time.now.utc, :message => "Task enqueued.")
    recurring_schedules = CoachRecurringSchedule.create(:coach_id => coach.id, :day_index => 3, :recurring_start_date => Time.now, :language_id  => Language.find_by_identifier('KLE').id, :start_time => Time.now)
    coach_activation_job = CoachActivationJob.new(coach.id, 'false', 'KS', bg_task.id)
    assert_nil recurring_schedules.recurring_end_date
    coach_activation_job.end_recurring_schedules
    recurring_schedules.reload
    assert_not_nil recurring_schedules.recurring_end_date
  end

  def test_handle_affected_sessions_for_sesion_with_no_learners
    coach = create_coach_with_qualifications('psubramanian', [])
    coach_session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :session_start_time => "2032-05-04 14:00:00 UTC".to_time, :language_identifier => "HEB", :eschool_session_id => "345698")
    ConfirmedSession.any_instance.stubs(:eschool_session).returns nil
    ConfirmedSession.any_instance.stubs(:learners_signed_up).returns 0
    ConfirmedSession.any_instance.stubs(:find_in_batches).returns [coach_session]
    Eschool::Session.stubs(:cancel).returns true
    bg_task = FactoryGirl.create(:background_task, :referer_id => coach.id, :triggered_by => 'KS', :background_type => "Coach Activation", :state => "Queued", :locked => true, :job_start_time => Time.now.utc, :message => "Task enqueued.")
    coach_activation_job = CoachActivationJob.new(coach.id, 'false', 'KS', bg_task.id)
    assert_false coach_session.cancelled
    assert_nil coach.availability_modifications.find_by_coach_session_id coach_session.id
    coach_activation_job.handle_affected_sessions
    coach_session.reload
    assert_true coach_session.cancelled
    assert_not_nil coach.availability_modifications.find_by_coach_session_id coach_session.id    
  end

  def test_handle_affected_sessions_for_sesion_with_learners
    coach = create_coach_with_qualifications('psubramanian', ['HEB'])
    ConfirmedSession.any_instance.stubs(:learners_signed_up).returns 0
    ConfirmedSession.any_instance.stubs(:reflex?).returns false
    bg_task = FactoryGirl.create(:background_task, :referer_id => coach.id, :triggered_by => 'KS', :background_type => "Coach Activation", :state => "Queued", :locked => true, :job_start_time => Time.now.utc, :message => "Task enqueued.")
    coach_session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :eschool_session_id => "345698", :language_identifier => "HEB")  
    coach_activation_job = CoachActivationJob.new(coach.id, 'false', 'KS', bg_task.id)
    assert_nil coach.availability_modifications.find_by_coach_session_id coach_session.id
    coach_activation_job.handle_affected_sessions
    coach_session.reload
    assert_false coach_session.cancelled
    assert_not_nil coach.availability_modifications.find_by_coach_id coach.id
  end

  def test_error_is_thrown_when_argument_is_nil
    coach_activation_job = CoachActivationJob.new
    methods = %w(get_handle get_coach get_message)
    methods.each do |meth|
      assert_raise RuntimeError do
        coach_activation_job.send(meth.to_sym)
      end
    end
  end
end

