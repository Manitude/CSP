# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

module Granite
  class AgentRestartTimeout < StandardError; end
  class InvalidAgent < StandardError; end
  class ControllerAgent
    extend SayWithTime
    include Granite::Agent
    include EventMachine
    include Granite::AgentMonitoring

    WAIT_TIMEOUT = 60 # how long to wait for an agent to die before killing it or erroring out
    RUBY = File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'])
    COMMAND_EXCHANGE = "/granite/command"
    COMMAND_EXCHANGE_OPTIONS = {:type => :direct, :durable => false, :auto_delete => false}
    # "shared" commands go to *one* of the of the Controller Agents; they all read from the same queue.
    SHARED_COMMAND_QUEUE = 'ControllerAgent-shared-commands'
    SHARED_COMMAND_ROUTING_KEY = 'agent.#.ControllerAgentSharedCommands'
    SKIP_WHITELIST_CHECK = 'skip_whitelist_check'

    QUEUE_ERROR_THRESHOLD = 5
    QUEUE_PID_LOOP_DELTA_T = 5 #seconds
    DEFAULT_ERROR_POINTS_PER_AGENT = 1000 #start 1 agent for every 10 points of error

    MAXIMUM_INTEGRAL_TERM = 10
    MINIMUM_INTEGRAL_TERM = 0

    START_AGENT_DELAY = 1

    attr_accessor :agent_info # Hash for starting agents, containing the number to start, the file to load, etc
    attr_accessor :queue_data # Hash with keys = Queue names and values => stats about the queue
    attr_reader :agents # Hash of the agent's pid to info about it
    attr_reader :agents_running #Hash of agent class names to a hash containing default number of agents to run, the maximum to run and how many are currently running
    attr_reader :agent_id_map #A Hash where the key is the agent's id and the value is the number 1 - it's used to track which agents we know about by their id

    # This sets up the list of binding keys to allow for general to more targeted messaging. It uses the regex of Topic exchanges
    # in order to stay familiar to other AMQP idioms. Currently it creates the following keys:
    # agent.#
    # agent.<ip>.#
    # agent.<ip>.<classname>
    # agent.#.<classname>
    def binding_keys
      if @binding_keys.nil?
        parts = ['agent', Granite::AgentStatus.local_ip_for_routing_key, klass.name.demodulize]
        @binding_keys = []
        parts.size.times do |i|
          str = parts.slice(0..i).join('.')
          str += '.#' unless parts.size == i + 1 # add wild card unless this is the last part
          @binding_keys << str
        end
        # add other wild card key(s):
        if parts.size > 2
          @binding_keys << [parts.first, parts.last].join('.#.')
          if parts.size > 3
            # implement this if we ever want more specific keys
          end
        end
      end
      logger.info("ControllerAgent binding keys is #{@binding_keys.join(', ')}")
      @binding_keys
    end

    def binding_keys_hash_array
      @key_hash_array ||= binding_keys.map { |key| {:key => key} }
    end

    def initialize
      reset_data_stores
      agentize({
        :method => self.method(:process_agent_heartbeat).to_proc,
        :queue => { :name => identity, :auto_delete => true, :durable => false, :exclusive => true },
        :actor_class => Granite::ControllerActor,
        :exchanges => Granite::Agent::STATUS_EXCHANGE,
      }.merge(Granite::Agent::STATUS_EXCHANGE_OPTIONS))
      agentize({
        :method => self.method(:process_command).to_proc,
        :queue => { :name => identity + '-commands', :auto_delete => true, :durable => false, :exclusive => true },
        :exchanges => COMMAND_EXCHANGE,
        :bindings => self.binding_keys_hash_array,
      }.merge(COMMAND_EXCHANGE_OPTIONS))
      agentize({
        :method => self.method(:process_command).to_proc,
        :queue => { :name => SHARED_COMMAND_QUEUE, :auto_delete => true, :durable => false },
        :exchanges => COMMAND_EXCHANGE,
        :bindings => [{:key => SHARED_COMMAND_ROUTING_KEY}],
      }.merge(COMMAND_EXCHANGE_OPTIONS))
    end

    def start(&blk)
      # set log file here so we can log to it - it's usually set up in Granite::Agent.start, i.e., after this
      setup_logger_output(File.new("#{Framework.root}/log/#{klass.name.demodulize.to_s.underscore.downcase}.log", 'a')) if klass.log_io.nil?

      if Granite::Configuration.respond_to?(:allowed_hosts) &&
         Granite::Configuration.allowed_hosts.present? &&
         Granite::Configuration.allowed_hosts.none?{|allowed_host| allowed_host.is_a?(String) ? Socket.gethostname == allowed_host : Socket.gethostname.match(allowed_host)} &&
         (ENV[Granite::ControllerAgent::SKIP_WHITELIST_CHECK].nil? || ENV[Granite::ControllerAgent::SKIP_WHITELIST_CHECK] == 'false')

        #logger.info("Current hostname, #{Socket.gethostname}, is not in the allowed_hosts configuration list. Controller is shutting down.")
        agent_log("Current hostname, #{Socket.gethostname}, is not in the allowed_hosts configuration list. Controller is shutting down.")
        return
      end

      default_start do |agent_instance|
        yield agent_instance if block_given?

        read_config
        setup_dead_agent_finder
        start_agents
      end
    end

    # reads in and stores the agents to start, how many to start from the granite_agents[.defaults].yml
    def read_config
      Granite::Agent.require_all
    end

    # starts all agents that were read in from the config file
    def start_agents
      @agents_running = {}

      Granite::Agent.agent_info.each do |agent, info|
        @agents_running[agent.to_s] = {:initial => info.count, :running => 0, :max => info.max}

        start_n_instances_of_agent(info.count, agent)
      end
    end

    def start_n_instances_of_agent(count, agent_name = nil)
      agent_log("Starting #{count} instances of #{agent_name.to_s}")

      begin
        count.times do |i|
          EM.add_timer(i * START_AGENT_DELAY) do
            start_agent(agent_name.to_s)
          end
        end
      rescue InvalidAgent
        #already logged in start_agent
      end
    end

    def start_agent(agent_name)
      agent_log("Starting agent #{agent_name}")

      begin
        agent_name.constantize #test to see if we know about this agent
      rescue
        agent_log_warn("Attempted to start an agent that could not be loaded: #{agent_name}")
        raise InvalidAgent.new("Attempted to start an agent that could not be loaded: #{agent_name}")
      end

      @agents_starting[agent_name.classify] ||= 0
      @agents_starting[agent_name.classify] += 1

      pid = Granite::PidHelper.start_agent(agent_name)

      if @agents[pid].nil?
        # store child process' info
        @agents[pid] = {:name => agent_name, :running => true, :stopping => false}
        @agents_running[agent_name][:running] += 1 

        fire_event Events::STARTED_AGENT
      else
        agent_log_error "Duplicate pid #{pid}"
      end
    end

    def agent_status_callback(status, timestamp)
      agent_data = @agents_id_map[status.id]
      
      if (status.agent_type != "Granite::ControllerAgent")
        if (agent_data.nil?)
          
          # some special procesing for agents on our local box
          if (status.host == Granite::AgentStatus.local_ip)
            @agents_starting[status.agent_type] -= 1

            if @agents_starting[status.agent_type] < 0
              deliver_error_notification!(RuntimeError.new("Count of starting agents of class #{status.agent_type} is less than 0!"), nil, status, "Granite::ControllerAgent#agent_status_callback")
            end
          end

          @agents_id_map[status.id] = 1 #just store something
        end

        if !status.queues.nil?
          status.queues.each do |name, stats|
            q_data = @queue_data[name]

            # if this is the first time we've seen this queue, generate an id 
            if( q_data.nil? )
              q_data = @queue_data[name] = {:integral => 0, :error => (0 - stats[:messages]), :agents => [status.id], :agent_types => [status.agent_type], :previous_timestamp => 0, :timestamp => timestamp}
            elsif( timestamp - q_data[:timestamp] > QUEUE_PID_LOOP_DELTA_T )
              update_queue_stats_hash(stats, q_data, timestamp)
              adjust_agents_for_queue_if_necessary(q_data)
            else
              # we haven't waited long enough - should we still capture the relevant information?
              return
            end
          end
        end
      end
    end

    def update_queue_stats_hash(stats, q_data, timestamp)
      q_data[:previous_error] = q_data[:error]
      q_data[:error] = (0 - stats[:messages])

      q_data[:previous_timestamp] = q_data[:timestamp]
      q_data[:timestamp] = timestamp

      q_data[:previous_messages] = q_data[:messages]
      q_data[:messages] = stats[:messages]
      q_data
    end

    def adjust_agents_for_queue_if_necessary(q_data)
      pid_error_value = pid_loop_value(q_data).abs

      expected_number_of_agents = (pid_error_value / DEFAULT_ERROR_POINTS_PER_AGENT).floor

      #for each agent that processes off that queue, determine whether to start some up, shut some down, or keep the same number running one more
      q_data[:agent_types].each do |agent_clazz|
        max = @agents_running[agent_clazz][:max]

        # We only want to do the work to determine how to adjust the agent count if the agent has
        # a maximum that's different from the count - see Granite::Agent#require_all for why this is
        if (max > @agents_running[agent_clazz][:initial])
          starting = @agents_starting[agent_clazz] ||= 0

          # Only modify the count if we aren't waiting for more agents to start up -> we dont' know what impact they'll have once they're
          # processing so we hold off
          if (starting == 0)
            #correct the number of running agents with how many are currently stopping
            stopping = @agents.values.count{|info| !info.nil? && info[:name] == agent_clazz && info[:stopping] == true}

            num_agents = @agents_running[agent_clazz][:running] + starting - stopping

            difference = expected_number_of_agents - num_agents


            if difference > 0
              # if we're not running the max allowed for this agent...
              if num_agents < max
                # cap difference to the maximum value
                if ( num_agents + difference > max )
                  difference = max - num_agents
                end

                agent_log("Starting #{difference} #{agent_clazz} up because PID value was #{pid_error_value}")

                difference.times do
                  start_agent(agent_clazz)
                end
              end
            elsif difference < 0
              initial = @agents_running[agent_clazz][:initial]

              difference = difference.abs

              # cap difference to the initial, i.e., minimum, value
              if ( num_agents - difference < initial )
                difference -= initial
              end

              # we want to shutdown agents slowly, in case we we hit an equilibrium before we shut down all excess ones
              if( difference >= 1 )
                agent_log("Stopping #{difference} #{agent_clazz} because PID value was #{pid_error_value}")
                difference.times do
                  pid = find_pid_for_running_agent_of_class(agent_clazz)
                  stop_agent(pid) if !pid.nil?
                end
              end
            end
          end
        end
      end
    end


    # updates the PID value
    # @param q_data The hash of Queue data
    def pid_loop_value(q_data)
      p = q_data[:error]
      i = calculate_integral(q_data)
      d = calculate_derivative(q_data)

      proportional_gain * p + integral_gain * i + derivative_gain * d
    end

    def calculate_derivative(q_data)
      t = q_data[:timestamp]
      t_1 = q_data[:previous_timestamp]
      v = q_data[:error]
      v_1 = q_data[:previous_error]

      (v_1 - v)/(t_1 - t)
    end


    def calculate_integral(q_data)
      q_data[:integral] += (q_data[:error] * (q_data[:timestamp] - q_data[:previous_timestamp]))
      if q_data[:integral] > MAXIMUM_INTEGRAL_TERM
        q_data[:integral] = MAXIMUM_INTEGRAL_TERM
      elif q_data[:integral] < MINIMUM_INTEGRAL_TERM
        q_data[:integral] = MINIMUM_INTEGRAL_TERM
      end
      q_data[:integral]
    end

    def stop_agent(pid, signal = 15)
      return if @agents[pid].nil?

      # if we tried to nicely stop the agents and they didn't stop, kill them dead
      @stop_timers ||= {}
      @stop_timers[pid] = EventMachine::Timer.new(WAIT_TIMEOUT) do
        stop_agent(pid, 9) unless signal == 9
        agent_log_warn("Agent with pid: #{pid} did not shut down within #{WAIT_TIMEOUT} seconds")
      end

      agent_log "Stopping agent #{@agents[pid][:name]} running with pid #{pid} and signal #{signal}"

      begin
        @agents[pid][:stopping] = true

        Process.kill(signal, pid)
        # Traps should catch the signal, so we won't worry about it here
      rescue
        # no process, cancel our timer
        cancel_stop_timer(pid)
      end
    end

    def stop_all_agents(signal = 15)
      @stopping_children = true
      agent_log "Stopping all agents with signal #{signal}"
      @agents.keys.each do |pid|
        stop_agent(pid, signal)
      end
      reset_data_stores
    end

    def handle_stopping
      # if we got a stop or a signal while processing a job then wait until it's done
      return if currently_processing_job?
      if stopping?
        agent_log "Shutting down..."
        default_handle_stopping
        stop_all_agents
      end
    end

    def cancel_stop_timer(pid)
      if !@stop_timers[pid].nil?
        @stop_timers.delete(pid) do |p, timer|
          timer.cancel
        end
      end
    end

    def setup_traps
      default_setup_traps

      # SIGCLD and SIGCHLD are apparently synonymous on modern unix operating systems
      trap('CHLD') do
        unless @stopping_children
          begin
            # sometimes it seems that the process may have already exited by the time we get here, and in that case
            # Process.wait2 will literally wait forever, so make sure use WNOHANG.
            pid, status = Process.wait2(-1, Process::WNOHANG)
            # when this process shells out (to, say, ps to gather memory usage stats), we get CHLD signals but we should
            # ignore them unless the signals came from a child agent process that we started.
            if @agents[pid]
            
              agent_log_warn("Child process #{@agents[pid][:name]} (pid: #{pid}) exited with status #{status.exitstatus}.\n\tExited normally? #{status.exited?}\n\tWas signaled? #{status.signaled?}\n\tStop signal? #{status.stopsig}\n\tTerm signal? #{status.termsig}")

              # cancel our stop timer if it exists
              cancel_stop_timer(pid)
                
              # Fire an event if we were expecting one
              if(@agents[pid][:stopping])
                fire_event Events::STOPPED_AGENT 
              end

              name = @agents[pid][:name]
              
              # TODO - if the count is 0, then we should _probably_ start one up again - in almost every instance
              @agents_running[name][:running] -= 1
              @agents.delete(pid)
            end
          rescue Exception => exception # might be Errno::ECHILD from the Process.wait2 or a Timeout::Error
            agent_log_warn("Trapped CHLD signal but encountered exception gathering process details: #{exception.class}: #{exception}")
          end
        end
      end
    end


    def process_command(header, payload)
      AMQP.channel.direct('amq.direct').publish(Granite::ControllerResponse.ack.to_job.to_json, :routing_key => header.reply_to) unless header.reply_to.nil?

      outgoing = Granite::ControllerResponse.ok
      payload = payload.deep_symbolize_keys
      begin
        agent_log "Received command payload>#{payload.inspect}<"
          case payload[:command]
            when ControllerCommand::START then
              if payload[:agent]
                modulized_name = classify_agent_string(payload[:agent])

                agent_log("Attempting to start agent(s) of type: #{modulized_name} from command of #{payload[:agent]}")

                agent_count = payload[:count] ? payload[:count] : 1
                start_n_instances_of_agent(agent_count, modulized_name)
              else
                agent_log_warn("Start command did not contain all necessary parameters")
                outgoing = Granite::ControllerResponse.error.set_opts({:message => "Start command did not contain all necessary parameters"})
              end
            when ControllerCommand::RESTART then
              stop_all_agents
              # FIXME: should be Granite::Configuration.reload_configuration!, but it doesn't exist
              Granite::Configuration.overridable_yaml_settings(:config_file => "granite_agents")
              read_config
              start_agents
            when ControllerCommand::STOP then
              pid = payload[:pid] if payload[:pid]
              agent_class = payload[:class] if payload[:class]
              agentId = payload[:id] if payload[:id]
              if signal = payload[:signal]
                if !pid.nil?
                  agent_log "Stopping agent with pid #{pid}"
                  stop_agent(pid, signal)
                elsif !agent_class.nil?
                  agent_count = payload[:count] ? [payload[:count], @agents.size].min : 1
                  agent_log "Stopping #{agent_count} agent(s) of type #{agent_class}"

                  modulized_name = classify_agent_string(agent_class)

                  agent_count.times do
                    find_pid_for_running_agent_of_class(modulized_name).if_hot { |agent_pid| stop_agent(agent_pid, signal) }
                  end
                elsif !agentId.nil?
                  agent_log "Stopping agent with id #{agentId}"
                  pid = find_pid_for_agent_with_id agentId
                  stop_agent(pid, signal)
                else
                  agent_log "Stopping all agents"
                  stop_all_agents(signal)
                  shutdown
                end
              else
                agent_log_warn("No signal parameter with STOP command.")
                outgoing = Granite::ControllerResponse.error.set_opts({:message => "No signal parameter with STOP command."})
              end
            when ControllerCommand::LIST then
              agent_log "Listing local agents"
              outgoing.set_opts({:result => self.agents})
            when ControllerCommand::STATUS then
              agent_log "Listing status for all known agents"
              # we need to explicitly convert the AgentStatus objects to hashes because not all versions of the JSON gem
              # do the right thing. E.g., community's doesn't convert it to a hash at all
              status_hash = self.agent_status.map_to_hash{|k,v| {k => v.to_hash}}
              outgoing.set_opts({:result => status_hash})
            when ControllerCommand::PURGE_DEAD then
              agent_log("Purging DEAD agents from internal data structures")
              purge_dead_agents
            else
              agent_log_warn("Received unknown command: #{payload[:command]}")
              outgoing = Granite::ControllerResponse.error.set_opts({:message => "Received unknown command: #{payload[:command]}"})
            end
      rescue Exception => exception
        agent_log_error("Exception while processing command>#{payload.inspect}< #{exception.message} #{exception.backtrace}")
        outgoing = Granite::ControllerResponse.error.set_opts({:message => exception.message, :backtrace => exception.backtrace})
      ensure
        fire_event Events::COMMAND_COMPLETED
        AMQP.channel.direct('amq.direct').publish(outgoing.to_job.to_json, :routing_key => header.reply_to) unless header.reply_to.nil?
      end
    end

    def reset_data_stores
      @stopping_children = false

      # associates the name of the agent with the file it's in and the number we should spawn
      self.agent_info = {}

      # keeps the currently running agents that this controller started
      @agents = {}
      @agents_starting = {}
      @agents_id_map = {}
      @queue_data = {}

      default_reset_data_stores
    end

    def use_raider(exchange = nil)
      false
    end

    def find_pid_for_agent_with_id(id)
      ip = Granite::AgentStatus.local_ip
      ret_pid = nil
      @agent_status.keys.find do |agent_id|
        next unless agent_id == id
        host = @agent_status[agent_id].host
        pid = @agent_status[agent_id].pid
        ret_pid = pid if host == ip && @agents.keys.find {|p_id| pid == p_id}
      end
      ret_pid
    end

    def find_pid_for_running_agent_of_class(clazz)
      @agents.keys.sort.find do |pid|
        agent = @agents[pid]
        agent[:name] == clazz && agent[:stopping] == false && agent[:running] == true
      end
    end

    def proportional_gain
      @proportional_gain ||= 1.0
    end

    def integral_gain
      @integral_gain ||= 0.0001
    end

    def derivative_gain
      @derivative_gain ||= 0.0
    end

    # 'agent_name' => 'AgentName'
    # 'granite/agent_name' => 'Granite::AgentName'
    # 'granite__agent_name' => 'Granite::AgentName'
    # 'granite::agent_name' => 'Granite::AgentName'
    # 'Granite::AgentName' => 'Granite::AgentName'
    # Note: #classify appears slightly broken in activesupport 3.2:
    # > 'Granite/RaiderAgent'.classify
    # => "Granite::Raideragent"
    # calling #tableize first seems to avoid triggering this.
    def classify_agent_string(agent_string)
      agent_string = agent_string.to_s.gsub(/__|::/, '/')
      agent_string.tableize.classify
    end

    class Events
      include RosettaStone::EventDispatcher::Event

      # Create constants and matching class methods to create commands associated with those constants
      CONSTS = %w(started_agent stopped_agent command_completed)

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
