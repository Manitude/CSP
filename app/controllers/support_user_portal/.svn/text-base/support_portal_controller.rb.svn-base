class SupportUserPortal::SupportPortalController < ApplicationController

  before_filter :restrict_access_to_support_pages

  def view_profile
    @page_title = _("My_ProfileFE3EBF53")
    @support_user = current_user
    @other_languages = Array.new
    @support_user.other_languages.split(',').each { |lang_code| @other_languages << SupportLanguage.find_by_language_code(lang_code).name } if @support_user.other_languages?
    render :template => "support_user_portal/view_profile"
  end

  def edit_profile
    @page_title = _("Edit_Profile995570ED")
    @support_user = SupportUser.find_by_id(current_user.id) if tier1_support_user_logged_in?
    @support_user = SupportLead.find_by_id(current_user.id) if tier1_support_lead_logged_in?
    @support_user = SupportHarrisonburgUser.find_by_id(current_user.id) if tier1_support_harrisonburg_user_logged_in?
    @support_user = SupportConciergeUser.find_by_id(current_user.id) if tier1_support_concierge_user_logged_in?
    @support_user = LedUser.find_by_id(current_user.id) if led_user_logged_in?
    @support_user = CoachManager.find_by_id(current_user.id) if manager_logged_in?
    @support_user = CommunityModerator.find_by_id(current_user.id) if community_moderator_logged_in?
    @support_user = Admin.find_by_id(current_user.id) if admin_logged_in?
    if request.post?
      other_languages = Array.new
      params[:olang].each { |language_code, value| other_languages << "#{language_code}" if value != "0" }
      @support_user.other_languages = other_languages.join(',')
      if (params[:remove_profile_picture] && params[:remove_profile_picture] == "true")
        @support_user.photo = nil
        ActiveRecord::Base.connection.execute("UPDATE accounts SET photo_file = null WHERE id = #{@support_user.id}")
      end
      if @support_user.update_attributes(params[:support_user])
        if @support_user.is_manager?
          response = Eschool::Coach.create_or_update_teacher_profile_with_multiple_qualifications(@support_user)
          if response
            response_xml = REXML::Document.new response.read_body
            status = response_xml.elements.to_a("//status").first.text
            if status == 'OK'
              redirect_to(view_support_profile_url, :notice => _('Profile_updated_successfullyA7192F63'))
            else
              message = response_xml.elements.to_a("//message").first.text
              redirect_to(view_support_profile_url, :flash => {:error => message})
            end
          else
            redirect_to(view_support_profile_url, :flash => {:error => "There is some problem, Please try again."})
          end
        else
          redirect_to(view_support_profile_url, :notice => _('Profile_updated_successfullyA7192F63'))
        end
      else
        render :template => "support_user_portal/edit_profile"
      end
    else
      render :template => "support_user_portal/edit_profile"
    end
  end

  def edit_admin_profile
    @page_title = _("Edit_Profile995570ED")
    @admin_user = Admin.find_by_id(current_user.id) if admin_logged_in?
    if request.post?
      if @admin_user.update_attributes(params[:support_user])
        redirect_to(view_support_profile_url, :notice => _('Profile_updated_successfullyA7192F63'))
      else
        render :template => "support_user_portal/edit_admin_profile"
      end
    else
      render :template => "support_user_portal/edit_admin_profile"
    end
  end

  def preference_settings
    @page_title = _("Contact_Preferences2785E088")
    @support_user = current_user
    @preference_setting = @support_user.get_preference

    if manager_logged_in?
      @cm_preference_setting = CmPreference.find_by_account_id(current_user.id)
      @cm_pref_attr = [:orphaned_session_alert_email, :orphaned_session_alert_email_type, :orphaned_session_alert_screen, :receive_reflex_sms_alert] #US462
      @preference_setting[:orphaned_session_alert_email]= @cm_preference_setting ? @cm_preference_setting.email_alert_enabled : nil
      @preference_setting[:orphaned_session_alert_email_type]= @cm_preference_setting ? @cm_preference_setting.email_preference : nil
      @preference_setting[:orphaned_session_alert_screen]= @cm_preference_setting ? @cm_preference_setting.page_alert_enabled : true
      @preference_setting[:min_time_to_alert_for_session_with_no_coach] = @cm_preference_setting ? @cm_preference_setting.min_time_to_alert_for_session_with_no_coach : ALERT_SCHEDULE_FOR_SESSION_WITH_NO_COACH[2]
      @preference_setting[:receive_reflex_sms_alert]= @cm_preference_setting ? @cm_preference_setting.receive_reflex_sms_alert : false
    end

    if !coach_logged_in? && request.post?
      preference_settings_except_coach and return
    elsif request.post?
      preference_settings_for_coach and return
    else
      render :template => "support_user_portal/preference_settings"
    end
  end

  def preference_settings_for_coach
      account = params[:preference_setting].delete(:account)
      user = @support_user.update_attributes(account)
      if user.blank?
        flash[:error] = @support_user.errors.full_messages.join('. ')
      else
        if @preference_setting.update_attributes(params[:preference_setting])
          flash[:notice] = _("Your_preference_settings_were_updated_successfullyAA95F752")
        else
          @errors = @preference_setting.errors.full_messages.join('. ')
          flash[:error] = @errors
        end
      end
      redirect_to support_preference_settings_url and return
  end

  def preference_settings_except_coach
      mobile_phone = params[:preference_setting][:account][:mobile_phone]
      if manager_logged_in? && mobile_phone.empty? && (!params[:preference_setting][:receive_reflex_sms_alert].to_i.zero? or !params[:preference_setting][:coach_not_present_alert].to_i.zero?)
        flash[:error] = "Please enter a valid mobile number first to enable SMS alert features"
      else
        account = params[:preference_setting].delete(:account)
        user = @support_user.update_attributes(account)
        if user.blank?
          flash[:error] = @support_user.errors.full_messages.join('. ')
        else
            if manager_logged_in?
              cm_prefer = {}
              @cm_preference_setting = CmPreference.find_by_account_id current_user.id
              if @cm_preference_setting.nil?
                @cm_preference_setting = CmPreference.new
                @cm_preference_setting.account_id = current_user.id
                set_values(cm_prefer)
                @cm_preference_setting.save
              else
                set_values(cm_prefer)
                @cm_preference_setting.update_attributes(cm_prefer)
              end
            end
            if @preference_setting.update_attributes(params[:preference_setting]) and ((@cm_preference_setting and @cm_preference_setting.errors.empty?) or @cm_preference_setting.nil?)
              flash[:notice] = _("Your_preference_settings_were_updated_successfullyAA95F752")
            else
              @errors = @preference_setting.errors.full_messages.join('. ')
              if @cm_preference_setting
                @errors += @cm_preference_setting.errors.full_messages.join('. ')
              end
              flash[:error] = @errors
            end
        end
      end
      redirect_to support_preference_settings_url and return
  end

  private

  def restrict_access_to_support_pages
    return if ((current_user.type.to_s == 'Admin' && ['view_profile', 'edit_admin_profile'].include?(params[:action])) || (current_user.type.to_s == 'Coach' && ['preference_settings'].include?(params[:action])))
    if !["SupportUser", "SupportLead", "SupportHarrisonburgUser", "SupportConciergeUser"].include?(current_user.type.to_s)
      #US401
      if !(["LedUser", "CoachManager", "CommunityModerator"].include?(current_user.type.to_s) && ['view_profile', 'edit_profile', 'preference_settings'].include?(params[:action]))
        redirect_to_appropriate_url
      end
    end
  end

  def set_values(cm_prefer)
    @cm_preference_setting.email_alert_enabled = params[:preference_setting][:orphaned_session_alert_email]
    cm_prefer[:email_alert_enabled] = params[:preference_setting].delete(:orphaned_session_alert_email)
    @cm_preference_setting.email_preference = params[:preference_setting][:orphaned_session_alert_email_type]
    cm_prefer[:email_preference] = params[:preference_setting].delete(:orphaned_session_alert_email_type)
    @cm_preference_setting.min_time_to_alert_for_session_with_no_coach = params[:preference_setting][:min_time_to_alert_for_session_with_no_coach]
    cm_prefer[:min_time_to_alert_for_session_with_no_coach] = params[:preference_setting].delete(:min_time_to_alert_for_session_with_no_coach)
    @cm_preference_setting.page_alert_enabled = params[:preference_setting][:orphaned_session_alert_screen]
    cm_prefer[:page_alert_enabled] = params[:preference_setting].delete(:orphaned_session_alert_screen)
    @cm_preference_setting.receive_reflex_sms_alert = params[:preference_setting][:receive_reflex_sms_alert]
    cm_prefer[:receive_reflex_sms_alert] = params[:preference_setting].delete(:receive_reflex_sms_alert)
  end
end

