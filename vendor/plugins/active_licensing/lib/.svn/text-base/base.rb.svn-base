# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.

%w[
  rubyize
  exceptions
  stubs_for_product_pool_apis
  product_right_hash
  async_api_communicator
  api_communicator
  multicall_api_communicator
  request_and_response_handler
  multicall
  license.rb
  creation_account
  product_right
  extension
  consumable
  content_range
  locking
  product_pool
].each do |filename|
  require File.join(File.dirname(__FILE__), filename)
end

if defined?(Rails)
  %w[
    system_readiness/active_licensing_connectivity
  ].each do |filename|
    require File.join(File.dirname(__FILE__), filename)
  end
end

module RosettaStone #:nodoc:
  # The ActiveLicensing module includes all logic related to communicating with the License Server over the License Server API (LS API).
  module ActiveLicensing
    VERSION = "1.0.0"

    # Regular expressions for validation.
    module Regexp
      CREATION_ACCOUNT_IDENTIFIER = /^[^,|" ]?[^,|"]*[^,|" :]$/
      LICENSE_IDENTIFIER = CREATION_ACCOUNT_IDENTIFIER
    end

    # functionality for whether we allow actually connecting to the LS when in the test Rails environment
    class << self
      def allow_real_api_calls_in_test_mode!
        @allow_real_api_calls_override = true
      end

      def stop_allowing_real_api_calls_in_test_mode!
        @allow_real_api_calls_override = false
      end

      def allow_real_api_calls_override?
        !!@allow_real_api_calls_override
      end
    end

    # Base is a Singleton that manages handling a list of RequestAndResponseHandlers (from which License, CreationAccount, and Multicall all
    # descend). It also  handles creating an ApiCommunicator object, which the RequestAndResponseHandlers use to manage HTTP communication in
    # single-call and multi-call modes.
    class Base
      include Singleton
      include YamlSettings
      yaml_settings :config_file => "active_licensing.yml"

      if ActiveSupport::VERSION::MAJOR < 3
        class_inheritable_accessor :default_settings
      else
        class_attribute :default_settings
      end
      # These are the same default timeouts net::http uses.
      self.default_settings = {:open_timeout => 30, :read_timeout => 60}.with_indifferent_access
      hash_key_accessor :name => :communicators, :keys => [:api_communicator, :multicall_communicator]
      attr_accessor :request_and_response_handlers

      # Sets up a hash to cache RequestAndResponseHandler sublclasses, as well as initializing a new ApiCommunicator with settings dependent
      # on the current Rails environment.
      def initialize(opts={})
        self.request_and_response_handlers = {}.with_indifferent_access

        # if we are able to run in async mode, do so opportunistically
        if defined?(EM) && defined?(EM::HttpRequest) && EM.reactor_running?
          self.api_communicator = AsyncApiCommunicator.new(plugin_settings)
          # not worrying about multicall_communicator for async mode yet
        else
          self.multicall_communicator = MulticallApiCommunicator.new(plugin_settings)
          self.api_communicator = ApiCommunicator.new(plugin_settings)
        end

        @multicalling = false

      end

      # Handles calls for "license" or "creation_account" (or any other category, in the future) by trying to find the appropriate class inside of
      # RosettaStone::ActiveLicensing. See README file for usage.
      def method_missing(sym, *args, &block)
        class_name = "RosettaStone::ActiveLicensing::#{sym.to_s.classify}"
        self.request_and_response_handlers[sym] ||= class_name.constantize.new(:base => self)
      rescue NameError
        logger.info("#{class_name} is not a class in RosettaStone::ActiveLicensing!") if defined?(logger)
        super
      end

      def plugin_settings
        @plugin_settings ||= default_settings.merge(settings[Framework.env] || {})
      end

      # Delegates api_calls to the appropriate communicator, dependending on whether we're operating in multicall mode or not.
      def api_call(*args)
        (@multicalling ? multicall_communicator : api_communicator).api_call(*args)
      end
      def api_post(*args)
        (@multicalling ? multicall_communicator : api_communicator).api_post(*args)
      end

      # Allows for the multi-call capabilities of the License Server. Multi-call has two distinct advantages:
      # * It allows for fewer HTTP requests, thus decreasing overall latency
      # * It allows for full transactionality, such that all requests are rolled back if any one request should fail
      #
      # See README for usage.
      def multicall(&block)
        @multicalling = true
        multi_caller = RosettaStone::ActiveLicensing::Multicall.new(:base => self)
        multi_caller.call(&block)
      ensure
        @multicalling = false
      end

      # FIXME - maybe the credentials should be a class variable? Seems like they possibly should be.
      def with_credentials(username, password, &block)
        original_credentials_set = communicators.map do |name, communicator|
          original_credentials = communicator.credentials.dup
          communicator.set_credentials(username, password)
          [name, original_credentials]
        end
        block.call
      ensure
        # Ensure we set the credentials back to their original value for each communicator
        original_credentials_set.each do |name, credentials|
          send(name).set_credentials(credentials[:username], credentials[:password])
        end
      end

    end # Base
  end # ActiveLicensing
end # RosettaStone
