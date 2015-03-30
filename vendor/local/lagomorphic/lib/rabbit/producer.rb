# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

# lame, but this doesn't get auto-required in 2.x it seems
require 'active_support/version'

class Rabbit::Producer
  # we're using a singleton here so that we can take advantage of ActiveSupport::Callbacks more easily (using instance methods).
  # otherwise everything here would be in class << self
  include Singleton
  include RosettaStone::PrefixedLogger

  
  if ActiveSupport::VERSION::MAJOR < 3
    class_inheritable_accessor :connection_config
    class_inheritable_accessor :exchange_options
    class_inheritable_accessor :publish_options
    class_inheritable_accessor :enable_compression
    class_inheritable_accessor :publish_retry_count
  else
    class_attribute :connection_config
    class_attribute :exchange_options
    class_attribute :publish_options
    class_attribute :enable_compression
    class_attribute :publish_retry_count
  end

  self.connection_config = Rabbit::Config.default_configuration
  self.exchange_options = {:type => :fanout, :durable => true}.freeze
  self.publish_options = {:persistent => true}.freeze # FIXME: want to add :mandatory => true, but tests break
  self.enable_compression = true

  # NOTE: this value gets passed as the :reconnect_attempts option to with_bunny_connection, which means that the publish operation will be
  # retried if a RabbitMQ connection error occurs.  THERE IS A RISK THAT DUPLICATE MESSAGES GET PUBLISHED if this number is greater
  # than zero.  If you'd rather risk losing messages than deal with duplicate messages, set this to zero!  In most producers we expect little
  # impact from duplicate messages and we default to retrying in order to reduce the risk of lost messages.
  self.publish_retry_count = 3

  include ActiveSupport::Callbacks
  if ActiveSupport::VERSION::MAJOR < 3
    define_callbacks :before_publish, :after_publish
  else
    define_callbacks :publish
  end

  class << self
    delegate :publish, :with_bunny_connection, :to => :instance
    delegate :compress, :decompress, :to => RosettaStone::Compression

    def establish_connection(new_config)
      if new_config.is_a?(Rabbit::Config)
        self.connection_config = new_config
      else
        self.connection_config = Rabbit::Config[new_config]
      end
    end

    def set_exchange(new_exchange)
      @exchange_name = new_exchange
    end

    def exchange_name
      @exchange_name || default_exchange_name
    end

    def default_exchange_name
      name.underscore.sub(/_producer$/, '')
    end

  end

  # use instance methods for the stuff that needs the callbacks support
  def publish(message, opts = {})
    @message = message
    return_value = nil
    if ActiveSupport::VERSION::MAJOR < 3
      run_callbacks(:before_publish)
      return_value = wrapped_publish(opts)
      run_callbacks(:after_publish)
    else
      run_callbacks(:publish) do
        return_value = wrapped_publish(opts)
      end
    end
    return_value
  end

  def wrapped_publish(opts)
    convert_message_to_json!
    compress_message_if_appropriate!
    log_benchmark('publishing message to rabbitmq') do
      with_bunny_connection(:reconnect_attempts => self.publish_retry_count) do |bunny|
        exchange = bunny.exchange(klass.exchange_name, klass.exchange_options.dup)
        logger.debug(%Q[Publishing message to exchange '#{klass.exchange_name}' with options #{klass.publish_options.inspect} #{klass.enable_compression ? " (#{@message.length} bytes)" : ": #{@message}"}])
        exchange.publish(@message, klass.publish_options.merge(opts))
      end
    end
  end

  def with_bunny_connection(*args, &block)
    Rabbit.connection_class.get(klass.connection_config).with_bunny_connection(*args, &block)
  end

  def convert_message_to_json!
    return if @message.is_a?(String)
    @message = @message.to_json
  end

  def compress_message_if_appropriate!
    return unless klass.enable_compression
    @message = klass.compress(@message)
  end
end
