require File.dirname(__FILE__) + '/test_helper'

class RosettaStone::SslFunctionalityTestController < ActionController::Base
  before_filter RosettaStone::ForceSsl, :only => :force_ssl
  before_filter RosettaStone::ForceNonSsl, :only => :force_non_ssl
  
  def force_ssl
    render(:text => request.protocol)
  end

  def force_non_ssl
    render(:text => request.protocol)    
  end
end

class RosettaStone::SslFunctionalityIntegrationTest < ActionController::IntegrationTest

  def setup
    host! 'localhost'
    fake_settings!(:enable_ssl => true, :http_port => 80, :https_port => 443)
    ActionController::Routing::Routes.clear!
    ActionController::Routing::Routes.draw {|map| map.connect 'ssl_functionality_test/:action', :controller => 'rosetta_stone/ssl_functionality_test' }
  end

  def teardown
    # Reloading routes from routes.rb 
    ActionController::Routing::Routes.reload!
  end

  def test_force_ssl_with_http
    https!(false)
    get 'ssl_functionality_test/force_ssl'
    assert_response :redirect
    assert_redirected_to('https://localhost/ssl_functionality_test/force_ssl')
  end

  def test_force_ssl_with_https
    https!(true)
    get 'ssl_functionality_test/force_ssl'
    assert_response :success
  end

  def test_force_non_ssl_with_https
    https!(true)
    get 'ssl_functionality_test/force_non_ssl'
    assert_response :redirect
    assert_redirected_to('http://localhost/ssl_functionality_test/force_non_ssl')
  end

  def test_force_non_ssl_with_http
    https!(false)
    get 'ssl_functionality_test/force_non_ssl'
    assert_response :success
  end

  def test_keep_current_port_and_protocol
    assert_equal({}, get_current_port_and_protocol(80, false))
    assert_equal({:port => 3000}, get_current_port_and_protocol(3000, false))
    assert_equal({:protocol => 'https'}, get_current_port_and_protocol(443, true))
    assert_equal({:protocol => 'https', :port => 8443}, get_current_port_and_protocol(8443, true))
  end

private
  def get_current_port_and_protocol(port = 80, ssl = false)
    https!(ssl)
    # this may only work in Rails 2.2 and up... fix it if you encounter the need
    action_controller_request_class_to_mock.any_instance.expects(:port).at_least_once.returns(port)
    get 'ssl_functionality_test/force_ssl'
    controller.keep_current_port_and_protocol
  end

  # handle compatibility across various versions of Rails
  def action_controller_request_class_to_mock
    if defined?(ActionController::RackRequest) # 2.2
      ActionController::RackRequest
    elsif defined?(ActionController::Request) # 2.3
      ActionController::Request
    else # 2.0
      ActionController::CgiRequest
    end
  end
end
