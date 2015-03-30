module Rabbit
  class AsyncConnection
    cattr_accessor :connection
    cattr_accessor :proxy

    class << self
      def get(config = nil)
        self.connection ||= establish_connection(config)
        self.proxy ||= BunnyAMQPProxy.new(connection)
      end

      def establish_connection(config)
        config = Rabbit::Config.get(config)
        AMQP.connect(config.configuration_hash(true))
      end
    end
    delegate :connection, :proxy, :to => klass

    class BunnyAMQPProxy
      def initialize(connection)
        @channel = AMQP::Channel.new(connection)
        @channel.auto_recovery = true
      end

      def exchange(name, options)
        AMQP::Exchange.new(@channel, options[:type], name, options)
      end

      def with_bunny_connection(options = {}, &block)
        yield self
      end
    end
  end
end
