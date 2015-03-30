module Granite::AgentMonitoring
  DEAD_AGENT_TIMEOUT = 30 # check for dead (remote) agents every 30 seconds
  AGENT_TIME_TO_LIVE = 15 # agent is considered dead if we haven't heard from it in 15 seconds

  class << self
    def included(base)
      base.send(:attr_reader, :agent_status)
      base.send(:attr_reader, :queue_status)
    end
  end

  def process_agent_heartbeat(header, payload, timestamp = nil)
    @agent_status ||= {}
    @queue_status ||= {}

    begin
      status = Granite::AgentStatus.from_payload(payload)
      if status.type == Granite::AgentStatus::UNREGISTER
        unregister_agent(status.id)
      elsif status.type == Granite::AgentStatus::STATUS
        if @agent_status[status.id].nil? && !unregistered_agents[status.id].nil?
          agent_log_warn "Got status message for unregistered agent #{status.id}"
        else
          @agent_status[status.id] = status
          @agent_status[status.id].last_updated = Time.now.to_i
          fire_event Events::AGENT_STATUS
        end
      else
        agent_log_warn("Unknown registration type: #{status.type}")
      end

      agent_status_callback(status, timestamp)

      return status
    rescue Granite::AgentStatus::AgentStatusParseError => e
      agent_log_error("Error parsing agent status (#{e.inspect})")
    rescue Exception => e
      agent_log_error("Error processing agent status #{e.inspect}\n #{e.backtrace}")
    end
  end

  def agent_status_callback(status, timestamp)
    #override to run code after each status is processed
  end

  # reimplement this to get custom behavior
  def reset_data_stores
    default_reset_data_stores
  end

  def default_reset_data_stores
    # keeps all the known agents' current statuses
    @agent_status = {}
    @queues_status = {}
  end

  def dead_agents
    # using reject here because it returns a Hash whereas select returns an Array...wtf?
    @agent_status.reject {|k, v| !v.dead }
  end

  def unregistered_agents
    @agent_status.reject {|k,as| as.registered || as.dead }
  end

  # Remove all agents that are considered DEAD from the internal agent status data structure
  # work item 27241
  def purge_dead_agents
    @agent_status.reject!{|k, v| v.dead}
  end

  def unregister_agent(id, dead = false)
    unless @agent_status[id].nil?
      @agent_status[id].registered = false
      @agent_status[id].dead = dead
      fire_event Events::UNREGISTERED_AGENT
    else
      agent_log("Received unregister event for agent that was never registered. #{id}")
    end
  end

  def queue_status_callback(queue)
    #override this to run code after each time a queue's status is updated
  end

  def setup_dead_agent_finder
    EM.add_periodic_timer(DEAD_AGENT_TIMEOUT) do
      now = Time.now.to_i
      array = @agent_status.keys.dup
      array.each do |agent|
        unregister_agent(agent, true) if now - @agent_status[agent].last_updated > AGENT_TIME_TO_LIVE
      end
    end
  end

  class Events
    include RosettaStone::EventDispatcher::Event

    # Create constants and matching class methods to create commands associated with those constants
    CONSTS = %w(unregistered_agent agent_status)

    def initialize(type)
      raise ArgumentError.new("type must be one of the defined types") if !CONSTS.include?(type)
      @event_type = type
    end

    CONSTS.each do |const|
      self.const_set(const.upcase, self.new(const))
    end
  end
end
