# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

require 'bunny'
# grr.  Bunny::Client doesn't autoload because the file is named client08.rb.  so, kick it once.
Bunny.new.class unless defined?(Bunny::Client)

module Rabbit
  class Error < StandardError; end
  class ConnectionError < Error; end
  class UnknownError < Error; end
  class AuthenticationError < Error; end
end

# synchronicity is assumed.
# also sympatico.
class Rabbit::Connection
  # we'll kill any operation within a with_bunny_connection block at this timeout (unless overridden)
  DEFAULT_MAXIMUM_RABBIT_OPERATION_TIMEOUT = 10 # in seconds

  # if a block passed to with_bunny_connection experiences a Rabbit::Connection error, we can have it reconnect
  # and retry the block, if you pass a number > 0 as :reconnect_attempts to with_bunny_connection.  However, we
  # disable this retry behavior by default because of potentially surprising behavior (for example, it might be
  # possible to get duplicate messages published or confusing errors due to the re-execution of the block)
  DEFAULT_MAXIMUM_RECONNECT_ATTEMPTS = 0

  # wait this number of seconds between retries
  DEFAULT_RECONNECT_DELAY = 2 # seconds

  # test_mode means that we raise whenever trying to connect to RabbitMQ instead of actually making a connection.
  # test_mode is enabled by default when the Rails environment is test
  cattr_accessor :test_mode
  self.test_mode = Framework.test?

  cattr_accessor :cached_connections
  self.cached_connections = {}

  include RosettaStone::PrefixedLogger

  attr_accessor :reconnect_attempts

  class << self
    def get(config = nil)
      config = Rabbit::Config.get(config)
      cached_connections[config.name] ||= new(config)
    end

    def disconnect_all!
      cached_connections.each do |name, connection|
        connection.disconnect!
        cached_connections.delete(name)
      end
    end

    def list_of_exceptions_that_require_connection_reset
      [
        # Bunny::AuthenticationError, # leaving this one out because it is only expected to happen when opening a connection fails because of auth details
        Bunny::ServerDownError,
        Bunny::ProtocolError,
        Bunny::ConnectionError,
        Bunny::ForcedConnectionCloseError,
        Bunny::ForcedChannelCloseError,
        Qrack::ConnectionTimeout,
        Qrack::ClientTimeout,
        Timeout::Error,
      ] + Errno.constants.map {|c| "Errno::#{c}".constantize}.uniq #see the Ruby-doc page on Errno
    end
  end
  delegate :list_of_exceptions_that_require_connection_reset, :to => :klass

  def initialize(config = nil)
    @config = Rabbit::Config.get(config)
    self.reconnect_attempts = 0
  end

  def connection
    raise "Oops, we were about to connect to RabbitMQ for real" if klass.test_mode
    @connection ||= establish_connection
  end

  def disconnect!
    logger.error("disconnecting RabbitMQ connection. (configuration: #{viewable_bunny_configuration})")
    begin
      @connection.stop if @connection
    rescue *list_of_exceptions_that_require_connection_reset => bunny_error
      logger.error("error while closing the connection: #{bunny_error}.  moving on.")
    end
    @connection = nil
  end

  def reconnect
    logger.error("reconnecting RabbitMQ connection. (configuration: #{viewable_bunny_configuration})")
    begin
      disconnect!

    rescue *list_of_exceptions_that_require_connection_reset => bunny_error
      logger.error("error while closing the connection: #{bunny_error}.  moving on.")
    end
  end

  def establish_connection
    conn = Bunny.new(bunny_configuration_attributes)
    log_benchmark("Establishing RabbitMQ connection (#{viewable_bunny_configuration})") do
      conn.start
    end
    return conn
  rescue Bunny::AuthenticationError => bunny_authentication_error
    logger.error("RabbitMQ server establish connection failed: #{bunny_authentication_error.class}: #{bunny_authentication_error}. (configuration: #{viewable_bunny_configuration})")
    raise Rabbit::AuthenticationError, "This might be due to a misconfiguration of the vhost or user/password.  Connection details: #{viewable_bunny_configuration}.  Details: #{bunny_authentication_error.to_s}\n\n-------------------------------------------------------------------\n|You may want to run `./rake rabbit:setup configuration=#{@config.name}`|\n-------------------------------------------------------------------"
  rescue *list_of_exceptions_that_require_connection_reset => bunny_connection_error
    logger.error("RabbitMQ server establish connection failed: #{bunny_connection_error.class}: #{bunny_connection_error}. (configuration: #{viewable_bunny_configuration})")
    raise Rabbit::ConnectionError, "#{bunny_connection_error.class}: #{bunny_connection_error}"
  rescue Exception => unknown_exception
    logger.error("RabbitMQ unknown error on establish connection: #{unknown_exception.class}: #{unknown_exception}. (configuration: #{viewable_bunny_configuration})")
    raise Rabbit::UnknownError, "#{unknown_exception.class}: #{unknown_exception}"
  end

  def bunny_configuration_attributes
    @config.configuration_hash(true)
  end

  def viewable_bunny_configuration
    bunny_configuration_attributes.except(:pass).inspect
  end

  # Note: please do not use the connection directly, always use with_bunny_connection, otherwise you would need to handle
  # all these potential exceptions yourself...
  # If you are doing an operation that you expect to take longer than DEFAULT_MAXIMUM_RABBIT_OPERATION_TIMEOUT, override
  # it with :operation_timeout.  Note that this timeout may include the time to run establish_connection if a connection does
  # not already exist.
  def with_bunny_connection(options = {}, &block)
    # all these options have to be numbers, not strings
    operation_timeout = options.with_indifferent_access.delete(:operation_timeout) || DEFAULT_MAXIMUM_RABBIT_OPERATION_TIMEOUT
    max_reconnect_attempts = options.with_indifferent_access.delete(:reconnect_attempts) || DEFAULT_MAXIMUM_RECONNECT_ATTEMPTS
    reconnect_delay = options.with_indifferent_access.delete(:reconnect_delay) || DEFAULT_RECONNECT_DELAY

    self.reconnect_attempts = 0

    begin
      Timeout.timeout(operation_timeout) do
        yield(connection)
      end
    rescue *list_of_exceptions_that_require_connection_reset => bunny_error
      logger.error("RabbitMQ connection error: #{bunny_error}. (configuration: #{viewable_bunny_configuration})")

      disconnect! # this should handle rescuing itself
      if self.reconnect_attempts < max_reconnect_attempts
        self.reconnect_attempts += 1 # put this on its own line to make it easier to read and understand
        delay = reconnect_delay ** self.reconnect_attempts
        logger.info("Retrying with_bunny_connection block for attempt #{self.reconnect_attempts + 1} in #{delay} seconds")
        sleep(delay) # allow things to settle out. WesD says the NetScaler takes ~3 seconds to fail over. Using an exponential backoff starting at 2^1
        retry
      else
        raise Rabbit::ConnectionError, bunny_error.to_s
      end
    end
  end
end
