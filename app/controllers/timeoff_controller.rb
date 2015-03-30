class TimeoffController < ApplicationController

  before_filter :load_common_data, :except => [:approve_modification]

  def list_timeoff
    time_offs = UnavailableDespiteTemplate.where(['approval_status IN (0,1) and coach_id = ? and end_date > ? and unavailability_type = 0', @coach.id, Time.now.utc]).order('start_date')
    @approved_modifications = time_offs.select {|mod| mod.approval_status == 1}
    @unapproved_modifications = time_offs - @approved_modifications
    render :partial => 'list_timeoff'
  end

  def edit_timeoff
    @modification = UnavailableDespiteTemplate.find_by_id(params[:mod_id])
    render :partial => 'edit_timeoff'
  end

  def create_timeoff
    @modification = UnavailableDespiteTemplate.new({
        :start_date => @next_slot_start_time,
        :end_date => @next_slot_start_time + @coach.duration_in_seconds
      })
    render :partial => 'create_timeoff'
  end

  def save_timeoff
    options = {
      :coach_id => @coach.id,
      :approval_status => 0,
      :start_date => TimeUtils.time_in_user_zone(params[:start_date]).utc,
      :end_date =>  TimeUtils.time_in_user_zone(params[:end_date]).utc,
      :comments => params[:comments]
    }
    modification = UnavailableDespiteTemplate.find_by_id(params[:timeoff_id])
    if modification.present?
      message = 'Your time off is altered accordingly and is awaiting approval.'
      if modification.approval_status == 0
        modification.update_attributes(options)
      else
        UnavailableDespiteTemplate.transaction do
          message = 'Your time off is altered accordingly and is awaiting approval, and your previous unapproved time off has been cancelled by system.' if modification.children.not_denied.present?
          modification.children.update_all({:approval_status => 3, :unavailability_type => 3}) if !modification.children.blank?
          modification = modification.children.create(options)
        end
      end
      event_type = 'TIME_OFF_EDITED'
    else
      modification = UnavailableDespiteTemplate.create(options)
      message = 'Your requested time off is created successfully and is awaiting approval.'
      event_type = 'REQUEST_TIME_OFF' + (modification.violates_policy? ? '_BY_VIOLATING_POLICY' : '')
    end
    errors = modification.errors.full_messages
    if errors.empty?
      trigger_timeoff_notifications(modification, event_type)
      render :text => message
    else
      render :text => errors.join(','), :status => 500
    end
  end

  def cancel_timeoff
    recent_modification = UnavailableDespiteTemplate.find_by_id(params[:timeoff_id])
    # If cancelling an approved timeoff which is currently running, alter that timeoff, if necessary, create a timeoff for the time that has already passed
    if recent_modification && (recent_modification.status == 1) && recent_modification.start_date < @next_slot_start_time
      back_early = UnavailableDespiteTemplate.create({
          :coach_id             => @coach.id,
          :start_date           => TimeUtils.current_slot,
          :end_date             => recent_modification.end_date,
          :approval_status      => 1,
          :comments             => 'Back Early to teach',
          :unavailability_type  => 3,
        })
      errors = back_early.errors.full_messages
      if errors.empty?
        if TimeUtils.current_slot == recent_modification.start_date
          recent_modification.destroy
          trigger_timeoff_notifications(back_early, 'TIME_OFF_REMOVED')
        else
          recent_modification.update_attribute(:end_date, TimeUtils.current_slot)
          trigger_timeoff_notifications(recent_modification, 'TIME_OFF_CUT_SHORT')
        end
        render :text => 'You are back and available to teach now.'
      else
        render :text => errors.join(','), :status => 500
      end
    # For cancelling a pending timeoff(during or before timeoff) or an approved timeoff(before timeoff start), change the approval status to Cancelled.
    elsif recent_modification
      remove_modification_notifications(recent_modification) if recent_modification.status == 0
      recent_modification.update_attribute(:unavailability_type, 3)
      recent_modification.update_attribute(:approval_status, 5)
      render :text => "Your time-off has been cancelled successfully."
    else
      render :text => "Something went wrong, please reload the page and try again.", :status => 500
    end
  end

  def check_policy_violation_for_availability_modification
    timeoff_id = params[:timeoff_id].blank?? -1 : params[:timeoff_id].to_i
    start_date = TimeUtils.time_in_user_zone(params[:start_date])
    end_date = TimeUtils.time_in_user_zone(params[:end_date])
    overlap_timeoffs = UnavailableDespiteTemplate.where(["id != ? and coach_id = ? and unavailability_type = 0 and approval_status IN (0,1) and start_date < ? and end_date > ?", timeoff_id, @coach.id, end_date, start_date])
    if overlap_timeoffs.any?
      render :text => "The timeoff request already exists. You can edit to shorten or extend your timeoff.", :status => 500
    else
      render :text => @coach.is_totale_aria? ? (!@coach.session_on(start_date).nil? || @coach.has_session_between?(start_date, end_date)) :  @coach.has_session_between?(start_date, end_date)
    end
  end

  def approve_modification
    modif  = UnavailableDespiteTemplate.find_by_id(params[:id])
    if modif
      if modif.approval_status == 0
        overlap_timeoff = UnavailableDespiteTemplate.where(["id != ? and coach_id = ? and unavailability_type = 0 and approval_status = 1 and start_date < ? and end_date > ?", modif.id, modif.coach_id, modif.end_date, modif.start_date]).last
        if params[:status] == "true"
          UnavailableDespiteTemplate.transaction do
            if overlap_timeoff.present?
              overlap_timeoff.update_attribute(:approval_status, 3)
              overlap_timeoff.update_attribute(:unavailability_type, 3)
            end
            sessions = modif.coach.sessions_between_time_boundries(modif.start_date, modif.end_date)
            sessions <<  modif.coach.check_previous_slot_for_session(modif.start_date)
            sessions.compact.each do |session|
              session.cancel_or_subsitute!
              session.cancelled? ? session.update_attributes(:cancellation_reason => "Time Off") : session.substitution.update_attributes(:reason => "Time Off")
            end
            LocalSession.created_between_time_boundries(modif.coach_id, modif.start_date, modif.end_date).each do |session|
              session.destroy
            end

            modif.parent.update_attributes({:approval_status => 3, :unavailability_type => 3}) if modif.parent

            TriggerEvent['ACCEPT_TIME_OFF'].notification_trigger!(modif)
            modif.update_attribute(:approval_status, 1)
            notice = "Time-off has been approved."
            status = "Approved"
          end
        else
          TriggerEvent['DECLINE_TIME_OFF'].notification_trigger!(modif)
          notice = "Time-off has been rejected."
          modif.update_attribute(:approval_status, 2)
          status = "Denied"
        end
        mail_time_off_notifications_immediately_to_coaches(modif, modif.coach)
      else
        error = "The time-off is already #{(modif.approval_status == 1)? "approved" : "rejected"}."
      end
    else
      error = "Something went wrong, please try again."
    end
    if params[:mail]
      redirect_to manager_notifications_path
    else
      render :partial => "shared/success_failure", :locals => {:error => error, :message => notice, :status => status}
    end
  end

  private

  def trigger_timeoff_notifications(modification, event_type)
    not_ids = TriggerEvent.where("name IN ('REQUEST_TIME_OFF_BY_VIOLATING_POLICY', 'REQUEST_TIME_OFF', 'TIME_OFF_REMOVED', 'TIME_OFF_CUT_SHORT', 'TIME_OFF_EDITED', 'ACCEPT_TIME_OFF')").collect{|noti| noti.id}
    SystemNotification.delete_all(["notification_id in (?) and target_id = ? ", not_ids, modification.id])
    TriggerEvent[event_type].notification_trigger!(modification)
    mail_time_off_notifications_immediately_to_coaches(modification)
  end

  def remove_modification_notifications(modification)
    not_ids = TriggerEvent.where("name IN ('REQUEST_TIME_OFF_BY_VIOLATING_POLICY', 'REQUEST_TIME_OFF', 'TIME_OFF_REMOVED', 'TIME_OFF_CUT_SHORT', 'TIME_OFF_EDITED', 'ACCEPT_TIME_OFF')").collect{|noti| noti.id}
    SystemNotification.delete_all(["notification_id in (?) and target_id = ? ", not_ids, modification.id])
  end

  def authenticate
    unless (params[:action] == "approve_modification" && manager_logged_in?) || coach_logged_in?
      if request.xhr?
        render :text => "Something went wrong, please reload the page and try again.", :status => 500
      else
        access_denied
      end
    end
  end

  def load_common_data
    @coach = current_coach
    @next_slot_start_time = TimeUtils.current_slot + @coach.duration_in_seconds
  end

end
