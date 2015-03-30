# Copyright:: Copyright (c) 2009 Rosetta Stone
# License:: All rights reserved.

# These methods get included into Test::Unit::TestCase for your convenience when writing tests.
module RosettaStone
  module TestUnitSslExtensions
    def instance_has_ssl_enabled!
      ssl_functionality_classes.each {|ssl_class| ssl_class.stubs(:instance_supports_ssl?).returns(true) }
    end

    def instance_has_ssl_disabled!
      ssl_functionality_classes.each {|ssl_class| ssl_class.stubs(:instance_supports_ssl?).returns(false) }
    end

    def https_port!(port = 443)
      ssl_functionality_classes.each {|ssl_class| ssl_class.stubs(:https_port).returns(port) }
    end

    def http_port!(port = 80)
      ssl_functionality_classes.each {|ssl_class| ssl_class.stubs(:http_port).returns(port) }
    end

    def simulated_ssl_request_headers
      { 'HTTP_X_FORWARDED_PROTO' => 'https' }
    end

    def assert_redirected_to_http
      assert_response :redirect
      assert(@response.redirected_to.is_a?(String), "Redirect target was not a full URL")
      assert_match(%r{^http://}, @response.redirected_to)
    end

    def assert_redirected_to_https
      assert_response :redirect
      assert(@response.redirected_to.is_a?(String), "Redirect target was not a full URL")
      assert_match(%r{^https://}, @response.redirected_to)
    end

  private
    # list of classes for which class methods may have to be stubbed
    def ssl_functionality_classes
      [RosettaStone::SslFunctionality, RosettaStone::ForceSsl, RosettaStone::ForceNonSsl]
    end
  end
end

# Only require test/unit when you're in the test environment
# (otherwise it seems to output "0 tests, 0 assertions, 0 failures, 0 errors"
# when running any rake task).
if Rails.test?
  require 'test/unit'
  Test::Unit::TestCase.send(:include, RosettaStone::TestUnitSslExtensions)
end
