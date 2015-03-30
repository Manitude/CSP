class SupportUserPortal::EschoolSessionsController < ApplicationController

  def show
    @license_identifier     = params[:license_identifier]
    @level_string           = params[:level_string]
    @product_right_ends_at  = params[:product_right_ends_at]
    @guid                   = params[:guid]
    @lang_identifier        = params[:lang_identifier]
    @language               = Language.find_by_identifier(params[:lang_identifier]).display_name
    page_num                = params[:requested_page] ? params[:requested_page] : params[:current_page] ? params[:current_page] : 1
    @user                   = Community::User.find_by_guid(params[:guid])
    @village                = (@user && @user.village_id) ? Community::Village.display_name(@user.village_id) : "None"
    @show_solo_sessions     = params[:solo_available_from].present?
    @show_group_sessions    = params[:is_old_learner] || params[:group_available_from].present?
    language_display_name   = "SESSIONS"
    language_display_name   = "Available Sessions for #{@user.name}" if @user
    self.page_title         = language_display_name
    @learner_timezone       = @user.time_zone if @user
    process_level_string_and_village_ids
    number_of_seats = get_number_of_seats
    process_reload_url
    result_set = ExternalHandler::HandleSession.find_upcoming_sessions_for_language_and_levels(Language[params["lang_identifier"]], {:level_string => @level_string, :start_date => Time.now, :end_date => Time.parse(@product_right_ends_at), :page_num => page_num, :village_ids => @village_ids, :number_of_seats => number_of_seats})
    if result_set
      @eschool_sessions = result_set.eschool_sessions
      add_additional_info
      @pagination       = result_set.pagination if result_set.respond_to?(:pagination)
    end
    render :template  => '/support_user_portal/eschool_sessions/show_eschool_sessions'
  end

  def export_sessions_to_csv
    @license_identifier     = params[:license_identifier]
    @level_string           = params[:level_string]
    @product_right_ends_at  = params[:product_right_ends_at]
    @lang_identifier        = params[:lang_identifier]
    @user                   = Community::User.find_by_guid(params[:guid])
    @learner_timezone       = @user.time_zone if @user
    process_level_string_and_village_ids
    number_of_seats = get_number_of_seats
    result_set = ExternalHandler::HandleSession.find_upcoming_sessions_for_language_and_levels_without_pagination(Language[@lang_identifier], {:level_string => @level_string, :start_date => Time.now, :end_date => Time.parse(@product_right_ends_at), :page_num => 1, :village_ids => @village_ids, :number_of_seats => number_of_seats})
    @eschool_sessions =  result_set ? result_set.eschool_sessions : []
    add_additional_info
    csv_content = []
    @eschool_sessions.each do |es|
      csv_content << [ es.user_start_time, es.learner_start_time, es.level, es.unit,es.lesson, es.wildcard_display, es.teacher, es.filled_seats ]
    end
    csv_generator = CsvGenerator.new(
      ["Date & Time (#{ Time.now.in_time_zone(current_user.tzone).strftime("%Z")})", "Learner Date & Time (#{ Time.now.in_time_zone(@learner_timezone).strftime("%Z")})", 	'Level', 	'Unit', 'Lesson', 	'Wildcard?', 	'Coach', 	'Learners/Seats'],
      csv_content
    )
    send_data(csv_generator.to_csv,:type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment", :filename => "sessions.csv")
  end
  
  def show_attendances
    @license_identifier = params[:license_identifier]
    @session_id = params[:session_id]
    @lang_identifier = params[:lang_identifier]
    @level_string = params[:level_string]
    @product_right_ends_at = params[:product_right_ends_at]
    @current_page = params[:current_page]
    @session_details = params[:session_details]
    @learner = Learner.find_by_guid(params[:guid])    
    result_set = ExternalHandler::HandleSession.find_registered_and_unregistered_learners_for_session(Language[params["lang_identifier"]], {:session_id => @session_id, :class_id => params[:class_id], :email => @learner.email})
    if result_set
      @registered_learners = result_set.attendances
      @unregistered_learners = result_set.learner_list # ALL Learners eligible to register for the session
      @unregistered_learners.delete_if {|ul| ul.email != @learner.email} #deleting all the learners EXCEPT the current one
      @registered_learners.each {|rl| @unregistered_learners.delete_if {|ul| rl.email == ul.email} } #deleting the current learner if he is already registered
      wildcard_units=params[:wildcard_units]
      if wildcard_units && wildcard_units!=''
        @level_unit_options_for_select = []
        wildcard_units.split(',').each do |unit|
          level_unit = CurriculumPoint.level_and_unit_from_single_number_unit(unit)
          @level_unit_options_for_select << unit
        end
      else
        params[:single_number_unit] = CurriculumPoint.single_number_unit_from_level_and_unit(params[:level], params[:unit])
      end
    end
    render :partial => '/support_user_portal/eschool_sessions/attendances'
  end

  def add_student
    result = ExternalHandler::HandleSession.add_student_to_session(TotaleLanguage.first, {:session_id => params[:session_id], :unit => params[:unit], :lesson => params[:lesson], :student_id => params[:student_id], :one_on_one => params[:one_on_one]})
    if result
      result.message = ERRORCodes[result.message] ? ERRORCodes[result.message] : result.message
      if (result.status=='OK')
        eschool_session=ExternalHandler::HandleSession.find_session(TotaleLanguage.first, {:id => params[:session_id]})
        session_hash = ConfirmedSession.find_by_eschool_session_id(params[:session_id]).to_hash
        session_hash[:wildcard]="false"
        session_hash[:level]=eschool_session.level
        session_hash[:unit]=eschool_session.unit
        session_hash[:lesson]=eschool_session.lesson
        ExternalHandler::HandleSession.update_sessions(TotaleLanguage.first, {:sessions=>[session_hash]}, eschool_session)
        render :json => {:level => eschool_session.level, :unit => eschool_session.unit, :lesson => eschool_session.lesson, :message => result.message.capitalize}, :status => 200
      else
        render :status => 500, :text => result.message.capitalize
      end
    else
      render :status => 500, :text => "There is some problem, Please try again."
    end
  end

  def remove_student
    result = ExternalHandler::HandleSession.remove_student_from_session(TotaleLanguage.first, {:attendance_id => params[:attendance_id]})
    if result
      response = XmlSimple.xml_in(result.body, 'KeyAttr'=>'response')
      if response["status"][0] == 'OK'
        render :status => 200, :text => response["message"][0].capitalize
      else
        render :status => 500, :text =>  ERRORCodes[response["message"][0]] ? ERRORCodes[response["message"][0]].capitalize : response["message"][0].capitalize
      end
    else
      render :status => 500, :text => "Something went wrong, Please report this problem."
    end
  end

  private

  def authenticate
    access_denied unless tier1_user_logged_in?
  end

  def add_additional_info
    @eschool_sessions.each do |es|
      es.user_start_time   =  TimeUtils.format_time(es.start_time.to_time, "%m/%d/%y %I:%M %p")
      es.learner_start_time   =  es.start_time.to_time.in_time_zone(@learner_timezone).strftime("%m/%d/%y %I:%M %p")
      es.level = es.level_unit.split(" ")[1]
      es.unit = es.level_unit.split(" ")[3]
      es.lesson = es.level_unit.split(" ")[5]
      es.village_name = es.village_name ? es.village_name : "None"
      es.wildcard_display = "-"
      if(es.wildcard_units)
        level_unit_hash = CurriculumPoint.level_and_unit_from_single_number_unit(es.wildcard_units.split(",").last.to_i)
        es.wildcard_display = "Max L#{level_unit_hash[:level]}, U#{level_unit_hash[:unit]}, LE4"
      end
    end
  end

  def process_level_string_and_village_ids
    if @level_string.nil? || @level_string == ''
      content_range_array  = params[:content_range_array]
      level_array          = Array.new(0)
      content_range_array.each_with_index{ |item,index|
        level_array << index/4 if index%4 == 0 && item == 'true'
      }
      @level_string   = level_array.join(",")
    end
    @village_ids            = []
    @village_ids << @user.village_id if (@user && @user.village_id != nil)
  end
  def process_reload_url
    redirect_params = params.clone
    redirect_params.delete("classroom_type")
    redirect_params.delete("requested_page")
    @reload_url = eschool_sessions_path(redirect_params)
  end
  def get_number_of_seats
    if params[:classroom_type] == 'solo' && @show_solo_sessions
      return [1 , 4]
    elsif params[:classroom_type] == 'group' && @show_group_sessions
      return (2..10).entries
    else
      params[:classroom_type] = 'all'
      number_of_seats = (2..10).entries
      number_of_seats << 1 if @show_solo_sessions
      return number_of_seats
    end
  end
end
