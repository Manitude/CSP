class CoachSchedulerController < ApplicationController
  layout 'schedules', :only => [:index, :my_schedule]
 
  def index
    if manager_logged_in?
      page_title = "Coach Schedule"
      @data = { :week_extremes => TimeUtils.week_extremes_for_user(params[:date]) }
      @data[:default_language] = current_user.languages.first.filter_name
      language = Language.find_by_identifier(params[:language])
      if language
        @data[:default_language] = language.filter_name
        @data[:language] = params[:language]
        coach = Coach.find_by_id(params[:coach])
        if coach
          languages = coach.languages
          identifiers = languages.collect{|lang| lang.identifier}
          @data[:now] = TimeUtils.time_in_user_zone.to_i*1000
          @data[:coach] = coach
          @data[:allow_session_creation_after] = GlobalSetting.find_by_attribute_name("allow_session_creation_after").attribute_value.to_i
          if identifiers.include?(params[:filter_language])
            @data[:language] = @data[:filter_language] = params[:filter_language]
            languages = Language.find_all_by_identifier(params[:filter_language])
            @data[:default_language] = languages.first.filter_name
          else
            @data[:filter_language] = 'all'
          end
          page_title = page_title + " - " + coach.full_name
          schedules, @data[:coach_session_count] = coach.schedule_details_for_week(params[:date], languages)
          @data[:schedules] = schedules.to_json.html_safe
        end
      end
      self.page_title = page_title
    else
      access_denied
    end
  end

  def my_schedule
    if coach_logged_in?
      @data = {:week_extremes => TimeUtils.week_extremes_for_user(params[:date])}
      @data[:coach] = current_user
      self.page_title = "My Schedule - " + @data[:coach].full_name
      languages = @data[:coach].languages
      identifiers = languages.collect{|lang| lang.identifier}
      @data[:language] = identifiers.include?(params[:language]) ? params[:language] : "all"
      languages = Language.find_all_by_identifier(@data[:language]) if @data[:language] != "all"
      schedules, @data[:coach_session_count] = @data[:coach].schedule_details_for_week(params[:date], languages)
      @data[:schedules] = schedules.to_json.html_safe
    else
      access_denied
    end
  end
 
  def coaches_for_given_language
    language = Language.find_by_identifier(params[:language])
    language_id = ["TMM-ENG-P","TMM-ENG-L"].include?(params[:language]) ? language.id : nil
    render :json => {:text => view_context.options_for_coach(Coach.all_qualified_for_language(language.id), nil, false, language_id)}
  end
  
  def topic_for_cefr_and_given_language
    topics = Topic.display_filtered_topic(params[:cefrLevel],params[:language])
    render :json => topics
  end

  def create_session_form_in_coach_scheduler  #To open a create session popup
    @slot_info = {}
    @slot_info[:language] = params[:language] 
    @slot_info[:coach] = Coach.find_by_id(params[:coach_id])
    @slot_info[:start_time] = Time.at(params[:start_time].to_i).utc
    @slot_info[:has_appointment_in_other_half] = @slot_info[:coach].session_on(TimeUtils.return_other_half(@slot_info[:start_time])).present? || @slot_info[:coach].has_recurring_without_udt?(TimeUtils.return_other_half(@slot_info[:start_time])) if @slot_info[:coach].is_tmm?
    @slot_info[:no_existing_template] = @slot_info[:coach].active_template_on_the_time(@slot_info[:start_time]).nil? ? true : false #To determine whether the coach is without any template
    @slot_info[:end_time] = @slot_info[:start_time] + @slot_info[:coach].duration_in_seconds
    @slot_info[:availability] = @slot_info[:coach].having_availability_at?(@slot_info[:start_time])
    @slot_info[:aria_recurring_availability] = @slot_info[:coach].having_availability_at?(TimeUtils.return_other_half(@slot_info[:start_time])) if @slot_info[:coach].has_one_hour? #To disable recurring check box for aria when bottom half hour is unavailable     
    @slot_info[:recurring_ends_at] = @slot_info[:coach].detect_availability_change_for_slot_in_future(@slot_info[:start_time]) 
    @slot_info[:aria_recurring_ends_at] = @slot_info[:coach].detect_availability_change_for_slot_in_future(TimeUtils.return_other_half(@slot_info[:start_time])) if @slot_info[:coach].has_one_hour?
    if @slot_info[:recurring_ends_at] && @slot_info[:aria_recurring_ends_at]
      @slot_info[:aria_recurring_ends_at] = [@slot_info[:recurring_ends_at],@slot_info[:aria_recurring_ends_at]].min
    elsif @slot_info[:recurring_ends_at]
      @slot_info[:aria_recurring_ends_at] = @slot_info[:recurring_ends_at]
    end
    @slot_info[:session_on_other_half] = CoachSession.find_confirmed_session_at(TimeUtils.return_other_half(@slot_info[:start_time]),@slot_info[:coach].id).present? # To disable aria in session pop up if bottom half-hour has totale/refex session 
    @slot_info[:time_off_in_current_slot] = true if UnavailableDespiteTemplate.where(["unavailability_type = 0 AND coach_id = ? AND start_date <= ? AND end_date >= ? and approval_status = 1", @slot_info[:coach].id, @slot_info[:start_time], @slot_info[:end_time]]).order("updated_at").last
    crs = CoachRecurringSchedule.for_coach_and_datetime(@slot_info[:coach].id, @slot_info[:start_time])
    udt = UnavailableDespiteTemplate.where(["unavailability_type != 3 AND coach_id = ? AND start_date <= ? AND end_date >= ?", @slot_info[:coach].id, @slot_info[:start_time], @slot_info[:end_time]]).order("updated_at").last
    if @slot_info[:coach].has_one_hour?
      crs2 = CoachRecurringSchedule.for_coach_and_datetime(@slot_info[:coach].id, TimeUtils.return_other_half(@slot_info[:start_time]))
      udt2 = UnavailableDespiteTemplate.where(["unavailability_type != 3 AND coach_id = ? AND start_date <= ? AND end_date >= ?", @slot_info[:coach].id, TimeUtils.return_other_half(@slot_info[:start_time]), TimeUtils.return_other_half_end_time(@slot_info[:end_time])]).order("updated_at").last
      @slot_info[:aria_not_allowed] = true if @slot_info[:session_on_other_half] || (udt2.blank? && crs2 && !crs2.language.is_one_hour? ) || (TimeUtils.current_slot == @slot_info[:start_time] || @slot_info[:start_time] == TimeUtils.current_slot + 30.minutes && @slot_info[:start_time].min == 30) #!crs2.language.is_aria? to allow create ARIA session on a timeoff in second half lying in between an aria recurring..& disables aria session creation on current slot
      @slot_info[:time_off_in_other_half_slot] = true if UnavailableDespiteTemplate.where(["unavailability_type = 0 AND coach_id = ? AND start_date <= ? AND end_date >= ? and approval_status = 1", @slot_info[:coach].id, TimeUtils.return_other_half(@slot_info[:start_time]), TimeUtils.return_other_half_end_time(@slot_info[:end_time])]).order("updated_at").last
    end
    if (session = @slot_info[:coach].session_on(@slot_info[:start_time]))
      @slot_info[:error_message] = "The Coach has a scheduled #{session.appointment? ? 'appointment' : 'session'} in #{session.display_name_in_upcoming_classes} at #{format_time_for_popup(session.session_start_time)} to #{format_time_for_popup(session.session_end_time)}."
    else
      if (@slot_info[:coach].has_one_hour?)
        check_recurrings_for_aria_coaches(crs, crs2, udt, udt2)
      else
        check_recurrings_for_totale_coaches(crs, udt)
      end
    end
    @slot_info[:warning] = "This coach is unavailable, per their template." if @slot_info[:warning].blank? && !@slot_info[:availability]
    if @slot_info[:error_message].blank?
      @slot_info[:threshold_reached] = @slot_info[:coach].threshold_reached?(@slot_info[:start_time]).to_json
      @slot_info[:reflex_lang] = ReflexLanguage.where(true).collect(&:identifier).to_json
      @slot_info[:all_languages_and_max_unit_array] = @slot_info[:coach].all_languages_and_max_unit_hash.to_json
    end
    @slot_info[:recurring_default_value] =  (@slot_info[:coach].qualifications.size > 1) ? false : (!@slot_info[:recurring_not_allowed] && @slot_info[:availability])
    render(:partial => "create_session_form_in_coach_scheduler")
  end
  
  def check_recurrings_for_totale_coaches(crs, udt)
    if crs
      if @slot_info[:availability] && udt.blank? && @slot_info[:coach].session_cancelled_at_eschool?(@slot_info[:start_time]).blank?
        @slot_info[:error_message] = "The Coach has a recurring #{crs.appointment? ? 'appointment': 'session'} in #{crs.display_name_in_upcoming_classes}. #{TimeUtils.beginning_of_week(@slot_info[:start_time]) <= crs.language.last_pushed_week ? 'It will be displayed once the schedule is pushed for this week.' : ''}".squeeze(' ')
      else
        @slot_info[:recurring_not_allowed] = true
        @slot_info[:warning] = "This Coach is already scheduled to have a recurring session/appointment starting on the following week. You can only schedule a one-off session/appointment during this time."
      end
    end
  end
  
  def check_recurrings_for_aria_coaches(crs, crs2, udt, udt2)
    if crs && crs.language.is_one_hour? && crs.recurring_type != 'recurring_appointment'
      if @slot_info[:availability] && udt.blank? && udt2.blank? && !@slot_info[:session_on_other_half] && @slot_info[:coach].session_cancelled_at_eschool?(@slot_info[:start_time]).blank?
        @slot_info[:error_message] = "The Coach has a recurring #{crs.appointment? ? 'appointment': 'session'} in #{crs.display_name_in_upcoming_classes}. #{TimeUtils.beginning_of_week(@slot_info[:start_time]) <= crs.language.last_pushed_week ? 'It will be displayed once the schedule is pushed for this week.' : ''}".squeeze(' ')
      else
        @slot_info[:aria_recurring_not_allowed] = true
        @slot_info[:recurring_not_allowed] = true
        @slot_info[:warning] = "This Coach is already scheduled to have a recurring session/appointment starting on the following week. You can only schedule a one-off session/appointment during this time."
      end
    elsif crs
      if @slot_info[:availability] && udt.blank? && udt2.blank? && @slot_info[:coach].session_cancelled_at_eschool?(@slot_info[:start_time]).blank?
        @slot_info[:error_message] = "The Coach has a recurring #{crs.appointment? ? 'appointment': 'session'} in #{crs.display_name_in_upcoming_classes}. #{TimeUtils.beginning_of_week(@slot_info[:start_time]) <= crs.language.last_pushed_week ? 'It will be displayed once the schedule is pushed for this week.' : ''}".squeeze(' ')
      else
        @slot_info[:aria_recurring_not_allowed] = true
        @slot_info[:recurring_not_allowed] = true
        @slot_info[:warning] = "This Coach is already scheduled to have a recurring session/appointment starting on the following week. You can only schedule a one-off session/appointment during this time."
      end
    elsif (crs2 && crs2.language.is_one_hour? && crs2.recurring_type != 'recurring_appointment') #crs2.language.is_aria? is being checked so that session is allowed to create when crs2 is totale
      if @slot_info[:availability] && !@slot_info[:session_on_other_half] && udt.blank? && udt2.blank? && @slot_info[:coach].session_cancelled_at_eschool?(@slot_info[:start_time]).blank?
        @slot_info[:error_message] = "The Coach has a recurring #{crs2.appointment? ? 'appointment': 'session'} in #{crs2.display_name_in_upcoming_classes}. #{TimeUtils.beginning_of_week(@slot_info[:start_time]) <= crs2.language.last_pushed_week ? 'It will be displayed once the schedule is pushed for this week.' : ''}".squeeze(' ')
      else
        @slot_info[:aria_recurring_not_allowed] = true
        if !crs2 || crs2.language.is_one_hour?  # !crs2 is being checked to allow session creation on cancelled slot with recurring running.
          @slot_info[:recurring_not_allowed] = true
          @slot_info[:warning] = "This Coach is already scheduled to have a recurring session/appointment starting on the following week. You can only schedule a one-off session/appointment during this time."
        end
      end
    elsif (crs2 && (udt2.present? && crs2.recurring_type != 'recurring_appointment'))
      @slot_info[:aria_recurring_not_allowed] = true
      if !crs2 || crs2.language.is_one_hour?
        @slot_info[:recurring_not_allowed] = true
        @slot_info[:warning] = "This Coach is already scheduled to have a recurring session/appointment starting on the following week. You can only schedule a one-off session/appointment during this time."
      end
    end
  end
  
  def create_eschool_session_from_coach_scheduler
    @datetime = params[:start_time].to_time
    @new_language = Language.find_by_identifier(params[:language_id])
    @datetime -= 30.minutes if @datetime.min == 30 && @new_language.is_one_hour? && params[:session_type] != 'appointment'
    if @datetime >= TimeUtils.current_slot
      level_unit_lesson = {:lesson => params[:lesson], :unit => params[:unit], :level => params[:level]}
      level_unit_lesson[:lesson] = 4 if params[:lesson] == '--'
      level_unit_lesson.merge!(AppUtils.form_level_unit(params[:unit])) if !params[:lesson].blank? && params[:unit] != '--'
      @coach = Coach.find_by_id(params[:coach_id])
      @data = {
        :teacher => {:user_name => @coach.user_name},
        :teacher_id => @coach.id,
        :lang_identifier => @new_language.identifier,
        :wildcard => (level_unit_lesson[:unit] == '--').to_s,
        :level => level_unit_lesson[:level],
        :unit => level_unit_lesson[:unit],
        :lesson => level_unit_lesson[:lesson],
        :max_unit => @coach.qualification_for_language(@new_language.id).max_unit,
        :duration_in_seconds => @new_language.duration_in_seconds,
        :number_of_seats => params[:number_of_seats],
        :external_village_id => params[:village_id],
        :topic_id => params[:topic_id],
        :teacher_confirmed => params[:teacher_confirmed] == "true",
        :details => params[:session_details],
        :session_type => params[:session_type],        
        :appointment_type_id => params[:appointment_type_id]
      }
      if params["recurring"] == "true"
        if params[:availability] == 'unavailable'
          error = ""
          if @new_language.is_one_hour? && params[:session_type] == 'session'
            error += @coach.create_availability_for_slot(@datetime) unless @coach.having_availability_at?(@datetime)
            error += @coach.create_availability_for_slot(@datetime+30.minutes) unless !(error.blank? && !@coach.having_availability_at?(@datetime+30.minutes))
          else
            error += @coach.create_availability_for_slot(@datetime)
          end 
          if !error.blank?
            render :text => error, :status => 500 and return
          end
        end
        @data[:recurring_schedule_id] = create_recurring_schedule.id
      end
      @data[:start_time] = @datetime
      create_map = {:session => "ConfirmedSession", :appointment => "Appointment"}
      created_slot = create_map[params[:session_type].to_sym].constantize.create_one_off(@data)
      if created_slot.present?
        skipped = created_slot.create_sessions_till_last_pushed_week
        @coach.update_time_off(created_slot)
        response = {
          :is_appointment => created_slot.appointment? ? true : false,
          :start_time => created_slot.session_start_time,
          :second_slot_start_time => created_slot.session_start_time + 30.minutes, 
          :aria_session => created_slot.is_one_hour? ? true : false, 
          :end_time => created_slot.session_end_time,
          :label => created_slot.label_for_active_session
        }
        response[:message] = "#{created_slot.appointment? ? 'Appointment(s)' : 'Session(s)'} have been successfully created."
        response[:message] = response[:message] + " But some week(s) were skipped because of already scheduled or time-offed or non-availability." if skipped
        render :json => response, :status => 200
      else
        CoachRecurringSchedule.destroy(@data[:recurring_schedule_id]) if @data[:recurring_schedule_id].present?
        render :text => "Something went wrong. Please try again.", :status => 500
      end
    else
      render :text => "#{params[:session_type] == 'session' ? 'Session' : 'Appointment'} (s) can't be created for time passed.", :status => 500
    end
  end
  
  def coach_session_details     # to show session details in a popup on clicking a session-slot in coach-scheduler
    @is_coach = coach_logged_in?
    @assign_sub_link = true
    duration = GlobalSetting.find_by_attribute_name("allow_session_creation_after").attribute_value.to_i
    @coach = @is_coach ? current_user : Coach.find_by_id(params[:coach_id])
    if @coach
      @time = Time.at(params[:start_time].to_i).utc
      @coach_session = CoachSession.where(["coach_id = ? and session_start_time = ?", @coach.id, @time]).order("cancelled, id DESC").first
      @coach_session = @coach.check_previous_slot_for_session(@time) unless @coach_session
      if !@coach_session || @coach_session.is_cancelled?
        @substitution = Substitution.where(["substitutions.coach_id = ? and coach_sessions.session_start_time = ? and substitutions.grabbed = ?", @coach.id, @time, false]).joins("INNER JOIN coach_sessions on coach_sessions.id = substitutions.coach_session_id").last
        @substitution = @coach.check_previous_slot_for_substitution(@time) unless @substitution
        if @substitution
          sub_session = @substitution.coach_session
          if @coach_session && @coach_session != sub_session #To handle udt over cancel and vice versa
            @assign_sub_link = false  if (sub_session.created_at < @coach_session.created_at || !sub_session.is_substituted?)
          end 
          @coach_session = @substitution.coach_session
          @substituted = true
        end
      end
      if @coach_session
        @is_one_hour_session = @coach_session.is_one_hour?
        @selected_recurring = !@coach_session.recurring_schedule_id.blank?
        @coach_availability = @coach.is_availabile_at_slot?(@coach_session.session_start_time.utc)? 'available' : 'unavailable'
        (@coach_session.is_cancelled? || @substituted) ? (@create_button = true ) : (@editing_is_possible = true if (@coach_session.session_status == 1) && (!@coach_session.is_started? || (@coach_session.reflex? && !@coach_session.is_passed?) || (@coach_session.tmm? && !@coach_session.is_passed?))) #Editing is allowed till session end time only for switching reflex to totale
        @cancel_current_session = true if !@coach_session.is_cancelled? & @coach_session.totale? & @coach_session.is_started? & !@coach_session.is_passed?
        @session_details =  @coach_session.eschool_session if @coach_session.totale?
        @aria_session_details  = @coach_session.supersaas_session if @coach_session.aria?
        @tmm_session_details = @coach_session.supersaas_session if (@coach_session.tmm? && !@coach_session.tmm_live?) && !@coach_session.appointment?
        @create_button = false if @coach_session.is_passed? || (@coach_session.totale? & (Time.now.utc > @coach_session.session_start_time + duration.minutes)) || (@coach_session.reflex? && @coach_session.is_started?)
        if @session_details
          learners = @session_details.learner_details
          guids = @coach_session.is_passed? ? learners.collect{ |learner| learner.student_guid if learner.student_attended == "true"} : learners.collect{ |learner| learner.student_guid}
          @learner_details = Learner.find_all_by_guid(guids.compact)
          @launch_url = @session_details.launch_session_url if @coach_session.falls_under_20_mins?
          @sess_feedback = "http://studio.rosettastone.com/teachers/session/" + @session_details.eschool_session_id.to_s + "/student_attendance" if @coach_session.is_started?
        elsif @coach_session.supersaas?
          @learner_details = @coach_session.supersaas_learner
          if @aria_session_details
            #This is not very reliable
            @aria_session_details = @learner_details.empty? ? ["None"] : @learner_details.collect{|l| l[:full_name]}
            @aria_learner_guid = @learner_details.empty? ? ["None"] : @learner_details.collect{|l| l[:guid]}.first
            @conflict_session = @coach_session.supersaas_coach.first.try(:fetch,:email) != @coach_session.coach.try(:rs_email) unless @coach_session.is_substituted?
            @learner_level =  ((@coach_session.number_of_seats == 1)  ? (Callisto::Base.get_learner_level(@learner_details[0][:guid]) if !@learner_details.empty? ) : @coach_session.topic.cefr_level) || "N/A"
          elsif @tmm_session_details
            @tmm_description = @coach_session.fetch_supersaas_slot_description unless @learner_details.empty?
            if @coach_session.tmm? && !@coach_session.tmm_live?
              @phone_data = {
                :learner_name => @learner_details.collect{|l| l[:full_name]},
                :learner_guid => @learner_details.collect{|l| l[:guid]}.first,
                :topic => @tmm_description["s"]["t"],
                :learner_contact_type => ContactType[@tmm_description["l"].first["ml"]["t"]],
                :learner_contact_value => @tmm_description["l"].first["ml"]["v"],
                :learner_company => [@tmm_description["l"].first["ag"].to_s, @tmm_description["l"].first["org"].to_s].reject(&:empty?).join(' - ')
              } unless @learner_details.empty?
            end
            @conflict_session = @coach_session.supersaas_coach.first.try(:fetch,:guid) != @coach_session.coach.try(:coach_guid) unless @coach_session.is_substituted?
          else
            @conflict_session = (@coach_session.session_status == 1)
          end 
        else
          @launch_url = construct_url_for('KLE', CocomoConfig.url) if !@coach_session.is_cancelled? && !@substituted && !@coach_session.is_passed?
        end
      end
    end
  end
  
  def edit_session_for_coach    # To show edit session popup in cs
    @edit_data = {:coach_session => CoachSession.find_by_id(params[:coach_session_id])}
    @edit_data[:selected_recurring] = !@edit_data[:coach_session].recurring_schedule_id.blank?
    @edit_data[:is_availabile]  = CoachAvailability.for_coach_and_datetime(@edit_data[:coach_session].coach_id, @edit_data[:coach_session].session_start_time).blank? ? 'unavailable' : 'available'
    @edit_data[:aria_recurring_availability] = CoachAvailability.for_coach_and_datetime(@edit_data[:coach_session].coach_id, TimeUtils.return_other_half(@edit_data[:coach_session].session_start_time)).blank? ? 'unavailable' : 'available' if @edit_data[:coach_session].is_one_hour? #To disable recurring check box for aria when bottom half hour is unavailable     
    @edit_data[:recurring_ends_at] = @edit_data[:coach_session].coach_id && @edit_data[:selected_recurring] ? @edit_data[:coach_session].recurring_schedule.recurring_end_date : false
    @edit_data[:end_due_to_template] = @edit_data[:coach_session].coach ? @edit_data[:coach_session].coach.detect_availability_change_for_slot_in_future(@edit_data[:coach_session].session_start_time) : false
    @edit_data[:aria_end_due_to_template] = @edit_data[:coach_session].coach ? @edit_data[:coach_session].coach.detect_availability_change_for_slot_in_future(TimeUtils.return_other_half(@edit_data[:coach_session].session_start_time)) : false
    @edit_data[:session_details_text] = @edit_data[:coach_session].details if @edit_data[:coach_session].tmm?
    if @edit_data[:end_due_to_template] && @edit_data[:aria_end_due_to_template]
      @edit_data[:aria_end_due_to_template] = [@edit_data[:end_due_to_template],@edit_data[:aria_end_due_to_template]].min
    elsif @edit_data[:end_due_to_template]
      @edit_data[:aria_end_due_to_template] = @edit_data[:end_due_to_template]
    end
    crs = CoachRecurringSchedule.for_coach_and_datetime(@edit_data[:coach_session].coach_id, @edit_data[:coach_session].session_start_time.utc)
    @edit_data[:recurring_disabled] = ((crs.try(:id) == @edit_data[:coach_session].recurring_schedule_id) || crs.blank?) ? false : true
    if @edit_data[:coach_session].language.is_one_hour? && !@edit_data[:coach_session].appointment?
      crs2 = CoachRecurringSchedule.for_coach_and_datetime(@edit_data[:coach_session].coach_id, TimeUtils.return_other_half(@edit_data[:coach_session].session_start_time.utc))
      @edit_data[:recurring_disabled] ||= (crs2.blank?) ? false : true
    end
    if !@edit_data[:coach_session].reflex? && !@edit_data[:coach_session].tmm? && (eschool_session = @edit_data[:coach_session].eschool_session)
      @edit_data[:learners_signed_up] = eschool_session.learners_signed_up
      @edit_data[:wildcard_level_unit] = true
      if eschool_session.wildcard == "false" || (eschool_session.wildcard == "true" && eschool_session.wildcard_locked == "true")
        @edit_data[:wildcard_level_unit] = false
        if eschool_session.lesson.blank?
          @edit_data[:selected_language_level]  = eschool_session.level.to_i
          @edit_data[:selected_language_unit]   = eschool_session.unit.to_i
        else
          @edit_data[:selected_language_unit]   = CurriculumPoint.single_number_unit_from_level_and_unit(eschool_session.level.to_i, eschool_session.unit.to_i)
          @edit_data[:selected_language_lesson] = eschool_session.lesson.to_i
        end
      end
      @edit_data[:wildcard_disabled] = eschool_session.learners_signed_up.to_i > 0
      @edit_data[:unit_disabled] = eschool_session.wildcard == "true" || eschool_session.learners_signed_up.to_i > 0
      @edit_data[:selected_seats]      = eschool_session.number_of_seats.to_i
      @edit_data[:selected_village_id] = eschool_session.external_village_id.to_i
      @edit_data[:recurring_disabled] = true if @edit_data[:coach_session].recurring_schedule.try(:external_village_id)
    end
    if @edit_data[:coach_session].supersaas?
      @edit_data[:learners_signed_up] = @edit_data[:coach_session].supersaas_learner.size     
      @edit_data[:selected_seats] = @edit_data[:coach_session].number_of_seats.to_i
      if @edit_data[:selected_seats] > 1 && @edit_data[:coach_session].aria?
          topic = Topic.find_by_id(@edit_data[:coach_session].topic_id)
          @edit_data[:current_topic_id] = topic.id
          @edit_data[:current_cefr] = topic.cefr_level
      end
    end
    if @edit_data[:coach_session].tmm? && coach_logged_in? && !@edit_data[:coach_session].appointment?
      @edit_data[:recurring_disabled] = true
    end
  end
  
  def update_session_from_cs   # To update the editted session details
    @coach_session = CoachSession.find_by_id(params[:coach_session_id])
    @coach         = @coach_session.coach
    @datetime      = @coach_session.session_start_time.utc
    if params[:action_type] == "SAVE" || params[:action_type] == "SAVE ALL"
      @original_language = @coach_session.language
      @new_language      = Language.find_by_identifier(params[:language_id])
      level_unit = AppUtils.form_level_unit(params[:unit])
      lesson = (params[:wildcard] == "true") ? 4 : params[:lesson]
      @data = {
        :teacher => {:user_name => @coach.user_name},
        :teacher_id => @coach.id,
        :lang_identifier => params[:language_id],
        :wildcard => params[:wildcard],
        :level => level_unit[:level],
        :unit => level_unit[:unit],
        :lesson => lesson,
        :max_unit => @coach.qualification_for_language(@new_language.id).max_unit,
        :duration_in_seconds => @coach_session.duration_in_seconds,
        :number_of_seats => params[:number_of_seats] || 4,
        :external_village_id => params[:village_id],
        :teacher_confirmed => params[:teacher_confirmed] == "true",
        :topic_id => params[:topic_id],
        :start_time => @datetime,
        :session_details => params[:session_details],
        :session_type => params[:is_appointment] == "true" ? "appointment" : "session",
        :appointment_type_id => params[:appointment_type_id]
      }
    end
    case params[:action_type]
      when "SAVE"
        message = update_session_details
      when "SAVE ALL"
        message = update_session_details_with_recurrence
      when "CANCEL"
        res, learner, contact_info = @coach_session.cancel_and_stop_recurrence(false, params[:cancellation_reason])
        unless res
          message = "Session has been successfully cancelled in CSP, however an error prevented it from being cancelled in RSA.<p><div style=\"color:red;\">Please be sure to notify the learner: #{learner}, #{contact_info}.</div></p>"
        else
          message = "#{@coach_session.appointment? ? 'Appointment' : 'Session'} has been successfully #{@coach_session.reflex? ? "removed" : "cancelled"}."
        end
      when "CANCEL ALL"
        res, learner, contact_info = @coach_session.cancel_and_stop_recurrence(true, params[:cancellation_reason])
        unless res
          message = "Session and its recurrence have been successfully cancelled in CSP, however an error prevented the following session from being cancelled in RSA: <p>#{@coach_session.language.display_name} #{TimeUtils.time_in_user_zone(@datetime).strftime("%B %d, %Y %r")}</p><p><div style=\"color:red;\">Please be sure to notify the learner: #{learner}, #{contact_info}.</div></p>"
        else
          message = "#{@coach_session.appointment? ? 'Appointment' : 'Session'} and its recurrence have been successfully #{@coach_session.reflex? ? "removed" : "cancelled"}."
        end
    else
    end
    render :text => "An issue occurred when your edit was submitted to eSchool, and your changes were not saved. Please try again later, and contact the Help Desk if the issue persists.", :status => 500 and return if message == "An issue occurred when your edit was submitted to eSchool, and your changes were not saved. Please try again later, and contact the Help Desk if the issue persists."
    render :json => {:is_appointment => @coach_session.appointment?, :start_time => @coach_session.session_start_time, :end_time => @coach_session.session_end_time, :label => @coach_session.cancelled ? "Cancelled" : @coach_session.label_for_active_session , :message => message, :reassigned => @coach_session.reassigned, :one_hour_session => (@coach_session.is_one_hour?) ? true : false}, :status => 200
  end
 
  def export_schedules_in_csv
    start_date = Time.at(params[:start_date_to_export].to_i).utc
    start_date = [start_date, TimeUtils.current_slot(current_user.has_one_hour?) + current_user.duration_in_seconds].max
    end_date   = TimeUtils.end_of_week(start_date)
    if coach_logged_in?
      local_sessions      = LocalSession.edited_between_time_boundries(current_user.id, start_date, end_date).order(:session_start_time)
      confirmed_sessions  = ConfirmedSession.where("coach_id = ? and session_start_time >= ? and session_start_time < ? and cancelled = 0", current_user.id, start_date, end_date).order(:session_start_time)
      appointments        = Appointment.where("coach_id = ? and session_start_time >= ? and session_start_time < ? and cancelled = 0", current_user.id, start_date, end_date).order(:session_start_time)
      time_offs           = UnavailableDespiteTemplate.where("unavailability_type = 0 and approval_status = 1 and coach_id = ? and end_date > ? AND start_date < ? ", current_user.id, start_date, end_date).order(:start_date)
      csv_header          = ["Subject","Start Date","Start Time","End Date","End Time"]
      csv_content         = []
      (local_sessions + confirmed_sessions + appointments).each{|schedule|
        csv_content << [schedule.label_for_google_calendar, TimeUtils.format_time(schedule.session_start_time , "%m/%d/%y"), TimeUtils.format_time(schedule.session_start_time , "%I:%M:%S %p"), TimeUtils.format_time(schedule.session_end_time , "%m/%d/%y"), TimeUtils.format_time(schedule.session_end_time , "%I:%M:%S %p")]
      }
      time_offs.each{|time_off|
        time_off_start = trim_to_start_time(time_off.start_date, start_date)
        time_off_end = trim_to_end_time(time_off.end_date, end_date)
        csv_content << ["Time Off", TimeUtils.format_time(time_off_start , "%m/%d/%y"), TimeUtils.format_time(time_off_start , "%I:%M:%S %p"), TimeUtils.format_time(time_off_end , "%m/%d/%y"), TimeUtils.format_time(time_off_end , "%I:%M:%S %p")]
      }
      csv_generator = CsvGenerator.new(csv_header, csv_content)
      send_data(csv_generator.to_csv,:type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment", :filename => "Schedule_as_on_#{TimeUtils.time_in_user_zone(Time.now.utc).strftime("%m-%d-%y_%H-%M-%S")}.csv")
    else
      access_denied
    end
  end
 
  private
  
  def trim_to_start_time(time, start_time)
     return (time < start_time) ? start_time : time
  end

  def trim_to_end_time(time, end_time)
    return (time > end_time) ? (end_time + 1.minute) : time
  end

  def update_session_details
    error_msgs = ""
    if (@original_language != @new_language)
      @coach_session.cancel_or_subsitute_as_per_language(true)
      @coach_session = ConfirmedSession.create_one_off(@data)
      error_msgs = @coach_session.errors.full_messages.join(',') unless @coach_session.errors.blank?
    else
      session = @data.merge({:eschool_session_id => @coach_session.eschool_session_id, :coach_username => @coach.user_name})
      @data[:id] = @coach_session.eschool_session_id
      @data[:sessions] = [session]
      @data[:supersaas_check] = true
      @data, result, error_msgs = ExternalHandler::HandleSession.update_sessions(@original_language, @data, @coach_session)
      @coach_session.update_attributes({
          :language_identifier => @data[:lang_identifier],
          :external_village_id => @data[:external_village_id],
          :number_of_seats    => @data[:number_of_seats],
          :topic_id => @data[:topic_id],
          :recurring_schedule_id => nil
        }) if error_msgs.blank? && !@new_language.is_tmm?
      if (@new_language.is_tmm? || @new_language.is_tmm_michelin?)
        @coach_session.update_attributes({:recurring_schedule_id => nil}) unless (@coach_session.recurring_schedule && params[:recurring] == 'true')
        if !@coach_session.session_details.nil?
        @coach_session.session_details.update_attributes({
          :details => @data[:session_details]
          })
        else
          @coach_session.create_session_details(:details => @data[:session_details]) if @data[:session_details]
        end
      end
    end
    if (@coach_session.tmm? && !@coach_session.recurring_schedule) || !@coach_session.tmm?
      if error_msgs.blank? && params[:recurring] == 'true'
        if params[:availability] == "unavailable"
          if @new_language.is_one_hour? && !@coach_session.appointment?
              error_msgs += @coach.create_availability_for_slot(@datetime) unless @coach.having_availability_at?(@datetime)
              error_msgs += @coach.create_availability_for_slot(@datetime+30.minutes) unless !(error_msgs.blank? && !@coach.having_availability_at?(@datetime+30.minutes))
          else
              error_msgs += @coach.create_availability_for_slot(@datetime)
          end 
        end 
        if error_msgs.blank?
          previous_recurring = CoachRecurringSchedule.for_coach_and_datetime(@coach.id, @datetime)
          previous_recurring.update_attributes(:recurring_end_date => @datetime) if previous_recurring
          @data[:recurring_schedule_id] = create_recurring_schedule.id
          #rs_with_future_start_date_for_the_slot = @coach.get_recurring_schedules_for_after_datetime(datetime)# If there are any recurring schedules in the future for this slot, stop this new recurring as soon as it is created..What a waste!
          #new_recurring_schedule.update_attributes(:recurring_end_date => rs_with_future_start_date_for_the_slot.recurring_start_date) if rs_with_future_start_date_for_the_slot
          @coach_session.update_attribute(:recurring_schedule_id, @data[:recurring_schedule_id])
          skipped = @coach_session.create_sessions_till_last_pushed_week
        end
      end
    end  
    initialize_notice_and_error(error_msgs, skipped)
  end
  def update_session_details_with_recurrence
    error_msgs = ""
    @coach_session.stop_recurring
    @data[:external_village_id] = nil if @new_language.is_lotus?
    @data[:recurring_schedule_id] = (params[:recurring] == "true") ? create_recurring_schedule.id : nil
    all_sessions = @coach_session.future_recurring_sessions
    if (@original_language != @new_language)
      all_sessions.each do |coach_session|
        coach_session.cancel_or_subsitute_as_per_language(true)
      end
      @coach_session.cancel_or_subsitute_as_per_language(true)
      @coach_session = ConfirmedSession.create_one_off(@data)
      skipped = @coach_session.create_sessions_till_last_pushed_week
    else
      if !@data[:recurring_schedule_id]
        all_sessions.each do |coach_session|
          coach_session.cancel_or_subsitute!
        end
      end
      all_sessions << @coach_session
      if @original_language.is_totale? || @original_language.is_aria?
        session = @data.merge({:coach_username => @coach.user_name})
        @data[:sessions] = []
        all_sessions.each do |coach_session|
          session[:eschool_session_id] = coach_session.eschool_session_id
          session[:coach_username] = coach_session.coach.try(:user_name)
          session[:start_time]= coach_session.session_start_time.utc
          @data[:sessions] << session.clone
        end
        @data[:supersaas_check] = @data[:number_of_seats].to_i>1 && @data[:recurring_schedule_id] && @coach_session.learners_signed_up == 0
        @data, result, error_msgs = ExternalHandler::HandleSession.update_sessions(@original_language, @data, @coach_session)
      end
        
      if error_msgs.blank?
        all_sessions.each do |coach_session|
          coach_session.update_attributes({
              :language_identifier => @data[:lang_identifier],
              :external_village_id => coach_session.eschool_session.try(:learners_signed_up).to_i>0 ? coach_session.external_village_id : @data[:external_village_id],
              :number_of_seats    => @data[:number_of_seats],
              :recurring_schedule_id => @data[:recurring_schedule_id],
              :topic_id => coach_session.learners_signed_up > 0 ? coach_session.topic_id : @data[:topic_id]
            })
        end
        if @coach_session.tmm?
          if !@coach_session.session_details.nil?
            @coach_session.session_details.update_attributes({
              :details => @data[:session_details]
            })
          else
            @coach_session.create_session_details(:details => @data[:session_details]) if @data[:session_details]
          end
        end
      end
    end
    initialize_notice_and_error(error_msgs, skipped)
  end
  def initialize_notice_and_error(error_msgs, skipped)
    if error_msgs.blank?
      message =  "The changes you made were updated successfully."
      message = message + " But some week(s) were skipped because of already scheduled or time-offed or non-availability." if skipped
    else
      message  = error_msgs
    end
    message
  end
  def create_recurring_schedule
    CoachRecurringSchedule.create_for(@datetime, @coach.id, @new_language.id, @data[:number_of_seats], @data[:external_village_id], @data[:topic_id], @data[:session_type], @data[:appointment_type_id])
  end 
  
end
