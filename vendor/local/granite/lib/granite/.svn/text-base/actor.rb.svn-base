# This class represents a worker that works off of one queue
# The queue may be bound to multiple exchanges
#

module Granite
  class Actor
    class ActorCreationError < StandardError; end
    include RosettaStone::EventDispatcher
    include RosettaStone::PrefixedLogger

    DEFAULT_EXCHANGE_OPTS = {:type => :fanout, :durable => true}
    DEFAULT_BINDING_OPTS = {}
    QUEUE_HA_OPTS = (!Granite::Configuration.high_availability.nil? && Granite::Configuration.high_availability)? {:arguments => {'x-ha-policy' => 'all'}} : {} rescue {}
    DEFAULT_QUEUE_OPTS = {:exclusive => false, :durable => true}.merge(QUEUE_HA_OPTS)
    required_tags = [:method, :exchanges]

    attr_accessor :exchange_names, :exchanges, :queue, :message_parsers, :handler

    def initialize(parent, settings)
      raise ActorCreationError unless settings_verified(settings)

      @parent = parent
      @exchange_names = settings.delete(:exchanges)
      @exchange_names = [@exchange_names] unless @exchange_names.is_a?(Array)

      @connection_name = settings[:connection].nil? ? @parent.class.connection : settings.delete(:connection)

      @queue_opts = DEFAULT_QUEUE_OPTS.dup

      if !settings[:queue].nil?
        @queue_opts.merge!(settings.delete(:queue))
      end

      @queue_opts[:name] = @parent.class.name.demodulize if @queue_opts[:name].nil?

      if !settings[:bindings].nil?
        @binding_opts = settings.delete(:bindings).collect do |hash|
          tmp = DEFAULT_BINDING_OPTS.dup
          tmp.merge(hash)
        end
      else
        @binding_opts = [{}]
      end

      @handler = settings.delete(:method)
      if @handler.is_a?(Symbol)
        if self.respond_to?(@handler, true)
          @handler = self.method(@handler).to_proc
        elsif @parent.respond_to?(@handler, true)
          @handler = @parent.method(@handler).to_proc
        else
          raise RuntimeError.new("Method symbol does not belong to either the actor or agent")
        end
      end

      @exchange_opts = DEFAULT_EXCHANGE_OPTS.merge(settings)

      self.message_parsers ||= {}
      self.message_parsers = settings[:message_parsers]
    end

    def subscribe
      bind do
        create_message_handler
        fire_event Events::SUBSCRIBED
      end
    end

    def create_message_handler
      # header - the AMQP::Header of the incoming message
      # message_body - the AMQP's message body - JSONed Granite::Job
      self.queue.subscribe(:ack => true) do |header, message_body|

        unless @parent.stopping?
          internal_error = false
          @parent.headers += 1
          exchange = header.exchange
          begin
            job = prepare_for_job(message_body)
            parse_message_according_to_source_exchange(exchange, job.payload)
            call_message_handler(header, job)

            @parent.number_of_jobs_processed += 1
          rescue Exception => exception
            @parent.agent_log_warn("#{exception.class}: #{exception.message}: #{exception.backtrace}")
            @parent.deliver_error_notification!(exception, header, message_body, @handler)
            begin
              handle_exception(header, message_body, job, exception)
            rescue Exception => double_exception
              @parent.agent_log "INTERNAL ERROR: #{double_exception.inspect}".to_console_string.red
              
              internal_error = true # we don't want to ack the header if we couldn't send it to raider
              raise double_exception
            end
          ensure
            unless @parent.skip_ack_header?(exchange) || internal_error
              with_delay_to_give_em_a_chance_to_publish_to_raider_if_necessary do
                header.ack
                @parent.headers -= 1

                fire_event Events::HANDLED_MESSAGE
                @parent.handle_stopping
              end
            end
          end
        end
      end # queue.subscribe
    end

    # does some housekeeping in preparation for doing a job, in addition to parsing the job itself
    def prepare_for_job(message_body)
      # reset for new job. this gets set to true if there is an error that would trigger a raider job,
      # in order give EM a chance to get the message off to raider before the agent starts plowing on
      # the next job
      @publishing_this_message_to_raider = false 

      fire_event Events::RECEIVED_MESSAGE
      reset_active_record_connections_if_necessary!
      Granite::Job.parse(message_body).tap do |job|
        @parent.agent_log "Message from queue: #{job.job_guid}"
        @parent.agent_log_debug "Job: #{job.inspect}"
      end
    end

    # contrary to the method names involved, this apparently does not actually disconnect
    # database connections if everything is ok.  it does, however, trigger a reconnect on
    # the next query if the database connection has been closed by the server or otherwise
    # disconnected.
    def reset_active_record_connections_if_necessary!
      ActiveRecord::Base.clear_active_connections! if defined?(ActiveRecord)
    end

    # subclasses can override this (RaiderActor does)
    # header - the AMQP::Header of the incoming message
    # message - the AMQP's message body - JSONed Granite::Job
    # job - The Granite::Job created from <code>message</code> - passed to avoid reparsing
    # exception - the exception that occurred
    # This method, if the parent says to support RAIDER, will enqueue the message in the raider
    # queue for the vhost of the current application. I.e., even if the actor is connected to tracking's vhost,
    # if this actor is in baffler, it will enqueue the message in baffler's raider queue
    def handle_exception header, message, job, exception
      exchange = header.exchange

      if @parent.use_raider(exchange)
        @publishing_this_message_to_raider = true
        raider_job = Granite::Job.create(job.to_json)
        conn_name = @connection_name || Framework.env
        reply_to = "#{conn_name}::#{self.queue.name}"
        @parent.agent_log("Sending message #{raider_job.inspect} to RAIDER with reply-to of #{reply_to}")
        @raider_mq ||= @parent.new_amqp_channel_for_connection_name(Rabbit::Config.get())

        @reQer ||= @parent.declare_exchange(@raider_mq, Granite::Agent::RAIDER_EXCHANGE, Granite::Agent::RAIDER_EXCHANGE_OPTIONS)
        @reQer.publish(raider_job.to_json, {:reply_to => reply_to, :persistent => true})
      end
    end

    # message parsers can be Procs or symbols, if it's a symbol, then it tries to find it first
    # on this Actor object then, failing that, tries to call it on the parent Agent object
    def parse_message_according_to_source_exchange(exchange, message_body)
      unless self.message_parsers.nil?
        parser = self.message_parsers[exchange]
        unless parser.nil?
          if parser.is_a?(Proc)
            parser.call(message_body)
          elsif self.respond_to?(parser)
            self.send(parser, message_body)
          else
            @parent.send(parser, message_body)
          end
        else
          @parent.agent_log "Agent #{@parent.class} does not have a parser for messages from #{exchange}"
        end
        fire_event Events::PARSED_MESSAGE
      end
    end

