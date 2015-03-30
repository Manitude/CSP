module ManagerPortalHelper
  def append_mm(hours_array)
    hours_array.collect{|x| x < 10 ? "0" + x.to_s + ":00" : x.to_s + ":00"}
  end

  def left_navigation_items
    lnav = []
    if manager_logged_in?
      lnav << {:link_text => _('Assign_CoachesBA50525D'),
        :selected_on => {'manager_portal' => ['assign_coaches']},
        :url_options => hash_for_assign_coaches_path}
      lnav << {:link_text => _('Manage_Languages5254C1D6'),
        :selected_on => {'manager_portal' => ['manage_languages']},
        :url_options => hash_for_manage_languages_path}
#      lnav << {:link_text => _('ConfigurationsCE781201'),
#        :selected_on => {'manager_portal' => ['configurations']},
#        :url_options => hash_for_configurations_path}
#      lnav << {:link_text => _('Create_Session85D580AB'),
#        :selected_on => {'manager_portal' => ['create_eschool_session']},
#        :url_options => hash_for_create_eschool_session_path}
      lnav << {:link_text => _('Cancel_SessionsD8C368A1'),
        :selected_on => {'manager_portal' => ['cancel_eschool_sessions']},
        :url_options => hash_for_cancel_eschool_sessions_path}
      lnav << {:link_text => _('Create_Coaches9182421A'),
        :selected_on => {'coach' => ['create_coach']},
        :url_options => hash_for_create_coach_path}
    end
    lnav
  end

  def currently_selected_left_nav_item
    found_nav = left_navigation_items.detect do |nav|
      nav[:selected_on].any? do |cont, actions|
        (params[:controller] == cont) && ((actions == :all) || actions.include?(params[:action]))
      end
    end
    found_nav ? found_nav : nil
  end

  #Converts "Advanced English" to advanced_english
  def classify(text)
    text.downcase.gsub(" ", "_")
  end
  
end
