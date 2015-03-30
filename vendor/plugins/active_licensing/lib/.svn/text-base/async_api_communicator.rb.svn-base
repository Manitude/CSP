# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.

require 'pathname'

module RosettaStone #:nodoc:
  module ActiveLicensing #:nodoc:
    # The AsyncApiCommunicator handles all HTTP communication with the License Server.
    class AsyncApiCommunicator
      hash_key_accessor :name => :configuration, :keys => [:host, :port, :proxy_host, :proxy_port, :endpoint_path, :open_timeout, :read_timeout]
      hash_key_accessor :name => :api_credentials, :keys => [:api_username, :api_password]

      # Sets up communication options (loaded from a YAML file in Base). Also, sets up an empty array of queued_calls for multi-call mode.
      def initialize(communication_options)
        if defined?(Rails)
          raise "HOSED CONFIG: Check your config/active_licensing.yml file for a '#{RAILS_ENV}' environment stanza!" unless communication_options
        elsif defined?(Goliath)
          raise "HOSED CONFIG: Check your config/active_licensing.yml file for a '#{Goliath.env}' environment stanza!" unless communication_options
        end
        communication_options.each { |k,v| send(:"#{k}=", v) }
        @queued_calls = []
      end

      # Makes the appropriate GET request to the license server and returns the response body received.
      def api_call(api_category, method_name, opts)
        with_http_retry do
          http_client(request_path(api_category, method_name, opts)).aget :head => {'authorization' => [api_username, api_password]}
        end
      end

      def api_post(api_category, method_name, data)
        data = data.to_query if data.is_a?(Hash)
        with_http_retry do
          http_client(request_path(api_category, method_name)).apost :head => {'authorization' => [api_username, api_password]}, :body => data
        end
      end

      def set_credentials(username, password)
        self.api_username = username
        self.api_password = password
      end

      def credentials
        {:username => api_username, :password => api_password}
      end

    private
      # Given a block, and an optional max_attempts argument, this method hands a Net::HTTP object off to
      # the block and tries to call it. If an exception is raised, it retries until max_attempts is reached.
      def with_http_retry(&block)
        raise "Was about to contact the LS for real.  You should either mock LS requests or use RosettaStone::ActiveLicensing.allow_real_api_calls_in_test_mode!" if raise_on_api_call?
        retry_deferrable = block.call
        user_deferrable = EM::DefaultDeferrable.new
        retry_deferrable.callback { |client| user_deferrable.succeed client }
        setup_retry_callbacks(retry_deferrable, user_deferrable, block, 0)
        user_deferrable
      end

      def setup_retry_callbacks(retry_deferrable, user_deferrable, block, retry_attempts)
        retry_deferrable.errback do |client|
          retry_attempts += 1
          if retry_attempts > 2
            user_deferrable.fail ConnectionException.new
          else
            new_deferrable = block.call
            new_deferrable.instance_variable_set("@callbacks", retry_deferrable.instance_variable_get("@callbacks"))
            new_deferrable.errback do
              setup_retry_callbacks(new_deferrable, user_deferrable, block, retry_attempts)
            end
          end
        end
      end

      def http_client(request_path)
        EM::HttpRequest.new(request_path, default_emhttp_options)
      end

      def default_emhttp_options
        opts = {:connect_timeout => open_timeout.to_i,
                :inactivity_timeout => read_timeout.to_i}
        if proxy_host && proxy_port
            opts.merge!({:proxy => {:host => proxy_host, :port => proxy_port}})
        end
        opts
      end

      # raise by default when in test mode, unless overridden.  see:
      #  * RosettaStone::ActiveLicensing.allow_real_api_calls_in_test_mode!
      #  * RosettaStone::ActiveLicensing.stop_allowing_real_api_calls_in_test_mode!
      def raise_on_api_call?
        return false if RosettaStone::ActiveLicensing.allow_real_api_calls_override?
        if defined?(Rails)
          Rails.test?
        elsif defined?(Goliath)
          Goliath.env?(:test)
        else
          false
        end
      end

      # Returns the path for an API HTTP request based on the category and method_name
      def request_path(api_category, method_name, opts={})
        "http://#{host}:#{port}" + Pathname.new("/#{endpoint_path}/#{api_category}/#{method_name}").cleanpath.to_s.tap do |path|
          path << "?#{opts.to_query}" if opts && opts.any?
        end
      end

      # Creates some wrapping XML that is used when sending requests to the license server as XML POSTs rather
      # than GETs
      def license_server_request_xml(&block)
        xml_out = ''
        xml_out.tap do
          xml = Builder::XmlMarkup.new(:indent => 2, :target => xml_out)
          xml.instruct!(:xml, :version => '1.0')
          xml.request(:client_version => RosettaStone::ActiveLicensing::VERSION, :client_name => "ActiveLicensing", &block)
        end
      end

      def credentials_configured?
        !api_username.blank? && !api_password.blank?
      end

    end # ApiCommunicator
  end # ActiveLicensing
end # RosettaStone
