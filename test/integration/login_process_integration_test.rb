require File.expand_path('../../test_helper', __FILE__)
require 'application_controller'

class LoginProcessIntegrationTest  < ActionController::TestCase

  def test_accessing_dashboard_without_logging_in

    @controller = DashboardController.new
    get :index
    assert_response :redirect

    @controller = CoachPortalController.new
    get :edit_profile
    assert_response :redirect
    assert_equal "You are not signed in. Please sign in.", flash[:error]
    assert_equal "/dashboard", session[:return_to]
    
    stub_ldap_authentication_for_coach_manager
    post :login , :coach => {:user_name => "test32", :password => "Password32"}
    assert_equal "Signed in successfully", flash[:notice]
    assert_response :redirect
  end

  private

  def stub_ldap_authentication_for_coach_manager
    User.stubs(:bypass_authentication?).returns(true)
  end
end