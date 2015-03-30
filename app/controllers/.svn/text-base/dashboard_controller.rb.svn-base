require File.dirname(__FILE__) + '/../utils/dashboard_utils'
require File.dirname(__FILE__) + '/../utils/coach_availability_utils'

class DashboardController < ApplicationController
  layout 'dashboard'

  def index
    self.page_title = _("DashboardDE657D5B")
  end

  def filter_sessions
    support_language = params[:support_language_id]
    session_language = params[:session_language_id] == 'ADE' ? 'JLE,KLE' : params[:session_language_id]
    dashboard_values = DashboardUtils.calculate_dashboard_values(params[:session_start_time_id])
    page_number = params[:page_number] || 1
    row_count = params[:session_start_time_id] == "Live Now" ? 500 : App.total_dashboard_row_count
    get_non_assistable_sessions = params[:get_non_assistable_sessions] ? params[:get_non_assistable_sessions] : 'false'
    user = current_user
    begin
      if !["AEB","AUK","AUS"].include?(params[:session_language_id])
        sessions = ExternalHandler::HandleSession.dashboard_data(TotaleLanguage.first, {:dashboard_user_name => user.user_name, :records_per_page => row_count, :page_num => page_number,
          :start_time => dashboard_values[:start_time], :end_time => dashboard_values[:end_time], :session_language => session_language, :support_language => support_language,
          :native_language => user.native_language, :dashboard_future_session => dashboard_values[:future_session?], :get_non_assistable_sessions => get_non_assistable_sessions}) unless params[:session_language_id] == "JLE,KLE"
      else
        sessions = Eschool::Session.new("eschool_sessions" => [])
        sessions.eschool_sessions += fetch_aeb_sessions(dashboard_values[:start_time],dashboard_values[:end_time],params[:session_language_id], row_count, page_number.to_i) 
        if dashboard_values[:start_time] < Time.now.beginning_of_hour
          sessions.eschool_sessions = sessions.eschool_sessions.sort_by{|session| session.session_time.to_time}.reverse
        else
          sessions.eschool_sessions = sessions.eschool_sessions.sort_by{|session| session.session_time.to_time}
        end
      end
      unless sessions.blank?
        can_pull_more = sessions.eschool_sessions.size == row_count
        if(params[:session_start_time_id] == "Live Now")
          sessions = filter_completed_sessions(sessions)
        end
      
        sessions.eschool_sessions.collect do |session|
          populate_can_show_support_links_info(session)
          populate_audio_devices_and_links(session)
          populate_village_name(session)
          populate_attendance_url(session)
          filter_session_if_no_local_session(session)
          coach_show_time_for_cancelled_session(session) if session.teacher_first_seen_at.blank? && session.cancelled == "true"
        end
        render :json => {:sessions => sessions, :can_pull_more => can_pull_more}.to_json
      else
        render :text => 'There is some problem please try again.', :status => 503
      end
    rescue SocketError, Errno::ECONNREFUSED
      render :text => 'Eschool could not be reached', :status => 503
    end
  end

  def fetch_aeb_sessions(start_time, end_time, lang_identifier, row_count, page_number)
    aeb_sessions = []
    order = start_time < Time.now.beginning_of_hour ? "session_start_time DESC" : "session_start_time ASC"
    sessions = ConfirmedSession.all(:select => "coach_sessions.*",:conditions => ["language_identifier in (?) and eschool_session_id is not NULL and session_start_time >= ? and session_end_time <= ?", (lang_identifier == "AEB" ? ["AUS","AUK"] : lang_identifier), start_time.beginning_of_hour, end_time.beginning_of_hour + 1.hour], :limit => row_count, :offset => (page_number-1)*row_count, :order => order)
    # adobe_cookie = AdobeConnect::Base.one_time_login if !sessions.empty? and (end_time.beginning_of_hour + 1.hour) > Time.now and (start_time.beginning_of_hour) < Time.now
    if !sessions.empty? and (end_time.beginning_of_hour + 1.hour) > Time.now and (start_time.beginning_of_hour) < Time.now
      cookies[:adobe_cookie] = { :value => AdobeConnect::Base.one_time_login, :expires => Time.now + 1800 } unless cookies[:adobe_cookie]
    end
    sessions.each do |session|
      learners = session.cancelled ? [] : session.supersaas_learner #no info to fetch about learners for cancelled aeb sessions
      cefr = session.number_of_seats > 1 ? (" - " + session.topic.cefr_level) : "" 
      session_data = {    #for creating Eschool::Session::EschoolSession object
        "label"=>Language[session.language_identifier].display_name + cefr,
        "alerts"=>nil,
        "attendances"=>[],
        "session_id"=> session.eschool_session_id,
        "students_in_room_count"=>"0",
        "teacher_has_technical_problem"=>"false", #from help request db. "true" if yes
        "teacher"=> session.coach.try(:full_name),
        "session_time"=>session.session_start_time,
        "teacher_first_seen_at"=>nil, #from adobeconnect 
        "audio_device_status"=>"audio_input_device_unknown_device",
        "teacher_last_seen_at"=>nil,
        "students_attended_count"=>"0",
        "cancelled"=> session.cancelled ? "true" : "false",
        "attendances_count"=>learners.size,
        "class_status"=> "already_finished",
        "number_of_seats"=>session.number_of_seats,
        "aeb"=>"true",
        "needs_teacher_now" => nil
      }
      
      if (session.session_start_time > Time.now)
        session_data["class_status"] = "starts_in_future"
      elsif(session.session_end_time > Time.now)
        session_data["class_status"] = "in_progress"
        session_data["needs_teacher_now"] = "needs_teacher_now" if !session.coach_id.nil?
        session_data["teacher_has_technical_problem"] = "true" if session.help_requests.find_by_role("Coach")
      end  
      currently_in_room = []
      participants_hash = []

      if (session.falls_under_20_mins?) and session.coach_id #fetch info from adobe connect if session falls in 20 minutes
        #adobe - only fetch from adobe if the session is in Adobe Connect
        code, host_uri = learners.blank? ? [nil,nil] : BigBlueButton::Base.determine_server_host(learners.first[:guid],session.eschool_session_id)
        to_adobe = host_uri =~ /adobeconnect.com$/ ? true : false
        adobe_response = AdobeConnect::Base.users_in_meeting_logged_in(session.eschool_session_id,cookies[:adobe_cookie]) if cookies[:adobe_cookie] and (to_adobe or learners.blank?)
        if !adobe_response.nil?
          participants_hash = AdobeResponseParser.new(adobe_response).parse
          currently_in_room = participants_hash.select{|p| p[:'date-end'].nil?}
          session_data["teacher_first_seen_at"] = participants_hash.select{|d| d[:login] == session.coach.coach_guid}.sort_by{|d| d[:'date-created']}.first.try(:[],:'date-created')
          session_data["teacher_first_seen_at"] = DateTime.strptime(session_data["teacher_first_seen_at"],"%Y-%m-%dT%H:%M:%S.%L %z").utc.to_time if session_data["teacher_first_seen_at"]
          session_data["needs_teacher_now"] = nil
          if session_data["class_status"] == "in_progress"
            l_guids = learners.map{|learner| learner[:guid]}
            session_data["students_in_room_count"] = currently_in_room.select{|l| l_guids.include?(l[:login])}.count  #fetch learners count currently in player
            session_data["needs_teacher_now"] = currently_in_room.detect{|s| s[:login] == session.coach.coach_guid}.nil? ? "needs_teacher_now" : nil if session_data["teacher_first_seen_at"].nil? unless session.is_cancelled? #see if teacher has arrived unless cancelled         
          end
        elsif !to_adobe and !learners.blank?
          session_data["teacher_first_seen_at"] = "No Player Information"
          session_data["needs_teacher_now"] = nil
          session_data["students_in_room_count"] = "N/A"
        end
      end
      if !learners.blank?
        #compose learner hash and insert into attendances array for each learner signed up
        learners.each do |learner|
          learner_entry_detail = participants_hash.detect{|s| s[:login] == learner[:guid]} || {}
          learner_data = {
            "guid"=>learner[:guid],
            "student_id"=>learner_entry_detail["principal-id"],
            "student_in_room"=> currently_in_room.detect{|s| s[:login] == learner[:guid]}.nil? ? "false" : "true", #fetch this info
            "email"=>learner[:email],
            "audio_input_device_status"=>"NA", #not required
            "audio_output_device"=>nil, #not required
            "last_name"=>"", #only full name available
            "first_name"=>learner[:full_name], 
            "audio_input_device"=>nil, #not required
            "has_technical_problem"=> session.help_requests.find_by_user_id(learner_entry_detail["principal-id"]).nil? ? "false" : "true" #from CoachSession.HelpRequest
          }
          session_data["attendances"] << learner_data
        end
      end
      eschool_session = Eschool::Session::EschoolSession.new(session_data)
      aeb_sessions << eschool_session
    end
    aeb_sessions
  end
  def filter_completed_sessions(sessions)
    filtered_sessions = sessions.eschool_sessions.reject { |session| session.class_status == "already_finished" }
    sessions.eschool_sessions = filtered_sessions
    sessions
  end

  def filter_session_if_no_local_session(session)
    session.is_not_present_in_csp = (session.is_reflex == 'false' && CoachSession.find_all_by_eschool_session_id(session.session_id).blank?) ? 'true' : 'false'
  end
    
  def populate_village_name(session)
    begin
      if session.village_id != '-1'
        village_name = Community::Village.display_name(session.village_id)
        session.village_name = village_name.blank? ? "--" : village_name
      else
        session.village_name = "--"
      end
    rescue Exception
      session.village_name = "--"
    end
  end

  def populate_attendance_url(session)
    (can_show_sub_link? && session.cancelled != 'true') ? show_sub_link = 'true' : show_sub_link = 'false'
    session.attendances_url = learners_for_session_path(:id => session.session_id, :learners_info => true, :session_start_time => params[:session_start_time], :session_language => params[:session_language_id], :support_language_id => params[:support_language_id], :requested_page => params[:requested_page], :session_details=> session.session, :show_assist_link => show_sub_link, :get_attendance => true)
    session.learners_in_room_url = learners_for_session_path(:id => session.session_id, :learners_info => true, :session_start_time => params[:session_start_time], :session_language => params[:session_language_id], :support_language_id => params[:support_language_id], :requested_page => params[:requested_page], :session_details=> session.session, :show_assist_link => show_sub_link, :get_learners_in_room => true)
    session.is_reflex = ['JLE', 'KLE', 'BLE', 'CLE'].detect{|reflex_language| session.label.index(reflex_language)}.nil? ? "false" : "true"
  end

  def can_show_sub_link?()
    ((tier1_support_user_logged_in? && !tier1_support_lead_logged_in?)  && community_moderator_logged_in? || tier1_support_concierge_user_logged_in?)? "false" : "true"
  end

  def populate_audio_devices_and_links(session)
    session.audio = ''
    session.teacher_first_seen_at = get_teacher_first_seen_at(session)
    session.coach_id = session.teacher ? get_local_coach_id_for_eschool_session(session) : 'None'
    session.teacher = session.teacher ? session.teacher : 'Substitute Requested'
    unless session.attendances.detect {|att| att.has_technical_problem == "true"}.nil?
      session.show_warning = 'true'
      session.image_alt = _('Warning8FF3A55A')
      session.image_title = _('Learners_Need_Technical_SupportE874BBF4')
    end
    if session.cancelled == 'false'
      session.cancel_text = _('CANCELA6EE02F4')
      session.audio = get_audio_value(session) unless session.attendances.blank?
      session.view_link_text = _('View_only22EA6CC3')
      session.full_support_text = _('Full_Support19128DD2')
      session.assign_substitute_text = 'Assign a Substitute'
      session.request_substitute_text = 'Request a Substitute'
      session.can_view_full_support = session.can_assign_sub = is_it_moderator_or_concierge_user?() ? 'false' : 'true'
    else
      session.cancel_text = _("CANCELLEDBD37E528")
    end
  end

  def coach_show_time_for_cancelled_session(session)
    if (coach_session = CoachSession.find_by_eschool_session_id(session.session_id))
      udt = UnavailableDespiteTemplate.where("coach_id = ? and unavailability_type = 4 and coach_session_id = ?",coach_session.coach_id,coach_session.id).first
      session.teacher_first_seen_at = (udt.created_at > coach_session.session_start_time) ? (session.teacher_first_seen_at.blank? ? "Coach did not join session." : session.teacher_first_seen_at) : "" if udt
    end
  end

  def get_audio_value(session)
    
    if session.attendances.detect {|att| !att.audio_input_device.nil?}
      session_audio_device = session.audio_device_status
      if session_audio_device == 'audio_input_device_yellow'
        return 'Possible Problems'
      elsif session_audio_device == 'audio_input_device_red'
        return 'Known Problems'
      elsif session_audio_device == 'audio_input_device_unknown_device'
        return 'Unknown'
      else
        return ''
      end
    end
    return ''
  end

  def get_teacher_first_seen_at(session)
    session_teacher_first_seen_at = session.teacher_first_seen_at
    return session_teacher_first_seen_at if session_teacher_first_seen_at == "No Player Information"
    session_teacher_first_seen_at.blank? ? "" : TimeUtils.format_time(session_teacher_first_seen_at.to_time, "%a, %b %-d, %Y %I:%M %p (%Z)")
  end

  def populate_can_show_support_links_info(session)
    session_label = session.label
     session.session_time = session.session_time.to_time
      session.session = session_label + ", ID #{session.session_id} : " + TimeUtils.format_time(session.session_time, "%a, %b %e, %Y %I:%M %p (%Z)")
      if session.cancelled == 'false'
        is_session_live = (((Time.now.utc - session.session_time).to_i < 1.hour.to_i) && (Time.now.utc - session.session_time).to_i >= -20.minute.to_i)
        session.can_show_support_links = (is_session_live and session.teacher) ? 'true' : 'false'
      end
  end

  def is_it_moderator_or_concierge_user?
    community_moderator_logged_in? || tier1_support_concierge_user_logged_in?
  end

  def get_learners_for_session
    setup_data_for_learners
    render :template  => "dashboard/learner_list" , :layout => false
  end

  def support_language_code(language)
    SupportLanguage.language_code(language)
  end

  def fetch_aeb_first_seen_at
    #adobe - only fetch from adobe if the session is in Adobe Connect
    code, host_uri = params[:learner].blank? ? [nil,nil] : BigBlueButton::Base.determine_server_host(params[:learner],params[:session_id])
    to_adobe = host_uri.nil? || (host_uri =~ /adobeconnect.com$/)
    if to_adobe
      cookies[:adobe_cookie] = { :value => AdobeConnect::Base.one_time_login, :expires => Time.now + 1800 } unless cookies[:adobe_cookie]
      adobe_response = AdobeConnect::Base.users_in_meeting_logged_in(params[:session_id],cookies[:adobe_cookie])
      if adobe_response
        coach_guid= Coach.find(params[:coach_id]).coach_guid
        participants_hash = AdobeResponseParser.new(adobe_response).parse
        teacher_first_seen_at = participants_hash.select{|d| d[:login] == coach_guid}.sort_by{|d| d[:'date-created']}.first.try(:[],:'date-created')
        teacher_first_seen_at = DateTime.strptime(teacher_first_seen_at,"%Y-%m-%dT%H:%M:%S.%L %z").utc.to_time if teacher_first_seen_at
      end
      if teacher_first_seen_at.blank? && params[:cancelled] == "true"
        coach_session = CoachSession.find_by_eschool_session_id(params[:session_id])
        udt = UnavailableDespiteTemplate.where("coach_id = ? and unavailability_type = 4 and coach_session_id = ?",params[:coach_id],coach_session.id).first
        teacher_first_seen_at = (udt.created_at > coach_session.session_start_time) ? "Coach did not join session." : "" if udt
      elsif teacher_first_seen_at.blank?
        teacher_first_seen_at = "Coach did not join session." #coach did not join if time is blank and session is not cancelled
      end
    else
      teacher_first_seen_at = "No Information."
    end

    render :text => (teacher_first_seen_at.blank? || teacher_first_seen_at ==  "Coach did not join session." || teacher_first_seen_at ==  "No Information.") ? teacher_first_seen_at.to_s : TimeUtils.format_time(teacher_first_seen_at.to_time, "%a, %b %-d, %Y %I:%M %p (%Z)")
  end

  helper_method :support_language_code, :get_support_language_display_name

  private

  def set_current_status_for_learners(students,session_id)
    student_status_for_session = LearnerSupportStatus.for_session(session_id)
    students.each do |st|
      @status[st.student_guid] = 'CHECK_AUDIO_DEVICE' if (st.audio_input_device_status != "green" && st.audio_input_device_status != 'NA')
      student_status_for_session.each do |st_status|
        if st_status.guid == st.student_guid
          if ((Time.now.utc > (st_status.updated_at + 5.minutes).utc) && (st_status.status == "ASSISTED"))
            @status[st.student_guid] = 'SUPPORT_COMPLETED'
            begin
              ExternalHandler::HandleSession.set_has_technical_problem(TotaleLanguage.first, {:remote_session_id => session_id, :student_guid => st.student_guid, :has_technical_problem => 0}) #Updating the problem status on eSchool
            rescue ActiveResource::ResourceNotFound, ActiveResource::ServerError
              #Till eSchool fixes its validation on the attendance class, we need to handle the 500 exception like this
              []
            end
            LearnerSupportStatus.update_status_for_learner_in_a_session(session_id, st.student_guid, 'SUPPORT_COMPLETED')
          else
            @status[st.student_guid] = st_status.status
          end
          break
        end
      end
    end
  end

  def setup_data_for_learners
    @session_id = params[:id]
    @eschool_session = ExternalHandler::HandleSession.find_session(TotaleLanguage.first, {:id => @session_id}) if !["AEB","AUK","AUS"].include?(params[:session_language])
    if @eschool_session.nil? # nil means it is not an eschool session so compose one for AEB
      aeb_session = CoachSession.find_by_eschool_session_id(@session_id)
      currently_in_room = {}
      if !params[:get_learners_in_room].nil? and !aeb_session.nil? and aeb_session.session_end_time > Time.now
        #adobe_cookie = AdobeConnect::Base.one_time_login
        cookies[:adobe_cookie] = { :value => AdobeConnect::Base.one_time_login, :expires => Time.now + 1800 } unless cookies[:adobe_cookie]
        
        adobe_response = AdobeConnect::Base.users_in_meeting_logged_in(aeb_session.eschool_session_id,cookies[:adobe_cookie])
        participants_hash = adobe_response.nil? ? [] : AdobeResponseParser.new(adobe_response).parse
        currently_in_room = participants_hash.select{|p| p[:'date-end'].nil?}
      end
      learners = aeb_session.supersaas_learner
      session_data = {
        "teacher_arrived"=> currently_in_room.detect{|s| s[:login] == aeb_session.coach.try(:coach_guid)}.nil? ? "false" : "true" ,
        "teacher_confirmed"=>"true",
        "launch_session_url"=>"launchOnline('http://google.com')",
        "teacher"=>aeb_session.coach.try(:user_name),
        "start_time"=>aeb_session.session_start_time,
        "learners_signed_up"=>learners.size,
        "learner_details"=>[],
        "teacher_id"=>aeb_session.coach_id,
        "students_attended"=>"0",
        "duration_in_seconds"=>"3600",
        "eschool_session_id"=>@session_id,
        "language"=>aeb_session.language_identifier,
        "number_of_seats"=>aeb_session.number_of_seats,
        "cancelled"=>aeb_session.cancelled,
        "aeb"=>true
      }
      learners.each do |learner|
        current_learner = currently_in_room.detect{|s| s[:login] == learner[:guid]} || {}
        learner_data = {
          "user_agent"=>"NA", #NA
          "last_name"=>nil,
          "audio_input_device_status"=>"NA", #NA
          "preferred_name"=>learner[:full_name],
          "support_language_iso"=> nil, #NA - nil defaults to english
          "audio_output_device"=>nil, #NA
          "audio_input_device"=>nil, #NA
          "student_time_zone"=>nil, #NA
          "student_in_room"=> currently_in_room.detect{|s| s[:login] == learner[:guid]}.nil? ? "false" : "true", #from adobe_connect
          "has_technical_problem"=>aeb_session.help_requests.find_by_user_id(current_learner["principal-id"]).nil? ? "false" : "true", #from help request DB
          "student_email"=>learner[:email],
          "student_guid"=>learner[:guid],
          "first_name"=>learner[:full_name]
        }
        session_data["learner_details"] << learner_data
      end
      @eschool_session = Eschool::Session.new(session_data)
    end
    @students = @eschool_session.learner_details
    @students = remove_learners_not_in_room(@students) if params[:get_learners_in_room]
    @status = Hash.new(0)
    @language_hash ||= SupportLanguage.language_code_and_display_name_hash unless @students.blank?
    if !@students.empty?
      if !session[:filter_language].nil? && session[:filter_language] != 'None'
        language_name = SupportLanguage.find_by_language_code(session[:filter_language]).name
        @students.delete_if {|st| st.support_language_iso != language_name}
      end
      @students = set_current_status_for_learners(@students,@session_id) 
    end if !["AEB","AUK","AUS"].include?(params[:session_language]) #no need to handle/filter support language for AEB
  end

  def remove_learners_not_in_room(students)
    students.delete_if {|student| student_not_in_room(student) }
  end

  def student_not_in_room(student)
    begin
      !(student.student_in_room == "true")
    rescue
      true
    end
  end


  def get_local_coach_id_for_eschool_session(session)
    local_session = CoachSession.find_by_eschool_session_id(session.session_id)
    return CoachSession.find_by_eschool_session_id(session.session_id).coach.id unless(local_session.nil? or local_session.coach.blank?)
    return "None"
  end

  def authenticate
    access_denied if coach_logged_in?
  end

  def get_support_language_display_name(student)
    begin
      if student.support_language_iso.blank?
        return "English"
      else
        return @language_hash[student.support_language_iso]
      end
    rescue
      return "English"
    end
  end

  def get_session_time(session)
    session_start_time_str = session.session.split(': ')[1]
    DateTime.strptime(session_start_time_str ,"%a, %b %e, %Y %I:%M %p (%Z)").utc
  end

end