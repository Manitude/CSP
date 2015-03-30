class PushToEschoolJob < Struct.new(:task_id)
  
  def perform
    begin
      @bt = BackgroundTask.find_by_id(task_id)
      raise "Background Task Not Present" unless @bt
      @sm = SchedulerMetadata.find_by_id(@bt.referer_id)
      raise "Scheduler Metadata not found" unless @sm
      set_task_status_to_started
      manager = Account.find_by_user_name(@bt.triggered_by)
      CustomAuditLogger.set_changed_by!("Push To Eschool - by #{manager.user_name}")
      Thread.current[:user_details] = "CCS-#{manager.user_name} - Bulk Push"
      Thread.current[:account] = manager
      perform_bulk_modifications
    rescue Exception => e
      @bt.update_attributes(:error => e.message)
      HoptoadNotifier.notify(e)
    ensure
      set_task_status_to_completed
      ActiveRecord::Base.verify_active_connections!
    end
  end

  def perform_bulk_modifications
    @sm.weeks_to_be_pushed.each do |start_of_week|
      end_of_week = start_of_week + 1.weeks - 1.minute
      Delayed::Worker.logger.info "\n******Bulk Modification Started for Week #{start_of_week} to #{end_of_week}******\n"
      MsBulkModifications::BulkEdit.perform(@sm, start_of_week, end_of_week)
      MsBulkModifications::BulkCreate.perform(@sm, start_of_week, end_of_week)
      MsBulkModifications::BulkCancel.perform(@sm, start_of_week, end_of_week)
      @sm.language.update_last_pushed_week(start_of_week)
      Delayed::Worker.logger.info "\n******Bulk Modification Finished for Week #{start_of_week} to #{end_of_week}******\n"
    end
  end

  def set_task_status_to_started
    message = "MS push for #{@sm.language.identifier} has been started at #{Time.now}."
    @bt.update_attributes(:state => "Started", :message => message)
    Delayed::Worker.logger.info "\n****************#{message}***************"
  end

  def set_task_status_to_completed
    message = "MS push for #{@sm.language.identifier} has been completed at #{Time.now}."
    @sm.update_attribute(:locked, false)
    @bt.update_attributes(:state => "Completed", :locked => false, :job_end_time => Time.now.utc, :message => message)
    Delayed::Worker.logger.info "\n****************#{message}***************"
  end

end
