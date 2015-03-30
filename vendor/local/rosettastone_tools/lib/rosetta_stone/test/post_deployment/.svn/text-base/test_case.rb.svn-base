# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.
require File.join(File.dirname(__FILE__), 'test_definitions')

class RosettaStone::PostDeployment::TestCase < ActiveSupport::TestCase
  attr_accessor :response
  extend RosettaStone::PostDeployment::TestDefinitions # contains the test "builders" for this suite
  include ActionController::Assertions::SelectorAssertions # for assert_select

  class << self
    def default_host
      raise "Override me"
    end

    # run with:
    # instance=local
    # instance=staging ...
    # instance=production ...
    def instance
      ENV['instance'] || 'opxdev'
    end

    def build_tests(test_definitions = {})
      test_definitions.each do |uri, definitions|
        definitions.each do |definition|
          build_test(uri, definition)
        end
      end
    end

    def build_test(uri, definition)
      # these builders are in TestDefinitions
      builder = "build_#{definition}_test"
      if respond_to?(builder)
        send(builder, uri)
      else
        raise ArgumentError, "Unrecognized test type: #{definition}"
      end
    end

    def http_and_https_host_set_for(base_host_names, domain = 'rosettastone.com')
      base_host_names.map do |base_host_name|
        %w(http https).map do |protocol|
          "#{protocol}://#{base_host_name}.#{domain}"
        end
      end.flatten
    end

  end

  def get(raw_uri, request_headers = {})
    uri = URI.parse(raw_uri)
    uri.host ||= klass.default_host
    uri.scheme ||= 'http'
    proxy_config = proxy_for_host_and_protocol["#{uri.scheme}://#{uri.host}"]
    raise "No proxy config for #{uri.scheme}://#{uri.host}" unless proxy_config

    simple_http_config = proxy_config.merge(:headers => request_headers, :use_ssl => (uri.scheme == 'https'))
    client = SimpleHTTP::Client.new(simple_http_config)
    logger.debug("requesting #{uri.to_s} with configuration #{simple_http_config.inspect}")
    self.response = client.get(uri.to_s)
    decorate_response!
  end

  # add a content_type method to the response object to make assert_select happy
  def decorate_response!
    class << response
      def content_type
        get_header('Content-Type')
      end
    end
    response
  end

  def http_proxy_host_and_port_for_instance
    case klass.instance
      when 'local' then {:proxy_host => '127.0.0.1', :proxy_port => 80}
      when 'opxdev' then {:proxy_host => 'opxdev.lan.flt', :proxy_port => 80}
      when 'staging' then
        Proc.new do |asset_host|
          if asset_host =~ /resources.rosettastone.com/
            #{:proxy_host => 'resources.rosettastone.com.edgekey-staging.net', :proxy_port => 80}
            {:proxy_host => '10.40.211.131', :proxy_port => 80}
          else
            {:proxy_host => 'giocondo.lan.flt', :proxy_port => 3128}
          end
        end
      when 'production' then {:proxy_host => nil, :proxy_port => nil}
    else
      raise "Unknown instance: #{klass.instance}"
    end
  end

  def https_proxy_host_and_port_for_instance
    case klass.instance
      when 'local' then {:proxy_host => '127.0.0.1', :proxy_port => 8080}
      when 'opxdev' then {:proxy_host => 'opxdev.lan.flt', :proxy_port => 8080}
      when 'staging' then {:proxy_host => 'stgdeploy1.lan.flt', :proxy_port => 8080}
      when 'production' then {:proxy_host => nil, :proxy_port => nil}
    else
      raise "Unknown instance: #{klass.instance}"
    end
  end

  def proxy_for_asset_host(asset_host)
    configuration =
      if asset_host.starts_with?('https://')
        https_proxy_host_and_port_for_instance
      else
        http_proxy_host_and_port_for_instance
      end
    configuration.is_a?(Proc) ? configuration.call(asset_host) : configuration
  end

  def proxy_for_host_and_protocol
    klass.asset_hosts_for_instance.map_to_hash do |asset_host|
      { asset_host => proxy_for_asset_host(asset_host) }
    end
  end

  def with_gzip(other = {})
    other.merge('Accept-Encoding' => 'gzip,deflate')
  end

  def assert_gzip
    assert_equal('gzip', response.get_header('Content-Encoding'), "Expected response to be gzip encoded: #{response.inspect}")
  end

  def assert_no_gzip
    assert_not_equal('gzip', response.get_header('Content-Encoding'), "Expected response to not be gzip encoded: #{response.inspect}")
  end

  def assert_expires
    #assert_not_nil(expires = response.get_header('Expires'), "Expected to have an Expires header: #{response.inspect}")
    #assert_not_nil(expires_time = Time.parse(expires))
    #assert_true(expires_time > 1.month.from_now.utc, "Expected Expires date to be farther in the future: #{expires_time}")
    cc_header = response.get_header('Cache-Control').to_s
    assert_match('public', cc_header)
    assert_match(/max-age=\d+/, cc_header)
    age = (cc_header =~ /max-age=(\d+)/ && $1)
    # akamai seems to stomp on our max-age and replaces it with a number that starts around 1046851 which is about 12 days
    assert_true(age.to_i > 10.days.to_i, "Expiry age of '#{age}' not greater than 10 days")
  end

  def assert_no_expires
    assert([nil, '0'].include?(response.get_header('Expires')), "Expected not to have an Expires header: #{response.inspect}")
    assert_no_match(/public/, response.get_header('Cache-Control').to_s)
    assert_no_match(/max-age=[^0]/, response.get_header('Cache-Control').to_s)
  end

  def assert_no_cache
    # FIXME: what should we set?  for 404's we seem to set 'no-cache' while on dynamic responses we have
    # 'private, max-age=0, must-revalidate'.  what's the difference?  should we care?
    valid_values = ['no-cache', 'private, max-age=0, must-revalidate']
    cache_control = response.get_header('Cache-Control').to_s
    assert_true(valid_values.any? {|valid_value| cache_control.include?(valid_value) }, "Expected #{cache_control} to indicate that caching is disallowed")
  end

  def assert_no_transform
    assert_match(/\bno-transform\b/, response.get_header('Cache-Control').to_s, "Expected #{response.get_header('Cache-Control')} to include no-transform")
  end

  def assert_not_no_transform
    assert_no_match(/no-transform/, response.get_header('Cache-Control').to_s, "Expected #{response.get_header('Cache-Control')} to not include no-transform")
  end

  # we add -gzip to the ETag based on whether the client sent an Accept-Encoding header that indicates that it supports gzip.
  # so if your request doesn't support gzip, pass false for expected_gzip
  def assert_valid_etag(expected_gzip = true)
    assert_not_nil(etag = response.get_header('ETag'), "Expected to have an ETag header: #{response.inspect}")
    assert_match(%r{^".+"$}, etag)
    return if response.code.to_s == '304'
    if expected_gzip
      assert_match('-gzip"', etag)
    else
      assert_no_match(/gzip/, etag)
    end
    assert_no_match(/gzip-gzip/, etag)
  end

  def assert_status(status_code = 200)
    assert_not_nil(response)
    assert_equal(status_code.to_s, response.code.to_s)
  end

  def assert_success
    assert_status(200)
  end
end
