# -*- encoding : utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper')

class BasicAuthenticationTest < Test::Unit::TestCase

  def setup
    SimpleHttpTestServer.start(:before_filter => instance_variable_setting_filter)
    @credentials = {:http_user => 'stephen', :http_password => 'colbert'}
  end

# Instance Method Tests

  def test_get_on_an_instance_sends_auth_credentials
    capture_from_webrick(:default_client) do |http|
      http.get(append_path('/?x=y'), @credentials)
    end
    assert_request_credentials @credentials
  end

  def test_put_on_an_instance_sends_auth_credentials
    capture_from_webrick(:default_client) do |http|
      http.put(append_path('/?a=b'), {:data => 'foo'}.merge(@credentials))
    end
    assert_request_credentials @credentials
  end

  def test_post_on_an_instance_sends_auth_credentials
    capture_from_webrick(:default_client) do |http|
      http.post(append_path('/?no=surprises&alarms=none'), {:data => 'such a pretty house'}.merge(@credentials))
    end
    assert_request_credentials @credentials
  end

  def test_delete_on_an_instance_sends_auth_credentials
    capture_from_webrick(:default_client) do |http|
      http.delete(append_path('/?paranoid=android'), {:data => 'kicking'}.merge(@credentials))
    end
    assert_request_credentials @credentials
  end

  def test_head_on_an_instance_sends_auth_credentials
    capture_from_webrick(:default_client) do |http|
      http.head(append_path('/?let=down'), {:data => 'kicking'}.merge(@credentials))
    end
    assert_request_credentials @credentials
  end

# Singleton Method Tests

  def test_get_singleton_method_sends_auth_credentials
    capture_from_webrick do
      SimpleHTTP::Client.get(append_path('/?x=y', :with_host => true), @credentials)
    end
    assert_request_credentials @credentials
  end

  def test_put_singleton_method_sends_auth_credentials
    capture_from_webrick do
      SimpleHTTP::Client.put(append_path('/?a=b', :with_host => true), {:data => 'foo'}.merge(@credentials))
    end
    assert_request_credentials @credentials
  end

  def test_post_singleton_method_sends_auth_credentials
    capture_from_webrick do
      SimpleHTTP::Client.post(append_path('/?no=surprises&alarms=none', :with_host => true), {:data => 'such a pretty house'}.merge(@credentials))
    end
    assert_request_credentials @credentials
  end

  def test_delete_singleton_method_sends_auth_credentials
    capture_from_webrick do
      SimpleHTTP::Client.delete(append_path('/?paranoid=android', :with_host => true), {:data => 'kicking'}.merge(@credentials))
    end
    assert_request_credentials @credentials
  end

  def test_head_singleton_method_sends_auth_credentials
    capture_from_webrick do
      SimpleHTTP::Client.head(append_path('/?let=down', :with_host => true), {:data => 'kicking'}.merge(@credentials))
    end
    assert_request_credentials @credentials
  end

  def test_get_singleton_method_does_not_send_auth_credentials_when_they_are_nil
    @credentials = {:http_user => nil, :http_password => nil}
    capture_from_webrick do
      SimpleHTTP::Client.get(append_path('/?x=y', :with_host => true), @credentials)
    end
    assert_no_request_credentials
  end

  def test_get_singleton_method_does_not_send_auth_credentials_when_they_are_blank
    @credentials = {:http_user => '', :http_password => ''}
    capture_from_webrick do
      SimpleHTTP::Client.get(append_path('/?x=y', :with_host => true), @credentials)
    end
    assert_no_request_credentials
  end

  def test_get_singleton_method_does_not_send_auth_credentials_when_no_keys_are_specified
    @credentials = {}
    capture_from_webrick do
      SimpleHTTP::Client.get(append_path('/?x=y', :with_host => true), @credentials)
    end
    assert_no_request_credentials
  end

end
