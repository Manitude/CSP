require 'csv'
class ManagerPortalController < ApplicationController
  include ActionView::Helpers::TextHelper
  include ActionController::Streaming

  layout 'manager_portal', :except => [:inactivate_coach, :mail_template]

  def index
    redirect_to week_view_url
  end

  def sign_in_as_my_coach
    coach = Coach.find_by_id(params[:coach_id])
    redirect_to(view_coach_profiles_url, :notice => 'Coach not available') && return unless coach
    user = User.new(coach.user_name)
    user.groups = [AdGroup.coach]
    user.account_id = coach.id
    user.time_zone = session[:user].time_zone
    session[:super_user] = session[:user] # swap the users
    self.current_user = user
    redirect_to(my_schedule_url, :notice => "Signed in as #{coach.user_name}.")
  end

  # assigns and also reassigns coaches.
  def assign_coaches
    @coaches ||= Coach.orphaned_coaches
    @assigned_coaches = current_manager.coaches
    @coach_managers = CoachManager.find(:all)
    @other_managers   = CoachManager.other_managers(current_manager)
    if request.post? && params[:coach_manager]
      @coach_manager = @coach_managers.detect {|cm| cm.id == params[:coach_manager].to_i}
      @assigned_coaches = @coach_manager.coaches
      @other_managers = CoachManager.other_managers(@coach_manager)
    end
    if request.post? && params[:coach_ids] && (params[:manager_id].nil? || params[:manager_id].any?)
      manager_id = params[:manager_id] || current_manager.id
      coach_ids  = params[:coach_ids] || []
      coach_ids.each do |coach_id|
        coach = Coach[coach_id]
        coach.update_attribute(:manager_id, manager_id) && @coaches.delete(coach)
      end
      count = coach_ids.length
      response = Eschool::Coach.update_manager_for_coaches(coach_ids,manager_id)
      if response
        response_xml = REXML::Document.new response.read_body
        status = response_xml.elements.to_a( "//status" ).first.text
        if status == 'OK'
          flash.now[:notice] = 'Successfully assigned ' + pluralize(count, 'coach')
        else
          message = response_xml.elements.to_a( "//message" ).first.text
          flash.now[:error] = message
        end
      else
        flash.now[:error] = "There is some problem, Please try again."
      end
    end
  end

  def manage_languages
    all_langs = Language.all_sorted_by_name
    current_manager.languages.reload
    if request.post?
      lang_ids = params[:lang_ids] || []
      lang_ids.each do |lang_id|
        #Add Michelin to Manager qualifications if French Live is included
        current_manager.add_qualifications_for(Language['TMM-MCH-L'].id) if(Language.find_by_id(lang_id).identifier == 'TMM-FRA-L')
        current_manager.add_qualifications_for(lang_id)
      end
      current_manager.languages.reload # reload the list
      count = lang_ids.length
      response = Eschool::Coach.create_or_update_teacher_profile_with_multiple_qualifications(current_manager)
      if response
        response_xml = REXML::Document.new response.read_body
        status = response_xml.elements.to_a( "//status" ).first.text
        if status == 'OK'
          flash.now[:notice] = 'Successfully assigned ' + pluralize(count, 'language')
        else
          message = response_xml.elements.to_a( "//message" ).first.text
          flash.now[:error] = 'Managed languages not saved in eSchool.<br/>Error while saving in eSchool: '+message
        end
      else
        flash.now[:error] = "There is some problem, Please try again."
      end
    end
    #Remove Michelin from List of Assigned Languages
    @assigned_langs = current_manager.languages.sort_by(&:display_name).delete_if { |lang| lang.identifier=='TMM-MCH-L' }
    assigned_lang_ids = @assigned_langs.collect(&:id)
    @langs = all_langs.delete_if { |lang| assigned_lang_ids.include?(lang.id) || lang.identifier=='TMM-MCH-L' }
  end

  def remove_language
    qualification = current_manager.qualifications.find_by_language_id(params[:id].to_i)
    if qualification
      #If French Live is removed, Michelin is removed as well
      current_manager.qualifications.find_by_language_id(Language['TMM-MCH-L']).destroy if Language.find_by_id(params[:id].to_i).identifier == 'TMM-FRA-L'
      qualification.destroy
      response = Eschool::Coach.create_or_update_teacher_profile_with_multiple_qualifications(current_manager)
      if response
        response_xml = REXML::Document.new response.read_body
        status = response_xml.elements.to_a( "//status" ).first.text
        if status == 'OK'
          redirect_to manage_languages_url, :notice => "You have removed #{Language.find_by_id(params[:id].to_i).display_name} from your list of managed languages."
        else
          message = response_xml.elements.to_a( "//message" ).first.text
          redirect_to manage_languages_url, :error => "You have removed #{Language.find_by_id(params[:id].to_i).display_name} from your list of managed languages.</br>Change didnot get saved in eschool.Error while saving in eSchool: #{message}"
        end
      else
        redirect_to manage_languages_url, :error => "There is some problem, Please try again."
      end
    else
      redirect_to manage_languages_url, :error => "There is some problem, Please try again."
    end
  end

  def view_coach_profiles
    @coaches = Coach.all
    @coach = Coach.find_by_id(params[:coach_id])
    @locked = BackgroundTask.where(["referer_id = ? AND background_type = ? AND (state = ? OR state = ?) AND locked = ?", params[:coach_id], "Coach Activation", "Queued", "Started", true]).any?
  end

  def inactivate_coach
    bt = BackgroundTask.find(:all, :conditions => {:referer_id => params[:coach_id], :background_type => "Coach Activation", :state => "Queued", :locked => true}).any?
    b_task = BackgroundTask.create(:referer_id => params[:coach_id], :triggered_by => current_user.user_name, :background_type => "Coach Activation", :state => "Queued", :locked => true, :job_start_time => Time.now.utc, :message => "Task enqueued.") unless bt
    Delayed::Job.enqueue(CoachActivationJob.new(params[:coach_id],params[:check_box_value],current_user.user_name,b_task.id)) unless bt
    if bt
      render(:partial => "shared/coach_inactive", :locals =>{:succeeded => false, :coach_id => params[:coach_id], :message => 'Already Locked' })
    else
      render(:partial => "shared/coach_inactive", :locals =>{:succeeded => true, :coach_id => params[:coach_id]})
    end
  end

  def week_view
    path = "/coach_scheduler"
    if params[:lang_identifier]
      path += "/#{params[:lang_identifier]}"
      if params[:coach_id]
        path += "/#{params[:coach_id]}"
        if params[:filter_language]
          path += "/#{params[:filter_language]}"
          if params[:start_date]
            path += "/#{params[:start_date][0..9]}"
          end
        end
      end
    end
    redirect_to path
  end

  def mail_template
    @languages = Language.all_sorted_by_name.reject(&:is_tmm?).reject(&:is_lotus?)#reflex sunset for mail template
  end

  def fetch_mail_address
    languages = (params[:id] == "all")? nil : params[:id]
    current_slot = TimeUtils.current_slot
    if manager_logged_in?
      emails = CoachSession.find_coaches_between(current_slot, current_slot+1.hour, languages).collect(&:rs_email).uniq
      if ["all","AUK","AUS"].include?(params[:id])
        emails += CoachSession.find_aria_coaches_between(current_slot.beginning_of_hour, current_slot+1.hour, params[:id]).collect(&:rs_email)
        emails.uniq!
      end
    else
      emails = Coach.find_all_active_coaches(languages).collect(&:rs_email).uniq
    end
    render :text => emails.join(","), :status => 200
  end

  def send_mail_to_coaches
    subject = params[:subject]
    to = params[:to].split(/[\,]/).map(&:strip)
    body = params[:body]
    begin
      GeneralMailer.send_mail_to_coaches(subject,to,body).deliver
    rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
      redirect_to :back, :notice => 'We are sorry! An issue was encountered, and your email was not sent. Please try again'
      return
    end
     redirect_to :back, :notice => 'Your mail has been sent successfully !'
  end

  def notifications
    Ambient.init
    Ambient.current_user = session[:user]
    self.page_title = 'Notifications and Alerts'
    @notifications = current_manager.get_filtered_notifications(params)
    @coaches = Coach.where(:active => 1)
  end

  def scheduling_threshold
    result={}
    self.page_title = 'Manage Scheduling Thresholds'
      if params[:save_button] && params[:language_scheduling_threshold] && params[:language_scheduling_threshold][:language_id]
        if LanguageSchedulingThreshold.find_by_language_id(params[:language_scheduling_threshold][:language_id])
          @language_scheduling_threshold = LanguageSchedulingThreshold.find_by_language_id(params[:language_scheduling_threshold][:language_id])
          if @language_scheduling_threshold.update_attributes(params[:language_scheduling_threshold])
            flash[:notice] = "record successfully updated"
          else
             flash[:error] = @language_scheduling_threshold.errors.collect{|t| (t[0].gsub!('max_assignment','')||t[0].gsub!('max_grab','')||t[0].gsub!('hours_prior_to_sesssion_override','')); t[1].gsub!('is invalid',''); t.join(' ')}.join("<br/>» ")
          end
        else
          @language_scheduling_threshold= LanguageSchedulingThreshold.new(params[:language_scheduling_threshold])
         if @language_scheduling_threshold.save
           flash[:notice] = "record successfully created"
         end
        end
      elsif params[:language_id]
        if LanguageSchedulingThreshold.find_by_language_id(params[:language_id])
          @language_scheduling_threshold = LanguageSchedulingThreshold.find_by_language_id(params[:language_id])
          result[:max_assignment] = @language_scheduling_threshold.max_assignment
          result[:max_grab] = @language_scheduling_threshold.max_grab
          result[:hours_prior_to_sesssion_override] = @language_scheduling_threshold.hours_prior_to_sesssion_override
          render :json => result.to_json, :status => 200
        else
         render :text=>"empty", :status => 200
        end
      else
        @language_scheduling_threshold = LanguageSchedulingThreshold.new
      end
    @selection = current_manager.languages.sort_by(&:display_name)
  end


  def substitutions_report
    @substitutions_data = []
    @coach_array = []
    @lang_array = []
    @grabbed_at = []
    self.page_title = 'Substitutions Report'
    @bool = true
    @selection_language = "--"
    @selection_coach = "--"
    @grabber_coach = "--"
    @selection_duration = "--"
    @selection_grabbed_within = "Show All"
    @lang_array = Language.all_sorted_by_name
    @max_hour = MAX_SUBSTITUION_CUTOFF_HOUR

    if(params[:hidden_lang_id])
      lang_id = params[:hidden_lang_id]
      if (lang_id == "")
        @coach_array = Coach.find(:all)
      else
        @coach_array = Language.find_by_id(lang_id).coaches
      end
      Coach.sort_by_name(@coach_array)
      render(:update){|page| page.replace_html 'select_coach' , :partial => "shared/coach_drop_down_partial"}
    end

    if request.post?
      lang_id = params[:lang_id]
      coach_id = params[:coach_id]
      duration = params[:duration]
      start_date = params[:start_date]
      end_date = params[:end_date]
      grabber_coach_id = params[:grabber_coach_id]
      grabbed_within = params[:grabbed_within]
      if(!lang_id || lang_id == '')
        @coach_array = Coach.find(:all)
      else
        @coach_array = Language.find_by_id(lang_id).coaches
      end
      Coach.sort_by_name(@coach_array)

      substitutions = substitutions_report_query_method(lang_id,coach_id,duration,start_date,end_date,grabber_coach_id,grabbed_within,'none')
      if lang_id && (lang_id==lang_id.to_i.to_s)
        substitutions = substitutions.select{|sub| (sub.language.id.to_s == lang_id) && !sub.coach_session.appointment? } unless lang_id.blank?
      elsif lang_id
        substitutions = substitutions.select{|sub| (sub.language.alias_id.to_s == lang_id) && sub.coach_session.appointment? } unless lang_id.blank?
      end
      @substitutions_data = process_substitutions(substitutions)
      render(:update){|page| page.replace_html 'update_sub_report', :partial => "shared/substitutions_report_partial"} and return
    end
  end

  def export_to_csv
    lang_id = params[:lang_id_hidden]
    coach_id = params[:coach_id_hidden]
    duration = params[:duration_hidden]
    start_date = params[:start_date_hidden]
    end_date = params[:end_date_hidden]
    grabber_coach_id = params[:grabber_coach_id_hidden]
    grabbed_within = params[:grabbed_within_hidden]

    if(params[:send] == "true")
      substitutions = substitutions_report_query_method(lang_id,coach_id,duration,start_date,end_date,grabber_coach_id,grabbed_within,'csv')
      if lang_id && (lang_id==lang_id.to_i.to_s)
        substitutions = substitutions.select{|sub| (sub.language.id.to_s == lang_id) && !sub.coach_session.appointment? } unless lang_id.blank?
      elsif lang_id
        substitutions = substitutions.select{|sub| (sub.language.alias_id.to_s == lang_id) && sub.coach_session.appointment? } unless lang_id.blank?
      end
      report1 = File.new('/tmp/substitutions_report.csv', 'w')
        CSV::Writer.generate(report1 , ',') do |title|
          title << ['Level','Unit','Village', 'Learners?','Session/Shift Date','Request made','Grabbed on','Requested by','Picked up by','Left Open(in minutes)','Reason']
          process_substitutions(substitutions).each do |r|
            title << [r[:level],r[:unit],r[:village],r[:learners_signed_up],r[:subsitution_date],r[:created_at],r[:grabbed_at],r[:coach],r[:grabber_coach],r[:grabbed_within],r[:reason]]
          end
        end
      report1.close
      send_file("/tmp/substitutions_report.csv", :type => "text/csv", :charset=>"utf-8", :disposition => "inline")
    else
      substitutions = substitutions_report_query_method(lang_id,coach_id,duration,start_date,end_date,grabber_coach_id,grabbed_within,'csv')
      if substitutions.size >= 500
        Delayed::Job.enqueue(AllLanguagesSubstitutionReport.new(current_user.id , start_date, end_date, lang_id, coach_id, grabber_coach_id, duration,grabbed_within))
        render :json => {:send => "false", :mail =>"#{current_user.rs_email}" }, :status => 200 and return
      else
        render :json => {:send => "true" }, :status => 200 and return
      end
    end
  end

  def substitutions_report_query_method(lang_id,coach_id,duration,start_date,end_date,grabber_coach_id,grabbed_within,str)
    lang_param = nil
    coach_param = nil
    duration_param1 = nil
    duration_param2 = nil
    grabber_coach_param = nil
    grabbed_at_param = nil
    arr_coach = []
    # First select string ------------------------------------------------------------------------------
    select_str = "SELECT *, B.full_name Coach_Name,IFNULL(C.full_name, 'Not yet Grabbed') Grabber_Coach_Name FROM (select substitutions.id idsub,substitutions.coach_id,substitutions.grabber_coach_id,substitutions.grabbed,substitutions.coach_session_id,substitutions.session_type,substitutions.reason,substitutions.created_at create_sub,substitutions.grabbed_at,TIMESTAMPDIFF(minute,substitutions.created_at,substitutions.grabbed_at) grabbed_time,substitutions.cancelled,coach_sessions.session_start_time,coach_sessions.external_village_id,coach_sessions.language_identifier,coach_sessions.single_number_unit,coach_sessions.number_of_seats,coach_sessions.attendance_count,coach_sessions.id from substitutions , coach_sessions where "
    # language based ---------------------------------------------------------------------------------
    if lang_id && (lang_id==lang_id.to_i.to_s)
      (lang_id == "") ? lang_param = Language.all.collect{ |l| l.identifier} : lang_param = [Language.find(lang_id).identifier]
    elsif lang_id
      lang_id=lang_id.split("-").first unless (lang_id == "")
      (lang_id == "") ? lang_param = Language.all.collect{ |l| l.identifier} : lang_param = Language.fetch_same_group_appointment_languages(lang_id).collect(&:identifier)
    end
    lang_str = 'coach_sessions.language_identifier in (?) '
    # Coach list ----------------------------------------------------------------------------------------
    if (coach_id.blank?)
      coach_str = ''
    elsif coach_id == "Extra Sessions"
      coach_str = "and  substitutions.coach_id is null and (coach_sessions.type = 'ExtraSession' or substitutions.session_type = 'ExtraSession') "
    else
      coach_str = "and substitutions.coach_id = '#{coach_id}' "
    end
    # Duration list---------------------------------------------------------------------------------------

    start_date = TimeUtils.time_in_user_zone(start_date).utc
    end_date = TimeUtils.time_in_user_zone(end_date).end_of_day.utc
    today_start = Time.now.beginning_of_day.utc
    tomorrow_start = Time.now.beginning_of_day.tomorrow.utc
    duration_param1 = start_date
    duration_param2 = end_date
    case duration
    when 'Last month'
      duration_param1 = (today_start - 1.month)
      duration_param2 = today_start
    when 'Last week'
      duration_param1 = (today_start - 1.week)
      duration_param2 = today_start
    when 'Yesterday'
      duration_param1 = (today_start - 1.day)
      duration_param2 = (today_start - 1.minute)
    when 'Today'
      duration_param1 = today_start
      duration_param2 = (tomorrow_start - 1.minute)
    when 'Tomorrow'
      duration_param1 = tomorrow_start
      duration_param2 = (tomorrow_start + 1.day - 1.minute)
    when 'Next Week'
      duration_param1 = tomorrow_start
      duration_param2 = (tomorrow_start + 7.days - 1.minute)
    when 'Next Month'
      duration_param1 = tomorrow_start
      duration_param2 = (tomorrow_start + 1.month - 1.minute)
    end
    duration_param1 = duration_param1.to_s(:db)
    duration_param2 = duration_param2.to_s(:db)
    duration_str = (duration == 'All') ? "" : "and coach_sessions.session_start_time >= '#{duration_param1}' and coach_sessions.session_start_time <= '#{duration_param2}' "
    #Grabber coach -----------------------------------------------------------------------------------
    if (!(grabber_coach_id) || (grabber_coach_id == ""))
      grabber_coach_str = 'and substitutions.grabber_coach_id is not NULL '
    elsif (grabber_coach_id == '--')
      grabber_coach_str = ""
    else
      grabber_coach_str = "and substitutions.grabber_coach_id = '#{grabber_coach_id}' "
    end
    # Grabbed At------------------------------------------------------
    grabbed_at_param = 0
    case grabbed_within
    when 'One hour'
      grabbed_at_param = 60
    when '2 hours'
      grabbed_at_param = 2*60
    when '12 hours'
      grabbed_at_param = 12*60
    when '24 hours'
      grabbed_at_param = 24*60
    when '36 hours'
      grabbed_at_param = 36*60
    when '48 hours'
      grabbed_at_param = 48*60
    when '72 hours'
      grabbed_at_param = 72*60
    when 'More than 3 days'
       #3*24*60 = 4320. hardcoded this value so that grabbed_at_param can be used to decide the query
      grabbed_at_str = "and TIMESTAMPDIFF(minute,substitutions.created_at,substitutions.grabbed_at) >= '4320' "
    when 'Open'
      grabbed_at_str = 'and substitutions.grabbed_at is null '
    when 'Show All'
      grabbed_at_str = ""
    end
    grabbed_at_str = "and TIMESTAMPDIFF(minute,substitutions.created_at,substitutions.grabbed_at) <= '#{grabbed_at_param}' " if (grabbed_at_param != 0)
    # Coach session str ---------------------------------------------------------------------
    coach_session_str = 'and coach_sessions.id = substitutions.coach_session_id '
    # Coach session str 1 ---------------------------------------------------------------------------
    if(str == 'none')
      coach_session_str1 =  ') A LEFT JOIN accounts B ON A.coach_id = B.id LEFT JOIN accounts C ON grabber_coach_id = C.id ORDER BY create_sub DESC LIMIT 500'
    elsif (str == 'csv')
      coach_session_str1 =  ') A LEFT JOIN accounts B ON A.coach_id = B.id LEFT JOIN accounts C ON grabber_coach_id = C.id ORDER BY create_sub DESC LIMIT 1000'
    end
    # Final query------------------------------------------------------------------------------------------------
    final_query = select_str+lang_str+coach_str+duration_str+grabber_coach_str+grabbed_at_str+coach_session_str+coach_session_str1
    Substitution.find_by_sql([final_query,lang_param])
  end

  def process_substitutions(substitutions)
    villages = Community::Village.find(:all)
    substitutions_data = Hash.new { |h,k| h[k] = [] }
    sess_hash = {}
    eschool_ids = []
    substitutions.each do |each_sub|
      learners = "none"
      coach_session_associated = each_sub.coach_session
      # create a hash to make a bulk call to eschool for session learner details.
      if each_sub.session_type == 'ExtraSession'
        session_name = (coach_session_associated.name.blank? ? "Extra Session" : "Extra Session - #{coach_session_associated.name}" )
      elsif(coach_session_associated.is_extra_session?)
        session_name = "ExtraSession"
      else
        session_name = ""
      end
      ex_id = each_sub.external_village_id
      village_name = "N/A"
      village = villages.detect{|each_village| each_village.id==ex_id.to_i} if !ex_id.nil?
      village_name = village.name if village
      each_substitution = {
        :coach              => each_sub.Coach_Name ? each_sub.Coach_Name : session_name ,
        :subsitution_date   => each_sub.session_start_time ? format_time(each_sub.session_start_time.to_time ,"%a %m/%d/%y %I:%M %p %Z") : 'N/A',
        :sub_id             => each_sub.id,
        :created_at         => format_time(each_sub.create_sub.to_time, "%a %m/%d/%y %I:%M %p %Z"),
        :grabbed_at         => each_sub.grabbed_at ? format_time(each_sub.grabbed_at.to_time, "%a %m/%d/%y %I:%M %p %Z") : 'N/A',
        :grabber_coach      => each_sub.Grabber_Coach_Name == 'Not yet Grabbed' ? 'N/A' : each_sub.Grabber_Coach_Name,
        :grabbed_within     => each_sub.grabbed_time && !(each_sub.grabbed_time.nil?) ? each_sub.grabbed_time : each_sub.cancelled ? 'Open/ Canceled': 'Open',
        :level              => "N/A",
        :unit               => "N/A",
        :lesson             => "N/A",
        :village            => village_name,
        :learners_signed_up => "N/A",
        :reason             => each_sub.reason,
        :id                 => each_sub.idsub
      }
      eschool_ids << coach_session_associated.eschool_session_id if coach_session_associated.totale? #collecting only eschool_session_id of  totale sessions for fetching info from eschool
      substitutions_data[coach_session_associated.eschool_session_id] << each_substitution
    end
    #now make a bulk call fetch the details and add it to the existing hash only for eschool sessions
    [ExternalHandler::HandleSession.find_sessions(TotaleLanguage.first, {:ids => eschool_ids})].compact.flatten.each do |sess|
      substitutions_data[sess.eschool_session_id.to_i].each do |obj|
        obj[:learners_signed_up] = (sess.learners_signed_up.to_i == 0) ? "No" : "YES(#{sess.learners_signed_up.to_i})"
        coach_session = CoachSession.find_by_eschool_session_id(sess.eschool_session_id)
        obj[:lesson] = sess.lesson
        obj[:level] = sess.level
        obj[:unit] = sess.unit
      end
    end
    substitutions_data.values.flatten.sort_by{|data| data[:subsitution_date].to_time}
  end

  def last_month( sub_date )
    time_zone_value = sub_date.time_zone.name
    return (sub_date < Time.now.in_time_zone(time_zone_value) && sub_date > Time.now.in_time_zone(time_zone_value) - 1.month)
  end

  def last_week( sub_date )
    time_zone_value = sub_date.time_zone.name
    return sub_date.between?( Time.now.in_time_zone(time_zone_value),  (Time.now.end_of_day.in_time_zone(time_zone_value) + 1.week) - 1.day )
  end

  def yesterday( sub_date )
    time_zone_value = sub_date.time_zone.name
    return sub_date.between?(Time.now.beginning_of_day.in_time_zone(time_zone_value) - 1.day ,Time.now.end_of_day.in_time_zone(time_zone_value) - 1.day)
  end

  def today( sub_date )
    time_zone_value = sub_date.time_zone.name
    return (sub_date + EXTENDED_SUBSTITUTE_REQUEST_TIME).between?(Time.now.in_time_zone(time_zone_value),Time.now.end_of_day.in_time_zone(time_zone_value))
  end

  def tomorrow( sub_date )
    time_zone_value = sub_date.time_zone.name
    return sub_date.between?(Time.now.beginning_of_day.in_time_zone(time_zone_value) + 1.day ,Time.now.end_of_day.in_time_zone(time_zone_value) + 1.day)
  end

  def upcoming( sub_date )
    time_zone_value = sub_date.time_zone.name
    return (sub_date + EXTENDED_SUBSTITUTE_REQUEST_TIME) > Time.now.in_time_zone(time_zone_value)
  end

  def configurations
    self.page_title = 'Time Frames'
    @langs = current_manager.languages.sort_by(&:display_name)
    (params[:lang_ids] || []).each do |lang_id, start_time|
      lang = Language.find_by_id(lang_id)
      # create entries only when value is present and not same as the current value
      next if start_time.blank? || lang.session_start_time.to_s == start_time
      coach_sessions = CoachSession.find(:all,:conditions => ["language_identifier = ? and session_start_time >=?",lang.identifier,Time.now.utc ])
      total_sessions = coach_sessions.size
      Thread.new {
        ActiveRecord::Base.connection_pool.with_connection do
          begin
            coach_sessions.each do |sess|
              # Cancel the session or request a sub *only* if it has not been done already.
              # (don't try to trigger sub for an already triggered sub)
              sess.cancel_or_subsitute! if sess.coach_id && !sess.cancelled
            end
          rescue Exception => e
            Rails.logger.info "Error occurred during session cancellation"
            Rails.logger.info "#{e.inspect}"
          end
        end
      }
      lang.configurations.create(:session_start_time => start_time, :created_by => current_manager.id)
      if total_sessions > 0
        flash.now[:notice] = "Timeframes updated successfully. Future sessions for this language without learners are being cancelled. Future sessions with learners have had substitution requests triggered."
      else
        flash.now[:notice] = "Configurations successfully updated."
      end
    end
    support_window = params[:tech_support] || params[:adobe]
    if support_window
      start_time = support_window[:start_time]
      end_time = support_window[:end_time]
      start_wday = WEEKDAY_NAMES.index(support_window[:start_day])
      end_wday = WEEKDAY_NAMES.index(support_window[:end_day])
      type = params[:tech_support] ? "TechSupport" : "AdobeMaintenance"
      SupportWindow.create_or_update(type, start_time, end_time, start_wday, end_wday)
      flash.now[:notice] = "Configurations successfully updated."
    end
    ts = SupportWindow.find_by_window_type("TechSupport")
    am = SupportWindow.find_by_window_type("AdobeMaintenance")
    @tech_support = {}; @adobe = {}
    if ts
      @tech_support[:start_time] = ts.start_time.strftime("%H:%M")
      @tech_support[:end_time] = ts.end_time.strftime("%H:%M")
    end
    if am
      @adobe[:start_time] = am.start_time.strftime("%H:%M")
      @adobe[:end_time] = am.end_time.strftime("%H:%M")
      @adobe[:start_day] = WEEKDAY_NAMES[am.start_wday]
      @adobe[:end_day] = WEEKDAY_NAMES[am.end_wday]
    end
  end

  def cancel_session
    coach_session = CoachSession.find_by_eschool_session_id(params[:session_id].to_i)
    if !coach_session.nil?
      coach = coach_session.coach
      coach_session.modify_coach_availability if coach
      coach_session.cancel_session!
      coach_session.update_attributes(:cancellation_reason => params[:reason]) if params[:reason]
      if coach
        message = "Your #{coach_session.language.identifier} Studio Session on #{TimeUtils.format_time(coach_session['session_start_time'], "%b %d, %Y %H:%M %Z")} has been cancelled."
        coach.system_notifications.create(:raw_message => message)
      else
        substitution = Substitution.find_by_coach_session_id(coach_session.id)
        substitution.cancel_session if substitution
      end
      render(:update){|page| page.replace_html "cancelled_msg#{params[:session_id]}", :partial => "shared/cancelled_message", :locals => {:message => MSG_MANAGER_CANCELLED_SESSION_SUCCESS, :succeeded => true }} and return if params[:cancelled_from_led].nil?
    else
      ExternalHandler::HandleSession.cancel_session(TotaleLanguage.first, {:remote_session_id => params[:session_id]})
    end
    redirect_to dashboard_url if !params[:cancelled_from_led].nil?
  end

  def get_teachers_for_language
    @coaches = Coach.for_qualification(Language.find_by_identifier(params[:lang_identifier])).to_a
    @selected_language=params[:lang_identifier]
    render(:partial => "select_coach", :locals => {:coaches => @coaches})
  end

  def max_qual_of_coach
    coach = Coach.find_by_user_name(params[:coach_user_name])
    level_unit = coach.max_level_unit_qualification_for_language(params[:lang_identifier])
    render :text => "(<i>Max Unit</i> : Level <b>#{level_unit[:level]}</b>, Unit <b>#{level_unit[:unit]}</b>)"
  end

  def get_teachers_for_manager_in_language
    @coach = Coach[params[:coach_id]]
    @selected_lang = Language.find_by_identifier(params[:lang_identifier])
    all_coaches=[]
    if params[:lang_identifier] == 'all'      # this never happens
      language_array = current_manager.languages
      language_array.each do |lang|
        all_coaches << Coach.for_qualification(Language.find_by_identifier(lang.identifier))
      end
      @coaches_for_language = all_coaches.flatten!
    else
      @coaches_for_language = Coach.for_qualification(Language.find_by_identifier(params[:lang_identifier])).to_a
    end
    render(:partial => "coaches_list", :locals => {:coaches => @coaches_for_language})
  end

  def coach_time_off
    self.page_title = 'Coach Time Off Report'
  end

  def get_time_off_ui
    timeframe = params[:timeframe]
    start_date = params[:start_date]
    end_date = params[:end_date]
    lang_identifier = params[:lang_identifier]
    region = params[:region]
    time_off_status = params[:time_off_status]
    @time_off_data,@report_start,@report_end = prepare_time_off_data(timeframe,start_date,end_date,lang_identifier,region,time_off_status)
    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          page.replace_html 'coach_time_off_data', :partial => 'coach_time_off_table.html.erb'
        end
      } if request.xhr?
    end
  end

  def get_coach_langauges
    render(:partial => "coach_languages", :locals => {:lang => Coach.find_by_id(params[:id]).languages.collect(&:display_name).sort.to_sentence})
  end

  def prepare_time_off_data(timeframe,start_date,end_date,lang_identifier,region,time_off_status)
      time_off_data = Hash.new { |h,k| h[k] = [] }
      range = get_time_range(timeframe, start_date, end_date)
      coach_ids = Coach.find_coaches_based_on_lang_and_region(lang_identifier,region).collect(&:id)
      condition = "((start_date between '#{range[:from]}' and '#{range[:to]}' or end_date between '#{range[:from]}' and '#{range[:to]}') or (start_date <= ? and end_date >= ?)) and coach_id IN(?) and unavailability_type = 0"
      condition += STATUS_FOR_TIME_OFF_REPORT[time_off_status].blank? ? " and approval_status IN(0,1,2)" : " and approval_status = #{STATUS_FOR_TIME_OFF_REPORT[time_off_status]}"
      timeoffs = UnavailableDespiteTemplate.where(condition,range[:from],range[:to],coach_ids)
         timeoffs.each do |time_off|
          coach = Coach.find_by_id(time_off.coach_id)
          time_diff = time_off[:end_date].to_time - time_off[:start_date].to_time
          durations_hash = {"d" => (time_diff/1.day).floor,"h" => ((time_diff%1.day)/1.hour)}
          time_off_record = {
            :time_off_id     => time_off[:id],
            :coach_name      => coach[:full_name],
            :coach_id        => coach.id,
            :coach_languages => coach.languages.collect(&:display_name).sort.to_sentence,
            :coach_region    => coach[:region_id] ? Region.find_by_id(coach[:region_id]).try(:name) : "N/A",
            :time_off_start  => TimeUtils.time_in_user_zone(time_off[:start_date]).strftime("%m/%d/%y %I:%M %p"),
            :time_off_end    => TimeUtils.time_in_user_zone(time_off[:end_date]).strftime("%m/%d/%y %I:%M %p"),
            :duration        => ("#{durations_hash["d"]}d " if !durations_hash["d"].zero?).to_s+("#{durations_hash["h"]}h" if !durations_hash["h"].zero?).to_s,
            :time_off_status => APPROVAL_STATUS[time_off[:approval_status]],
            :affected_count  => coach.get_affected_session_count(time_off[:start_date].to_time,time_off[:end_date].to_time,time_off[:approval_status]),
            :action          => (time_off[:approval_status] != 0) ? "blank" : (time_off[:approval_status] == 0 && (time_off[:end_date].to_time > Time.now.utc)) ? "links" : "text"
          }
          time_off_data[time_off.id] << time_off_record
         end
      return time_off_data.values.flatten,range[:from],range[:to]
  end

  def export_time_off_report
    timeframe = params[:timeframe_hidden]
    start_date = params[:start_date_hidden]
    end_date = params[:end_date_hidden]
    lang_identifier = params[:lang_identifier_hidden]
    region = params[:region_hidden]
    time_off_status = params[:time_off_status_hidden]
    export_data,report_start,report_end = prepare_time_off_data(timeframe,start_date,end_date,lang_identifier,region,time_off_status)
    report1 = File.new('/tmp/coach_time_off_report.csv', 'w')
    report_language = Language[lang_identifier].try(:display_name) || "All Language"
    header = "Time off Report - " + report_language + " - " + TimeUtils.format_time(report_start.to_time, "%B %d, %Y %I:%M %p") + " to " + TimeUtils.format_time(report_end.to_time, "%B %d, %Y %I:%M %p")
        CSV::Writer.generate(report1 , ',') do |title|
          title << [header]
          title << ['Coach Name','Languages','Hub City', 'Start Date','End Date','Duration','Status','Affected Session(s)*']
          export_data.each do |r|
            title << [r[:coach_name],r[:coach_languages],r[:coach_region],r[:time_off_start],r[:time_off_end],r[:duration],r[:time_off_status],r[:affected_count]]
          end
          title << ["Affected Sesions - # of Sessions Scheduled, Cancelled or Substituted ","","","","","","",""]
        end
      report1.close
      send_file("/tmp/coach_time_off_report.csv", :type => "text/csv", :charset=>"utf-8", :disposition => "inline")

  end

  private

  def authenticate
    if tier1_support_lead_logged_in?
      access_denied unless (["view_coach_profiles","sign_in_as_my_coach", "cancel_session","mail_template","fetch_mail_address","send_mail_to_coaches"].include?(params[:action]))
    else
      access_denied unless manager_logged_in? && !extranet? || ['cancel_session','mail_template','fetch_mail_address','send_mail_to_coaches'].include?(params[:action])
    end
  end

end
