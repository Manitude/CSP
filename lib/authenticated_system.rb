module AuthenticatedSystem

protected

  def logged_in?
    !current_user.nil?
  end

  def coach_logged_in?
    current_raw_user && current_raw_user.is_coach?
  end

  def aria_coach_logged_in?
    coach_logged_in? && current_user.is_only_aria?
  end
  def manager_logged_in?
    current_raw_user && current_raw_user.is_manager?
  end

  def admin_logged_in?
    current_raw_user && current_raw_user.is_admin?
  end

  def tier1_support_user_logged_in?
    current_raw_user && current_raw_user.is_tier1_support_user?
  end

  def tier1_support_lead_logged_in?
    current_raw_user && current_raw_user.is_tier1_support_lead?
  end

  def tier1_user_logged_in?
    tier1_support_user_logged_in? || tier1_support_lead_logged_in? ||
      tier1_support_harrisonburg_user_logged_in? || tier1_support_concierge_user_logged_in?
  end

  def tier1_support_user_or_lead_logged_in?
    tier1_support_user_logged_in? || tier1_support_lead_logged_in?
  end

  def community_moderator_logged_in?
    current_raw_user && current_raw_user.is_community_moderator?
  end

  def led_user_logged_in?
    current_raw_user && current_raw_user.is_led_user?
  end

  def tier1_support_harrisonburg_user_logged_in?
    current_raw_user && current_raw_user.is_tier1_support_harrisonburg_user?
  end

  def tier1_support_concierge_user_logged_in?
    current_raw_user && current_raw_user.is_tier1_support_concierge_user?
  end

  def current_coach
    (coach_logged_in?)? current_user : nil
  end

  def current_manager
    (manager_logged_in?)? current_user : nil
  end

  def current_admin
    (admin_logged_in?)? current_user : nil
  end

  def current_user
    current_raw_user && current_raw_user.account
  end

  def current_user_name
    current_user.display_name
  end

  # Store the given user in the session.
  def current_user=(new_user)
    session[:user] = new_user
  end

  # Since current_user has been molested to turn into Account model
  def current_raw_user
    session[:user]
  end

  # Filter method to enforce a login requirement.
  #
  # To require logins for all actions, use this in your controllers:
  #
  #   before_filter :login_required
  #
  # To require logins for specific actions, use this in your controllers:
  #
  #   before_filter :login_required, :only => [ :edit, :update ]
  #
  # To skip this in a subclassed controller:
  #
  #   skip_before_filter :login_required
  #
  def login_required
    if !logged_in?
      store_location
      redirect_to_login("You are not signed in. Please sign in.")
    end
  end
  
  def redirect_to_login(message)
    respond_to do |format|
      format.html do
        flash[:error] = message
        redirect_to(login_url, :flash => session[:flash])
      end
    end
  end
  
  # Redirect as appropriate when an access request fails.
  #
  # The default action is to redirect to the login screen.
  #
  # Override this method in your controllers if you want to have special
  # behavior in case the user is not authorized
  # to access the requested action.  For example, a popup window might
  # simply close itself.
  def access_denied
    redirect_to_login("Sorry, you are not authorized to view the requested page. Please contact the IT Help Desk.")
  end

  # Store the URI of the current request in the session.
  #
  # We can return to this location by calling #redirect_back_or_default.
  def store_location
    session[:return_to] = request.fullpath
  end

  # Redirect to the URI stored by the most recent store_location call or
  # to the passed default.
  def redirect_back_or_default(default)
    return_url  = session[:return_to]
    session[:return_to] = nil
    redirect_to(return_url || default, :flash => session[:flash]) and return
  end

  # Inclusion hook to make current_user, logged_in?
  # available as ActionView helper methods.
  def self.included(base)
    base.send :helper_method, :current_user, :current_coach, :current_manager, :current_admin, :logged_in?, :coach_logged_in?, :manager_logged_in?, :admin_logged_in?, :current_user_name, :tier1_support_user_logged_in?, :tier1_support_lead_logged_in?, :tier1_user_logged_in?, :community_moderator_logged_in?, :led_user_logged_in?, :tier1_support_harrisonburg_user_logged_in?, :tier1_support_concierge_user_logged_in?, :tier1_support_user_or_lead_logged_in?, :aria_coach_logged_in?
  end
end
