class CoachActivationJob < Struct.new(:coach_id, :check_box_value, :triggered_by, :task_id)
  def perform
    begin
      set_task_status_to_started
      activate_or_inactivate
    rescue Exception => e
      log_error e
    ensure
      set_task_status_to_completed
      ActiveRecord::Base.verify_active_connections!
    end
  end

  def end_recurring_schedules
    coach = get_coach
    recurring_schedules_with_nil_end_date = CoachRecurringSchedule.update_all('recurring_end_date = NOW()', "coach_id = #{coach.id} and IFNULL(recurring_end_date,-1) = #{-1}")
    Delayed::Worker.logger.info "Found #{recurring_schedules_with_nil_end_date.size} recurring schedules."
    Delayed::Worker.logger.info 'Recurring schedules got changed.'
  end

  def remove_templates
    coach = get_coach
    availability_templates = CoachAvailabilityTemplate.update_all("deleted = #{true}", "coach_id = #{coach.id} and deleted = false")
    Delayed::Worker.logger.info "Found #{availability_templates.size} availability templates."
    Delayed::Worker.logger.info 'Availability templates are deleted.'
  end

  def handle_affected_sessions
    coach = get_coach
    ConfirmedSession.find_in_batches({:batch_size => 20, :conditions => ['session_start_time >= CURDATE() and coach_id = ? and cancelled = 0', coach.id]}) do |batch|
      batch.each do |coach_session|
        coach_session.cancel_or_subsitute!
      end
    end
    Delayed::Worker.logger.info 'Sessions are sub triggered'
  end

  def remove_timeoffs
    coach = get_coach
    timeoffs = UnavailableDespiteTemplate.update_all("approval_status = 2","coach_id = #{coach.id} and unavailability_type = 0 and approval_status = 0")
    Delayed::Worker.logger.info "Denied #{timeoffs} timeoffs which were pending for the coach #{coach.id}."
  end

  def change_status_in_eschool
    begin
      coach = get_coach
      response = Eschool::Coach.create_or_update_teacher_profile_with_multiple_qualifications(coach)
      if response
        response_xml = REXML::Document.new response.read_body
        status = response_xml.elements.to_a("//status").first.text
        if status == 'ERROR'
          background_task = get_handle
          background_task.update_attribute(:error, 'Status not changed in eSchool.<br/>Error while saving in eSchool: ' + response_xml.elements.to_a("//message").first.text)
        end
      end
    rescue ActiveResource::ResourceNotFound => e
      HoptoadNotifier.notify(e)
      background_task = get_handle
      background_task.update_attribute(:error, 'Status not changed in eSchool.<br/>Eschool seems to be unavailable. Please try again later.')
    end
  end

  def get_message
    raise "Improper active value for coach" unless check_box_value
    check_box_value == 'true' ? 'Activating' : 'Inactivating'
  end

  def get_active_value
    raise "Improper active value for coach" unless check_box_value
    check_box_value == 'true'
  end

  def get_coach
    raise "Coach Not Present" unless coach_id
    Account.find_by_id(coach_id)
  end

  def get_handle
    raise "Background Task Not Present" unless task_id
    BackgroundTask.find task_id
  end

  def set_task_status_to_started
    background_task = get_handle
    message = get_message
    background_task.update_attribute(:state, "Started")
    Delayed::Worker.logger.info "Coach locked for #{message}."
  end

  def activate_or_inactivate
    active_value = get_active_value
    coach = get_coach
    # Remove the schedules of the coach being deactivated
    if coach
      coach.update_attribute(:active, active_value)
      Delayed::Worker.logger.info 'Changed value In accounts.'
      coach.reload
      unless active_value
        end_recurring_schedules
        remove_templates
        handle_affected_sessions
        remove_timeoffs
      end
      # Send changes to eSchool
      change_status_in_eschool
    end
  end

  def set_task_status_to_completed
    background_task = get_handle
    background_task.update_attributes(:state=> "Completed", :locked => false, :job_end_time => Time.now.utc)
    Delayed::Worker.logger.info 'Done!!'
  end

  def log_error(exception)
    background_task = get_handle
    background_task.update_attributes(:error => exception.message)
    HoptoadNotifier.notify(exception)
  end
end