require File.dirname(__FILE__) + '/test_helper'

class RosettaStone::SslFunctionalityTest < Test::Unit::TestCase

  def test_force_ssl_does_nothing_if_already_ssl
    default_settings!
    controller = fake_controller(:ssl? => true, :redirect_to => false)
    RosettaStone::ForceSsl.filter(controller)
  end

  def test_force_non_ssl_does_nothing_if_already_not_ssl
    default_settings!
    controller = fake_controller(:ssl? => false, :redirect_to => false)
    RosettaStone::ForceNonSsl.filter(controller)
  end

  def test_force_ssl_redirects_to_https_if_http
    default_settings!
    controller = fake_controller(:ssl? => false, :redirect_to => 'https://host.domain:3443/path')
    RosettaStone::ForceSsl.filter(controller)
  end

  def test_force_non_ssl_redirects_to_http_if_https
    default_settings!
    controller = fake_controller(:ssl? => true, :redirect_to => 'http://host.domain:3000/path')
    RosettaStone::ForceNonSsl.filter(controller)
  end

  def test_https_port_not_in_redirect_url_if_standard
    fake_settings!(:https_port => 443)
    controller = fake_controller(:ssl? => false, :redirect_to => 'https://host.domain/path')
    RosettaStone::ForceSsl.filter(controller)
  end

  def test_http_port_not_in_redirect_url_if_standard
    fake_settings!(:http_port => 80)
    controller = fake_controller(:ssl? => true, :redirect_to => 'http://host.domain/path')
    RosettaStone::ForceNonSsl.filter(controller)
  end

  def test_defaults_from_mocking_lack_of_settings_file
    no_settings!
    class_list.each do |class_to_check|
      assert_false(class_to_check.instance_supports_ssl?)
      assert_equal(80, class_to_check.http_port)
      assert_equal(443, class_to_check.https_port)
    end
  end

  def test_no_forcing_to_ssl_if_no_settings_file
    no_settings!
    controller = fake_controller(:ssl? => false, :redirect_to => false)
    RosettaStone::ForceSsl.filter(controller)
  end

  def test_force_ssl_with_force_non_ssl_parameter_remembers_this_in_session_and_does_not_redirect
    default_settings!
    mock_session = {}
    controller = fake_controller(:ssl? => false, :redirect_to => false, :session => mock_session, :params => {:force_non_ssl => 'true'})
    RosettaStone::ForceSsl.filter(controller)
    assert_true(mock_session[:ssl_functionality_force_non_ssl])
  end

  def test_force_ssl_with_force_non_ssl_parameter_set_to_false_puts_nothing_in_session_and_redirects
    default_settings!
    mock_session = {}
    controller = fake_controller(:ssl? => false, :redirect_to => 'https://host.domain:3443/path', :session => mock_session, :params => {:force_non_ssl => 'false'})
    RosettaStone::ForceSsl.filter(controller)
    assert_equal({}, mock_session)
  end

  def test_force_ssl_with_force_non_ssl_in_session_does_not_redirect
    default_settings!
    mock_session = {:ssl_functionality_force_non_ssl => true}
    controller = fake_controller(:ssl? => false, :redirect_to => false, :session => mock_session)
    RosettaStone::ForceSsl.filter(controller)
    assert_true(mock_session[:ssl_functionality_force_non_ssl])
  end

private
  def fake_controller(options = {})
    request = fake_request(options)
    # using this whole hullabaloo instead of just mock() to disambiguate 
    # which mocking framework to use in apps that use rspec
    Mocha::Mockery.instance.named_mock('controller') do
      stubs(:request).returns(request)
      stubs(:session).returns(options[:session] || {})
      stubs(:params).returns(options[:params] || {})
      if options[:redirect_to] === true
        expects(:redirect_to).once
      elsif options[:redirect_to]
        expects(:redirect_to).with(options[:redirect_to]).once
      else
        expects(:redirect_to).never
      end
    end
  end

  def fake_request(options = {})
    mock_set = {
      :ssl? => false,
      :request_uri => '/path',
      :host => 'host.domain',
    }.merge(options.symbolize_keys)

    Mocha::Mockery.instance.named_mock('request') do
      stubs(mock_set)
    end
  end
end
