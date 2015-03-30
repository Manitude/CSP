# -*- encoding : utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper')

class ProxySettingsTest < Test::Unit::TestCase

  def setup
    SimpleHttpTestMockProxyServer.start(:on_request => lambda { |request,response| @request, @response = request, response })
  end

# Instance Method Tests

  def test_get_on_instances_is_made_through_a_configured_proxy
    capture_from_webrick(:default_client, :proxy => true) do |http|
      http.get(append_path('/?x=y'))
    end
    assert_request_method 'GET'
    assert_request_was_proxied
  end

  def test_put_on_instances_is_made_through_a_configured_proxy
    capture_from_webrick(:default_client, :proxy => true) do |http|
      http.put(append_path('/?a=b'), :data => 'foo')
    end
    assert_request_method 'PUT'
    assert_request_was_proxied
  end

  def test_post_on_instances_is_made_through_a_configured_proxy
    capture_from_webrick(:default_client, :proxy => true) do |http|
      http.post(append_path('/?no=surprises&alarms=none'), :data => 'such a pretty house')
    end
    assert_request_method 'POST'
    assert_request_was_proxied
  end

  def test_delete_on_instances_is_made_through_a_configured_proxy
    capture_from_webrick(:default_client, :proxy => true) do |http|
      http.delete(append_path('/?paranoid=android'), :data => 'kicking')
    end
    assert_request_method 'DELETE'
    assert_request_was_proxied
  end

  def test_head_on_instances_is_made_through_a_configured_proxy
    capture_from_webrick(:default_client, :proxy => true) do |http|
      http.head(append_path('/?let=down'), :data => 'kicking')
    end
    assert_request_method 'HEAD'
    assert_request_was_proxied
  end

# Singleton Method Tests

  def test_get_singleton_method_is_made_through_a_configured_proxy
    capture_from_webrick do
      SimpleHTTP::Client.get(append_path('/?x=y', :with_host => true, :proxy => true), default_proxy_options)
    end
    assert_request_method 'GET'
    assert_request_was_proxied
  end


  def test_put_singleton_method_is_made_through_a_configured_proxy
    capture_from_webrick do
      SimpleHTTP::Client.put(append_path('/?a=b', :with_host => true, :proxy => true), default_proxy_options)
    end
    assert_request_method 'PUT'
    assert_request_was_proxied
  end

  def test_post_singleton_method_is_made_through_a_configured_proxy
    capture_from_webrick do
      SimpleHTTP::Client.post(append_path('/?no=surprises&alarms=none', :with_host => true, :proxy => true), default_proxy_options)
    end
    assert_request_method 'POST'
    assert_request_was_proxied
  end

  def test_delete_singleton_method_is_made_through_a_configured_proxy
    capture_from_webrick do
      SimpleHTTP::Client.delete(append_path('/?paranoid=android', :with_host => true, :proxy => true), default_proxy_options)
    end
    assert_request_method 'DELETE'
    assert_request_was_proxied
  end

  def test_head_singleton_method_is_made_through_a_configured_proxy
    capture_from_webrick do
      SimpleHTTP::Client.head(append_path('/?let=down', :with_host => true, :proxy => true), default_proxy_options)
    end
    assert_request_method 'HEAD'
    assert_request_was_proxied
  end

end
