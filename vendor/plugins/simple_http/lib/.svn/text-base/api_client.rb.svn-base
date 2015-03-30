# -*- encoding : utf-8 -*-
module SimpleHTTP
  class ApiClient
    include RosettaStone::YamlSettings
    cattr_accessor :test_mode
    self.test_mode = Rails.test?

    class ApiClientError < StandardError
    end

    # Config filename convention implemented here. It takes the client's class name, and the immediately enclosing module name (required), to make the config filename.
    #
    # Example:
    # >> RosettaStone::BadgeAwarding::ApiClient.config_filename
    # => "badge_awarding_api_client.yml"
    #
    def self.config_filename
      (parent.to_s.demodulize + to_s.demodulize).underscore + ".yml"
    end

    attr_accessor :simple_http_client

    hash_key_accessor :name => :configuration,
      :keys => [:host, :port, :proxy_host, :proxy_port, :http_user, :http_password, :read_timeout, :open_timeout]

    def initialize
      klass.yaml_settings :config_file => klass.config_filename
      raise "HOSED CONFIG: Required configuration options are missing from #{klass.config_filename}." unless klass[:host] && klass[:port]
      klass.settings.each { |k,v| send(:"#{k}=", v) }
      self.simple_http_client = desired_http_client
    end

    def method_missing(meth, *args, &blk)
      raise "Unknown method #{meth} called in #{klass}. Did you forget to implement an API method?"
    end

    private

    delegate :get, :post, :head, :put, :delete, :to => :simple_http_client

    # Given a block, and an optional max_attempts argument, this method hands a Net::HTTP object off to
    # the block and tries to call it. If an exception is raised, it retries until max_attempts is reached.
    def request_with_retry(max_attempts = 3, exception_class = ApiClientError, &block)
      #raise "Oops! We were about to contact the #{klass.parent.to_s.demodulize} server for real." if klass.test_mode
      attempt = 1
      begin
        yield
      rescue SimpleHTTP::Client::SimpleHTTPException => e
        Rails.logger.error("#{klass} error during communication (attempt #{attempt}), retrying: #{e.class}: #{e.message}")
        attempt += 1
        retry unless attempt > max_attempts
        exception_message = "#{klass}: Could not connect after #{max_attempts} attempts."
        Rails.logger.error(exception_message)
        raise exception_class, exception_message
      end
    end

    def default_simplehttp_options
      configuration.reverse_merge!(default_timeout_options)
      {
        :host => host, :port => port, :proxy_host => proxy_host, :proxy_port => proxy_port,
        :open_timeout => open_timeout.to_i, :read_timeout => read_timeout.to_i,
        :http_user => http_user, :http_password => http_password,
        :headers => {'Content-type' => 'text/xml'}
      }
    end

    def default_timeout_options
      {:open_timeout => 5, :read_timeout => 30}
    end

    def desired_http_client
      SimpleHTTP::Client.new(default_simplehttp_options)
    end
  end
end
