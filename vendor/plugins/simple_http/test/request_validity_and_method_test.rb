# -*- encoding : utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper')

class RequestValidityAndMethodTest < Test::Unit::TestCase

  def setup
    SimpleHttpTestServer.start(:before_filter => instance_variable_setting_filter)
  end

# Instance Method Tests

  def test_get_on_an_instance_sends_a_valid_request
    capture_from_webrick(:default_client) do |http|
      http.get(append_path('/?x=y'))
    end
    assert_request_method 'GET'
    assert_query_string 'x=y'
    assert_request_has_no_body
  end

  def test_put_on_an_instance_sends_a_valid_request
    capture_from_webrick(:default_client) do |http|
      http.put(append_path('/?a=b'), :data => 'foo')
    end
    assert_request_method 'PUT'
    assert_query_string 'a=b'
    assert_request_has_body 'foo'
  end

  def test_post_on_an_instance_sends_a_valid_request
    capture_from_webrick(:default_client) do |http|
      http.post(append_path('/?no=surprises&alarms=none'), :data => 'such a pretty house')
    end
    assert_request_method 'POST'
    assert_query_string 'no=surprises&alarms=none'
    assert_request_has_body 'such a pretty house'
  end

  def test_delete_on_an_instance_sends_a_valid_request
    capture_from_webrick(:default_client) do |http|
      http.delete(append_path('/?paranoid=android'), :data => 'kicking')
    end
    assert_request_method 'DELETE'
    assert_query_string 'paranoid=android'
    assert_request_has_no_body
    assert_equal 'Infinity', @request.header['depth'].first
  end

  def test_head_on_an_instance_sends_a_valid_request
    capture_from_webrick(:default_client) do |http|
      http.head(append_path('/?let=down'), :data => 'kicking')
    end
    assert_request_method 'HEAD'
    assert_query_string 'let=down'
    assert_request_has_no_body
  end

# Singleton Method Tests

  def test_get_singleton_method_sends_a_valid_request
    capture_from_webrick do
      SimpleHTTP::Client.get(append_path('/?x=y', :with_host => true))
    end
    assert_request_method 'GET'
    assert_query_string 'x=y'
    assert_request_has_no_body
  end

  def test_put_singleton_method_sends_a_valid_request
    capture_from_webrick do
      SimpleHTTP::Client.put(append_path('/?a=b', :with_host => true), :data => 'foo')
    end
    assert_request_method 'PUT'
    assert_query_string 'a=b'
    assert_request_has_body 'foo'
  end

  def test_post_singleton_method_sends_a_valid_request
    capture_from_webrick do
      SimpleHTTP::Client.post(append_path('/?no=surprises&alarms=none', :with_host => true), :data => 'such a pretty house')
    end
    assert_request_method 'POST'
    assert_query_string 'no=surprises&alarms=none'
    assert_request_has_body 'such a pretty house'
  end

  def test_delete_singleton_method_sends_a_valid_request
    capture_from_webrick do
      SimpleHTTP::Client.delete(append_path('/?paranoid=android', :with_host => true), :data => 'kicking')
    end
    assert_request_method 'DELETE'
    assert_query_string 'paranoid=android'
    assert_request_has_no_body
    assert_equal 'Infinity', @request.header['depth'].first
  end

  def test_head_singleton_method_sends_a_valid_request
    capture_from_webrick do
      SimpleHTTP::Client.head(append_path('/?let=down', :with_host => true), :data => 'kicking')
    end
    assert_request_method 'HEAD'
    assert_query_string 'let=down'
    assert_request_has_no_body
  end

end
