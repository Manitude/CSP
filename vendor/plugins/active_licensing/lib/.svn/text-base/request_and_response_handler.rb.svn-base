# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.
require 'xmlsimple'

module RosettaStone #:nodoc:
  module ActiveLicensing #:nodoc:
    # Encapsulates a license server XML response that has been parsed into a hash.
    class ParsedResponseHash < HashWithIndifferentAccess
      attr_reader :xml
      # So it only gets set the first time
      def xml=(xml_string); @xml ||= xml_string; end
      def api_exception?; !self['exception'].blank?; end
      def api_message?;   !self['message'].blank?; end

      # Parses an XML response into a ParsedResponseHash using some default options with XmlSimple
      def self.from_xml(xml_string, extra_options = {})
        default_opts = {'keeproot' => false, 'forcearray' => ['parameter', 'error'], 'SuppressEmpty' => nil }
        options = default_opts.merge(extra_options)
        self.new.replace(hash_from_xml(xml_string, options)).tap do |hash|
          hash.xml = xml_string.to_s
        end
      end

      def self.hash_from_xml(xml_string, options)
        hash_from_xml = XmlSimple.xml_in(xml_string, options) || {}
        if hash_from_xml.is_a?(Hash)
          return hash_from_xml
        else
          return {'exception' => {'type' => 'invalid_response_xml', 'content' => xml_string.to_s}}
        end
      end

      # Reparses the XML body and replaces the contents of this hash
      def reparse_with_options!(extra_options = {})
        replace reparse_with_options(extra_options)
      end

      # Reparses the XML body and returns a new ParsedResponseHash
      def reparse_with_options(extra_options = {})
        self.class.from_xml(xml, extra_options)
      end
    end # ParsedResponseHash

    # A RequestAndResponseHandler handles parsing the XML response from the License Server and returning useful information. It further takes
    # care of exception handling, and allows for the defintion of custom response handling for those XML responses that do not follow generic
    # conventions.
    #
    # In practice, each RequestAndResponseHandler may also define methods to request specific API methods differently, but this has yet to be useful.
    #---
    # FIXME: Should this be an abstract class?
    class RequestAndResponseHandler
      attr_reader :base

      # Takes a :base as a required argument of the options hash.
      def initialize(opts)
        raise ArgumentError, "You must specify a base object" unless @base = opts[:base]
      end

      def parse_content_ranges!(hashes)
        hashes.each do |entitlement|
          entitlement['content_ranges'] = (entitlement['content_ranges'] && entitlement['content_ranges']['content_range']) || ['all']
        end
        hashes
      end

      # The generic case is that the RequestAndResponseHandler will not have a custom request method defined, and so method_missing will be
      # used to cause the API call to occur.
      def method_missing(sym, *args, &block)
        post_or_get = api_method_definitions[sym][:use_post] ? :post : :get
        handle_request(post_or_get, sym, args.first)
      end

    private

      def handle_request(post_or_get, sym, data)
        api_method = post_or_get == :post ? :api_post : :api_call
        response = base.send(api_method, api_category, sym.to_s, data)

        # Opportunistically make response handling asynchronous when possible
        if defined?(EM) && response.is_a?(EM::Deferrable)
          response.callback do |client|
            begin
              response.succeed(handle_response(sym.to_s, client.response))
            rescue Exception => e
              response.fail(e)
            end
          end
          response
        else
          # If we get :defer_handling as the return value then we shouldn't try to handle the response just yet.
          (response == :defer_handling) ? :handling_deferred : handle_response(sym.to_s, response)
        end
      end

      # Returns a hash of API methods and the options specified at definition time.
      # In order to ensure backwards compatibility, this method will always return a
      # Hash that will always return another Hash for any key, even for API methods
      # that aren't defined using RequestAndResponseHandler#handle.
      #
      # Usage:
      #   if api_method_definitions[:details][:use_post] ...
      #
      def api_method_definitions
        self.class.instance_variable_get('@method_definitions') || Hash.new(Hash.new({}))
      end

      # In a sub-class, allows you to specify a custom handler for a given method, like so:
      #
      #   handle :my_method do |response_body|
      #     ...custom_processing_here...
      #   end
      #
      # Options can be passed to further customize the handler:
      #
      #   handle :my_method, :use_post => true, :use_standard_from_xml => true do |response_body|
      #     ...custom_processing_here...
      #   end
      #
      # :use_post
      #   specifies that HTTP POST should be used when calling the remote endpoint.
      # :use_standard_from_xml
      #   specifies that the (successful) response can be parsed with the standard Hash#from_xml
      #   that Rails defines. Exception responses are still parsed with ParsedResponseHash#from_xml.
      #
      def self.handle(name, opts={}, &block)
        invalid_keys = opts.keys - [:use_post, :use_standard_from_xml]
        raise ArgumentError.new("Unknown method definition option(s): #{invalid_keys.join(", ")}") unless invalid_keys.empty?
        @method_definitions ||= Hash.new({})
        @method_definitions[name.to_sym] = opts
        define_method("handle_#{name}", &block) if block_given?
      end

      # This handles parsing the XML response from the License Server and passing off exception handling to handle_exception. If a custom response
      # handler has been defined for the class, then it is used to further parse the XML and return custom information; if not, default_response_handler
      # is used.
      def handle_response(method_name, response_body)
        raise BlankResponseException.new("Got a blank response. Something bad is probably going on with the License Server.") if response_body.blank?
        logger.debug("Received XML from LS API:\n#{response_body}") if defined?(logger)

        if api_method_definitions[method_name.to_sym][:use_standard_from_xml]
          response_hash = Hash.from_xml(response_body.to_s.strip).with_indifferent_access
          return handle_exception(ParsedResponseHash.from_xml(response_body)) unless response_hash['response']['exception'].blank?
        else
          response_hash = ParsedResponseHash.from_xml(response_body)
          return handle_exception(response_hash) if response_hash.api_exception?
        end

        method_name = :"handle_#{method_name}"
        respond_to?(method_name) ? send(method_name, response_hash) : default_response_handler(method_name, response_hash)
      rescue REXML::ParseException => parse_exception
        raise LicenseServerException, "#{parse_exception.message}: Failed to parse License Server response"
      end

      # The default response handler simply attempts to handle the message in the XML. If no message is found (and no exception was raised earlier), then
      # a LicenseServerException is raised, likely indicating that this API call requires a custom response handler.
      def default_response_handler(method_name, response_hash)
        return handle_message(response_hash['message']) if response_hash.api_message?
        raise LicenseServerException, "Expected either a message or an exception to be returned. Perhaps this method necessitates its own response handler?"
      end

      # Handles raising the appropriate Exception class from the exception indicated in the XML.
      def handle_exception(response_hash)
        exception = response_hash['exception']
        generate_and_raise_exception(exception['type'], exception['content'])
      end

      def generate_and_raise_exception(type, message)
        exception_name = "RosettaStone::ActiveLicensing::#{type.classify}"

        ActiveLicensing.const_set(type.classify, Class.new(LicenseServerException)) unless ActiveLicensing.const_defined?(type.classify)
        logger.error("Exception from LS API: #{exception_name} (#{message})") if defined?(logger)
        raise exception_name.constantize, message
      end

      # Returns true if the message type is success.
      def handle_message(message); message['type'] == 'success'; end

      # Returns an 'api_category' used in generating the correct path for API calls, based on the name of the class. A class can override this convention,
      # if necessary.
      def api_category; self.class.to_s.demodulize.underscore; end

    end
  end # ActiveLicensing
end # RosettaStone
