require 'will_paginate/array'
require File.dirname(__FILE__) + '/../utils/coach_availability_utils'

class SubstitutionController < ApplicationController

  before_filter :validate_ajax, :only => [:check_sub_policy_violation, :request_substitute_for_coach, :reason_for_sub_request, :fetch_available_coaches]

  def request_substitute_for_coach
    session = CoachSession.where(["cancelled = 0 and coach_id = ? and session_start_time = ?", params[:current_coach_id], params[:time].to_time]).last
    if session
      udt = session.request_substitute(current_user.is_manager?)
      if !session.cancelled?
      session.substitution.update_attributes(:reason => params[:reason])
      end
      label = (udt.unavailability_type == 4)? ["Cancelled","cs_cancelled"] : session.label_for_substitution(UNAVAILABILITY_TYPE[udt.unavailability_type])
      render :json => {:start_time => session.session_start_time.to_i, :end_time => session.session_end_time.to_i, :label => label, :message => (label[0] == "Cancelled") ? "Substitute Requested but Session Cancelled(No learner)" : "Substitute was requested successfully", :one_hour_session => session.is_one_hour?, :cancelled => session.cancelled?, :is_appointment => session.appointment?}, :status => 200
    else
      render :text => "Something went wrong, please try again.", :status => 500
    end
  end


  def check_sub_policy_violation
    session_start_time = TimeUtils.time_in_user_zone(params[:start_time].to_i/1000)
    coach = Coach.find_by_id params[:coach_id]
    coach_session = CoachSession.where("coach_id = ?  and session_start_time = ? and cancelled is false",coach.id,session_start_time).first
    if coach
      start_time = session_start_time.beginning_of_month.to_s(:db)
      end_time = session_start_time.end_of_month.to_s(:db)
      sql = "Select DISTINCT * from substitutions s join coach_sessions c on s.coach_session_id = c.id join unavailable_despite_templates u where c.type NOT IN ('ExtraSession','Appointment') and s.coach_id = ? and c.session_start_time >= ? and c.session_start_time < ? and u.coach_session_id = c.id and (s.coach_id != s.grabber_coach_id OR s.grabber_coach_id is null) and u.unavailability_type in (1,5) order by s.created_at, u.created_at desc;"
      substitutions = Substitution.find_by_sql([sql,coach.id,start_time,end_time])
      substitution = nil
      unless substitutions.blank?
        substitution_day_start = (TimeUtils.time_in_user_zone substitutions.first.coach_session.session_start_time).beginning_of_day
        #following line gets all the substitutions of the sub day and consider closest substitution for continuous block checking.
        substitution = substitutions.select{|x|  x.coach_session.session_start_time >= substitution_day_start && x.coach_session.session_start_time < substitution_day_start+1.day}.sort_by{|s| (s.coach_session.session_start_time - session_start_time).abs}.first
      end
      if !substitution.blank?
        first_session_start_time = TimeUtils.time_in_user_zone substitution.coach_session.session_start_time
        if ( (((first_session_start_time.beginning_of_day - session_start_time.beginning_of_day)/24.hours).abs) == 1 )
          render :json => {:violation => (!substitution.is_in_same_block?(coach_session)).to_s, :text => "session at : #{first_session_start_time.strftime("%a %D")}" }, :status => 200 and return
        end
        render :json => {:violation => "false" }, :status => 200 and return if (first_session_start_time.to_date == session_start_time.to_date)
        render :json => {:violation => "true" , :text => "session at : #{first_session_start_time.strftime("%a %D")}" }, :status => 200 and return
      end
      render :json => {:violation => "false" }, :status => 200 and return
    end
  end

  def assign_substitute_for_coach
    @assigned_coach = Coach.find_by_id(params[:assigned_coach])
    @coach_session = CoachSession.find_by_id(params[:coach_session_id])
    substituted_session = true
    if @assigned_coach && @coach_session
      substitution = @coach_session.substitution
      @coach_id = substitution.try(:coach_id)
      trigger_event_type = 'MANUALLY_REASSIGNED'
      if substitution.blank? || substitution.grabber_coach_id
        substituted_session = false
        substitution = Substitution.create(:coach_id => @coach_session.coach_id, :grabbed => false, :coach_session_id => @coach_session.id, :reason => params[:reason])
        trigger_event_type = 'MANUALLY_ASSIGNED'
        modification = @coach_session.modify_coach_availability(5)
      end
      substitution.perform_substitution(@assigned_coach, true, trigger_event_type)
      @coach_session = CoachSession.find_by_id(params[:coach_session_id])
      if (substitution.coach_id == @assigned_coach.id)
        label = [@coach_session.label_for_active_session, (@coach_session.appointment? ? "cs_appointment_session_slot" : "cs_solid_session_slot")]
      else
        label = @coach_session.label_for_substitution(modification ? "Reassigned" : nil)
      end
      half_slot = half_slot_session?(substituted_session) if params[:from_cs] == "true"
      render :json => {:half_slot => half_slot, :start_time => @coach_session.session_start_time.to_i, :end_time => @coach_session.session_end_time.to_i, :label => label, :message => "Substitute was assigned successfully", :one_hour_session => @coach_session.is_one_hour?}, :status => 200
    else
      render :text => "There was some error.", :status => 500
    end
  end

  def half_slot_session?(substituted_session)
    return false if !@coach_session.is_one_hour? || !substituted_session
    slot_time = TimeUtils.return_other_half(params[:slot_time].to_time)
    if (CoachSession.where("session_start_time = ? and cancelled = false and coach_id = ?", slot_time, @coach_id).present?)
      return "second" if slot_time.min == 30
      return "first"
    end
  end

  def cancel_substitution
    if params[:sub_id]
      substitution = Substitution.find_by_id(params[:sub_id])
    else
      coach_session = CoachSession.find_by_id(params[:session_id])
      coach_session = CoachSession.find_by_eschool_session_id(params[:session_id]) if coach_session.nil?
      substitution = coach_session.substitution if coach_session
    end
    if substitution
      if !substitution.cancelled && substitution.grabber_coach_id.nil?
        substitution.cancel!(params[:notice] == "true")
        substitution.coach_session.update_attribute(:cancellation_reason, params[:reason]) if params[:reason].present?
        render :text => "#{substitution.coach_session.appointment? ? 'Appointment' : 'Session'} was cancelled successfully.", :status => 200
      else
        render :text => "#{substitution.coach_session.appointment? ? 'Appointment' : 'Session'} has been already cancelled/reassigned/grabbed.", :status => 500
      end
    else
      render :text => "There was some error.", :status => 500
    end
  end

  def substitutions_alert
    if params[:closed] == "true"
      current_user_show_sub = ShownSubstitutions.find_by_coach_id(current_user.id)
      current_user_show_sub.destroy if current_user_show_sub
      ShownSubstitutions.create(:coach_id => current_user.id)
    end

    substitutions = Substitution.get_future_alerts(current_user)
    @substitution_data = substitutions.collect{|each_sub| prepare_substitution_data(each_sub)}.compact
    #Limit no. of alerts based on preference setting
    @substitution_data = @substitution_data[0...current_user.get_preference.no_of_substitution_alerts_to_display]
    render(:partial => coach_logged_in? ? 'substitution/substitutions_alert' : 'shared/substitutions_alert')
  end

  def fetch_available_coaches
    @fetch_reason = params[:fetch_reason] == "true"
    if params[:sub_id]
      substitution = Substitution.find_by_id(params[:sub_id])
      if substitution && !substitution.cancelled && substitution.grabber_coach_id.nil?
        @coach_session = substitution.coach_session
      else
        @error = "#{substitution.coach_session.appointment? ? 'Appointment' : 'Session'} has been already cancelled/reassigned/grabbed. Please refresh the page."
      end
    else
      @coach_session = CoachSession.find_by_id(params[:session_id])
      @coach_session = CoachSession.find_by_eschool_session_id(params[:session_id]) if @coach_session.nil?
    end
    if @coach_session.blank?
      @alternate_coaches = []
    else
      is_appointment = @coach_session.appointment?
      single_number_unit = @coach_session.eschool_session ? @coach_session.eschool_session.level ? CurriculumPoint.single_number_unit_from_level_and_unit(@coach_session.eschool_session.level, @coach_session.eschool_session.unit) : @coach_session.eschool_session.unit : 0
      @alternate_coaches = CoachAvailabilityUtils.eligible_alternate_coaches(@coach_session.session_start_time, @coach_session.language.id, single_number_unit,0,is_appointment)
    end
    render :partial => 'fetch_available_coaches'
  end

  def reason_for_sub_request
    render :partial => 'reason_for_sub_request'
  end

  def substitutions
    user = current_user
    self.page_title = user.is_manager? ? 'Manage Substitutions' : 'View/Grab Substitutions'
    params[:duration] ||= "Upcoming Week"
    @substitutions = user.manage_substitutions(params[:duration], params[:coach_id], params[:lang_id])
    @substitutions[:data] = @substitutions[:data].paginate(:per_page => 10, :page => params[:page])
  end

  def grab_substitution
    coach = current_coach
    substitution = Substitution.find_by_id(params[:sub_id])
    if coach && coach.active && substitution
      session = substitution.coach_session
      if substitution.has_grabbed?
        error = "This #{substitution.coach_session.appointment? ? 'appointment' : 'session'} has already been grabbed by another coach."
      elsif  substitution.has_canceled?
        error = "This #{substitution.coach_session.appointment? ? 'appointment' : 'session'} has already been cancelled."
      elsif substitution.has_reassigned?
        error = "This #{substitution.coach_session.appointment? ? 'appointment' : 'session'} has already been re-assigned."
      elsif coach.has_session_conflict?(session.session_start_time, session.language,session.appointment?)
        error = "You are already scheduled at this time."
      elsif session.eschool_session_unit.to_i > Coach.max_unit(coach.id, session.language_id).to_i
        error = "You are not qualified to teach this session."
      elsif session.is_extra_session? && coach.is_excluded?(session)
        error = "You are not allowed to teach this session."
      elsif !session.appointment? && coach.threshold_reached?(session.session_start_time).detect{|x| x===true} && (session.session_start_time > (Time.now.utc + LanguageSchedulingThreshold.get_hours_prior_to_sesssion_override(session.language_id).hours))
        error = "You have reached or exceeded the maximum number of sessions for the following week(s). Please contact your Coach Manager if you would like to teach additional sessions."
      else
        substitution.perform_substitution(coach, false, 'SUBSTITUTION_GRABBED')
        message = "You are now scheduled to substitute for this #{substitution.coach_session.appointment? ? 'appointment' : 'session'}."
      end
    else
      error = "There is some problem, please reload the page and try again."
    end
    render :json => {:is_appointment => substitution.coach_session.appointment? ? true : false, :error => error, :message => message, :status => nil}
  end

  def trigger_sms

    lang_id = params[:lang_id]
    lang = Language.find_by_id(lang_id)
    appointment_lang_ids = Language.fetch_same_group_appointment_languages(lang).collect(&:id) if (lang_id.to_s.include? "-A") # to check if the language id is of appointment type(i.e it has -A appended).
    if lang
      current_slot = TimeUtils.current_slot
      if appointment_lang_ids
        sessions_count = Appointment.where(:language_id => appointment_lang_ids, :session_start_time =>(current_slot..current_slot + 24.hours), :cancelled => 0, :coach_id => nil).try(:count).to_i
      else
        sessions_count = CoachSession.where(:language_id => lang.id, :session_start_time =>(current_slot..current_slot + 24.hours), :cancelled => 0, :coach_id => nil, :type => ['ConfirmedSession', 'ExtraSession']).reject{|sess| sess.supersaas? && !sess.eschool_session_id}.try(:count).to_i
      end

      if sessions_count > 0
        session_type = (appointment_lang_ids) ? "appointment" : "session" 
        language_ids = (appointment_lang_ids) ? appointment_lang_ids : lang.id 
        Delayed::Job.enqueue(SendSmsSubstitution.new(language_ids, sessions_count , session_type), 0)
        message = 'SMS Triggered Successfully.'
      else
        message = 'There are no substitute requested sessions/appointments to be started in the next 24 hours.'
      end
    else
      message = 'There were some error. Please try again.'
    end
    render :text => message
  end

  def show_reason_in_sub_report
    @reason = Substitution.find_by_id(params[:id]).try(:reason)
    @error = "No reason found for this substitution" if @reason.nil?
    render :partial => 'show_reason_in_sub_report'
  end

  private

  def prepare_substitution_data(substitution)
    eschool_session = substitution.coach_session.eschool_session
    langobj = eschool_session ? Language.find_by_identifier(eschool_session.language) : substitution.language
    sub_data = {
      :language   => substitution.coach_session.appointment? ? substitution.coach_session.display_name_in_upcoming_classes : langobj.display_name,
      :date_time  => TimeUtils.format_time(substitution.substitution_date, '%a %d %b %Y %H:%M:%S'),
      :sub_id     => substitution.id,
      :level      => "L-" + ((eschool_session.nil? || langobj.is_lotus?)? "NA" : eschool_session.level),
      :unit       => "U-" + ((eschool_session.nil? || langobj.is_lotus?)? "NA" : eschool_session.unit),
      :updated_at => substitution.updated_at
    }

    sub_data.merge!({:show_warning_icon => can_show_warning_icon?(substitution.substitution_date)}) if manager_logged_in?
    if coach_logged_in?
      return nil if (grab_disable = !current_coach.can_grab?(substitution))
      sub_data.merge!({
                        :coach_user_names => substitution.eligible_coaches.collect(&:user_name),
                        :language_id => langobj.id,
                        :grab_disable => grab_disable
      })
    end
    sub_data
  end

  def can_show_warning_icon?(substitution_date)
    cm_pref = current_user.cm_preference
    no_coach_alert_time = cm_pref.nil? ? 1 : cm_pref.page_alert_enabled ? cm_pref.min_time_to_alert_for_session_with_no_coach : nil
    no_coach_alert_time && substitution_date.utc <= Time.now.utc + no_coach_alert_time.hour
  end

  def validate_ajax
    unless request.xhr?
      flash[:error] = "#{request.filtered_parameters["action"]} is not a valid url"
      redirect_to(login_url, :flash => session[:flash]) and return
     end
  end

end
