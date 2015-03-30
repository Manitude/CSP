require 'icalendar'

class CoachPortalController < ApplicationController

  def get_next_session_details
    if @next_session
      @time = TimeUtils.format_time(@next_session.session_start_time, '%^A %m/%d   %I.%M%p')
      if @next_session.appointment?
        @language = @next_session.display_name_in_upcoming_classes
        @details = @next_session.details
      elsif @next_session.reflex?
        @language = 'Advanced English'
        @launch_url = construct_url_for('KLE', CocomoConfig.url) # No time check is done because the count down time per say appears only 20 minutes before start of session.
      elsif @next_session.supersaas?
        @language = @next_session.language.display_name
        @supersaas_sess = @next_session.supersaas_session
        if @supersaas_sess 
        @launch_url = @next_session.falls_under_20_mins? ?  true : false 
        if @launch_url
          if @next_session.aria?
            learner_detail = @next_session.supersaas_learner
            @aria_learner_guid = learner_detail.empty? ? ["None"] : learner_detail.collect{|l| l[:guid]}.first
          else
            @supersaas_description = @next_session.fetch_supersaas_slot_description
          end
        end
        else
        @next_session = nil
        end
      elsif @next_session.tmm?
        @language = @next_session.language.display_name
        @details = @next_session.details
      else
        @eschool_sess = @next_session.eschool_session
        if @eschool_sess
          @language = @next_session.language.display_name
          @level = @eschool_sess.level
          @unit = @eschool_sess.unit
          @avg_attendance = @eschool_sess.average_attendance.to_f.round(1)
          @launch_url = @eschool_sess.launch_session_url if @next_session.falls_under_20_mins?
        else
          @next_session = nil
        end
      end
    end
    render :partial => 'countdown_session_details'
  end

  def sign_in_as_super_user
    old_user = self.current_user
    super_user = session[:super_user]
    redirect_to(coach_portal_url, :notice => 'Invalid action!') && return unless super_user
    self.current_user = super_user
    session[:super_user] = nil
    flash[:notice] = "Signed back in as #{super_user.user_name} from #{old_user.user_name}"
    redirect_to_appropriate_url
  end

  def index
    redirect_to calendar_week_url
  end

  def view_profile
    @coach = current_coach
  end

  def edit_profile
    @coach = current_coach
    if request.post?
      if params[:remove_profile_picture] == "true"
        @coach.photo = nil
        ActiveRecord::Base.connection.execute("UPDATE accounts SET photo_file = null WHERE id = #{@coach.id}")
      end
      @coach.update_attributes(params[:coach])
      
      # update qualifications
      params[:qualification] && params[:qualification].each do |lang_id, max_unit|
        max_unit = 1 unless TotaleLanguage.find_by_id(lang_id)
        @coach.update_or_create_qualification(lang_id.to_i, max_unit.to_i)
      end
      
      @coach.create_or_update_outside_csp("update") if @coach.errors.blank?
      if @coach.errors.blank?
        flash[:notice] = "Profile has been updated successfully."
        redirect_to view_profile_url
      end
    end
  end

  def notifications
    self.page_title = 'Notifications'
    @notifications = current_coach.system_notifications_not_reassigned_or_grabbed(false)
  end

  def calendar_week
    path = "/my_schedule/#{params[:lang_id] || "all"}"
    if params[:start_date]
      path += "/#{params[:start_date][0..9]}"
    end
    redirect_to path
  end

  def view_my_upcoming_classes
    start_time = TimeUtils.current_slot.beginning_of_hour
    @upcoming_sessions = current_coach.sessions_between_time_boundries(start_time, start_time + 1.week)
    @upcoming_sessions.reject!{|sess| sess.is_passed?}
    render :partial => 'view_my_upcoming_classes'
  end

  def coach_showed_up
    cs = CoachSession.find_by_id(params[:id])
    cs.update_attributes(:coach_showed_up => true, :seconds_prior_to_session => (cs.session_start_time.to_i - Time.now.utc.to_i)) if cs
    render :nothing => true
  end

  private

  def authenticate
    access_denied unless coach_logged_in?
  end

end
