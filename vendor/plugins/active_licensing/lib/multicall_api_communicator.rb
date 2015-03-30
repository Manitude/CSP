# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.

require 'pathname'

module RosettaStone #:nodoc:
  module ActiveLicensing #:nodoc:
    class MulticallApiCommunicator < ApiCommunicator
      attr_reader :queued_calls

      def initialize(*args)
        super
        @queued_calls = []
      end

      # Takes API calls and queues them up to be sent by dispatch_calls later. Returns the symbol :defer_handling
      # in order to let any response handlers know they dont yet have a response to handle.
      # def api_call
      # def api_post
      %w(call post).each do |call_type|
        define_method("api_#{call_type}") do |api_category, method_name, opts|
          queue_call(api_category, method_name, opts)
          return :defer_handling
        end
      end

      # Builds the multicall request XML and makes the HTTP POST to the license server. Clears the call queue afterwards.
      def dispatch_calls
        raise NoApiCallsSpecified, 'At least one API call must be in the multicall request' if queued_calls.empty?
        path = request_path('multicall', 'index')
        with_http_retry(path) { |http| http.post(path, :headers => {'Content-Type' => 'application/xml'}, :data => multicall_request_xml).body }
      ensure
        queued_calls.clear
      end

    private
      # Adds an api call to the call queue
      def queue_call(api_category, method_name, opts)
        queued_calls << {:api_category => api_category, :method_name => method_name, :params => opts}
      end

      # Creates the appropriate XML for POSTing to the License Server's Multicall Controller. There is one <call> element for every
      # queued call.
      def multicall_request_xml(calls = queued_calls)
        license_server_request_xml do |xml|
          xml.multicall do
            calls.each do |call_hash|
              xml.call(:path => request_path(call_hash[:api_category], call_hash[:method_name])) do
                call_hash[:params].each { |name, value| xml.parameter(value, :name => name) } if call_hash[:params]
              end
            end
          end
        end
      end

    end # MulticallApiCommunicator
  end # ActiveLicensing
end # RosettaStone
