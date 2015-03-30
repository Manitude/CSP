# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.

require 'pathname'

module RosettaStone #:nodoc:
  module ActiveLicensing #:nodoc:
    # The ApiCommunicator handles all HTTP communication with the License Server.
    class ApiCommunicator
      include RosettaStone::PrefixedLogger
      hash_key_accessor :name => :configuration, :keys => [:host, :port, :proxy_host, :proxy_port, :endpoint_path, :open_timeout, :read_timeout]
      hash_key_accessor :name => :api_credentials, :keys => [:api_username, :api_password]

      # Sets up communication options (loaded from a YAML file in Base). Also, sets up an empty array of queued_calls for multi-call mode.
      def initialize(communication_options)
        raise "HOSED CONFIG: Check your config/active_licensing.yml file for a '#{RAILS_ENV}' environment stanza!" unless communication_options
        communication_options.each { |k,v| send(:"#{k}=", v) }
        @queued_calls = []
      end

      # Makes the appropriate GET request to the license server and returns the response body received.
      def api_call(api_category, method_name, opts)
        with_http_retry(request_path(api_category, method_name)) { |http| http.get(request_path(api_category, method_name, opts)).body }
      end

      def api_post(api_category, method_name, data)
        path = request_path(api_category, method_name)
        data = data.to_query if data.is_a?(Hash)
        with_http_retry(path) { |http| http.post(path, :data => data).body }
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
      def with_http_retry(path_for_log_message, max_attempts = 3, &block)
        raise "Was about to contact the LS for real.  You should either mock LS requests or use RosettaStone::ActiveLicensing.allow_real_api_calls_in_test_mode!" if raise_on_api_call?
        attempt = 1
        begin
          log_benchmark("sending LS API request to #{path_for_log_message} (attempt #{attempt})") do
            block.call(http_client)
          end
        rescue SimpleHTTP::Client::SimpleHTTPException => e
          Framework.logger.fatal("Error while contacting license server, retrying: #{e.class}: #{e.message}")
          attempt += 1
          retry unless attempt > max_attempts
          raise ConnectionException.new(:original_exception => e), "Could not Connect to the License Server"
        end
      end

      def http_client
        @http ||= SimpleHTTP::Client.new(default_simplehttp_options)
      end

      def default_simplehttp_options
        opts = {:host => host, :port => port, :open_timeout => open_timeout.to_i,
                :read_timeout => read_timeout.to_i, :proxy_host => proxy_host, :proxy_port => proxy_port}
        opts.merge!(:http_user => api_username, :http_password => api_password) if credentials_configured?
        opts
      end

      # raise by default when in test mode, unless overridden.  see:
      #  * RosettaStone::ActiveLicensing.allow_real_api_calls_in_test_mode!
      #  * RosettaStone::ActiveLicensing.stop_allowing_real_api_calls_in_test_mode!
      def raise_on_api_call?
        return false if RosettaStone::ActiveLicensing.allow_real_api_calls_override?
        Framework.test?
      end

      # Returns the path for an API HTTP request based on the category and method_name
      def request_path(api_category, method_name, opts={})
        Pathname.new("/#{endpoint_path}/#{api_category}/#{method_name}").cleanpath.to_s.tap do |path|
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
