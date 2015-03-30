# -*- encoding : utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper')

class ResponseValidityTest < Test::Unit::TestCase

  def setup
    SimpleHttpTestServer.start(:before_filter => instance_variable_setting_filter)
  end

  def test_get_receives_a_valid_response
    response = capture_from_webrick(:default_client) do |http|
      http.get(append_path('/?x=y'))
    end
    assert_valid_response_from_server(response)
  end

  def test_put_receives_a_valid_response
    response = capture_from_webrick(:default_client) do |http|
      http.put(append_path('/?a=b'), :data => 'foo')
    end
    assert_valid_response_from_server(response)
  end

  def test_post_receives_a_valid_response
    response = capture_from_webrick(:default_client) do |http|
      http.post(append_path('/?no=surprises&alarms=none'), :data => 'such a pretty house')
    end
    assert_valid_response_from_server(response)
  end

  def test_delete_receives_a_valid_response
    response = capture_from_webrick(:default_client) do |http|
      http.delete(append_path('/?paranoid=android'), :data => 'kicking')
    end
    assert_valid_response_from_server(response)
  end

  def test_head_receives_a_valid_response
    response = capture_from_webrick(:default_client) do |http|
      http.head(append_path('/?let=down'), :data => 'kicking')
    end
    assert_valid_response_from_server(response, false)
  end

  def test_get_header
    response = capture_from_webrick(:default_client) do |http|
      http.get(append_path('/?x=y'))
    end
    assert_not_nil(content_length = response.get_header('Content-Length'))
    assert_equal(content_length, response.get_header('content-length'))
    assert_nil(response.get_header('Some-nonexistent-header'))
  end

private

  def assert_valid_response_from_server(response, has_body = true)
    assert_equal '200', response.status
    assert_equal '1.1', response.http_version
    if has_body
      assert_equal 'OK', response.body
    else
      assert_nil response.body
    end
    assert_true(response.headers.is_a?(Hash))
    assert_not_nil(response.get_header('Connection'))
  end

end
