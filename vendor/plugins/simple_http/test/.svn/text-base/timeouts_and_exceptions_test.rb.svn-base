# -*- encoding : utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper')

class TimeoutsAndExceptionsTest < Test::Unit::TestCase

  def setup
    SimpleHttpTestServer.start(:before_filter => instance_variable_setting_filter)
  end

  def test_setting_open_timeout_in_instantiation
    Net::HTTP.any_instance.expects(:open_timeout=).with(47)
    capture_from_webrick(:default_client, :extra_options => {:open_timeout => 47}, :disregard_request => true) do |http|
      http.get(append_path('/?x=y'))
    end
  end

  def test_setting_open_timeout_in_singleton_request
    Net::HTTP.any_instance.expects(:open_timeout=).with(37)
    SimpleHTTP::Client.get(append_path('/?let=down', :with_host => true), :open_timeout => 37)
  end

  # Net::HTTP defaults to 60. we should too.
  def test_not_setting_read_timeout_in_instantiation
    Net::HTTP.any_instance.expects(:read_timeout=).with(60)
    capture_from_webrick(:default_client, :disregard_request => true) do |http|
      http.get(append_path('/?x=y'))
    end
  end

  def test_setting_read_timeout_in_instantiation
    Net::HTTP.any_instance.expects(:read_timeout=).with(47)
    capture_from_webrick(:default_client, :extra_options => {:read_timeout => 47}, :disregard_request => true) do |http|
      http.get(append_path('/?x=y'))
    end
  end

  # Net::HTTP defaults to 60. we should too.
  def test_not_setting_read_timeout_in_singleton_request
    Net::HTTP.any_instance.expects(:read_timeout=).with(60)
    SimpleHTTP::Client.get(append_path('/?let=down', :with_host => true))
  end

  def test_setting_read_timeout_in_singleton_request
    Net::HTTP.any_instance.expects(:read_timeout=).with(37)
    SimpleHTTP::Client.get(append_path('/?let=down', :with_host => true), :read_timeout => 37)
  end

  def test_open_exception
    IO.stubs(:select).returns(nil)
    assert_raise(SimpleHTTP::Client::ConnectionException) do
      SimpleHTTP::Client.get(append_path('/?let=down', :with_host => true))
    end
  end

end
