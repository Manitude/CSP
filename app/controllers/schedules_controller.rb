require File.dirname(__FILE__) + '/../utils/coach_availability_utils'
require File.expand_path('../../utils/historical_count_finder', __FILE__)

class SchedulesController < ApplicationController

  layout 'schedules', :only => [:index, :language_schedules]

  def index
    self.page_title = "Master Scheduler"
    @data = {:week_extremes => TimeUtils.week_extremes_for_user, :default_language => current_user.languages.first.filter_name}
  end

  def language_schedules
    page_title = "Master Scheduler"
    @data = {:week_extremes => TimeUtils.week_extremes_for_user(params[:date])}
    @data[:default_language] = current_user.languages.first.filter_name
    @data[:language] = params[:language]
    language = Language.find_by_identifier(params[:language])
    if language
      @data[:default_language] = language.filter_name
      if (metadata = language.locked?)
        @data[:is_locked] = true
        populate_push_data_and_message(language)
        if metadata && metadata.total_sessions > 0
          if (language.is_lotus? or language.is_tmm?)
            session_creation_message = "Currently, schedules are being committed for this language. Out of #{metadata.total_sessions} schedules, #{metadata.completed_sessions}  have been committed."
          elsif language.is_aria?
            session_creation_message = "Currently, sessions are being pushed to SuperSaas for this language. Out of #{metadata.total_sessions} sessions, #{metadata.completed_sessions}  have been pushed."
          else
            session_creation_message = "Currently, sessions are being pushed to eschool for this language. Out of #{metadata.total_sessions} sessions, #{metadata.completed_sessions}  have been pushed."
          end
        end
        @data[:push_status_message] = session_creation_message ? session_creation_message : (language.is_lotus? ? "There are sessions actively being created for this language. Please try again shortly. " : "There are sessions being pushed to eschool for this language. Please try again once this process has completed." )
      else
        @data[:classroom_type] = params[:classroom_type]
        @data[:village] = (params[:village] == "all" || params[:village] == "none" || !Community::Village.find_by_id(params[:village]).blank?) ? params[:village] : 'all'
        @data[:removed_sessions] = 0
        @data[:new_sessions] = 0
        create_calender_and_populate_sessions(@data[:week_extremes][0].utc, @data[:week_extremes][1].utc, language)
        page_title = "Master Schedule - #{language.display_name}"
      end
    else
      redirect_to schedules_path
    end
    self.page_title = page_title
  end

  def create_calender_and_populate_sessions(start_time, end_time, language)
    languege_not_pushed = language.not_pushed?(start_time)
    @data.merge!({
        :start_of_current_week => TimeUtils.beginning_of_week_for_user,
        :sessions_in_present_week => 0,
        :last_pushed_week => language.last_pushed_week
      })

    six_weeks_check_from = [TimeUtils.beginning_of_week(@data[:last_pushed_week]), @data[:start_of_current_week].utc].max
    @data[:can_push_this_week] = ((@data[:classroom_type] == 'all' && @data[:village] == 'all') &&
        (start_time >= @data[:start_of_current_week].utc) && (start_time <= (six_weeks_check_from + MAX_WEEKS_TO_BE_PUSHED_AT_ONCE.weeks)))

    sessions_hash = Hash.new { |hash, key| hash[key] = {:sessions => [], :sessions_count => 0, :historical_sessions_count => 0,
        :type => 'normal', :recurring_sessions => [], :recurring_ids => [],
        :recurring_sessions_count => 0, :local_sessions_count => 0, :local_removed_count => 0, :local_edited_count => 0,:extra_session_count=>0,:substitution_count => 0} }
    if language.is_totale?
      session_slots = ExternalHandler::HandleSession.sessions_count_for_ms_week(language, {:start_time => start_time, :end_time => end_time, :language_identifier => language.identifier, :classroom_type => params[:classroom_type], :village_id => @data[:village], :handle_eschool_down => true}) || []
      if session_slots.is_a?(Hash) and session_slots[:connection_refused]
        flash[:error] = "Eschool is not reachable. Please try again."
        session_slots = []
      end
    else
      session_slots = CoachSession.sessions_count_for_ms_week(start_time, end_time, language.identifier, language.is_supersaas?, params[:classroom_type])
    end
    populate_confirmed_sessions(session_slots, sessions_hash, language)
    populate_recurring_sessions(start_time, end_time, language, sessions_hash, params[:classroom_type]) if languege_not_pushed
    local_sessions_count = populate_local_sessions(start_time, end_time, language, sessions_hash)
    @data[:can_push_this_week] = (@data[:can_push_this_week] && local_sessions_count > 0) unless languege_not_pushed
    @data[:sessions_in_historical_week] = HistoricalCountFinder.new.find(start_time, sessions_hash, @data[:language])
    include_dst_switch_slot(sessions_hash, start_time, end_time)
    @data[:sessions_hash] = sessions_hash.to_json.html_safe
  end

  def include_dst_switch_slot(sessions_hash, start_time, end_time)
    if TimeUtils.daylight_shift(start_time, end_time) == 1.hour
      session_to_update = sessions_hash[(start_time + 2.hours - 1.minute).to_i]
      session_to_update[:switch_to_dst] = true
      session_to_update[:end_time] = (start_time + 2.hours).to_i
    end
  end

  def populate_confirmed_sessions(session_slots, sessions_hash, language)
    session_slots = session_slots.reject {|slot| slot.sessions_count.to_i == 0 }
    session_slots.each do |slot|
      @data[:sessions_in_present_week] = @data[:sessions_in_present_week] + slot.sessions_count.to_i
      slot_to_update = sessions_hash[slot.slot_time.to_time.to_i]
      slot_to_update[:sessions_count] = slot.sessions_count.to_i
      if slot.sub_requested_count.to_i > 0
        extra_session_count = ExtraSession.get_extra_session_count_for_a_language_on_a_slot(slot.slot_time.to_time, language.identifier)
        if extra_session_count > 0
          slot_to_update[:extra_session_count] = extra_session_count
          slot_to_update[:type] = 'ExtraSession'
          @data[:sessions_in_present_week] -= extra_session_count
        end
        slot_to_update[:substitution_count] = slot.sub_requested_count.to_i - extra_session_count
        slot_to_update[:sub_needed] = true
      end
      slot_to_update[:emergency_session_present] = true if language.is_supersaas? && slot.emergency_session_count > 0
      slot_to_update[:pushed_to_eschool] = true
      slot_to_update[:end_time] = (slot.slot_time.to_time + language.duration_in_seconds - 1.minute).to_i
    end
  end

  def populate_local_sessions(start_time, end_time, language, sessions_hash)
    local_sessions = LocalSession.find_for(start_time, end_time, language.identifier, params[:classroom_type],@data[:village])
    removed_sessions_count = 0
    locally_edited_counts = 0
    local_sessions.each do |session|
      session_to_update = sessions_hash[session.session_start_time.to_i]
      session_to_update[:end_time] = (session.session_end_time - 1.minute).to_i
      if session.session_metadata
        if session.session_metadata.recurring
          session_to_update[:type] = 'LocalRecurring'
          session_to_update[:recurring_sessions_count] = session_to_update[:recurring_sessions_count] + 1
        elsif  session.session_metadata.action == 'cancel' || session.session_metadata.action == 'delete'
          session_to_update[:type] = 'LocalCancelled'
          session_to_update[:local_removed_count] = session_to_update[:local_removed_count] + 1
          removed_sessions_count = removed_sessions_count + 1
        elsif session.session_metadata.action == 'edit'
          locally_edited_counts = locally_edited_counts + 1
          session_to_update[:local_edited_count] = session_to_update[:local_edited_count] + 1
        else
          session_to_update[:type] = 'LocalSession'
          session_to_update[:local_sessions_count] = session_to_update[:local_sessions_count] + 1
        end
      end
      session_to_update[:pushed_to_eschool] = false
    end
    @data[:new_sessions] = @data[:new_sessions] + local_sessions.size - removed_sessions_count - locally_edited_counts
    @data[:removed_sessions] = removed_sessions_count
    (local_sessions.size + removed_sessions_count)
  end

  def populate_recurring_sessions(start_time, end_time, language, sessions_hash, classroom_type)
    recurring_sessions = CoachRecurringSchedule.fetch_for(start_time, end_time, language.id, @data[:village])
    recurring_sessions.reject!{|rs| rs.recurring_type == 'recurring_appointment'} #exclude appointment from MS
    @data[:new_sessions] = recurring_sessions.size
    if language.is_aria?
      if classroom_type == 'solo'
        recurring_sessions = recurring_sessions.select {|session| session.number_of_seats == 1 || session.number_of_seats.nil? }
      elsif classroom_type == 'group'
        recurring_sessions = recurring_sessions.select {|session| !session.number_of_seats.nil? && session.number_of_seats > 1 }
      end
    else
      if classroom_type == 'solo'
        recurring_sessions = recurring_sessions.select {|session| session.number_of_seats == 1}
      elsif classroom_type == 'group'
        recurring_sessions = recurring_sessions.select {|session| session.number_of_seats > 1 && session.number_of_seats != 4}
      end
    end

    recurring_sessions.each do |session|
      recurring_start_time = session.scheduled_time
      session_to_update = sessions_hash[recurring_start_time.to_i]
      session_to_update[:end_time] = (recurring_start_time + language.duration_in_seconds - 1.minute).to_i
      session_to_update[:type] = 'RecurringSession'
      session_to_update[:recurring_sessions] << {:session_start_time => recurring_start_time}
      session_to_update[:recurring_sessions_count] = session_to_update[:recurring_sessions_count] + 1
      session_to_update[:recurring_ids] << session.id
    end
  end

  def coach_availability_for_week
    coach = Coach.find_by_id(params[:coach])
    @session_details = coach.availlbility_for_week(params[:date],params[:language]) if coach
  end

  def slot_info
    @slot_info = {
      :language_id => params[:language_id],
      :village_id => params[:village_id],
      :session_start_time => Time.at(params[:start_time].to_i/1000).utc,
    }
    language = Language[params[:language_id]]
    if language.is_lotus?
      slot_info_lotus(language, params)
    elsif language.is_totale?
      slot_info_totale(language, params)
    elsif language.is_tmm_michelin?
      slot_info_tmm_michelin(language,params)
    elsif language.is_tmm_phone?
      slot_info_tmm_phone(language,params)
    elsif language.is_tmm?
      slot_info_tmm(language,params)
    else
      slot_info_aria(language, params)
    end
  end

  def extra_session_reflex
    language = Language.find_by_identifier(params[:language])
    @extra_session = {
      :coaches => language.coaches,
      :lang_id => language.id,
      :session_start_time => params[:start_time]
    }
    render :template => 'schedules/extra_session_popup_reflex'
  end

  def view_session_details #called from Lev/Unit/Village link in the MS slot info popup for Totale languages
    session_details = ExternalHandler::HandleSession.find_session(Language[params[:language_identifier]], {:id => params[:eschool_session_id]})
    if session_details
      coach_session = CoachSession.find_by_eschool_session_id(params[:eschool_session_id].to_i)
      coach_full_name = coach_session.coach ? coach_session.coach.full_name : "---"
      if session_details.start_time.to_time + session_details.duration_in_seconds.to_i.seconds < Time.now.utc
        learner_guids = session_details.learner_details.collect{ |learner| learner.student_guid }.compact
        status =  session_details.learner_details.collect{ |learner| learner.student_attended if learner.student_attended == "true"}.compact
        learner_text = "Learners Attended:"
        learner_text_no_learners = "No Learners Attended"
      else
        learner_guids = session_details.learner_details.collect{ |learner| learner.student_guid }
        status =  session_details.learner_details.collect{ |learner| learner.student_guid}
        learner_text = "Learners:"
        learner_text_no_learners = "No Learners have signed up."
      end
      level_unit = level_unit_label(coach_session)
      learner_count = learner_guids.size
      learner_details = Learner.find_all_by_guid(learner_guids)

      @session_details = {
        :level_unit => level_unit,
        :coach_full_name => coach_full_name,
        :learner_count => learner_count,
        :learner_details => learner_details,
        :status => status,
        :session_details => session_details,
        :learner_text => learner_text,
        :start_time => params[:start_time],
        :learner_text_no_learners => learner_text_no_learners
      }
    end
  end

  def get_learner_info
    @learner_session_detail = ExternalHandler::HandleSession.find_session(Language[params[:language_identifier]], {:id => params[:id]})
    @learner_data = Learner.find(params[:learner_id])
    @time_zone = ""
    @languages = ""
    @learner_session_detail.learner_details.collect{|learner| @time_zone = learner.student_time_zone if learner.student_guid == @learner_data.guid}
    #@learner_session_detail.learner_details.collect{|learner| @languages = learner.student_language if learner.student_guid == @learner_data.guid}
  end

  def session_status(cs)
    cs.is_cancelled? ? "Cancelled" : (cs.coach.blank? ? 'Substitute required' : 'Active')
  end

  def create_session
    session_start_time = Time.at(params[:start_time].to_i/1000).utc
    language = Language.find_by_identifier(params[:lang_identifier])

    all_coaches = CoachAvailabilityUtils.eligible_alternate_coaches(session_start_time, language.id,0,30)
    if language.is_one_hour?
      additional_coaches  = CoachAvailabilityUtils.eligible_alternate_coaches(session_start_time + 30.minutes, language.id, 0, 30)
      unwanted_list = []
      # We are sorry for this :P the big calculation is to remove the coaches having session on either slots
      # first (na1 | na2) - (na1 & na2) is done to find the uncommon coaches between na1 and na2
      # Then the loop ignores the coach if he is present in either of the available list(a1 or a2)
      # unwanted list contains all the coaches who have a session on either slot and unavailability on the other half.
      # Hence we ignore those coaches from the union of unwanted lists. Happy coding >:D
      ((all_coaches[1] | additional_coaches[1])  - (all_coaches[1] & additional_coaches[1])).each do |ele|
        unwanted_list << ele if !(all_coaches[0] | additional_coaches[0]).include?(ele)
      end
      all_coaches[0] = all_coaches[0] & additional_coaches[0]
      all_coaches[1] =  (all_coaches[1] | additional_coaches[1]) - unwanted_list
    end
    datetime_in_user_timezone = TimeUtils.time_in_user_zone(session_start_time)
    @wc_release_date = AppUtils.wc_release_date
    @create_session = {
      :session_start_time => session_start_time,
      :session_in_maintenance_time => SupportWindow.session_in_maintenance_time?(datetime_in_user_timezone),
      :session_not_in_support_time => SupportWindow.falls_outside_tech_support_window?(datetime_in_user_timezone.hour),
      :ext_village_id => params[:ext_village_id],
      :language => Language.find_by_identifier(params[:lang_identifier]),
      :all_coaches => all_coaches,
      :is_emergency => (language.is_aria? && ((session_start_time - Time.now.utc)/1.hour < EMERGENCY_SESSION_LIMITATION[:aria]))
    }
    render :template => '/schedules/lotus_create_sessions_ms' if language.is_lotus?
  end

  def edit_session
    @wc_release_date = AppUtils.wc_release_date
    @edit_session = self.send("edit_#{params[:type].underscore}", params)
    @edit_session[:disable_village] = (params[:ext_village_id] != "all" || !@edit_session[:learners].blank?) if @edit_session[:language].is_totale?
    @current_topic = Topic.where("id = ?",@edit_session[:topic_id])
  end

  def check_recurrence_end_date
    coaches = Coach.find(params[:coach_id])
    slot_time = Time.at(params[:start_time].to_i).utc
    slot_length = Language[params[:lang_id]].duration if params[:lang_id]
    unless coaches.blank?
      if coaches.is_a?(Array)
        end_dates = []
        coaches.each do |coach|
          result = coach.detect_availability_change_for_slot_in_future(slot_time)
          result = coach.detect_availability_change_for_slot_in_future(slot_time + 30.minutes) if !result && slot_length == 60
          end_dates << { :coach_name => coach.full_name, :end_date => TimeUtils.time_in_user_zone(result).strftime("%m/%d/%Y") } if result
        end
        render :json => end_dates.to_json, :status => 200
      else
        result = coaches.detect_availability_change_for_slot_in_future(slot_time)
        result = coaches.detect_availability_change_for_slot_in_future(slot_time + 30.minutes) if !result && slot_length == 60
        render :text => (result ? TimeUtils.time_in_user_zone(result).strftime("%m/%d/%Y") : result.to_s), :status => 200
      end
    else
      render :text => "Something went wrong.", :status => 500 and return
    end
  end

  def save_local_session
    start_time = Time.at(params[:start_time].to_i).utc
    coach_id = params[:coach_id]
    language = Language.find_by_id(params[:lang_id])
    recurring = params[:recurring] == "true"
    response = {
      :start_time => start_time.to_i,
      :end_time => (start_time + language.duration_in_seconds).to_i,
      :message => 'false'
    }
    if language.is_lotus?
      coach_id = coach_id.join(',')
      conflicting_coaches = []
      coaches = Coach.find_all_by_id(coach_id.scan( /\d+/ ))
      if recurring
        coaches.each do |coach|
            conflicting_coaches << coach.full_name if find_conflicting_sessions_till_last_pushed_week(start_time, language, coach)
        end
      end
      response[:recurring_count] = 0
      response[:new_count] = 0
      if conflicting_coaches.any?
        response[:message] = "#{conflicting_coaches.join(", ").reverse.sub(/,/, 'dna ').reverse} has conflicting sessions in future. " # we are leaving in memory of suman :)
      else
        coaches.each do |coach|
          recurring_flag = recurring && coach.having_availability_at?(start_time)
          if recurring_flag
            response[:recurring_count] += 1
          else
            response[:new_count] += 1
          end
          param = {
            :coach_id => coach.id,
            :session_start_time => start_time,
            :language_identifier => language.identifier,
            :recurring => recurring_flag,
          }
          LocalSession.create_one_off(param)
        end
      end
    else
      param = {
        :coach_id => coach_id,
        :number_of_seats => params[:number_of_seats],
        :single_number_unit => params[:single_number_unit],
        :external_village_id => params[:village_id],
        :session_start_time => start_time,
        :teacher_confirmed => params[:teacher_confirmed],
        :lessons => params[:lesson],
        :recurring => params[:recurring],
        :language_identifier => language.identifier,
        :topic_id => params[:topic_id],
        :details => params[:details].blank? ? nil : params[:details]
      }
      coach = Coach.find_by_id(coach_id)
      response[:message] = "#{coach.full_name} has conflicting sessions in future. " if recurring && find_conflicting_sessions_till_last_pushed_week(start_time, language, coach)
      LocalSession.create_one_off(param)
    end
    render :json => response, :status => 200
  end

  def save_extra_session
    start_time = Time.at(params[:start_time].to_i).utc
    language = Language.find_by_id(params[:lang_id])
    end_time = start_time + language.duration_in_seconds
    response = {:start_time => start_time.to_i, :end_time => end_time.to_i}
    if(language.is_lotus?)
      extra_session_params = {
        :start_time           => start_time,
        :end_time             => end_time,
        :name                 => params[:name],
        :lang_identifier      => language.identifier
      }

      ExtraSession.create_one_off_reflex(extra_session_params, params[:excluded_coaches].split(','))
      response[:message] = "Extra Session created successfully."
      render :json => response, :status => 200
    else
      if ( AppUtils.wc_release_date > start_time )
        level_unit = ( params[:wildcard] == "true") ? {} : { :unit => params[:unit], :level => params[:level] }
      else
        level_unit = (params[:wildcard] == "true") ? {} : AppUtils.form_level_unit( params[:unit] )
      end

      extra_session_params = {
        :level                => level_unit[:level],
        :unit                 => level_unit[:unit],
        :lesson               => (params[:lesson] == '--') ? 4 : params[:lesson],
        :number_of_seats      => params[:number_of_seats],
        :start_time           => start_time,
        :topic_id             => params[:topic_id],
        :name                 => params[:name],
        :duration_in_seconds  => language.duration_in_seconds,
        :lang_identifier      => Language.find_by_id(params[:lang_id]).identifier,
        :wildcard             => params[:wildcard],
        :external_village_id  => params[:village_id],
        :max_unit             => Language.find_by_id(params[:lang_id]).max_unit,
        :details              => params[:details]
      }
      result = ExtraSession.create_one_off(extra_session_params, params[:excluded_coaches])
      if result[:notice] == "Session was successfully created."
        response[:message] = "Extra Session created successfully."
        render :json => response, :status => 200
      else
        response[:message] = "Something went wrong. Please try again."
        render :json => response, :status => 200
      end
    end
  end

  def edit_extra_session
    extra_session = ExtraSession.find_by_eschool_session_id(params[:session_id])
    extra_session_map = {'TotaleLanguage' => 'totale', 'AriaLanguage' => 'aria', 'ReflexLanguage' => 'reflex', 'TMMPhoneLanguage' => 'tmm', 'TMMMichelinLanguage' => 'tmm'}
    @session_details = self.send("edit_extra_session_#{extra_session_map[extra_session.language.type]}")
  end

  def edit_extra_session_totale
    @wc_release_date = AppUtils.wc_release_date
    extra_session = ExtraSession.find_by_eschool_session_id(params[:session_id])
    eschool_session = extra_session.eschool_session
    single_number_unit = (eschool_session.wildcard == "true") ? eschool_session.wildcard_units.split(',').length : CurriculumPoint.single_number_unit_from_level_and_unit(eschool_session.level, eschool_session.unit)
    level_unit_lesson = (AppUtils.wc_release_date > extra_session.session_start_time) ? CurriculumPoint.level_and_unit_from_single_number_unit(single_number_unit) : {:unit => single_number_unit, :lesson => eschool_session.lesson}
    all_coaches = CoachAvailabilityUtils.eligible_alternate_coaches(extra_session.session_start_time, extra_session.language_id)
    @session_details = {
      :extra_session => extra_session,
      :coaches => all_coaches.flatten,
      :session_name => extra_session.name,
      :excluded_coaches => extra_session.excluded_coaches.collect{|coach| coach.id},
      :number_of_seats => eschool_session.number_of_seats,
      :ext_village_id => extra_session.external_village_id,
      :level => level_unit_lesson[:level],
      :unit => level_unit_lesson[:unit],
      :lesson => level_unit_lesson[:lesson],
      :wildcard => eschool_session.wildcard == "true",
      :session_id => extra_session.id,
      :type => "ExtraSession"
    }
    @session_details[:disable_village] = (params[:ext_village_id] != "all")
    render :template => 'schedules/edit_extra_session_totale.html.erb'
  end

  def edit_extra_session_reflex
    extra_session = ExtraSession.find_by_id(params[:coach_session_id])
    language = Language.find_by_identifier(extra_session.language_identifier)
    excluded_coaches = extra_session.excluded_coaches.collect{|coach| coach.id}
    @session_details={
      :extra_session => extra_session,
      :lang_id => language.id,
      :coaches => language.coaches,
      :excluded_coaches => excluded_coaches
    }
    render :template => 'schedules/edit_extra_session_reflex.html.erb'
  end

  def edit_extra_session_aria
    extra_session = ExtraSession.find_by_eschool_session_id(params[:session_id])
    all_coaches = CoachAvailabilityUtils.eligible_alternate_coaches(extra_session.session_start_time, extra_session.language_id)
    @session_details = {
      :extra_session => extra_session,
      :coaches => all_coaches.flatten,
      :session_name => extra_session.name,
      :excluded_coaches => extra_session.excluded_coaches.collect{|coach| coach.id},
      :number_of_seats => extra_session.number_of_seats,
      :topic_id => extra_session.topic_id,
      :session_id => extra_session.id,
      :language => extra_session.language,
      :learners_signed_up => extra_session.learners_signed_up,
      :type => "ExtraSession"
    }
    @current_topic = Topic.where("id = ?",@session_details[:topic_id])
    render :template => 'schedules/edit_extra_session_aria.html.erb'
  end

  def edit_extra_session_tmm
    extra_session = ExtraSession.find_by_eschool_session_id(params[:session_id])
    all_coaches = CoachAvailabilityUtils.eligible_alternate_coaches(extra_session.session_start_time, extra_session.language_id)
    @session_details = {
      :extra_session => extra_session,
      :coaches => all_coaches.flatten,
      :session_name => extra_session.name,
      :excluded_coaches => extra_session.excluded_coaches.collect{|coach| coach.id},
      :number_of_seats => extra_session.number_of_seats,
      :session_id => extra_session.id,
      :language => extra_session.language,
      :type => "ExtraSession",
      :details => extra_session.details
    }
    @current_topic = Topic.where("id = ?",@session_details[:topic_id])
    render :template => 'schedules/edit_extra_session_tmm.html.erb'
  end

  def edit_reflex_session_details #basically to assign substitute.
    session = CoachSession.find_by_id(params[:coach_session_id])
    all_coaches = CoachAvailabilityUtils.eligible_alternate_coaches(session.session_start_time, session.language_id)
    @session_details ={
      :coaches => all_coaches[0],
      :unavailable_coaches => all_coaches[1],
      :session_id => session.id
    }
  end

  def save_assign_sub
    coach_session = CoachSession.find_by_id(params[:session_id])
    if coach_session
      if coach_session.session_metadata.blank?
        SessionMetadata.create(:action => params[:action_type],:coach_session_id => coach_session.id,:coach_reassigned => true)
      else
        coach_session.session_metadata.update_attributes(:action => params[:action_type],:coach_reassigned => true)
      end
      if (coach_session.update_attribute(:coach_id ,params[:coach_id]) && coach_session.update_attribute(:type , params[:type]) )
        render :text => "OK", :status => 200
      else
        render :text=>"There is some error. Please try again.", :status => 500
      end
    else
      render :text=>"There is some error. Please try again.", :status => 500
    end
  end

  def remove_lotus_session
    coach_session = CoachSession.find_by_id(params[:coach_session_id])
    if coach_session
      coach_session.convert_to_local_session(params[:type], params[:action_type], params[:recurring])
      render :text => "removed", :status => 200
    else
      render :text=>"There is some error. Please try again.", :status => 500
    end
  end

  def delete_local_session
    if params[:recurring_session_id]
      CoachRecurringSchedule.update(params[:recurring_session_id].to_i, :recurring_end_date => Time.at(params[:date].to_i/1000) - 1.week)
    else
      LocalSession.destroy(params[:local_session_id].to_i)
    end
    render :text => "OK", :status => 200
  end

  def cancel_totale_session
    coach_session = CoachSession.find_by_id(params[:coach_session_id])
    if coach_session
      coach_session.cancel_totale_session(params[:type], params[:action_type], params[:cancellation_reason])
      text = (params[:type] == "ConfirmedSession") ? coach_session.coach ? "Active" : "Substitute required" : "cancelled"
      render :text => text , :status => 200
    else
      render :text=>"There is some error. Please try again.", :status => 500
    end
  end

  def update_extra_session_reflex
    extra_session = ExtraSession.find_by_id(params[:coach_session_id])
    extra_session.update_session_details(params[:name],nil,nil,nil,nil,params[:excluded_coaches])
    render :text => "Session updated successfully."
  end

  def push_sessions_to_eschool
    language = Language[params[:language_identifier]]
    unless language.locked? #LOCK THE PAGE DOWN BEFORE STARTING THE PROCESS
      start_of_week = TimeUtils.beginning_of_week(params[:start_time])
      scheduler_metadata = SchedulerMetadata.create(:locked => true, :lang_identifier => language.identifier, :start_of_week => start_of_week)
      scheduler_metadata.update_sessions_count
      Rails.logger.info "\n***************lock object created *******for lang #{language.identifier}.\n"
      b_task = BackgroundTask.create(:referer_id => scheduler_metadata.id, :triggered_by => current_user.user_name, :background_type => "MS Bulk Modification", :state => "Queued", :locked => true, :job_start_time => Time.now.utc, :message => "Task enqueued.")
      Delayed::Job.enqueue(PushToEschoolJob.new(b_task.id), 0)
    end
    redirect_to "/schedules/#{language.identifier}/all/#{params[:start_time].strip}/all"
  end

  def authenticate
    access_denied unless manager_logged_in?
  end

  def update_session
    self.send( "update_#{params["type"].tableize.singularize}", params )
  end

  def get_aeb_topics
    topics = Topic.display_filtered_topic(params[:cefr_level], params[:language])

    render :json => topics
  end

  private

  def edit_local_session(params)
    local_session = CoachSession.find(params[:session_id])
    coach = local_session.coach
    coach = Coach.find_by_id(local_session.session_metadata.new_coach_id) if !coach
    language = Language.find_by_identifier(local_session.language_identifier)
    details = (local_session.session_metadata && local_session.session_metadata.action == 'edit') ? local_session.session_metadata.details : local_session.details
    coach["max_unit"] = Coach.max_unit(coach.id, language.id)
    max_unit = coach.qualification_for_language(language.id).max_unit
    unit_value = local_session.single_number_unit || max_unit
    start_time = Time.at(params[:start_time].to_i/1000).utc
    level_unit_lesson = (AppUtils.wc_release_date > start_time) ? CurriculumPoint.level_and_unit_from_single_number_unit(unit_value) : {:unit => unit_value, :lesson => local_session.session_metadata.lessons}
    recurring_ends_at = (local_session.session_metadata.recurring && local_session.coach_id) ? local_session.coach.detect_availability_change_for_slot_in_future(local_session.session_start_time) : false
    eschool_session = local_session.eschool_session
    learners = eschool_session.try(:learner_details)
    wildcard_disabled = eschool_session.nil? ? false : eschool_session.learners_signed_up.to_i > 0
    unit_disabled = eschool_session.nil? ? local_session.single_number_unit.nil? : (eschool_session.wildcard == "true" || eschool_session.learners_signed_up.to_i > 0)
    {
      :session_start_time => start_time,
      :coaches            => local_session.eligible_alternate_coaches,
      :ext_village_id     => local_session.external_village_id,
      :no_of_seats        => local_session.number_of_seats,
      :recurring          => local_session.session_metadata.recurring ? true : false,
      :teacher_confirmed  => local_session.session_metadata.teacher_confirmed,
      :unit               => level_unit_lesson[:unit],
      :level              => level_unit_lesson[:level],
      :lesson             => level_unit_lesson[:lesson],
      :language           => local_session.language,
      :session_id         => local_session.id,
      :recurring_ends_at  => recurring_ends_at,
      :type               => "LocalSession",
      :topic_id           => local_session.session_metadata.topic_id,
      :details            => details,
      :wildcard           => local_session.single_number_unit ? false : true,
      :learners           => learners,
      :wildcard_disabled  => wildcard_disabled,
      :unit_disabled      => unit_disabled
    }
  end

  def edit_confirmed_session(params)
    confirmed_session = CoachSession.find_by_eschool_session_id(params[:session_id])
    confirmed_session = CoachSession.find(params[:coach_session_id]) unless confirmed_session
    start_time = Time.at(params[:start_time].to_i/1000).utc
    if(confirmed_session.class != LocalSession)
      if confirmed_session.language.is_totale?
        eschool_session = confirmed_session.eschool_session
        wildcard_disabled = eschool_session.nil? ? false : eschool_session.learners_signed_up.to_i > 0
        unit_disabled = eschool_session.nil? ? local_session.single_number_unit.nil? : (eschool_session.wildcard == "true" || eschool_session.learners_signed_up.to_i > 0)
        learners = eschool_session.learner_details
        single_number_unit = (eschool_session.wildcard == "false" || (eschool_session.wildcard == "true" && eschool_session.wildcard_locked == "true")) ? CurriculumPoint.single_number_unit_from_level_and_unit(eschool_session.level, eschool_session.unit) : eschool_session.wildcard_units.split(',').length
        level_unit_lesson = (AppUtils.wc_release_date > start_time) ? CurriculumPoint.level_and_unit_from_single_number_unit(single_number_unit) : {:unit => single_number_unit, :lesson => eschool_session.lesson}
        totale_session_hash = {
        :no_of_seats        => eschool_session.number_of_seats,
        :teacher_confirmed  => eschool_session.teacher_confirmed == "true"? true : false,
        :level              => level_unit_lesson[:level],
        :unit               => level_unit_lesson[:unit],
        :lesson             => level_unit_lesson[:lesson],
        :learners           => learners,
        :wildcard           => !(eschool_session.wildcard == "false" || (eschool_session.wildcard == "true" && eschool_session.wildcard_locked == "true")),
        :wildcard_disabled  => wildcard_disabled,
        :unit_disabled      => unit_disabled
        }
      end
      eligible_coaches = confirmed_session.eligible_alternate_coaches
      if confirmed_session.coach
        coach = confirmed_session.coach
        coach["max_unit"] = Coach.max_unit(confirmed_session.coach_id, confirmed_session.language.id)
        eligible_coaches[0] << coach
        Coach.sort_by_name(eligible_coaches[0])
      end
      recurring_ends_at = (!confirmed_session.recurring_schedule_id.blank? && confirmed_session.coach_id) ? confirmed_session.coach.detect_availability_change_for_slot_in_future(confirmed_session.session_start_time) : false
      session_hash = {
        :session_start_time => confirmed_session.session_start_time,
        :coaches            => eligible_coaches,
        :ext_village_id     => confirmed_session.external_village_id,
        :recurring          => !confirmed_session.recurring_schedule_id.blank?,
        :language           => confirmed_session.language,
        :session_id         => confirmed_session.id,
        :type               => "ConfirmedSession",
        :recurring_ends_at  => recurring_ends_at,
        :no_of_seats        => confirmed_session.number_of_seats,
        :topic_id           => confirmed_session.topic_id,
        :coach_id           => confirmed_session.coach_id ? confirmed_session.coach_id : 'Need A Substitute',
        :learners_signed_up => confirmed_session.learners_signed_up
      }
      session_hash[:details] = confirmed_session.details
      crs = CoachRecurringSchedule.for_coach_and_datetime(confirmed_session.coach_id, confirmed_session.session_start_time.utc)
      recurring_disable_condition_1 =  confirmed_session.recurring_schedule.try(:external_village_id) ? true : false
      recurring_disable_condition_2 =  (crs.blank? || (crs.try(:id) == confirmed_session.recurring_schedule_id) ) ? false : true
      session_hash[:recurring_disabled] = recurring_disable_condition_1 || recurring_disable_condition_2
      if confirmed_session.language.is_one_hour?
        crs2 = CoachRecurringSchedule.for_coach_and_datetime(confirmed_session.coach_id, TimeUtils.return_other_half(confirmed_session.session_start_time.utc))
        session_hash[:recurring_disabled] ||= (crs2.blank?) ? false : true
      end
      confirmed_session.language.is_totale? ? session_hash.merge(totale_session_hash) : session_hash
    else
      params[:session_id] = confirmed_session.id
      session = edit_local_session(params)
      session[:type] = "ConfirmedSession"
      session
    end
  end

  def edit_standard_local_session(params)
    recurring_schedule_id = params[:coach_session_id]
    start_time = Time.at(params[:start_time].to_i/1000).utc
    recurring_schedule = CoachRecurringSchedule.find_by_id(recurring_schedule_id)
    max_unit = Coach.max_unit(recurring_schedule.coach_id, recurring_schedule.language_id)
    level_unit_lesson = (AppUtils.wc_release_date > start_time) ? CurriculumPoint.level_and_unit_from_single_number_unit(max_unit) : {:unit => max_unit, :lesson => 4}
    {
      :session_start_time => start_time,
      :coaches            => [[recurring_schedule.coach],[]],
      :ext_village_id     => recurring_schedule.external_village_id,
      :recurring          => true,
      :teacher_confirmed  => true,
      :language           => Language.find_by_id(recurring_schedule.language_id),
      :type               => "StandardLocalSession",
      :level              => level_unit_lesson[:level],
      :unit               => level_unit_lesson[:unit],
      :lesson             => level_unit_lesson[:lesson],
      :session_id         => recurring_schedule.id,
      :no_of_seats        => recurring_schedule.number_of_seats,
      :topic_id           => recurring_schedule.topic_id
    }
  end

  def update_local_session(params)
    local_session = params[:type].constantize.find_by_id(params[:session_id])
    local_session.update_attributes(:number_of_seats => params[:number_of_seats],
      :single_number_unit => params[:single_number_unit], :external_village_id => params[:village_id])
    if local_session.details
      local_session.session_details.update_attributes(:details => params[:details])
    elsif (!params[:details].blank?)
      local_session.create_session_details(:details => params[:details])
    end

    local_session.session_metadata.update_attributes(:teacher_confirmed => params[:teacher_confirmed],
      :lessons => params[:lesson], :recurring => params[:recurring], :topic_id => params[:topic_id])
    render :text => "Updated Successfully"
  end

  def update_extra_session(params)
    extra_session = ExtraSession.find_by_id(params[:session_id])
    language = Language.find_by_identifier(params[:lang_id])
    if extra_session.session_start_time >= AppUtils.wc_release_date
      level_unit = AppUtils.form_level_unit(params[:unit])
      lesson = (params["wildcard"] == "true") ? 4 : params[:lesson]
    else
      lesson = nil
      level_unit = {:unit => params[:unit], :level => params[:level]}
    end
    return_params, result, message = ExternalHandler::HandleSession.update_sessions(language, {:sessions=>[{
            :eschool_session_id => extra_session.eschool_session_id,
            :coach_username => nil,
            :lang_identifier => language.identifier,
            :wildcard => params[:wildcard],
            :level => level_unit[:level],
            :unit => level_unit[:unit],
            :lesson => lesson,
            :max_unit => language.max_unit,
            :duration_in_seconds => SESSION_LENGTH_IN_SECS,
            :number_of_seats => params[:number_of_seats],
            :start_time => extra_session.session_start_time,
            :external_village_id => params[:village_id],
            :teacher_confirmed => nil,
            :topic_id => params[:topic_id],
            :details => params[:details].blank? ? nil : params[:details]
          }]}, extra_session)

    if !result.blank? && result.length > 0
      extra_session.update_session_details(params[:name],params[:number_of_seats],params[:level],params[:unit],params[:village_id],params[:excluded_coaches],params[:topic_id],params[:details])
      render :text => "Session details updated"
    else
      render :text => "An issue occurred when your edit was submitted to eSchool, and your changes were not saved. Please try again later, and contact the Help Desk if the issue persists."
    end
  end

  def update_standard_local_session(params)
    coach_recurring_schedule = CoachRecurringSchedule.find_by_id(params[:session_id])
    coach = coach_recurring_schedule.coach
    start_time = Time.at(params[:start_time].to_i/1000).utc
    session = LocalSession.create_one_off({
      :coach_id => coach.id,
      :number_of_seats => params[:number_of_seats],
      :single_number_unit => params[:single_number_unit],
      :external_village_id => params[:village_id],
      :session_start_time => start_time,
      :teacher_confirmed => params[:teacher_confirmed],
      :lessons => params[:lesson],
      :recurring => params[:recurring],
      :recurring_id => coach_recurring_schedule.id,
      :topic_id => params[:topic_id],
      :language_identifier => coach_recurring_schedule.language.identifier,
      :details => params[:details].blank? ? nil : params[:details]
    })
    render :text => session ? "Succefully Updated" : "An issue occurred when your edit was submitted to eSchool, and your changes were not saved. Please try again later, and contact the Help Desk if the issue persists."
  end

  def update_confirmed_session(params)
    edited_session = CoachSession.find_by_id(params[:session_id])
    edited_session.update_attributes(:external_village_id => params[:village_id],
      :single_number_unit => params[:single_number_unit],
      :number_of_seats => params[:number_of_seats])
    edited_session.type = "LocalSession"
    if edited_session.save
      if edited_session.substitution && !edited_session.substitution.grabbed && edited_session.substitution.coach_id.to_s == params[:coach_id]
        reassigned = edited_session.reassigned
      else
        reassigned = params[:reassigned]
      end
      edited_session.create_session_metadata({:teacher_confirmed => params[:teacher_confirmed],
        :lessons => params[:lesson],
        :recurring => params[:recurring], :topic_id => params[:topic_id],
        :details => params[:details].blank? ? nil : params[:details],
        :action => ((params[:update_one_session] == "true") ? "edit_one" : "edit_all"),
        :coach_reassigned => reassigned}.merge(edited_session.coach_id != params[:coach_id].to_i ? { :new_coach_id => params[:coach_id] } : {}))
      render :text => "Session details updated"
    else
      render :text => "An issue occurred when your edit was submitted, and your changes were not saved. Please try again later, and contact the Help Desk if the issue persists."
    end
  end

  def populate_push_data_and_message(language)
    if SchedulerMetadata.find_by_lang_identifier(language.identifier)
      scheduler_metadata = SchedulerMetadata.where("locked = 1")
      total_sessions = 0
      current_language_total_sessions = 0
      current_language_pushed_sessions = 0
      scheduler_metadata.each do |sm|
        total_sessions += sm.total_sessions.to_i
        if language.identifier == sm.lang_identifier
          current_language_total_sessions = sm.total_sessions.to_i
          current_language_pushed_sessions = sm.completed_sessions
        end
      end
      language_name = language.display_name
      sessions_pushed_text = language.is_lotus? || language.is_tmm? ? "#{language_name} sessions committed : #{current_language_pushed_sessions} " : "#{language_name} sessions Pushed : #{current_language_pushed_sessions} "
      sessions_in_queue_text = language.is_lotus? || language.is_tmm? ? "#{language_name} sessions in commit queue : #{current_language_total_sessions} " : language.is_aria? ? "#{language_name} sessions in SuperSaas queue : #{current_language_total_sessions} " : "#{language_name} sessions in eSchool queue : #{current_language_total_sessions} "
      total_sessions_in_queue_text = language.is_lotus? || language.is_tmm? ? "Total sessions in commit queue : #{total_sessions} " : language.is_aria? ?  "Total sessions in SuperSaas queue : #{total_sessions} " : "Total sessions in eSchool queue : #{total_sessions} "
      @data[:push_data_message] = "#{sessions_pushed_text}  |  #{sessions_in_queue_text}  |  #{total_sessions_in_queue_text}"
    end
  end

  def find_conflicting_sessions_till_last_pushed_week(datetime, language, coach)
    slot_time = TimeUtils.time_in_user_zone(datetime) + 7.days
    end_of_last_pushed_week = TimeUtils.end_of_week_for_user(language.last_pushed_week)
    while slot_time < end_of_last_pushed_week
      return true if coach.has_session_conflict?(slot_time, language) || coach.has_recurring_schedule_conflict?(slot_time.utc, language)
      slot_time += 7.days
    end
    return false
  end

  def slot_info_lotus(language, params)
    @slot_info[:shift_details] = actual_session_and_edited_lotus(language, params[:village_id], @slot_info[:session_start_time])
    @slot_info[:local_sessions] = local_session_and_recurring(language, params[:village_id], @slot_info[:session_start_time], params[:recurring_ids])
    render :template => 'schedules/slot_info_lotus.html.erb'
  end

  def slot_info_totale(language, params)
    @slot_info[:minutes_to_allow_session_creation] = GlobalSetting.find_by_attribute_name("allow_session_creation_before").attribute_value.to_i
    @slot_info[:session_in_maintenance_time] = SupportWindow.session_in_maintenance_time?(@slot_info[:session_start_time])
    @slot_info[:session_not_in_support_time] = SupportWindow.falls_outside_tech_support_window?(@slot_info[:session_start_time].hour)
    villages = Hash[Community::Village.all.collect{|village| [village.id, village.name]}]

    @slot_info[:local_sessions] = locally_created_session(@slot_info[:session_start_time], language, villages, params[:classroom_type], params[:village_id], params[:recurring_ids])
    @slot_info[:shift_details] = totale_pushed_session(@slot_info[:session_start_time], language, villages, params[:classroom_type], params[:village_id]) unless @slot_info[:eschool_down]
    render :template => 'schedules/slot_info.html.erb'
  end

  def slot_info_aria(language, params)
    @slot_info[:display_emergency_text] = false
    @slot_info[:minutes_to_allow_session_creation] = GlobalSetting.find_by_attribute_name("allow_session_creation_before").attribute_value.to_i
    @slot_info[:shift_details] = aria_pushed_session(language, params[:village_id], @slot_info[:session_start_time])
    @slot_info[:local_sessions] = local_session_and_recurring(language, params[:village_id], @slot_info[:session_start_time], params[:recurring_ids])
    render :template => 'schedules/slot_info_aria.html.erb'
  end

  def slot_info_tmm(language, params)
    @slot_info[:minutes_to_allow_session_creation] = GlobalSetting.find_by_attribute_name("allow_session_creation_before").attribute_value.to_i
    @slot_info[:shift_details] = actual_session_and_edited_tmm(language, params[:village_id], @slot_info[:session_start_time])
    @slot_info[:local_sessions] = local_session_and_recurring(language, params[:village_id], @slot_info[:session_start_time], params[:recurring_ids])
    render :template => 'schedules/slot_info_tmm.html.erb'
  end

  def slot_info_tmm_phone(language, params)
    @slot_info[:minutes_to_allow_session_creation] = GlobalSetting.find_by_attribute_name("allow_session_creation_before").attribute_value.to_i
    @slot_info[:shift_details]  = tmm_pushed_session(language, params[:village_id], @slot_info[:session_start_time])
    @slot_info[:local_sessions] = local_session_and_recurring(language, params[:village_id], @slot_info[:session_start_time], params[:recurring_ids])
    render :template => 'schedules/slot_info_tmm_phone.html.erb'
  end

  def slot_info_tmm_michelin(language, params)
    @slot_info[:display_emergency_text] = false
    @slot_info[:minutes_to_allow_session_creation] = GlobalSetting.find_by_attribute_name("allow_session_creation_before").attribute_value.to_i
    @slot_info[:shift_details]  = tmm_pushed_session(language, params[:village_id], @slot_info[:session_start_time])
    @slot_info[:local_sessions] = local_session_and_recurring(language, params[:village_id], @slot_info[:session_start_time], params[:recurring_ids])
    render :template => 'schedules/slot_info_tmm_michelin.html.erb'
  end

  def tmm_pushed_session(language, village_id, session_start_time)
    shift_details = []
    coach_sessions = CoachSession.get_sessions_for_language_village_and_time(language.identifier, session_start_time, village_id)
    coach_sessions += LocalSession.all_edited_and_cancelled(language.identifier, session_start_time, village_id)
    coach_sessions.each do |cs|
      recurring = cs.recurring_schedule
      calculated_end_date = cs.coach.detect_availability_change_for_slot_in_future(cs.session_start_time) if cs.coach
      if calculated_end_date && recurring
        recurring_ends_at =  recurring.try(:recurring_end_date) ? TimeUtils.time_in_user_zone([recurring.recurring_end_date,calculated_end_date].min).strftime("%m/%d/%Y") : (calculated_end_date).strftime("%m/%d/%Y")
      else
        recurring_ends_at =  recurring.try(:recurring_end_date) ? TimeUtils.time_in_user_zone(recurring.recurring_end_date).strftime("%m/%d/%Y") : "--"
      end
      recurring_ends_at = (TimeUtils.time_in_user_zone(cs.session_start_time).to_date <= recurring_ends_at.to_date) ? recurring_ends_at : "--" if recurring && recurring_ends_at != "--"
      # learner_level = Callisto::Base.get_learner_level(cs.supersaas_learner[0][:guid]) if !cs.supersaas_learner.empty? && cs.number_of_seats == 1
      # topic = cs.number_of_seats > 1 ? Topic.find(cs.session_metadata.try(:topic_id) || cs.topic_id) : nil
      learner_details = cs.supersaas_learner
      learner_count = learner_details.size
      tmm_topic = learner_details.empty? ? ["None"] : learner_details.collect{|l| l[:topic]}.first
      session = {
        :eschool_session_id   => cs.eschool_session_id,
        :details              => cs.details.blank? ? "--" : cs.details,
        :coach_session_id     => cs.id,
        :recurring_ends_at    => recurring_ends_at,
        :recurring            => recurring,
        :is_extra_session     => cs.is_a?(ExtraSession),
        :session_status       => cs.session_status,
        :number_of_seats      => cs.number_of_seats,
        :session_level        => (learner_details.empty? || cs.language.is_tmm_phone?)? "N/A" : "invalid",
        :is_recurring         => !cs.recurring_schedule_id.blank?
       }
      @slot_info[:display_emergency_text] ||= (cs.session_status == 0)
      session[:learner_count] = cs.is_cancelled? || cs.session_status == 0 ? 0 : learner_count
      # session[:classroom_type] = get_classroom_type(session[:number_of_seats], session[:learner_count], cs.aria?)
      if cs.is_a?LocalSession
        session[:status] = cs.session_metadata.action.camelize + "ed"
        session[:status] = "Edited" if session[:status].match("Edit")
        session[:status] = "Cancelled" if session[:status].match("Cancel")
        session[:type] = "LocalSession"
      else
        session[:status] = session_status(cs)
        session[:type] = "StandardSession"
      end

      if cs.coach.blank?
        sub = Substitution.where(["coach_session_id = ?", cs.id]).includes([:coach]).last
        if sub
          coach = sub.coach
          session[:status] = 'Sub requested - Cancelled' if sub.cancelled && cs.is_a?(ConfirmedSession)
        end
      else
        coach = cs.coach
      end
      if coach
        if cs.is_local_session? && (new_coach_id = cs.session_metadata.new_coach_id)
          session[:coach_full_name] = Coach.find_by_id(new_coach_id).full_name
          session[:coach_id] = new_coach_id
        else
          session[:coach_full_name] = coach.full_name
          session[:coach_id] = coach.id
        end
      end

      shift_details << session
    end
    get_shift_details_based_on_classroom_type(shift_details)
  end

  def aria_pushed_session(language, village_id, session_start_time)
    shift_details = []
    coach_sessions = CoachSession.get_sessions_for_language_village_and_time(language.identifier, session_start_time, village_id)
    coach_sessions += LocalSession.all_edited_and_cancelled(language.identifier, session_start_time, village_id)
    coach_sessions.each do |cs|
      recurring = cs.recurring_schedule
      calculated_end_date = cs.coach.detect_availability_change_for_slot_in_future(cs.session_start_time) if cs.coach
      if calculated_end_date && recurring
        recurring_ends_at =  recurring.try(:recurring_end_date) ? TimeUtils.time_in_user_zone([recurring.recurring_end_date,calculated_end_date].min).strftime("%m/%d/%Y") : (calculated_end_date).strftime("%m/%d/%Y")
      else
        recurring_ends_at =  recurring.try(:recurring_end_date) ? TimeUtils.time_in_user_zone(recurring.recurring_end_date).strftime("%m/%d/%Y") : "--"
      end
      recurring_ends_at = (TimeUtils.time_in_user_zone(cs.session_start_time).to_date <= recurring_ends_at.to_date) ? recurring_ends_at : "--" if recurring && recurring_ends_at != "--"
      learner_level = Callisto::Base.get_learner_level(cs.supersaas_learner[0][:guid]) if !cs.supersaas_learner.empty? && cs.number_of_seats == 1
      topic = (cs.number_of_seats >1 && (!cs.session_metadata.try(:topic_id).nil? || !cs.topic_id.nil?)) ? Topic.find(cs.session_metadata.try(:topic_id) || cs.topic_id) : nil
      session = {
        :eschool_session_id   => cs.eschool_session_id,
        :coach_session_id     => cs.id,
        :recurring_ends_at    => recurring_ends_at,
        :recurring            => recurring,
        :is_extra_session     => cs.is_a?(ExtraSession),
        :session_status       => cs.session_status,
        :learner_level        => learner_level || "N/A",
        :number_of_seats      => cs.number_of_seats,
        :session_level        => topic.try(:cefr_level) || "N/A",
        :is_recurring         => !cs.recurring_schedule_id.blank?,
        :is_confirmed         => cs.is_extra_session?

       }
      @slot_info[:display_emergency_text] ||= (cs.session_status == 0)
      session[:learner_count] = cs.is_cancelled? || cs.session_status == 0 ? 0 : cs.learners_signed_up
      session[:classroom_type] = get_classroom_type(session[:number_of_seats], session[:learner_count], cs.aria?)
      if cs.is_a?LocalSession
        session[:status] = cs.session_metadata.action.camelize + "ed"
        session[:status] = "Cancelled" if session[:status].match("Cancel")
        session[:status] = "Edited" if session[:status].match("Edit")
        session[:type] = "LocalSession"
      else
        session[:status] = session_status(cs)
        session[:type] = "StandardSession"
      end

      if cs.coach.blank?
        sub = Substitution.where(["coach_session_id = ?", cs.id]).includes([:coach]).last
        if sub
          coach = sub.coach
          session[:status] = 'Sub requested - Cancelled' if sub.cancelled && cs.is_a?(ConfirmedSession)
        end
      else
        coach = cs.coach
      end
      if coach
        if cs.is_local_session? && (new_coach_id = cs.session_metadata.new_coach_id)
          session[:coach_full_name] = Coach.find_by_id(new_coach_id).full_name
          session[:coach_id] = new_coach_id
        else
          session[:coach_full_name] = coach.full_name
          session[:coach_id] = coach.id
        end
      end

      shift_details << session
    end
    get_shift_details_based_on_classroom_type(shift_details)
  end

  def local_session_and_recurring(language, village_id, session_start_time, recurring_ids)
    local_session = []
    if language.not_pushed?(session_start_time)
      CoachRecurringSchedule.find_all_sessions_with_ids(recurring_ids).each do |recurring_session_obj|
        topic = (recurring_session_obj.language.is_aria? && recurring_session_obj.number_of_seats > 1 && !recurring_session_obj.topic_id.nil?) ? Topic.find(recurring_session_obj.topic_id) : nil
        recurring_end_date = recurring_session_obj.coach.detect_availability_change_for_slot_in_future(session_start_time)
        local_session << {
          :coach_full_name => recurring_session_obj.coach.full_name,
          :coach_id => recurring_session_obj.coach_id,
          :status => "Not Active-Recurring",
          :type => "StandardLocalSession",
          :session_id => recurring_session_obj.id,
          :recurring_ends_at    => recurring_end_date ? TimeUtils.time_in_user_zone(recurring_end_date).strftime("%m/%d/%Y") : "--" ,
          :session_level  => topic.try(:cefr_level) || "N/A",
          :classroom_type     => get_classroom_type(recurring_session_obj.number_of_seats, nil, recurring_session_obj.language.is_aria?),
          :number_of_seats => recurring_session_obj.number_of_seats,
          :language => recurring_session_obj.language.display_name,
          :dialect => recurring_session_obj.coach.qualification_for_language(recurring_session_obj.language_id).dialect.try(:name),
          :details => "N/A"
        }
      end
    end
    LocalSession.all_session_in_a_time_slot(session_start_time, language.identifier, village_id).each do |local_session_obj|
      topic = local_session_obj.language.is_aria? && local_session_obj.number_of_seats > 1 ? Topic.find(local_session_obj.session_metadata.topic_id) : nil
      recurring_end_date = (local_session_obj.coach && local_session_obj.session_metadata.recurring) ? local_session_obj.coach.detect_availability_change_for_slot_in_future(session_start_time) : false
      local_session << {
        :coach_full_name => local_session_obj.coach.full_name,
        :coach_id => local_session_obj.coach_id,
        :status => local_session_obj.session_metadata.recurring ? "Not Active-Recurring" : "Not Active",
        :type => "LocalSession",
        :session_id => local_session_obj.id,
        :recurring_ends_at    => recurring_end_date ? TimeUtils.time_in_user_zone(recurring_end_date).strftime("%m/%d/%Y") : "--" ,
        :session_level  => topic.try(:cefr_level) || "N/A",
        :classroom_type     => get_classroom_type(local_session_obj.number_of_seats, nil, local_session_obj.aria?),
        :number_of_seats => local_session_obj.number_of_seats,
        :language => local_session_obj.language.display_name,
        :dialect => local_session_obj.coach.qualification_for_language(local_session_obj.language_id).dialect.try(:name),
        :details => local_session_obj.details.blank? ? "--" : local_session_obj.details
      }
    end
    get_shift_details_based_on_classroom_type(local_session)
  end

  def actual_session_and_edited_lotus(language, village_id, session_start_time)
    shift_details = []
    coach_sessions = CoachSession.get_sessions_for_language_village_and_time(language.identifier, session_start_time, village_id)
    coach_sessions += LocalSession.all_edited_and_cancelled(language.identifier, session_start_time, village_id)
    coach_sessions.each do |cs|
      recurring = cs.recurring_schedule
      calculated_end_date = cs.coach.detect_availability_change_for_slot_in_future(cs.session_start_time) if cs.coach
      if calculated_end_date && recurring
        recurring_ends_at =  recurring.try(:recurring_end_date) ? TimeUtils.time_in_user_zone([recurring.recurring_end_date,calculated_end_date].min).strftime("%m/%d/%Y") : (calculated_end_date).strftime("%m/%d/%Y")
      else
        recurring_ends_at =  recurring.try(:recurring_end_date) ? TimeUtils.time_in_user_zone(recurring.recurring_end_date).strftime("%m/%d/%Y") : "--"
      end
      recurring_ends_at = (TimeUtils.time_in_user_zone(cs.session_start_time).to_date <= recurring_ends_at.to_date) ? recurring_ends_at : "--" if recurring && recurring_ends_at != "--"
      session = {
        :coach_session_id     => cs.id,
        :session_name         => cs.name,
        :recurring_ends_at    => recurring_ends_at,
        :recurring            => recurring,
        :remove_text          => "Remove",
        :status               => "Active",
        :is_recurring         => !cs.recurring_schedule_id.blank?
      }
      if cs.coach
        coach = cs.coach
        session[:coach_full_name] = coach.full_name
        session[:coach_id] = coach.id
      else
        session[:status] = "Substitute required"
      end

      if cs.is_a?(ExtraSession)
        session[:status] = "Extra Session"
        session[:recurring_text] = "Edit"
      elsif cs.is_a?(LocalSession)
        session[:color] = (cs.session_metadata.action == "delete" && !cs.session_metadata.recurring) ? "removed_session" : "remove_with_recurring"
        session[:remove_text] = "UnRemove" if cs.session_metadata.action == "delete"
        session[:recurring_text] = (cs.session_metadata.action == "edit") ? "Remove Recurrence":"Make Recurring"
      else
        session[:recurring_text] = session[:recurring] ? "Remove Recurrence" : "Make Recurring"
      end
      session[:status] = 'Cancelled' if cs.cancelled

      if session[:status] == 'Cancelled'  && !cs.is_a?(ExtraSession)
        sub = Substitution.where(["cancelled = ? AND coach_session_id = ?", true, cs.id]).includes([:coach]).last
        if sub
          session[:sub_req_coach] = sub.coach.full_name
          session[:status] = 'Sub requested - Cancelled'
          session[:sub_req_coach_id] = sub.coach.id
        end
      end

      shift_details << session
    end
    shift_details
  end

  def actual_session_and_edited_tmm(language, village_id, session_start_time)
    shift_details = []
    coach_sessions = CoachSession.get_sessions_for_language_village_and_time(language.identifier, session_start_time, village_id)
    coach_sessions += LocalSession.all_edited_and_cancelled(language.identifier, session_start_time, village_id)
    coach_sessions.each do |cs|
      recurring = cs.recurring_schedule
      calculated_end_date = cs.coach.detect_availability_change_for_slot_in_future(cs.session_start_time) if cs.coach
      if calculated_end_date && recurring
        recurring_ends_at =  recurring.try(:recurring_end_date) ? TimeUtils.time_in_user_zone([recurring.recurring_end_date,calculated_end_date].min).strftime("%m/%d/%Y") : (calculated_end_date).strftime("%m/%d/%Y")
      else
        recurring_ends_at =  recurring.try(:recurring_end_date) ? TimeUtils.time_in_user_zone(recurring.recurring_end_date).strftime("%m/%d/%Y") : "--"
      end
      recurring_ends_at = (TimeUtils.time_in_user_zone(cs.session_start_time).to_date <= recurring_ends_at.to_date) ? recurring_ends_at : "--" if recurring && recurring_ends_at != "--"
      session = {
        :coach_session_id     => cs.id,
        :session_name         => cs.name,
        :recurring_ends_at    => recurring_ends_at,
        :recurring            => recurring,
        :status               => "Active",
        :language             => cs.language.display_name,
        :is_recurring         => !cs.recurring_schedule_id.blank?
      }
      if cs.coach
        coach = cs.coach
        if cs.is_local_session? && (new_coach_id = cs.session_metadata.new_coach_id)
          new_coach = Coach.find_by_id(new_coach_id)
          session[:coach_full_name] = new_coach.full_name
          session[:coach_id] = new_coach_id
          session[:dialect] = new_coach.qualification_for_language(cs.language_id).dialect.try(:name)
        else
          session[:coach_full_name] = coach.full_name
          session[:coach_id] = coach.id
          session[:dialect] = coach.qualification_for_language(cs.language_id).dialect.try(:name)
        end
      else
        session[:dialect] = cs.substitution.coach.qualification_for_language(cs.language_id).dialect.try(:name)
        session[:status] = "Substitute required"
      end

      if cs.is_a?(LocalSession)
        session[:type] = "LocalSession"
        session[:status] = cs.session_metadata.action.camelize + "ed"
        session[:status] = "Cancelled" if session[:status].match("Cancel")
        session[:status] = "Edited" if session[:status].match("Edit")
      end
      session[:status] = 'Cancelled' if cs.cancelled

      if session[:status] == 'Cancelled'  && !cs.is_a?(ExtraSession)
        sub = Substitution.where(["cancelled = ? AND coach_session_id = ?", true, cs.id]).includes([:coach]).last
        if sub
          session[:sub_req_coach] = sub.coach.full_name
          session[:status] = 'Sub requested - Cancelled'
          session[:sub_req_coach_id] = sub.coach.id
        end
      end

      shift_details << session
    end
    shift_details
  end

  def totale_pushed_session(session_start_time, language, villages, classroom_type, village_id)
    shift_details = []
    coach_sessions = CoachSession.get_sessions_for_language_village_and_time(language.identifier, session_start_time, village_id)
    coach_sessions += LocalSession.all_edited_and_cancelled(language.identifier, session_start_time, village_id)
    es_hash = {}
    eschool_ids = coach_sessions.collect{|session| session.eschool_session_id}.compact
    unless eschool_ids.blank?
      es_sessions = ExternalHandler::HandleSession.find_sessions(language, {:ids => eschool_ids, :handle_eschool_down => true})
      if es_sessions.is_a?(Hash) && es_sessions[:connection_refused]
        @slot_info[:eschool_down] = true
      elsif !es_sessions.blank?
        es_sessions.each do |es|
          es_hash[es.eschool_session_id.to_i] = es
        end
      end
    end
    coach_sessions.each do |cs|
      cs.sess = es_hash[cs.eschool_session_id]
      recurring = cs.recurring_schedule
      calculated_end_date = cs.coach.detect_availability_change_for_slot_in_future(cs.session_start_time) if cs.coach
      if calculated_end_date && recurring
        recurring_ends_at =  recurring.try(:recurring_end_date) ? TimeUtils.time_in_user_zone([recurring.recurring_end_date,calculated_end_date].min).strftime("%m/%d/%Y") : (calculated_end_date).strftime("%m/%d/%Y")
      else
        recurring_ends_at =  recurring.try(:recurring_end_date) ? TimeUtils.time_in_user_zone(recurring.recurring_end_date).strftime("%m/%d/%Y") : "--"
      end
      recurring_ends_at = (TimeUtils.time_in_user_zone(cs.session_start_time).to_date <= recurring_ends_at.to_date) ? recurring_ends_at : "--" if recurring && recurring_ends_at != "--"

      session = {
        :learner_count            => cs.learners_signed_up,
        :eschool_session_id       => cs.eschool_session_id,
        :external_village_id      => cs.external_village_id,
        :village                  => villages[cs.external_village_id],
        :is_extra_session         => cs.is_a?(ExtraSession),
        :coach_session_id         => cs.id,
        :number_of_seats          => cs.number_of_seats,
        :recurring_ends_at        => recurring_ends_at,
        :is_recurring                => !cs.recurring_schedule_id.blank?
      }

      session[:classroom_type] = get_classroom_type(session[:number_of_seats], session[:learner_count], cs.aria?)

      if cs.is_a?LocalSession
        session[:status] = cs.session_metadata.action.camelize + "ed"
        session[:status] = "Cancelled" if session[:status].match("Cancel")
        session[:status] = "Edited" if session[:status].match("Edit")
        session[:level_unit_str] = level_unit_label_for_local_session(cs)
        session[:type] = "LocalSession"
        session[:teacher_confirmed] = cs.session_metadata.teacher_confirmed
      else
        session[:level_unit_str] = level_unit_label(cs)
        session[:teacher_confirmed] = cs.confirmed?
        session[:status] = session_status(cs)
        session[:type] = "StandardSession"
      end

      if cs.coach.blank?
        sub = Substitution.where(["coach_session_id = ?", cs.id]).includes([:coach]).last
        if sub
          coach = sub.coach
          session[:status] = 'Sub requested - Cancelled' if sub.cancelled && cs.is_a?(ConfirmedSession)
        end
      else
        coach = cs.coach
      end
      if coach
        if cs.is_local_session? && (new_coach_id = cs.session_metadata.new_coach_id)
          session[:coach_full_name] = Coach.find_by_id(new_coach_id).full_name
          session[:coach_id] = new_coach_id
        else
          session[:coach_full_name] = coach.full_name
          session[:coach_id] = coach.id
        end
      end

      shift_details << session
    end
    get_shift_details_based_on_classroom_type(shift_details)
  end

  def locally_created_session(session_start_time, language, villages, classroom_type, village_id, recurring_ids)
    local_sessions = []
    if language.not_pushed?(session_start_time)
      CoachRecurringSchedule.find_all_sessions_with_ids(recurring_ids).each do |recurring_session_obj|
        recurring_ends_at = recurring_session_obj.coach.detect_availability_change_for_slot_in_future(session_start_time)
        local_sessions << {
          :coach_full_name => recurring_session_obj.coach.full_name,
          :coach_id => recurring_session_obj.coach_id,
          :status => "Not Active-Recurring",
          :type => "StandardLocalSession",
          :level_unit_str => level_max_unit_for_recurring(recurring_session_obj ,session_start_time),
          :village => villages[recurring_session_obj.external_village_id],
          :session_id => recurring_session_obj.id,
          :number_of_seats => recurring_session_obj.number_of_seats,
          :classroom_type     => get_classroom_type(recurring_session_obj.number_of_seats, nil, recurring_session_obj.language.is_aria?),
          :recurring_ends_at => recurring_ends_at ? TimeUtils.time_in_user_zone(recurring_ends_at).strftime("%m/%d/%Y") : "--"
        }
      end
    end
    LocalSession.all_session_in_a_time_slot(session_start_time, language.identifier, village_id).each do |local_session_obj|
      recurring_ends_at = (local_session_obj.coach && local_session_obj.session_metadata.recurring) ? local_session_obj.coach.detect_availability_change_for_slot_in_future(session_start_time) : false
      local_sessions << {
        :coach_full_name => local_session_obj.coach.full_name,
        :coach_id => local_session_obj.coach_id,
        :status => local_session_obj.session_metadata.recurring ? "Not Active-Recurring" : "Not Active",
        :level_unit_str => level_unit_label_for_local_session(local_session_obj),
        :village => villages[local_session_obj.external_village_id],
        :type => "LocalSession",
        :session_id => local_session_obj.id,
        :number_of_seats => local_session_obj.number_of_seats,
        :classroom_type     => get_classroom_type(local_session_obj.number_of_seats, nil, local_session_obj.aria?),
        :recurring_ends_at => recurring_ends_at ? TimeUtils.time_in_user_zone(recurring_ends_at).strftime("%m/%d/%Y") : "--"
      }
    end
    get_shift_details_based_on_classroom_type(local_sessions)
  end

  def level_max_unit_for_recurring(recurring_session_obj, session_start_time)
    max_unit  = Coach.max_unit(recurring_session_obj.coach_id, recurring_session_obj.language_id)
    max_unit_string = "Max "
    if (AppUtils.wc_release_date > session_start_time)
      level_unit_info = CurriculumPoint.level_and_unit_from_single_number_unit(max_unit)
      max_unit_string += "L#{level_unit_info[:level]} U#{level_unit_info[:unit]}"
    else
      level_unit_info = {:level =>(Float(max_unit)/Float(4)).ceil, :unit => max_unit, :lesson => 4}
      max_unit_string += "L#{level_unit_info[:level]} U#{level_unit_info[:unit]} LE4"
    end
    max_unit_string
  end

  def level_unit_label_for_local_session(local_session_obj)
    max_unit            = local_session_obj.single_number_unit || Coach.max_unit(local_session_obj.coach_id, local_session_obj.language_id)
    level_unit_info     = CurriculumPoint.level_and_unit_from_single_number_unit(max_unit)
      ((local_session_obj.single_number_unit.blank? ?  "Max ":"")+
    ((AppUtils.wc_release_date >= local_session_obj.session_start_time) ?
      "L#{level_unit_info[:level]} U#{level_unit_info[:unit]}" : "L#{level_unit_info[:level]} U#{max_unit} LE#{local_session_obj.session_metadata.lessons}"))
  end

  def level_unit_label(session)

    eschool_session = session.eschool_session
    label = ''
    if eschool_session
      if eschool_session.wildcard == "false" || (eschool_session.wildcard == "true" && eschool_session.wildcard_locked == "true")
        single_number_unit = CurriculumPoint.single_number_unit_from_level_and_unit(eschool_session.level, eschool_session.unit)
        label += (eschool_session.start_time.to_time > AppUtils.wc_release_date) ?  "L#{eschool_session.level} U#{single_number_unit} LE#{eschool_session.lesson}" : "L#{eschool_session.level} U#{eschool_session.unit}"
     else
        units = eschool_session.wildcard_units.split(',')
        length =units.length.to_i
        label += (eschool_session.start_time.to_time > AppUtils.wc_release_date) ? "Max L#{((units[length-1].to_f)/4).ceil}- U#{length}-LE#{eschool_session.lesson}" : "Max L#{((units[length-1].to_f)/4).ceil}- U#{((((units[length -1].to_f)%4))==0)?4:((units[length -1].to_f)%4).ceil}"

      end
    else
      level_unit = CurriculumPoint.level_and_unit_from_single_number_unit(session.single_number_unit)
      if (session.session_start_time > AppUtils.wc_release_date)
        label += "L#{level_unit[:level]} U#{session.single_number_unit} LE#{4}"
      else
        label += "L#{level_unit[:level]} U#{level_unit[:unit]}"
      end
    end
    label

  end

  def get_number_of_seats(classroom_type)
    if classroom_type == "solo"
      no_of_seats = [1]
    elsif classroom_type == "group"
      no_of_seats = [2,3,5,6,7,8,9,10]
    else
      no_of_seats = (1..10).entries
    end
    return no_of_seats
  end

  def get_classroom_type(number_of_seats, learner_count = nil, is_aria = false)
    number_of_seats = number_of_seats.to_i
    if(number_of_seats == 1)
      "Solo"
    elsif(number_of_seats == 4 && learner_count.to_i == 0 && !is_aria)
      "Open"
    else
      "Group"
    end
  end

  def get_shift_details_based_on_classroom_type(shift_details)
    if(params["classroom_type"]=="all")
      shift_details
    elsif (params["classroom_type"].downcase == "solo")
      shift_details.select {|session| session[:classroom_type].downcase == "solo"}
    else (params["classroom_type"].downcase == "group")
      shift_details.select {|session| session[:classroom_type].downcase == "group"}
    end
  end
end
