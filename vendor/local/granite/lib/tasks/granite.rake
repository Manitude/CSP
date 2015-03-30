# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

namespace :granite do
  
  namespace :ranged_chunk do
    desc "Runs all of the ranged chunk agents"
    task :run_all => [:environment, :notify_on_exception] do
      Granite::RangedChunkAgent.run_agents
    end
  end
  
  desc "Start up everything granite for this app as defined in config/agents.yml. If granite is running and  you supply agent class names in the form, AgentClass=2, it will start 2 agents of that class. For namespaced agents, supply the fully qualified name using underscores ('_') in place of colons (':') e.g., Granite::RaiderAgent would be specified like so: Granite__RaiderAgent. You can target all, one, or a specific Controller agent by setting the 'controller' environment variable to 'all', 'one', <target controller's ip> respectively. If it is not defined, it will target the local one"
  task :start => :environment do
    Granite::PidHelper.start
  end

  desc "Stops the granite agents via the ControllerAgent. If you supply agent class names in the form, AgentClass=2, it will stop only 2 agents of that class. You can target all, one, or a specific Controller agent by setting the 'controller' environment variable to 'all', 'one', <target controller's ip> respectively. If it is not defined, it will target the local one"
  task :stop => :environment do
    Granite::PidHelper.stop
  end

  task :stop_for_deploy => :environment do
    ENV[Granite::PidHelper::KILL_ON_TIMEOUT_VAR] = '1'
    Granite::PidHelper.stop
  end

  desc "Stops the granite agents via command line tools"
  task :stop! => :environment do
    Granite::PidHelper.stop!
  end

  desc "Forcibly kills the granite agents, after trying to stop them politely.  WARNING: This can use a kill -9!"
  task :kill => :stop! do
    Granite::PidHelper.kill!
  end

  desc "Forcibly kills the granite agents, after trying to stop them politely.  WARNING: This can use a kill -9!"
  task :kill! => :kill do end

  desc "Restart the granite agents via the ControllerAgent"
  task :restart_child_agents => :environment do
    Granite::PidHelper.restart_child_agents
  end

  desc "Restart the granite agents via command-line toolsYou can target all, one, or a specific Controller agent by setting the 'controller' environment variable to 'all', 'one', <target controller's ip> respectively. If it is not defined, it will target the local one"
  task :restart => :environment do
    Granite::PidHelper.restart
  end

  desc "Display the status of all the agents the controller knows about. You can target all, one, or a specific Controller agent by setting the 'controller' environment variable to 'all', 'one', <target controller's ip> respectively. If it is not defined, it will target the local one"
  task :status => :environment do
    list = Granite::PidHelper.status_pretty_print
    if list.is_a?(Array)
      puts list.join("\n") if !list.nil?
    else
      puts list
    end
  end

  desc "List the agent processes via the ControllerAgent. You can target all, one, or a specific Controller agent by setting the 'controller' environment variable to 'all', 'one', <target controller's ip> respectively. If it is not defined, it will target the local one"
  task :list => :environment do
    list = Granite::PidHelper.list_pretty_print
    puts list.join("\n") if !list.nil?
  end
  desc "List the agent processes via command-line tools"
  task :list! => :environment do
    puts Granite::PidHelper.list!.join("\n")
  end


  desc "List the number of granite processes running in a pretty format."
  task :count! => :environment do
    processes = Granite::PidHelper.list!.length
    puts "Host '#{`hostname`.chomp}' has #{processes} granite-related processes running!"
  end

  desc "Remove all agents listed as DEAD from the ControllerAgent, and thus from the output from status"
  task :purge_dead_agents => :environment do
    puts Granite::PidHelper.purge_dead_agents
  end

  desc "Create the correct /granite/raider exchange if it's not correct"
  task :fix_raider_exchange => :environment do
    configuration = Rabbit::Config.get(ENV['configuration'])
    begin
      puts "Fixing /granite/raider exchange for configuration #{ENV['configuration']}"
      exch = nil
      created = false
      begin
        Rabbit::Connection.get(configuration).with_bunny_connection do |bunny|
          exch = bunny.exchange(Granite::Agent::RAIDER_EXCHANGE, :passive => true)
          puts "/granite/raider exists but might not have the right options"
        end
      rescue
        Rabbit::Connection.get(configuration).with_bunny_connection do |bunny|
          #exchange doesn't exist, create it
          exch = bunny.exchange(Granite::Agent::RAIDER_EXCHANGE, Granite::Agent::RAIDER_EXCHANGE_OPTIONS)
          puts "/granite/raider created with proper options"
          created = true
        end
      end

      #exchange exists, but might not have the correct options at this point

      queue = nil
      begin
        Rabbit::Connection.get(configuration).with_bunny_connection do |bunny|
          queue = bunny.queue('RaiderAgent', {:passive => true})
          queue.unbind
        end
      rescue
        #don't care if it isn't bound
      end

      if !created
        begin
          Rabbit::Connection.get(configuration).with_bunny_connection do |bunny|
            # bunny doesn't always throw an exception when it accesses an exchange w/ different options, so we delete what we have regardless
            puts "Deleting old exchange whether or not it's right due to bunny weirdness"
            exch.delete

            exch = bunny.exchange(Granite::Agent::RAIDER_EXCHANGE, Granite::Agent::RAIDER_EXCHANGE_OPTIONS)
            puts "/granite/raider created with proper options"
          end
        rescue
          #don't care much
        end
      end

      if !queue.nil?
        Rabbit::Connection.get(configuration).with_bunny_connection do |bunny|
          queue.bind(exch, {})
          puts "RaiderAgent queue bound to existing exchange"
        end
      end

      #verify
      Rabbit::Connection.get(configuration).with_bunny_connection do |bunny|
        puts "Verifying the setup"
        exch = bunny.exchange(Granite::Agent::RAIDER_EXCHANGE, Granite::Agent::RAIDER_EXCHANGE_OPTIONS)
        exchange_options = exch.instance_variable_get(:@opts)
        client = exch.instance_variable_get(:@client)
        vhost = client.instance_variable_get(:@vhost)
        raise RuntimeError.new("Exchange doesn't have the right options") unless exchange_options[:durable] == true && exchange_options[:auto_delete] == false
        puts "Verified! - Exchange creation"

        if !queue.nil?
          bindings = Rabbit::Helpers.send(:rabbitmqctl_execute, "list_bindings -p #{vhost} source_name destination_name").split("\n")
          binding_hash = {}
          bindings.map! do |binding|
            a = binding.split("\t")
            binding_hash[a[0]] = a[1]
          end
          raise RuntimeError.new("Bindings are incorrect") unless !binding_hash['/granite/raider'].nil? && binding_hash['/granite/raider'] == 'RaiderAgent'
          puts "Verified! - Bindings"
        end
      end
    rescue => e
      puts "Error occurred trying to recreate the exchange #{e}"
    end
  end

  desc "Create deadletter exchange and queue. Note: this task is obsolete."
  task :create_deadletter_queue => :environment do
    Rabbit::Connection.get.with_bunny_connection do |bunny|
      exch = bunny.exchange(Granite::Agent::DEADLETTER_EXCHANGE, Granite::Agent::DEADLETTER_EXCHANGE_OPTIONS)
    end
    Rabbit::Helpers.create_queue('DeadLetter', Granite::Agent::DEADLETTER_EXCHANGE, nil, {}, {:key => 'dead'})
  end

  desc "Clear all messages from the deadletter queue. WARNING: DESTROYS DATA"
  task :clear_deadletter_queue => :environment do
    Rabbit::Helpers.purge_queue('DeadLetter')
  end

  desc 'Starts up one agent'
  task :start_agent => :environment do
    raise ArgumentError.new("you need to pass agent='agent'") unless ENV['agent']
    agent = ENV['agent'].constantize
    agent.start
  end
  
  desc 'Publish overdue later messages'
  task :publish_overdue_later_messages => :environment do 
    Granite::Later.publish_overdue_messages  
  end
end
