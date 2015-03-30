# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

module Granite
  load_amqp!

  class AgentRestartTimeout < StandardError; end
  class PidHelper
    extend SayWithTime

    CONTROLLER_COMMAND_RESPONSE_TIMEOUT = 15 # seconds
    KILL_ON_TIMEOUT_VAR = 'kill_on_timeout'

    class << self
      attr_accessor :wait_timeout

      # we are not responsible for your lost data if you call this method
      def kill!
        logger.info "PidHelper.kill!"
        kill_processes!(9)
      end

      def stop
        logger.info "PidHelper.stop"
        signal = 15
        agents = get_agent_env_vars
        if !agents.empty?
          logger.info "PidHelper.stop stopping specified agents: #{agents.inspect}"
          agents.each do |agent|
            # send 1 command for each agent you want killed instead of telling the controller to kill N agents
            count = ENV[agent].to_i || 1
            logger.info "PidHelper stopping #{count} #{agent}s"
            count.times do |i|
              send_command_to_controller Granite::ControllerCommand.stop.set_opts({:class => agent, :count => 1, :signal => signal})
            end
          end
        else
          kill_processes(signal)
        end
      end

      def stop!
        logger.info "PidHelper.stop!"
        kill_processes!(15)
      end

      def start
        logger.info "PidHelper.start"
        agents = get_agent_env_vars
        if !controller_running?
          logger.info "PidHelper.start: Starting controller"
          controller = "Granite::ControllerAgent"
          script = "File.open('#{controller_pid_file}', 'w+') do |f|
                      f.puts(Process.pid)
                    end

                    at_exit do
                      Granite::PidHelper.delete_controller_pid_file
                    end\n"

          #daemonize
          fork do
            Process.setsid
            start_agent("Granite::ControllerAgent", script)
          end
        end

        if !agents.empty?
          logger.info "PidHelper.start: Starting specified agents: #{agents.inspect}"
          agents.each do |agent|
            send_command_to_controller Granite::ControllerCommand.start.set_opts({:agent => agent, :count => ENV[agent].to_i})
          end
        end
      end

      def restart_child_agents
        logger.info "PidHelper.restart_child_agents"
        if controller_running?
          logger.info "PidHelper.restart_child_agents: sending restart command"
          send_command_to_controller  Granite::ControllerCommand.restart
        else
          logger.info "PidHelper.restart_child_agents: sending start command"
          send_command_to_controller  Granite::ControllerCommand.start
        end
      end

      def get_agent_env_vars
        ENV.keys.grep /.*agent$/i
      end

      def restart
        logger.info "PidHelper.restart"
        stop
        wait_for_controller_to_die
        start
      end

      # returns an array where each index is a line
      def list_pretty_print
        lines = []
        reply = list
        return "" if reply.nil?
        reply.each do |pid, info|
          lines << "#{pid}\t#{info[:name]}\t#{info[:path]}\t#{info[:command]}"
        end
        lines.sort
      end

      # returns a hash
      def list
        logger.info "PidHelper.list"
        send_command_to_controller(Granite::ControllerCommand.list)
      end

      def list!
        logger.info "PidHelper.list!"
        `ps auxwww | grep #{pid_identifier} | grep -v grep`.split("\n")
      end

      # returns an array where each index is a line
      def status_pretty_print
        lines = []
        reply = status
        return "" if reply.blank?
        reply.each do |id, agent|
          if agent[:dead] == true
            lines << "#{id}\t#{agent[:host]}\t#{agent[:pid]}\t(DEAD)"
          else
            lines << "#{id}\t#{agent[:host]}\t#{agent[:pid]}\t#{agent[:currently_processing_job].to_s}\t#{agent[:number_of_jobs_processed].to_s}\t#{agent[:queues].inspect}"
          end
        end
        lines.sort
      end

      # returns a hash
      def status
        logger.info "PidHelper.status"
        send_command_to_controller(Granite::ControllerCommand.status)
      end

      # work item 27241
      def purge_dead_agents
        logger.info "PidHelper.purge_dead_agents"
        send_command_to_controller(Granite::ControllerCommand.purge_dead)
      end

      def wait_for_processes_to_die
        logger.info "PidHelper.wait_for_processes_to_die"
        count = 0
        while list!.any? && count < wait_timeout
          sleep 1
          count += 1
        end
        if (count == wait_timeout)
          raise AgentRestartTimeout.new("Not all agents shutdown within #{wait_timeout} seconds")
        end
      end

      def wait_for_controller_to_die
        logger.info "PidHelper.wait_for_controller_to_die"
        count = 0
        while controller_running? && count < wait_timeout
          sleep 1
          count += 1
        end
        if (count == wait_timeout)
          raise AgentRestartTimeout.new("ControllerAgent did not die after #{wait_timeout} seconds")
        end
      end

      def pid_identifier
        "#{Granite.app_name.downcase}_granite_agent_#{Framework.env}"
      end

      def controller_pid_identifier
        pid_identifier + "_controller"
      end

      #returns the pid of the child process
      def start_agent(agent_name, before_start = "" )
        ENV['RAILS_ENV'] = Framework.env
        env_rb = Framework.root.join('config', 'environment.rb')

        runner_script ||= "$0 = '#{pid_identifier}:#{agent_name.demodulize.underscore}'
                          require '#{env_rb}'
                          Process.setsid  #add this as added protection against Process.kill(15, 0)
                          #{before_start}
                          #{agent_name.classify}.start"

        fork {
          $stderr.reopen('/dev/null', 'w')
          exec Granite::ControllerAgent::RUBY, '-e', runner_script
        }
      end

      def execute_cmd(command)
        logger.info "PidHelper.execute_cmd #{command}"
        say_with_time("executing #{command.gsub(/-p[^ ]* /, '-p ')}") do
          `#{command}`
        end
        if $? != 0
          raise "command not successful: #{command}"
        end
      end

      def kill_processes(signal = 15)
        logger.info "PidHelper.kill_processes"
        send_command_to_controller Granite::ControllerCommand.stop.set_opts({:signal => signal})
      end

      def kill_processes!(signal = 15)
        logger.info "PidHelper.kill_processes!"
        `pkill -#{signal} -f #{pid_identifier}`
      end

      def kill_controller(signal = 15)
        pid = controller_pid
        if (pid != 0)
          `kill -#{signal} #{pid}`
        end
      end


      # we try to determine if the targeted controller agent is running (could be non-local). If info from Rabbit is inconclusive, we test the local machine for a process
      def controller_running?
        controller = target_controller

        logger.info "PidHelper.controller_running? #{controller}"

        if controller == "agent.#{Granite::AgentStatus.local_ip_for_routing_key}.ControllerAgent"
          return local_controller_process_running?
        else
          Rabbit::Connection.get().with_bunny_connection do |bunny|
            queue_exists = false
            begin
              q = bunny.queue(Granite::ControllerAgent::SHARED_COMMAND_QUEUE, :passive => true)
              queue_exists = !q.nil?
            rescue => e
              queue_exists = false
            ensure
              return queue_exists
            end
          end
        end
      end

      def local_controller_process_running?
        running = false
        pid = controller_pid
        if(pid != 0)
          running = controller_process_info(pid).size > 1 #make sure it's running

          if (!running)
            warn_msg = "#{controller_pid_file} file exists, but controller doesn't appear to be running with pid #{pid}. Deleting and continuing."
            logger.warn(warn_msg)
            puts warn_msg if Framework.env != 'test'
            delete_controller_pid_file
          end
        end

        running
      end

      def controller_process_info(pid)
        `ps #{pid}`.split("\n")
      end

      def controller_pid
        pid = 0
        if(File.exist?(controller_pid_file))
          File.open(controller_pid_file, "r") do |f|
            pid = f.gets # read the pid
          end

          if (pid.nil?)
            warn_msg = "#{controller_pid_file} file exists, but has no pid in it. Deleting and starting Granite."
            logger.warn(warn_msg)
            puts warn_msg if Framework.env != 'test'
            delete_controller_pid_file
            pid = 0
          end
        end
        pid.to_i
      end

      def delete_controller_pid_file
        File.delete(controller_pid_file) if File.exist?(controller_pid_file)
      end

      def controller_pid_file
        @controller_pid_file ||= File.expand_path("tmp/controller_agent_#{Framework.env}.pid", Framework.root)
      end

      def wait_timeout
        @wait_timeout ||= 60
      end

      # By default we target the local controller, but the user can target a specific one with an ip, any random one with 'one' and every controller with 'all'
      def target_controller
        host = ENV.keys.grep(/controller/i)
        if !host.nil? && !host.blank?
          host = ENV['controller']
          if host == 'all'
            key = "agent.#.ControllerAgent"
          elsif host =~ /\b(?:\d{1,3}\.){3}\d{1,3}\b/ #an ip address
            host_underscored = host.gsub(/\./, '_')
            key = "agent.#{host_underscored}.ControllerAgent"
          elsif host == 'one'
            key = Granite::ControllerAgent::SHARED_COMMAND_ROUTING_KEY
          else
            # send to the local ControllerAgent by default
            key = "agent.#{Granite::AgentStatus.local_ip_for_routing_key}.ControllerAgent"
          end
        else
          # send to the local ControllerAgent by default
          key = "agent.#{Granite::AgentStatus.local_ip_for_routing_key}.ControllerAgent"
        end
        key
      end

      def comm_timed_out
        begin
          Timeout.timeout(15) do
            stop!
          end
        rescue Timeout::Error
          kill!
        end
      end

      # if the user sets the granite_timeout environment variable, we'll use that, otherwise we use the machine's load average to adjust the default timeout
      def comm_timeout
        (ENV['granite_timeout'].to_s =~ /^\d+/ && ENV['granite_timeout'].to_i) ||
          (CONTROLLER_COMMAND_RESPONSE_TIMEOUT + (load_average * 2))
      end

      def load_average
        `uptime | awk '{print $(NF - 2)}'`.to_s.sub(/,?$/, '').to_f
      end

      def send_command_to_controller(command)
        raise 'App.name is not set! Agent collisions may occur if this is not set!' if Granite.app_name === 'App'
        logger.info "PidHelper.send_command_to_controller(#{command.inspect})"
        return if command.nil? or !command.is_a?(Granite::ControllerCommand)
        if controller_running?
          config = Rabbit::Config.get.configuration_hash(true)
          reply = ''
          routing_key = target_controller
          begin
            logger.info "PidHelper.send_command_to_controller: timeout of #{comm_timeout}"
            Rabbit::Connection.get().with_bunny_connection(:logging => false, :operation_timeout => comm_timeout) do |bunny|
              bunny.qos(:prefetch_count => 1)
              reply_qname = "pidhelper-#{"%08x" % rand(0x1000000)}"

              logger.info "PidHelper.send_command_to_controller: set reply queue to #{reply_qname}"

              queue = bunny.queue(reply_qname, :durable => false, :exclusive => true, :auto_delete => true)

              queue.bind('amq.direct', :key => reply_qname)

              logger.info("Sending command to controller agent(s) with routing key: #{routing_key}")

              bunny.exchange(Granite::ControllerAgent::COMMAND_EXCHANGE, :type => :direct, :passive => true).publish(command.to_job.to_json, :persistent => false, :key => routing_key, :reply_to => reply_qname)

              unsubscribe = false
              queue.subscribe(:ack => true) do |message|
                message = message[:payload] unless message[:payload].nil?
                payload = Granite::Job.parse(message).payload.deep_symbolize_keys
                logger.info "PidHelper.send_command_to_controller: Received response #{message}"
                case payload[:response]
                  when Granite::ControllerResponse::OK
                    if payload[:result]
                      reply = payload[:result]
                    else
                      reply = Granite::ControllerResponse::OK
                    end
                    unsubscribe = true
                  when Granite::ControllerResponse::ERROR
                    reply = "#{payload[:message]}\n#{payload[:backtrace] unless payload[:backtrace].nil?}"
                    unsubscribe = true
                  when Granite::ControllerResponse::ACK
                    logger.info("Received ACK")
                end
                if(unsubscribe)
                  queue.unsubscribe
                  queue.ack
                  break
                end
              end

            end
          rescue Rabbit::ConnectionError => e
            logger.warn "Communications with the Controller failed: #{e.inspect}"
            $stderr << "Communications with the Controller has timed out. Something may be wrong, you may need to stop/kill the agents\n" if Framework.env != 'test'
            comm_timed_out if !ENV[KILL_ON_TIMEOUT_VAR].nil?
          end
          return reply
        else
          $stderr << "Controller agent is not currently running!\n" if Framework.env != 'test'
          return ""
        end
      end
    end
  end
end
