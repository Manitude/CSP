require File.expand_path('../../test_helper', __FILE__)
require 'ms_utils'

class PushToEschoolJobTest < ActiveSupport::TestCase

  def test_set_task_status_to_started
    sm = create_and_return_scheduler_metadata('ESP')
    bg_task = BackgroundTask.create(:referer_id => sm.id, :triggered_by => CoachManager.first.user_name, :background_type => "MS Bulk Modifications", :state => "Queued", :locked => true, :job_start_time => Time.now.utc, :message => "Task enqueued.")
    job = PushToEschoolJob.new(bg_task.id)
    job.instance_variable_set("@sm",sm)
    job.instance_variable_set("@bt",bg_task)
    job.set_task_status_to_started
    bg_task.reload
    assert_equal "Started", bg_task.state
  end
  
  def test_set_task_status_to_completed
    sm = create_and_return_scheduler_metadata('ESP')
    bg_task = BackgroundTask.create(:referer_id => sm.id, :triggered_by => CoachManager.first.user_name, :background_type => "MS Bulk Modifications", :state => "Queued", :locked => true, :job_start_time => Time.now.utc, :message => "Task enqueued.")
    job = PushToEschoolJob.new(bg_task.id)
    job.instance_variable_set("@sm",sm)
    job.instance_variable_set("@bt",bg_task)
    job.set_task_status_to_completed
    bg_task.reload
    assert_equal "Completed", bg_task.state
    assert_false bg_task.locked
  end
  
  #*****************************need to move these two to language.rb test******************

  def test_update_last_pushed_week_should_not_update_when_last_pushed_week_in_future
   sm = create_and_return_scheduler_metadata('ESP')
   start_of_the_week = TimeUtils.beginning_of_week.utc
   language = Language.find_by_identifier("ESP")
   language.update_attribute(:last_pushed_week, start_of_the_week + 2.weeks)
   language.update_last_pushed_week(start_of_the_week)
   language.reload
   assert_equal start_of_the_week + 2.weeks, language.last_pushed_week
  end

  def test_update_last_pushed_week_should_update_when_last_pushed_week_in_past
   sm = create_and_return_scheduler_metadata('ESP')
   start_of_the_week = TimeUtils.beginning_of_week.utc
   language = Language.find_by_identifier("ESP")
   language.update_attribute(:last_pushed_week, start_of_the_week - 2.weeks)
   language.update_last_pushed_week(start_of_the_week)
   language.reload
   assert_equal start_of_the_week, language.last_pushed_week
  end

  #********************************************************************************************

  def test_perform_bulk_modifications_flow
    sm = create_and_return_scheduler_metadata('ESP')
    json_data = {"create" => "0", "edit" => "1", "cancel" => "1", "delete" => "1"}.to_json
    sessions = {:create => "0", :edit => "1", :cancel => "1", :delete => "1"}
    bg_task = BackgroundTask.create(:referer_id => sm.id , :triggered_by => CoachManager.first.user_name, :background_type => "MS Bulk Modification", :state => "Queued", :locked => true, :job_start_time => Time.now.utc, :message => "Task enqueued.")
    push_to_eschool_job = PushToEschoolJob.new(bg_task.id)
    bulk_modifications_stubs
    push_to_eschool_job.perform
  end

  def test_log_error_flow
    sm = create_and_return_scheduler_metadata('KLE')
    bg_task = BackgroundTask.create(:referer_id => sm.id, :triggered_by => CoachManager.first.user_name, :background_type => "MS Bulk Modification", :state => "Queued", :locked => true, :job_start_time => Time.now.utc, :message => "Task enqueued.")
    push_to_eschool_job = PushToEschoolJob.new(bg_task.id)
    PushToEschoolJob.any_instance.stubs(:set_task_status_to_started).raises(Exception.new('exception'))
    HoptoadNotifier.expects(:notify)
    assert_no_difference 'MsErrorMessage.all.size' do
      push_to_eschool_job.perform
    end
    bg_task.reload
    assert_not_nil bg_task.error
  end

  private

  def bulk_modifications_stubs
    MsBulkModifications::BulkEdit.expects(:perform)
    MsBulkModifications::BulkCreate.expects(:perform)
    MsBulkModifications::BulkCancel.expects(:perform)
  end

  def deflate(string)
    z = Zlib::Deflate.new(Zlib::DEFAULT_COMPRESSION)
    data = z.deflate(string, Zlib::FINISH)
    z.close
    data
  end
end
