# -*- encoding : utf-8 -*-
ENV['RAILS_ENV'] = 'test'
require File.dirname(__FILE__) + '/../../../../test/test_helper.rb' unless defined?(RAILS_ROOT)
$: << File.dirname(__FILE__) + '/../lib'
require File.join(File.expand_path(File.dirname(__FILE__)), 'simple_http_test_servers')

class Test::Unit::TestCase

  # To wait for the request to be processed and @request and so forth to be set, all requests to the
  # test WEBrick server must be run from a block passed to this method.
  def capture_from_webrick(client_settings = nil, options = {})
    @request = @response = @params = nil
    if client_settings == :default_client
      client_options = default_client_options.merge(options[:extra_options] || {})
      client_options.merge!(default_proxy_options).merge!(:host => 'example.com') if options[:proxy]
      r = yield(SimpleHTTP::Client.new(client_options))
    else
      r = yield
    end
    while @request.nil? do
      true
    end if !options[:disregard_request]
    return r
  end

  def default_client_options
    {:host => '127.0.0.1', :port => SimpleHttpTestServer.default_port}
  end

  def default_proxy_options
    {:proxy_host => default_client_options[:host], :proxy_port => SimpleHttpTestMockProxyServer.default_port}
  end

  def append_path(path, options = {})
    full_path = SimpleHttpTestServer::TEST_SERVER_MOUNT_PATH + path
    host = options[:proxy] ? 'example.com' : default_client_options[:host]
    options[:with_host] ? "http://#{host}:#{default_client_options[:port]}#{full_path}" : full_path
  end

  def assert_request_method(request_method)
    assert_equal request_method, @request.request_method
  end

  def assert_query_string(query_string)
    assert_equal query_string, @request.query_string
  end

  def assert_request_has_body(body = nil)
    if !body.nil?
      assert_equal body, @request.body
    else
      assert !@request.body.nil?
    end
  end

  def assert_request_has_no_body
    assert_nil @request.body
  end

  def assert_request_was_proxied
    assert_equal 'example.com', @request.host
    # the request port shouldnt be the same as the port that was connected to if proxying.
    assert @request.port != @request.addr[1]
  end

  def assert_request_credentials(credentials = {})
    assert_equal credentials[:http_user], @request.username
    assert_equal credentials[:http_password], @request.password
  end

  def assert_no_request_credentials
    assert_nil @request.username
    assert_nil @request.password
  end

  def instance_variable_setting_filter
    lambda { |request,response,params| @request, @response, @params = request, response, params }
  end

end
