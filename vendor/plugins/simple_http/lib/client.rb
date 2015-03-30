# -*- encoding : utf-8 -*-
require 'uri'

module SimpleHTTP
  class Client
    class SimpleHTTPException < StandardError; end
    class ConnectionException < SimpleHTTPException; end
    class UnhandledException < SimpleHTTPException; end

    CONFIG_FILENAME = "simple_http_client"
    #If this config file exists, then we're going to use it for our defaults
    if File.exists?("config/#{CONFIG_FILENAME}.defaults.yml")
      send(:include, RosettaStone::OverridableYamlSettings)
      overridable_yaml_settings(:config_file => CONFIG_FILENAME, :hash_reader=>false)
    end
    attr_accessor :configuration
    hash_key_accessor :name => :configuration,
                      :keys => [:host, :port, :proxy_host, :proxy_port, :open_timeout, :read_timeout, :headers, :http_user, :http_password, :use_ssl]

    # Initializes a new SimpleHTTP::Client. Takes a hash of the following arguments:
    # :host - Optional. The hostname or IP of the server to make requests to when not specified in the URL.
    # :port - Optional. The remote port to connect to, defaults to 80.
    # :proxy_host - Optional. The hostname or IP of a proxy server to make requests through.
    # :proxy_port - Optional. The remote proxy port to connect to.
    # :open_timeout - Optional. Sets a timeout in seconds for opening the HTTP connection.
    # :read_timeout - Optional. Sets a timeout in seconds for reading from the HTTP connection.
    # :headers - Optional. A hash defining a set of HTTP headers to pass along with every request this instance makes.
    # :http_user - Optional. A username to use for HTTP basic authorization.
    # :http_password - Optional. A password to use for HTTP basic authorization.
    def initialize(configuration = {})
      if klass.respond_to?(:all_settings)
        #If there is a yaml settings file for the defaults, then use that as the base
        configuration = klass.all_settings.merge(configuration)
      end
      
      # Net::HTTP defaults to a 60 second read_timeout. We should make sure
      # that this doesn't get overwritten with nil if it's not specified.
      configuration[:read_timeout] ||= 60

      self.configuration = configuration
    end

    def headers # :nodoc:
      configuration[:headers] ||= {}
    end

  private

    def delegate_instance_request(verb, path_or_url, args)
      request_options = merge_instance_options_with_args_and_path(args, path_or_url)
      klass.const_get(verb.to_s.classify).new(request_options).go!
    end

    INSTANTIATION_ARG_KEYS = [:host, :port, :headers, :proxy_host, :proxy_port, :open_timeout, :read_timeout, :http_user, :http_password, :use_ssl]
    def instance_request_options
      INSTANTIATION_ARG_KEYS.inject({}) do |options,key|
        options[key] = send(key)
        options
      end
    end

    def merge_instance_options_with_args_and_path(args, path_or_url)
      instance_request_options.except(:headers).merge(args.except(:headers)).tap do |merged|
        merged.merge!(:headers => headers.merge(args[:headers] || {}))
        merged.merge!(merge_args_and_path(merged, path_or_url))
      end
    end

    def merge_args_and_path(args, path_or_url)
      parsed_url = URI.parse(path_or_url)
      from_url = {}
      from_url.merge!(:host => parsed_url.host) unless parsed_url.host.blank?
      from_url.merge!(:port => parsed_url.port) unless parsed_url.port.blank?
      from_url[:path] = parsed_url.respond_to?(:request_uri) ? parsed_url.request_uri : (args[:path] || path_or_url)
      args.merge(from_url)
    end

    def self.delegate_singleton_from_path_or_url(verb, path_or_url, args)
      partitioned = partition_singleton_args(path_or_url, args)
      new(partitioned[:instantiation_args]).send(verb, path_or_url, partitioned[:request_args])
    end

    # FIXME - Kind of a gross method.
    def self.partition_singleton_args(path_or_url, args)
      return {:instantiation_args => args.only(*INSTANTIATION_ARG_KEYS), :request_args => args.except(*INSTANTIATION_ARG_KEYS)}
    end

  end   # Client
end
