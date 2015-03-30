require 'cgi'
require 'authenticated_system'

class ApplicationController < ActionController::Base

  layout 'default'

  include AuthenticatedSystem
  include FaceboxRender
  helper :all
  include ApplicationHelper

  # force users to SSL if the instance is configured to support it (see config/ssl.yml)
  before_filter RosettaStone::ForceSsl
  before_filter :login_required, :except => [:login, :logout, :application_status, :populate_help_request, :get_crossdomain_xml]
  before_filter :authenticate, :except => [:login, :logout]
  before_filter :profile_complete?, :except => [:login, :logout]
  before_filter :set_locale
  before_filter AuditLoggingFilter.new(:changed_by_reader => :audit_log_modifying_entity_name)
  before_filter :load_next_session
  before_filter :set_user_time_zone

  after_filter :track_user_activity

  downloads_files_for :account, :photo

  # called out explicitly in routes
  def routes_catchall
    flash[:error] = "The Url '#{params[:path]}' is  not available."
    redirect_to_appropriate_url
  end

  def page_title=(page_title)
    @page_title = page_title
  end

  def valid_help_request_user(user)
    valid = false
    if user && user.attribute_names.include?(:sn)
      instance = RosettaStone::InstanceDetection.instance_name
      if instance == "production"
        valid = (user.sn.first == "Admin Prod")
      elsif instance == "staging"
        valid = (user.sn.first == "Admin Staging")
      else
        valid = (user.sn.first == "Admin Dev")
      end
    end
    valid
  end

  def fetch_languages
    render :text => view_context.options_for_filter_languages(nil, params[:category])
  end

  def get_crossdomain_xml
    render :file => 'shared/get_crossdomain_xml.xml.erb'
  end

  def populate_help_request
    user_name, password = params[:user_name], params[:password]
    user = User.ldap_api.authenticate(:user_name => user_name, :password => password)
    if valid_help_request_user(user)
      begin
        raise "InvalidParameters" unless params[:userID].present? && params[:role].present? && params[:url].present?
        details = {:user_id => params[:userID], :role => "Coach"}
        details[:role] = "Learner" if params[:role] == "viewer"
        session_id = params[:url].match('[\/][m](\d+)').captures[0]
        details[:external_session_id] =  session_id.to_i
        HelpRequest.create(details)
        render :text => "Help requested successfully", :status => 200
      rescue Exception => ex
        notify_hoptoad(ex)
        render :text => "Something went wrong ! Please try again.", :status => 500
      end
    else
      render :text => "Authentication Failed.", :status => 500
    end
  end

  def get_learners
    @learner = Learner.find_by_guid(params[:license_guid] || params[:guid]) if (params[:license_guid] || params[:guid])
    @learner = Learner.find_by_id(params[:learner] || params[:id]) unless @learner
    @learner = Learner.find_by_email(params[:email] || params[:license_identifier]) if (!@learner && (params[:email] || params[:license_identifier]))
    if @learner.nil?
      flash[:error] = "Learner Not Found."
      redirect_to learners_path and return
    end
  end

  def login
    self.page_title = _('Sign_in763983FA')

    if request.post? && params[:coach]
      user_name, password = params[:coach][:user_name], params[:coach][:password]
      user = User.authenticate(user_name, password)
      if user
        return_to = session[:return_to]
        reset_session
        if user.account.is_coach? && (Time.now - user.account.created_at) < 3.minutes
          #don't allow to login if the coach entry was created just now
          flash[:error] = "Your coach manager or supervisor has not yet created a profile for you in the Customer Success Portal.<br/>Once your profile has been created you will be able to log in.".html_safe
          redirect_to login_url
        else
          user.time_zone = TimeUtils.time_zone_map[params[:coach][:time_zone]] || 'Eastern Time (US & Canada)'
          self.current_user = user
          if coach_logged_in? && !current_coach.valid_user?
            reset_session
            flash[:error] = "You tried to login before your profile was created. Please contact your Coach Manager.".html_safe
            redirect_to login_url and return
          end
          flash[:notice] = _("Signed_in_successfully6EA2958D")
          #  set cookie only if user is coach or CM
          cookies[:emergency_alert] = 'show_alert' if current_user.is_coach? || current_user.is_manager?
          session[:return_to] = return_to
          redirect_to_appropriate_url
        end
      else
        flash[:error] = "Failed to authenticate #{user_name}. Incorrect username/password combination.".html_safe
        redirect_to login_url
      end
    elsif logged_in?
      redirect_to_appropriate_url
    end
    render :template => '/coach_portal/login' unless performed?
  end

  def set_locale
    #ENV['take_translation_screenshots'] = 'true'
    I18n.locale = preferred_locale
  end

  # returns a string if a valid locale is found
  # this will return nil if an invalid locale is specified
  def preferred_locale
    available_locales = Lion.supported_locales.map(&:to_s)
    locale = if ENV['translation_screenshot_locale']
      ENV['translation_screenshot_locale']
    elsif params[:one_time_locale]
      params[:one_time_locale]
    elsif params[:locale] && available_locales.include?(params[:locale])
      session[:locale] = params[:locale]
    elsif session[:locale]
      session[:locale]
    elsif current_user && current_user.native_language
      current_user.native_language
    elsif cookies[:locale] && available_locales.include?(cookies[:locale])
      cookies[:locale]
    else
      Lion.default_locale
    end
    locale
  end

  def logout
    current_user.update_attribute(:last_logout, Time.now.utc) if current_user
    reset_session
    flash[:notice] = "Logged out"
    redirect_to login_url
  end

  def audit_log_modifying_entity_name
    current_user ? current_user.user_name : "Unknown"
  end

  def totale_being_pushed?
    (SchedulerMetadata.where("lang_identifier not in ('KLE','AUS','AUK') and locked is true").size > 0)
  end

  def reason_for_cancellation
    @called_from = params[:called_from]
    @dashboard_page = true if params[:from_dashboard]
    if params[:coach_session_id]
      eschool_session_id = CoachSession.find_by_id(params[:coach_session_id]).eschool_session_id
      params[:eschool_session_id] = eschool_session_id
    end
    render :partial => "shared/reason_for_cancel_session"
  end

  def aria_launch_url
      if(params[:eschool_session_id]) #Call from Dashboard
        cs = CoachSession.find_by_eschool_session_id(params[:eschool_session_id])
        user_id = current_user.id
      elsif(params[:coach_session_id]) #Call from Coach Scheduler
        cs = CoachSession.find_by_id(params[:coach_session_id])
        user_id = cs.coach.id
      end
      if params[:student_guid] == "None" #If no learner added to the session, launch into AEB
        url = AdobeConnect::Base.provide_launch_link(cs.eschool_session_id, user_id)
        render :text => url, :status => 200 and return if url
      else
        code,host_uri = BigBlueButton::Base.determine_server_host(params[:student_guid], cs.eschool_session_id)
        #if host_url matches adobe connect launch into adobeconnect, else BigBlueButton
        if host_uri =~ /adobeconnect.com$/
          url = AdobeConnect::Base.provide_launch_link(cs.eschool_session_id, user_id, host_uri)
          render :text => url, :status => 200 and return if url
        else
          code,url = BigBlueButton::Base.form_url("create",cs.eschool_session_id, params[:student_guid])
            if code == "200"
              code,url = BigBlueButton::Base.form_url("join",cs.eschool_session_id, params[:student_guid], cs.coach.full_name,cs.coach.coach_guid)
              if code == "302"
                render :text => url, :status => 200 and return
              end
            end
        end
      end
      render :text => "You currently do not have a profile in Adobe connect that supports coaching this session. Please contact your manager or supervisor for assistance.", :status => 500 and return if url==false
      render :text => "Something went wrong. Please try again later.", :status => 500 and return
  end

  def sync_eschool_csp_data
    lang_list = (Language.all - TotaleLanguage.all).collect(&:identifier).map{|k| "'#{k}'"}.join(",")
    begin
      msg = "A totale language is being pushed currently. Please try again later"
      UserUpdateExecutionDetail.record_time(UPDATE_IDENTIFIER[:synch_eschool]) do
        affected_sessions = ConfirmedSession.where("language_identifier not in (#{lang_list}) and eschool_session_id is null and session_start_time >= ?",TimeUtils.current_slot+30.minutes)
        if affected_sessions.blank?
          msg = "All sessions are updated. No affected session found. "
        else
          completed_sessions = []
          ids = affected_sessions.collect{|cs| {:external_session_id=> cs.id, :eschool_session_id => cs.eschool_session_id}}
          response = ExternalHandler::HandleSession.get_session_details(TotaleLanguage.first, {:ids => ids })
          raise "No response from eschool" unless response
          sessions = EschoolResponseParser.new(response.read_body).parse
          sessions.each do | ses |
            coach_session = affected_sessions.detect{ | x | x.id == ses.external_session_id.to_i }
            coach_session.update_attributes(:eschool_session_id => ses.eschool_session_id.to_i,:session_status => 1) if coach_session
            completed_sessions << coach_session
          end
          remaining_sessions = affected_sessions - completed_sessions
          completed = completed_sessions.size
          # the folowing piece of code is to attempt to create the sessions that got created here and not in eschool for some reason.
          remaining_sessions.each do |sess|
            response = ExternalHandler::HandleSession.create_sessions(TotaleLanguage.first, sess.to_hash)
            es_session = nil
            if !response
              ids = [{:eschool_session_id => sess.eschool_session_id,:external_session_id => sess.id}]
              response = ExternalHandler::HandleSession.get_session_details(TotaleLanguage.first, {:ids => ids })
            end
            if response
              es_session = EschoolResponseParser.new(response.read_body).parse
              sess.update_attributes(:eschool_session_id => es_session[0].eschool_session_id, :session_status => COACH_SESSION_STATUS["Created in Eschool"])
            end
            sess.destroy if sess.eschool_session_id.blank?
            completed += 1
          end
          msg = "#{affected_sessions.size} were affected in CSP and #{completed} sessions have been updated"
        end
      end unless totale_being_pushed?
      render :json => {:text => msg}, :status => 200
    rescue Exception => ex
        notify_hoptoad(ex)
        render :text => "Something went wrong, please try again.", :status => 500
    end
  end

  def application_status
      begin community_user_db = Community::User.find_by_id(1) ? true : false rescue false end
      begin rsmanager_db = RsManager::User.find(:first) ? true : false rescue false end
      begin license_server = LicenseServer::License.find(:first) ? true : false rescue false end
      begin eschool_session_api = Eschool::Session.find(:one, :from => "/api/cs/check_if_teacher_exists", :params => {:user_name => "test12", :email => "test12@rosettastone.com"} ) ? true : false rescue false end
      begin eschool_session_api_smx = Eschool::Learner.find(:one, :from => "/api/students/1cb8854c-19eb-102c-9376-0015c5afe2a9/studio_history") ? true : false rescue false end
      begin baffler_api = RosettaStone::Baffling::ApiClient.new.ping["status"] ? true : false rescue false end
      begin license_api = RosettaStone::ActiveLicensing::Base.instance.license.authenticate(:license => 'skumar@rosettasone.com', :password => 'Password') ? true : false rescue false end
      begin locos_api = Locos::Lotus.find_learners_in_dts ? true : false rescue false end
      begin supersaas_api = SuperSaas::User.login_as_admin.match(/SS_keep/) ? true : false rescue false end
      response_hash = {:applications_status => {
          :community_user_db => community_user_db,
          :rsmanager_db => rsmanager_db,
          :license_server => license_server,
          :eschool_session_api => eschool_session_api,
          :eschool_session_api_smx => eschool_session_api_smx,
          :baffler_api => baffler_api,
          :license_api => license_api,
          :locos_api => locos_api,
          :supersaas_api => supersaas_api
        }}
      respond_to do |format|
        format.html {render :template => 'coach_portal/application_status', :locals => response_hash }
        format.text {render :text => render_to_text(response_hash[:applications_status]) }
      end
  end

  def render_to_text(hash)
    result = ''
    hash.each do |key, value|
      result += "#{key.to_s.titlecase.upcase} : #{value == true ? 1 : 0}\n"
    end
    result
  end

  def application_configuration
    if(manager_logged_in? || admin_logged_in?)
      if request.post?
        ApplicationConfiguration.all.each do |app_config|
          app_config.update_attributes(:value => params[app_config.setting_type])
        end
        flash.now[:notice] = "Settings updated successfully."
      end

      render :template => 'shared/application_configuration', :locals =>{:app_configs => ApplicationConfiguration.all}
    else
      access_denied
    end
  end

  def reroute
    if coach_logged_in?
      redirect_to :controller => 'coach_portal' , :action => 'calendar_week'
    elsif manager_logged_in?
      redirect_to :controller => 'schedules' , :action => 'index'
    else
      redirect_to :controller => 'extranet/learners'
    end
  end

  def mark_notification_as_read
    notif = current_user && current_user.system_notifications.find_by_id(params[:id])
    notif && notif.mark_as_read
    render :nothing => true
  end

  # This method can be removed. Remove it once the next sprint starts and verify.
  def extranet?
    request.host.include?('extranet')
  end
  helper_method :extranet?

  def next_session_start_time
    # @next_session will be generated by load_next_session
    render :partial => 'shared/next_session_start_time'
  end

  def get_learner_details
    @learner = Learner.find_by_id(params[:learner_id])
    learner_session_detail = ExternalHandler::HandleSession.find_session(TotaleLanguage.first, {:id => params[:id]})
    attendance = learner_session_detail.learner_details.detect{|learner| learner.student_guid == @learner.guid} if learner_session_detail
    @time_zone = attendance.student_time_zone if attendance
    render :layout => false, :template => 'coach_portal/get_learner_details'
  end

  def construct_url_for(lang, room_host)
    if coach_logged_in?
      session[:player_session_recording_mode] = (ExternalHandler::HandleSession.get_reflex_studio_recording_enabled(TotaleLanguage.first) != "false") if session[:player_session_recording_mode].blank?
      "javascript:launchOnline('http://launch.rosettastone.com/en/reflex_studio?external_coach_id=#{current_coach.id}&amp;language_identifier=#{lang}&amp;room_host=#{room_host}&amp;full_name=#{current_user.full_name.gsub(/[\']/,"\\\\\'")}&amp;player_session_recording_mode=#{session[:player_session_recording_mode]}&amp;support_chat_link=','#{get_live_chat_url}')"
    end
  end

  def update_aria_session_with_slot_id
    coach_session = CoachSession.find_by_id(params[:coach_session_id])
    result = coach_session.update_aria_session # returns array with first element a text and second element response code
    render :text => result[0], :status => result[1]
  end

  def alert_is_active
     show_alert = Alert.display_active_topic ? 'true' : 'false'
     respond_to do |format|
      format.text {render :text => show_alert }
     end
     # render :nothing => true
  end

  def coach_alert
    # selects an active record from db and pass it to the front-end.
    @alert = Alert.display_active_topic || {"description" => nil}
    @alert["scenario"] = params[:scenario] if params[:scenario]
    render :layout => false, :template => 'shared/coach_alert'    
  end

  def publish_coach_alert
    #saves the active column of previous active alert as false and creates a new row with active status as true in the db.
    @alert = Alert.display_active_topic
    @alert.deactivate! if @alert
    new_alert = {"description" => params[:description], "created_by" => current_user["id"], "active" => 1}
    @publishAlert = Alert.create!(new_alert)
    render :nothing => true
  end

  def remove_coach_alert
    # sets the active column as false in the db 
    alert = Alert.display_active_topic
    alert.deactivate! if alert
    render :nothing => true
  end

  def on_duty_list
    @full_list = ManagementTeamMember.scoped.order(:position)
    @list = @full_list.empty? ? [] : @list = @full_list.where("on_duty = ?", true)
    @message = GlobalSetting.find_by_attribute_name("on_duty_text_message")
    render :layout => false, :template => 'shared/on_duty_list'
  end

  def save_on_duty_message
    @message = GlobalSetting.find_by_attribute_name("on_duty_text_message")
    @message[:attribute_value] = params[:message]
    @message.save

    render :nothing => true
  end

  def save_on_duty_list
    ids = [];
    if !params[:members].nil?
      params[:members].each do |key,value|
        ids.push(key)
        member = ManagementTeamMember.find(key)
        member.on_duty = true
        member.available_start = value[:start_time]
        member.available_end = value[:end_time]
        member.save
      end
    end

    list = ManagementTeamMember.where("id not in (?)", ids.empty? ? [0] : ids)
    list.each do |member|
      member.on_duty = false
      member.save
    end

    render :nothing => true
  end

  def get_dialects
    dialects = {}
    Dialect.where("language_id = ?", params[:language_id]).each do |d|
      dialects[d.id] = d.name
    end
    render :json => dialects
  end


  private

  # To store. In the data variable. since data[0] would indicate either Sunday or Monday depending on START_OF_THE_WEEK
  def wday_for_storing(wday)
    START_OF_THE_WEEK == 'Monday' ? (wday == 0 ? 6 : (wday - 1)) : wday
  end

  def render_404
    render :file => "#{Rails.root}/public/404.html", :status => 404
  end

  def render_500
    render :file => "#{Rails.root}/public/500.html"
  end

  def profile_complete?
    redirect_to edit_profile_url and return if coach_logged_in? && !current_coach.valid_user?
  end

  # override this in the controller with appropriate logic, if needed.
  def authenticate
    true
  end

  def redirect_to_appropriate_url
    if tier1_user_logged_in? || community_moderator_logged_in?
      redirect_back_or_default get_preferred_url(learners_url, SUPPORT_USER_LEAD_START_PAGES)
    elsif admin_logged_in?
      redirect_back_or_default "/homes/admin_dashboard"
    elsif led_user_logged_in? || tier1_support_harrisonburg_user_logged_in? || tier1_support_concierge_user_logged_in?
      redirect_back_or_default get_preferred_url(dashboard_url, SUPPORT_USER_LEAD_START_PAGES)
    elsif admin_logged_in? || coach_logged_in? || extranet?
      redirect_back_or_default get_preferred_url(coach_portal_url, COACH_START_PAGES)
    elsif manager_logged_in?# manager, takes precedence over coach
      redirect_back_or_default get_preferred_url(homes_url, COACH_MANAGER_START_PAGES)
    else # unknown user
      reset_session
      access_denied
    end
  end

  rescue_from  ActiveResource::ResourceNotFound, :with => :client_error
  rescue_from ActiveResource::ServerError, :with => :server_error

  def client_error(e); logger.info "ActiveResource : Client Error : #{e.message}"; logger.info e.backtrace.join("\n"); render :template => 'shared/_client_error';
  end

  def server_error(e); logger.info "ActiveResource : Server Error : #{e.message}"; logger.info e.backtrace.join("\n"); render :template => 'shared/_server_error';
  end

  #Generates the paginating opts hash
  # In the form of {:page => 1, :per_page => 10}
  def paginating_options
    opts = {}
    opts[:page] = (params[:page].nil? || params[:page].to_i <= 1) ? 1 : params[:page].to_i
    opts[:per_page] = params[:per_page].nil? ? 10 : params[:per_page].to_i
    return opts
  end

  def events_data(home_page = false)
    @date = TimeUtils.time_in_user_zone(params[:date]).to_date
    @events = current_user.events(home_page)
    if home_page
      @events = @events.select{|e| TimeUtils.time_in_user_zone(e.event_start_date).month == @date.month}
      @events_start_date = @events.collect{|event| TimeUtils.time_in_user_zone(event.event_start_date).to_date}
    elsif params[:event_date]
      @events = @events.select{|e| TimeUtils.time_in_user_zone(e.event_start_date).to_date == params[:event_date].to_date }
    end
  end

  def load_next_session
    @next_session = current_coach.next_session if coach_logged_in?
  end

  def get_live_chat_url
    if(current_user.full_name.to_s.index("'"))
      full_name = current_user.full_name ? current_user.full_name.gsub(/[\']/,"\\\\\'") : ""
    else
      full_name = current_user.full_name ? CGI.escape(current_user.full_name) : ""
    end
    email = current_user.rs_email ? CGI.escape(current_user.rs_email) : ""
    "http://totale.rosettastone.com/support?task=chat&&cak=jshfnekwish384y4h72hce77fjdf3884jfnd&name="+full_name+"&email="+email+"&app=studio&locale=en-US"
  end
  helper_method :get_live_chat_url

  def get_preferred_url(url, allowed_pages)
    default_url = url
    preference = current_user.get_preference
    if preference.start_page && allowed_pages.values.include?(preference.start_page) && START_PAGE_URLS.keys.include?(preference.start_page)
      default_url = self.send(START_PAGE_URLS[preference.start_page])
    end
    return default_url
  end


  def track_user_activity
    name = ""
    role = ""
    to_track_actions = ["bulk_modify_eschool_sessions", "create_coach", "create_eschool_session"]

    if !current_user.blank?
      name = current_user.user_name
      role = current_user.type
    end

    if !role.blank? && role == "CoachManager"
      if to_track_actions.include?(params[:action].to_s)
        if session[:track_filter_action] != params[:action].to_s
          session[:track_filter_action] = params[:action].to_s
          action = "Went to the following action : #{params[:action].to_s}"

          action = "Pushed all session to Eschool" if params[:action].to_s == "bulk_modify_eschool_sessions" && params[:commit].to_s == "PUSH TO ESCHOOL"

          action = "Created a coach" if params[:action].to_s == "create_coach" && params[:commit].to_s == "Save"
          coach  = Coach.find_by_user_name(params[:coach][:user_name].to_s) if !params[:coach].blank? && params[:coach][:user_name].blank? && params[:action].to_s == "create_coach"
          action = action + "for #{params[:coach][:user_name].to_s} coach" if coach

          action = "Created a one-off session" if params[:action].to_s == "create_eschool_session" && params[:commit].to_s == "Create"
          UserAction.create(:user_name => name, :user_role => role, :action => action)
        end
      end
    end

  end

  def mail_time_off_notifications_immediately_to_coaches(modification, for_who = nil, message = nil)
    if message.nil?
      not_ids = TriggerEvent.where("name IN ('REQUEST_TIME_OFF_BY_VIOLATING_POLICY', 'REQUEST_TIME_OFF', 'TIME_OFF_REMOVED', 'TIME_OFF_CUT_SHORT', 'TIME_OFF_EDITED', 'ACCEPT_TIME_OFF', 'DECLINE_TIME_OFF')").collect{|noti| noti.id}
      sys_not = SystemNotification.where("notification_id in (?) and target_id = ? ", not_ids , modification.id).last
      if sys_not
        message = sys_not.message(true)
        if sys_not.require_cta_links?
          tar_obj = sys_not.target_object
          message += "<a href = 'http://coachportal.rosettastone.com/approve-modification/#{sys_not.target_object.id}/true?mail=true'>Approve</a>".html_safe if tar_obj.end_date.utc > Time.now.utc
          message += "         "
          message += "<a href = 'http://coachportal.rosettastone.com/approve-modification/#{sys_not.target_object.id}/false?mail=true'>Deny</a>".html_safe if tar_obj.end_date.utc > Time.now.utc
        end
      end
    end
    if for_who.is_a?Coach
      recipients = [for_who.get_preferred_mail_id_by_type('notifications_email')].compact
    else
      managers = CoachManager.where(:active => 1)
      recipients = managers.collect{|manager| manager.get_preferred_mail_id_by_type('notifications_email')}.compact
    end
    GeneralMailer.notifications_email(message, recipients).deliver if recipients.any?
  end

  def create_sub_sms_text(size,language_name)
    text = "#{language_name} has #{size} sessions with subs needed right now. Please check the substitutions page in the Customer Success Portal."
    text.size > 160 ? text[0..156]+'...' : text
  end

  def set_user_time_zone
    if (user = current_user)
      Thread.current[:account] = user
      Thread.current[:user_details] = "CCS-#{user.user_name} - One Off"
    end
  end

end
