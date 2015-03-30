# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.
require 'rosetta_stone/mem_usage'
require 'rosetta_stone/cpu_usage'
require 'rosetta_stone/event_dispatcher'

module Granite
  load_amqp!

  module Agent
    class ConnectionLostError < StandardError; end

    HEARTBEAT_INTERVAL = 10
    STATUS_EXCHANGE = '/granite/heartbeat'
    STATUS_EXCHANGE_OPTIONS = {:type => :fanout, :durable => false, :auto_delete => false, :nowait => false}
    RAIDER_EXCHANGE = '/granite/raider'
    RAIDER_EXCHANGE_OPTIONS = {:type => :fanout, :durable => true, :auto_delete => false, :nowait => false}
    AMQP_RECONNECT_TIMEOUT = 10 #seconds
    AMQP_BROKER_GRACEFUL_SHUTDOWN_CODE = 320 #from http://rdoc.info/github/ruby-amqp/amqp/master/file/docs/ErrorHandling.textile
    AMQP_PRECONDITION_FAILED = 406 #from AMQP 0.9.1 specs
    AMQP_RESOURCE_LOCKED = 405
    AMQP_PERIODIC_RECONNECT_TIMEOUT = 10 #seconds
    DEFAULT_CONTENT_TYPE = "application/json"
    DEADLETTER_EXCHANGE = '/granite/deadletter'
    DEADLETTER_EXCHANGE_OPTIONS = {:type => :topic, :durable => true, :auto_delete => false}
    DEFAULT_LOG_LEVEL = Logger::Severity::WARN

    class << self
      # If App.name is not set in 2+ apps, then their granite agents will be started with pkill_identifiers
      # set to the same value so stopping them in one app (with the stop! task) will cause *ALL* agents with
      # the same pkill_identifier to be stopped.
      raise 'App.name is not set! This must be set in order to run Granite Agents.' if Granite.app_name === 'App'

      def included(model)
        model.send(:attr_accessor, :number_of_jobs_processed)
        model.send(:attr_accessor, :headers)
        model.send(:attr_accessor, :stopping)
        model.send(:attr_accessor, :actors)
        model.send(:attr_accessor, :amqp_connections)
        model.send(:attr_accessor, :amqp_channels)
        model.send(:attr_reader, :exception_count)
        model.send(:attr_reader, :status_exchange)
        model.send(:cattr_accessor, :log_io)
        model.class.send(:attr_accessor, :connection) # needs to be different per subclass of Granite::BaseAgent
        model.extend ClassMethods
        model.send(:include, InstanceMethods)
        model.send(:include, Granite::AgentLog)
        model.send(:include, RosettaStone::PrefixedLogger)
        model.send(:include, RosettaStone::EventDispatcher)
      end
    
      # Given a modulized agent class name, will return the full path to the file that contains it or nil if it doesn't exist
      def get_filename_for_agent_class(agent_class)
        # gives us the full path to the agent file, even if it's in a plugin
        all_agent_files.detect {|file| file =~ /.*#{File::SEPARATOR}#{agent_class.demodulize.underscore}.rb/}
      end

      def require_all
        Granite::Agent.connections ||= {}
        Granite::Agent.agent_info ||= {}

        Granite::Configuration.agents.each do |agent_name, details|
          if agent_name.first != agent_name.first.upcase
            raise RuntimeError.new("The requirements of the granite_agents.yml has changed.  Use class names. i.e. Namespace::Of::MyClass")
          end
          clazz = agent_name.constantize
          if details.is_a?(Fixnum)
            count = details
            max = count
          else
            count = details["default"]
            max = details["max"]
          end
          Granite::Agent.connections[clazz] = clazz.connection
          Granite::Agent.agent_info[clazz] = Granite::AgentInfo.new(count, max)
        end
        Granite::Agent.connections
      end
      alias_method :all_connections, :require_all
    end

    mattr_accessor :connections, :agent_info


    module ClassMethods

      def start(&blk)
        agent = new
        agent.start(&blk)
        agent
      end

      # implement this in your including class, if you want to do something more than hoptoad
      def on_exception(options = nil)
      end
      
      def queue_name
        self.name.demodulize
      end
    end

    module InstanceMethods
      # options
      # :method - required - The method to call when receiving events from the given exchanges, can be a symbol or a Proc. If it's a symbol, it will be converted to a proc IFF the actor class responds to it, or, failing that, if the agent class responds to it. Method/Proc must take 2 arguments, the header of the message and the job payload.
      # :exchanges - required - an exchange name (symbol or string) or array of exchange names to subscribe to and call the given method
      # :message_parsers - optional - a Hash of exchange name to method symbol to call to parse messages received from given exchange
      # :type - optional - the type of exchange (:fanout, :direct, :topic, :header)
      # :queue - optional - Hash of queue options
      #   :name - required - name of the queue
      #   :exclusive - optional - default false
      #   :durable - optional - default false
      #   :auto_delete - optional - default false
      # :bindings - optional - Array of Hashes of binding options
      #   :key - optional - for :topic or :direct exchanges, this defines the binding key to use to bind the queue
      # :actor_class - optional - the subclass of Granite::Actor to use for this queue/bindings. Only use when absolutely necessary
      def agentize(opts)
        self.actors ||= []
        if opts.has_key?(:actor_class)
          actor = opts[:actor_class].new(self, opts)
        else
          actor = Granite::Actor.new(self, opts)
        end

        actor.add_event_listener(Granite::Actor::Events::RECEIVED_MESSAGE.event_type, self.method(:event_handler).to_proc)
        actor.add_event_listener(Granite::Actor::Events::HANDLED_MESSAGE.event_type, self.method(:event_handler).to_proc)

        self.actors.push(actor)
        @connection = klass.connection
      end

      # reimplement this method if you need custom startup processing
      def start(&blk)
        default_start &blk
      end

      def default_start(&blk)
        #initialize all variables that would normally be initialized in a constructor
        @signal_trapped = self.stopping = false
        @exception_count = 0
        self.number_of_jobs_processed = 0
        self.headers = 0

        # set log file
        setup_logger_output(File.new("#{Framework.root}/log/#{klass.name.demodulize.to_s.underscore.downcase}.log", 'a')) if klass.log_io.nil?


        # We now default to a log level of WARN to cut down on chatter. This can be changed by setting log_level in
        # granite_agents.yml
        logger.level = "Logger::Severity::#{Granite::Configuration.log_level.to_s.upcase}".constantize rescue DEFAULT_LOG_LEVEL

        agent_log("starting up with log level #{severity_label(log_level)}", 5) #always log this

        # this doesn't work when it tries to bind to more than one connection.
        consumer_connection_name = @connection

        setup_traps

        Rabbit::Helpers.test_connection(consumer_connection_name)

        args = consumer_config(consumer_connection_name).to_hash.symbolize_keys.merge(:logging => false)
        begin
          EM.run do
            connection = new_amqp_connection(args)
            self.amqp_connections = [connection]
            AMQP.connection = connection
            AMQP.channel = new_amqp_channel(connection)

            setup_timers

            yield self if block_given?

            setup_heartbeat
            register

            subscribe
          end
        # Rescue these here so anytime we get them (i.e., here or raider or status connection, we stop the EM loop and exit)
        rescue AMQP::TCPConnectionFailed => tcpcf
          agent_log_error("Failed to connect to broker: TCP connection failed. #{tcpcf}")
          deliver_error_notification!(tcpcf, nil, nil, nil)
        rescue AMQP::PossibleAuthenticationFailureError => afe
          agent_log_error("Failed to connect to broker (possible authentication error). #{afe}")
          deliver_error_notification!(afe, nil, nil, nil)
        end
      end

      def subscribe
        @subscribed_actors = 0
        self.actors.each do |actor|
          actor.add_event_listener(Granite::Actor::Events::SUBSCRIBED.event_type, self.method(:actor_subscribed_handler).to_proc)
          actor.subscribe
        end
        fire_event Events::SUBSCRIBED
      end

      def consumer_config(connection_name = nil)
        connection_name ||= Framework.env
        # default to the default rabbit config
        Rabbit::Config.get(connection_name).configuration_hash(true) # remaps :password to :pass
      end

      def shutdown
        agent_log "Agent.stop() called"
        self.stopping = true
        handle_stopping
      end

      def identity
        @identity ||= "#{klass.name.demodulize}-#{Granite::AgentStatus.local_ip}-#{Process.pid}-#{("%06x" % rand(0x1000000))}"
      end

      def queue_name
        self.class.queue_name
      end

      def deliver_error_notification!(exception, header, message, method)
        decompressed_message = RosettaStone::Compression.decompress(message) rescue message
        decoded_message = ActiveSupport::JSON.decode(decompressed_message) rescue decompressed_message
        notifier_options = {
          :error_class => exception.klass.to_s,
          :error_message => "#{klass}: exception in #{method}: #{exception.inspect}",
          :environment => ENV,
          :parameters => {
            :method => method,
            :message => decoded_message,
            :agent => klass.to_s,
            :agent_id => identity,
          }.merge(error_notification_optional_params(exception))
        }
        # When exception parameter is present, hoptoad notifier seems to ignore error_message
        RosettaStone::GenericExceptionNotifier.deliver_exception_notification(exception, notifier_options)
        @exception_count ||= 0
        @exception_count += 1
      rescue Exception => exception
        agent_log_warn("Error delivering to Hoptoad: #{exception.class}: #{exception.backtrace}")
      end

      #Override this if you would like to send some extra parameters along with the Hoptoad error
      #notification. The hash that is returned from this function will be merged in with the
      #default params that are sent to Hoptoad by the agent exception notification code.
      def error_notification_optional_params(exception)
        {}
      end

      # we set @header when we get a job and unset it when we're done
      def currently_processing_job?
        self.headers > 0
      end

      def stopping?
        @signal_trapped || self.stopping || (!AMQP.connection.nil? && !!AMQP.closing?)
      end

      def default_handle_stopping
        # if we got a stop or a signal while processing a job then wait until it's done
        return if currently_processing_job? || !AMQP.connection.connected?
        if stopping?
          agent_log('unregistering...')
          unregister

          agent_log('stopping AMQP...')

          self.amqp_channels.each do |ch_id, info|
            info[:instance].close if !info[:instance].nil?
          end

          self.amqp_connections.each do |conn|
            conn.disconnect
          end

          # Give all the channels time to shutdown
          EM.add_timer(0.4) do
            agent_log('stopping EM...')
            EM.stop do
              @signal_trapped = self.stopping = false
              agent_log('agent stopped')
            end
          end
        end
      end

      # Reimplement this if you need custom behavior
      def handle_stopping
        default_handle_stopping
      end

      def setup_timers
        EM.add_periodic_timer(60) do
          agent_log 'this agent is still running'
        end
      end

      # Reimplement this method for custom trap setting
      def setup_traps
        default_setup_traps
      end

      def default_setup_traps
        ['INT', 'TERM'].each do |sig|
          trap(sig) do
            unless @signal_trapped
              agent_log("trapped signal #{sig}, #{currently_processing_job? ? "will halt after current job is complete." : "stopping."}")
              @signal_trapped = true
              handle_stopping
            end
          end
        end
      end

      def next_queue_status queue_list, index, queue_hash, proc_obj
        queue = queue_list[index]

        proc_obj.call(queue_hash) if queue.nil?
        unless queue.nil?
          queue.status do |num_messages, num_consumers|
            queue_hash[queue.name] = {:messages => num_messages, :consumers => num_consumers}
            next_queue_status queue_list, index += 1, queue_hash, proc_obj
          end
        end
      end

      def queues proc_obj
        next_queue_status self.actors.map(&:queue), 0, {}, proc_obj
      end

      def exchanges
        exchanges = []
        self.actors.each do |actor|
          exchanges.concat(actor.exchange_names)
        end
        exchanges
      end

      # by default, all agents will use raider to retry failed messages. Override this method if you don't want that behavior
      # Actors will always provide the exchange that the message is from so that your method may use raider only for specific exchanges
      def use_raider(exchange)
        true
      end


      # by default, all actors will ack the message's header itself in its ensure block.
      # Currently only the RaiderAgent overrides this
      def skip_ack_header?(exchange)
        false
      end

      def setup_heartbeat
        init_status_exchange
        EM.add_periodic_timer(HEARTBEAT_INTERVAL) do
          queues self.method(:publish_status_job).to_proc
        end
      end

      # Since registration is the same as a status update, this method provides a way to explicitly send an update
      def register
        init_status_exchange
        queues self.method(:publish_status_job).to_proc
        fire_event Events::REGISTERED
      end

      def unregister
        init_status_exchange
        @status_exchange.publish(Granite::AgentStatus.unregister(identity).to_job.to_json, :persistent => false)
        fire_event Events::UNREGISTERED
      end

      def init_status_exchange
        return unless @status_exchange.nil?

        args = consumer_config().to_hash.symbolize_keys.merge(:logging => false)

        status_vhost_connection = new_amqp_connection(args)

        status_mq = new_amqp_channel(status_vhost_connection)

        @status_exchange = declare_exchange(status_mq, STATUS_EXCHANGE, STATUS_EXCHANGE_OPTIONS)
      end

      def publish_status_job(queue_hash)
        status = Granite::AgentStatus.status(identity, {
          :agent_type => klass.name,
          :number_of_jobs_processed => self.number_of_jobs_processed,
          :exchanges => exchanges,
          :queues => queue_hash,
          :agent => klass.name.demodulize,
          :job_execution_times => job_execution_times,
          :memory_usage_virtual => RosettaStone::MemUsage.virtual,
          :memory_usage_resident => RosettaStone::MemUsage.resident,
          :accumulated_cpu_time => RosettaStone::CpuUsage.cpu_time_since_process_start, # in seconds
          :process_uptime => RosettaStone::CpuUsage.elapsed_time_since_process_start, # in seconds
          :exception_count => (@exception_count || 0)# the number of exceptions that this agent has seen
        }).to_job
        @status_exchange.publish(status.to_json, :persistent => false)
        clear_execution_times! # each heartbeat message contains the execution times of the previous period, then we clear it
      end

      def event_handler(event)
        if event.event_type == ::Granite::Actor::Events::RECEIVED_MESSAGE.event_type
          fire_event ::Granite::Agent::Events::RECEIVED_MESSAGE
        elsif event.event_type == ::Granite::Actor::Events::HANDLED_MESSAGE.event_type
          fire_event ::Granite::Agent::Events::HANDLED_MESSAGE
        end
      end

      def actor_subscribed_handler(event)
        @subscribed_actors += 1
        if @subscribed_actors == self.actors.size
          notify_that_we_are_ready
        end
      end

      def notify_that_we_are_ready
        agent_log('ready')
        fire_event Events::READY
      end

      def record_execution_time!(job_process_time_in_milliseconds)
        self.job_execution_times << job_process_time_in_milliseconds
      end

      def job_execution_times
        @job_execution_times ||= []
      end

      def clear_execution_times!
        @job_execution_times = []
      end

      # Creates a new instance of an AMQP::Channel for the specified connection. This allows us to connect to multiple vhosts from one agent/actor
      def new_amqp_channel_for_connection_name(conn_name)
        args = consumer_config(conn_name).to_hash.symbolize_keys.merge(:logging => false)
        vhost_connection = new_amqp_connection(args)

        channel = new_amqp_channel(vhost_connection)

        channel
      end


      def new_amqp_connection(connection_options)
        connection = AMQP.connect(connection_options)

        # for connection-level errors
        connection.on_error do |conn, connection_close|
          agent_log("Connection closed. Reply code = #{connection_close.reply_code}, reply text = #{connection_close.reply_text}")
          if (connection_close.reply_code == AMQP_BROKER_GRACEFUL_SHUTDOWN_CODE)
            agent_log("Broker shutdown gracefully. Starting periodic reconnection timer")
            conn.periodically_reconnect(AMQP_PERIODIC_RECONNECT_TIMEOUT)
          else
            deliver_error_notification!(Granite::Agent::ConnectionLostError.new(connection_close.reply_text), nil, connection_close.reply_text, :on_error)
            agent_log_error "Handling a connection-level exception."
            agent_log_error "AMQP class id : #{connection_close.class_id}"
            agent_log_error "AMQP method id: #{connection_close.method_id}"
            agent_log_error "Status code   : #{connection_close.reply_code}"
            agent_log_error "Error message : #{connection_close.reply_text}"
            handle_stopping
          end
        end

        connection.on_tcp_connection_loss do |conn, settings|
          #This is called ONCE when a connection failure is detected, subsequent failures to reconnect will be handled by th on_connection_interruption handler
          agent_log_warn("TCP connection lost. Attempting to reconnect in #{AMQP_RECONNECT_TIMEOUT} seconds")
          deliver_error_notification!(Granite::Agent::ConnectionLostError.new("TCP connection lost"), nil, "TCP connection lost. Attempting to reconnect in #{AMQP_RECONNECT_TIMEOUT}", nil)

          #conn.reconnect(false, AMQP_RECONNECT_TIMEOUT)
        end

        connection.on_connection_interruption do |conn|
          # per amqp gem documentation, this handler is invoked before the event is propagated to queues, channels, etc.
          agent_log_warn("Connection interruption detected. Attempting to reconnect in #{AMQP_RECONNECT_TIMEOUT} seconds")
          deliver_error_notification!(Granite::Agent::ConnectionLostError.new("Connection interrupted"), nil, "TCP connection lost. Attempting to reconnect in #{AMQP_RECONNECT_TIMEOUT}", nil)

          conn.reconnect(false, AMQP_RECONNECT_TIMEOUT)
        end

        connection.on_recovery do
          agent_log("Connection recovered")
        end

        self.amqp_connections ||= []
        self.amqp_connections << connection

        connection
      end

      def new_amqp_channel(connection)
        channel = AMQP::Channel.new(connection, AMQP::Channel.next_channel_id, {:auto_recovery => true, :prefetch => 1})

        channel.on_error do |ch, channel_close|
          if (channel_close.reply_code == AMQP_PRECONDITION_FAILED) #Precondition failed
            agent_log_warn("Channel precondition failed for channel #{ch} with #{channel_close.reply_text}")

            #ch.reuse #not available in 0.8.0, but will be availble in 0.8.1
            recover_channel_from_precondition_fail(ch)
          elsif (channel_close.reply_code == AMQP_RESOURCE_LOCKED) #probably declared a queue with the same name as an exclusive, pre-existing one
            agent_log_warn("Attempted to use a resource that was locked. Possibly you declared a queue with the same name as an existing, exclusive queue. #{ch} with #{channel_close.reply_text}")
          else
            agent_log_error("Fatal channel error #{ch}, #{channel_close.reply_text}")
            # TODO how should we handle this?
          end
        end

        channel.on_recovery do |_|
          agent_log("Channel #{channel.id} recovered. Connection status: #{channel.status}")
        end

        self.amqp_channels ||= {}
        self.amqp_channels[channel.id] = {:instance => channel}

        channel
      end

      def declare_exchange(channel, name, options)
        agent_log("Granite::Agent#declare_exchange(#{channel.id}, #{name.inspect}, #{options.inspect})")
        begin
          self.amqp_channels ||= {}
          self.amqp_channels[channel.id] ||= {}
          self.amqp_channels[channel.id][:exchanges] ||= {}
          self.amqp_channels[channel.id][:exchanges][name] ||= {}
          self.amqp_channels[channel.id][:exchanges][name][:options] = options #save these here in case it dies

          e = AMQP::Exchange.new(channel, options[:type], name, options) do |exchange, declare_ok|
            self.amqp_channels[channel.id][:exchanges][name][:instance] = exchange #save the instance
          end
          e.after_recovery do |ex|
            agent_log("Exchange #{name} has recovered")
          end
          return e
        rescue AMQP::Error => e
          agent_log_error("Error occurred when declaring the exchange #{e}")

          if (options[:passive].nil? || !options[:passive])
            declare_exchange(channel, name, options.merge(:passive => true))
          else
            agent_log_error("Error when trying to declare exchange #{e} with :passive => true, shutting down agent")
            #
            # this might be heavy-handed as we might be able to limp by without this exchange if the agent listens to multiple...
            raise e
          end
        end
      end

      def declare_queue(channel, name, options)
        agent_log("Granite::Agent#declare_queue(#{channel.id}, #{name.inspect}, #{options.inspect})")
        # should we short-circuit this if we have one already? Or let amqp gem handle that
        self.amqp_channels ||= {}
        self.amqp_channels[channel.id] ||= {}
        self.amqp_channels[channel.id][:queues] ||= {}
        self.amqp_channels[channel.id][:queues][name] ||= {}
        self.amqp_channels[channel.id][:queues][name][:options] = options

        begin
          q = channel.queue(name, options) do |queue, declare_ok|
            self.amqp_channels[channel.id][:queues][name][:instance] = queue
          end
          q.after_recovery do |que|
            agent_log("Queue #{name} has recovered")
          end
          return q
        rescue AMQP::Error => e
          agent_log_error("Error occurred when declaring the queue #{e}")

          if (options[:passive].nil? || !options[:passive])
            declare_queue(channel, name, options.merge(:passive => true))
          else
            agent_log_error("Error when trying to declare queue #{e} with :passive => true, shutting down agent")
            #
            # this might be heavy-handed as we might be able to limp by without this exchange if the agent listens to multiple...
            raise e
          end
        end
      end

      def recover_channel_from_precondition_fail(ch)
        agent_log("Recovering channel from precondition failure")

        # create a new channel with the old channel's connection
        channel = new_amqp_channel(ch.connection)

        # run through all exchanges on the old channel and re-declare them with the new one
        if !self.amqp_channels[ch.id][:exchanges].nil?
          self.amqp_channels[ch.id][:exchanges].each do |exchange_name, info|
            options = info[:options]
            if(info[:instance].nil?)
              options.merge!({:passive => true})
            end
            declare_exchange(channel, exchange_name, options)
          end
        end

        # run through all queues on the old channel and re-declare them with the new one
        if !self.amqp_channels[ch.id][:queues].nil?
          self.amqp_channels[ch.id][:queues].each do |queue_name, info|
            options = info[:options]
            if(options[:instance].nil?)
              options.merge!({:passive => true})
            end
            declare_queue(channel, queue_name, options)
          end
        # need to re-bind here
        end

        self.amqp_channels.delete(ch.id)
      end
    end # module InstanceMethods

    class Events
      include RosettaStone::EventDispatcher::Event

      # Create constants and matching class methods to create commands associated with those constants
      CONSTS = %w(ready subscribed received_message handled_message registered unregistered)

      def initialize(type)
        raise ArgumentError.new("type must be one of the defined types") if !CONSTS.include?(type)
        @event_type = type
      end

      CONSTS.each do |const|
        self.const_set(const.upcase, self.new(const))
      end
    end # class Events
  end # module Agent
end # module Granite
