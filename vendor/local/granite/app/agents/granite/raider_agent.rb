class Granite::RaiderAgent
  class MaximumMessageRetryCountReachedError < StandardError; end
  class MalformedRaiderMessageError < StandardError; end
  include Granite::Agent
  include RosettaStone::EventDispatcher

  DEADLETTER_QUEUE_NAME = 'DeadLetter'
  DEADLETTER_QUEUE_BINDING_KEY = 'dead'
  DEADLETTER_QUEUE_OPTIONS = Granite::Actor::DEFAULT_QUEUE_OPTS.merge({:durable => true, :auto_delete => false, :nowait => false, :exclusive => false})

  def initialize
    @amqp_channels_hash ||= {}
    @republishing = false

    agentize({
      :method => :process,
      :queue => {:durable => true, :auto_delete => false},
      :actor_class => Granite::RaiderActor,
      :exchanges => Granite::Agent::RAIDER_EXCHANGE
    }.merge(Granite::Agent::RAIDER_EXCHANGE_OPTIONS))
  end

  # header - the AMQP::Header of the message that wraps the failed message
  # message - The failed (original) message
  # timestamp - the timestamp when the failed message was sent to Raider (in UTC seconds)
  def process(header, message, timestamp)
    raise MalformedRaiderMessageError unless valid_raider_message?(header, message)
    job = Granite::Job.parse(message)

    attempts = job.retries.to_i
    attempts += 1
    job.retries = attempts

    max_retries, delay = max_retry_and_delay(attempts)
    adjusted_delay = delay - (Time.now.to_i - timestamp.to_i)
    delay = adjusted_delay if adjusted_delay < delay # ensure that the job is not delayed for _more_ than the configured delay amount

    if attempts <= max_retries
      if delay <= 0
        republish_message(header, message, job)
      else
        next_run_time =
          begin
            Time.at(Time.now.to_i + delay).to_s(:db)
          rescue RangeError => range_error
            "ERROR CALCULATING: #{range_error}.  delay = #{delay}"
          end

        agent_log("Scheduling job #{job.job_guid} to be republished for attempt #{attempts + 1} in #{delay} seconds (waiting until #{next_run_time})")
        EM.add_timer(delay) do
          republish_message(header, message, job)
        end
      end
    else
      agent_log("Retried message #{job.inspect} maximum times. Discarding.")
      publish_message_to_deadletter_exchange(job)
      handle_message_cleanup(header, message, Events::DISCARDED_MESSAGE, MaximumMessageRetryCountReachedError.new)
    end
  rescue Exception => unexpected_exception # ugh, this can happen if, say Granite::Job.parse raises MalformedMessage
    agent_log_warn("Unexpected exception while processing message #{message} (header: #{header.inspect}). Discarding. #{unexpected_exception.class}: #{unexpected_exception.backtrace}")

    handle_message_cleanup(header, message, Events::DISCARDED_MESSAGE, unexpected_exception)
  end

  def delay_between_retries
    @delay_between_retries ||= Granite::Configuration.raider[:delay_between_retries]
  end

  def max_retry_and_delay(attempts)
    max_retries, delay = if delay_between_retries.is_a?(Array)
      [delay_between_retries.size, delay_between_retries[attempts -1]]
    else
      [Granite::Configuration.raider[:max_message_retries].to_i, delay_between_retries]
    end
  end

  # whoa, so meta
  def use_raider(exchange)
    false
  end

  # this agent is taking responsibility for always acking the messages itself; this makes it so that Actor won't re-ack them.
  def skip_ack_header?(exchange)
    true
  end

  # for this agent, we only care about whether we're currently trying to requeue the message since the requeue timer
  # could be for a long time (LS has a 1 hour timer) so return whether we're republishing here and entrust AMQP/RabbitMQ
  # to requeue the message since it's not acked yet if we aren't
  def currently_processing_job?
    @republishing
  end

  # Helper method to do the common things after a message has been handled/discarded/requeued/exception occurred
  def handle_message_cleanup(header, message, event, exception = nil)
    header.ack if header.respond_to?(:ack) # we can get here after rescuing MalformedRaiderMessageError, so let's be overly defensive
    self.headers -= 1
    deliver_error_notification!(exception, header, message, :process) unless exception.nil?

    fire_event event
    self.actors.each do |actor|
      actor.fire_event Granite::Actor::Events::HANDLED_MESSAGE
    end

    @republishing = false # doesn't matter if we were or not
    handle_stopping
  end

  def publish_message_to_deadletter_exchange(job) 
    # move it to the new dead letter queue forever 
    raider_job = job 
    conn_name = @connection_name || Framework.env 
    reply_to = "#{conn_name}::RaiderAgent" 
    agent_log("Sending message #{raider_job.inspect} to #{Granite::Agent::DEADLETTER_EXCHANGE} with reply-to of #{reply_to}") 

    @dead_channel ||= new_amqp_channel_for_connection_name(conn_name) 

    @dead_exchange ||= declare_exchange(@dead_channel, Granite::Agent::DEADLETTER_EXCHANGE, Granite::Agent::DEADLETTER_EXCHANGE_OPTIONS) 

    #ensure that the dead leters have someplace to go
    @dead_queue ||= declare_queue(@dead_channel, DEADLETTER_QUEUE_NAME, DEADLETTER_QUEUE_OPTIONS)
    @dead_queue.bind(@dead_exchange, {:routing_key => DEADLETTER_QUEUE_BINDING_KEY})
    @dead_exchange.publish(raider_job.to_json, {:routing_key => DEADLETTER_QUEUE_BINDING_KEY, :reply_to => reply_to, :persistent => true, :mandatory => true}) 
  end 

private
  # we pass both the message (json payload) and the Granite::Job to avoid having to reparse the message
  # header - The AMQP::Header of the Raider message
  # message - The JSON payload which is the failed message
  # job - The Granite::Job version of the failed message
  def republish_message(header, message, job)
    @republishing = true
    fire_event Events::REQUEUING_MESSAGE
    begin
      reply_to = header.reply_to.split('::')
      connection = reply_to[0]
      queue_name = reply_to[1]
      agent_log("Republishing message #{job.inspect} to queue #{queue_name} on vhost #{connection}.")

      channel = @amqp_channels_hash[connection] ||= new_amqp_channel_for_connection_name(connection)
      default_exchange ||= channel.default_exchange

      default_exchange.publish(job.to_json, {:routing_key => queue_name})

    rescue Exception => exception
      agent_log_warn("#{exception.class}: #{exception.backtrace}")
      deliver_error_notification!(exception, header, message, :republish_message)
    ensure
      handle_message_cleanup(header, message, Events::REQUEUED_MESSAGE)
    end
  end

  def valid_raider_message?(header, message)
    !header.nil? && !!header.reply_to
  end

  class Events
    include RosettaStone::EventDispatcher::Event

    # Create constants and matching class methods to create commands associated with those constants
    CONSTS = %w(requeued_message discarded_message requeuing_message)


    def initialize(type)
      raise ArgumentError.new("type must be one of the defined types") if !CONSTS.include?(type)
      @event_type = type
    end

    CONSTS.each do |const|
      self.const_set(const.upcase, self.new(const))
    end
  end
end