private
    def settings_verified(settings)
      !settings.nil? && !settings[:exchanges].nil? && !settings[:method].nil?
    end

    # must be called within the AMQP EM loop
    def bind
      if @connection_name == @parent.class.connection
        @mq = AMQP.channel
      else
        @mq = @parent.new_amqp_channel_for_connection_name(@connection_name)
      end

      self.queue = @parent.declare_queue(@mq,@queue_opts[:name], @queue_opts.merge(:nowait => false))

      self.exchanges ||= {}

      @expected_successful_binds = @exchange_names.size * @binding_opts.size
      @successful_binds = 0
      @exchange_names.each do |exchange|
        self.exchanges[exchange] = @parent.declare_exchange(@mq, exchange, @exchange_opts.merge(:nowait => false))
        @binding_opts.each do |binding|
          self.queue.bind(self.exchanges[exchange], binding.merge(:nowait => false)) do |bind_response|
            @successful_binds += 1
            yield if @successful_binds == @expected_successful_binds
          end
        end # @binding_opts.each
      end # @exchange_names.each
    end

    # Helper function split out to allow specialized handling in subclasses without having to reproduce subscribe()
    # Currently, only RaiderActor overrides this
    def call_message_handler(header, job)
      exchange = header.exchange

      log_benchmark("processing #{exchange} for job_guid #{job.job_guid}") do
        @handler.call(header, job.payload)
      end
      @parent.record_execution_time!(RosettaStone::Benchmark.most_recent_benchmark)
    end

    def with_delay_to_give_em_a_chance_to_publish_to_raider_if_necessary(&block)
      if publishing_this_message_to_raider?
        with_cleanup_delay(&block)
      else
        block.call
      end
    end

    def with_cleanup_delay(&block)
      EM.add_timer(0.2, &block)
    end

    def publishing_this_message_to_raider?
      !!@publishing_this_message_to_raider
    end

    class Events
      include RosettaStone::EventDispatcher::Event

      # Create constants and matching class methods to create commands associated with those constants
      CONSTS = %w(subscribed received_message parsed_message handled_message)


      def initialize(type)
        raise ArgumentError.new("type must be one of the defined types") if !CONSTS.include?(type)
        @event_type = type
      end

      CONSTS.each do |const|
        self.const_set(const.upcase, self.new(const))
      end
    end
  end
end
