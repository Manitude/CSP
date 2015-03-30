# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.

require 'rexml/document'

module RosettaStone #:nodoc:
  module ActiveLicensing #:nodoc:
    # A RequestAndResponseHandler that handles parsing the result of a multi-call response XML by splitting the XML and calling the appropriate
    # RequestAndResponseHandlers in either License and CreationAccount handlers.
    class Multicall < RequestAndResponseHandler

      # Evaluates the block in the context of the Base (which is how the API calls get queued up, when api_call is called via the License and
      # CreationAccount handlers), then dispatches the call and handles the response.
      def call(&block)
        base.instance_eval(&block)
        # Duped because multicall_communicator clears the queue after it dispatches.
        queued_calls = base.multicall_communicator.queued_calls.dup
        handle_multicall_response(queued_calls, base.multicall_communicator.dispatch_calls)
      end

    private

      # Handles the parsing of the response from a multi-call API call by splitting the XML up into multiple responses and having each response
      # get parsed by the appropriate handler.
      def handle_multicall_response(calls, response_body)
        rexml_document = parse_response(response_body)
        xml_responses = split_xml(rexml_document)

        responses = []
        xml_responses.each_with_index do |xml_response,index|
          next unless call = calls[index]

          api_category, method_name = call[:api_category], call[:method_name]
          api_response = base.request_and_response_handlers[api_category].send(:handle_response, method_name, xml_response)
          responses << { :api_category => api_category, :method_name => method_name, :response => api_response }
        end

        responses
      rescue LicenseServerException => original_exception
        logger.error("Multicall response included exception: #{original_exception.class} (#{original_exception.inspect})") if defined?(logger)
        raise CallException.new({:original_exception => original_exception, :successful_responses => responses})
      end

      # deals with various kinds of invalid responses and returns a REXML document
      def parse_response(response_body)
        raise BlankResponseException.new("Got a blank response. Something bad is probably going on with the License Server.") if response_body.blank?

        document = begin
          REXML::Document.new(response_body)
        rescue REXML::ParseException => parse_exception
          raise LicenseServerException, "#{parse_exception.class}: Failed to parse License Server multicall response"
        end

        # detect a top-level exception in the multicall response
        ls_api_exception = REXML::XPath.first(document, '/response/exception')
        if ls_api_exception
          generate_and_raise_exception(ls_api_exception.attributes['type'], ls_api_exception.text)
        end

        document
      end

      # Splits an XML document of the whole multicall response into a series of
      # XML strings (each representing the response to an individual call) based
      # on an XPath query
      def split_xml(rexml_document)
        rexml_document.elements.to_a('/response/calls/call').map do |el|
          r = REXML::Element.new('response')
          el.elements.to_a.each { |c| r.add_element(c) }
          r.to_s
        end
      end
    end # Multicall
  end # ActiveLicensing
end # RosettaStone
