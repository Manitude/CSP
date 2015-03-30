# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

require File.expand_path('../test_helper', File.dirname(__FILE__))

class Granite::ControllerAgentTest < ActiveSupport::TestCase
  
  class Agent1
    include Granite::Agent
  end
  
  class Agent2
    include Granite::Agent
  end
  
  class Agent3
    include Granite::Agent
  end
  
  class Agent4
    include Granite::Agent
  end
  
  def setup
    Granite::Agent.connections = {}
    Granite::Agent.agent_info = {}
    Granite::ControllerAgent.log_io = AgentOutputLogger::IO
    Rabbit::Connection.test_mode = false
    Rabbit::Helpers.output_commands = false # no need to print out the commands we're running for tests
    Granite::PidHelper.expects(:comm_timed_out).never
  end

  def teardown
    purge_all_queues!
    Granite::PidHelper.delete_controller_pid_file
  end

  test 'handle_stopping calls default_handle_stopping' do
    Granite::Agent.stubs(:agent_info).returns({'Agent1' => Granite::AgentInfo.new(1)})

    stub_configuration({'agents' => {'Agent1' => 1}})

    controller = Granite::ControllerAgent.new

    controller.expects(:currently_processing_job?).returns(false)

    controller.expects(:default_handle_stopping)
    controller.expects(:stop_all_agents)
    EM.expects(:stop).never

    controller.shutdown
  end

  test 'controller starts the right number of agents' do
    stub_configuration({
      'Granite::ControllerAgentTest::Agent1' => 1, 
      'Granite::ControllerAgentTest::Agent2' => 2, 
      'Granite::ControllerAgentTest::Agent3' => 3})
    agent = Granite::ControllerAgent.new
    agent.expects(:start_agent).with('Granite::ControllerAgentTest::Agent1').once
    agent.expects(:start_agent).with('Granite::ControllerAgentTest::Agent2').times(2)
    agent.expects(:start_agent).with('Granite::ControllerAgentTest::Agent3').times(3)
    assert_agent_event(agent, Granite::Agent::Events::READY, lambda{|event| EM.add_timer(2) {EM.stop}})

    agent.start
  end

  test 'controller does not start if its hostname is not allowed' do
    Granite::Configuration.stubs(:allowed_hosts).returns(['slartibartfast', 'spacemanspiff'])
    agent = Granite::ControllerAgent.new
    agent.expects(:default_start).never

    agent.start
  end

  test 'controller starts if the skip_whitelist_check env variable is set to true' do
    ENV[Granite::ControllerAgent::SKIP_WHITELIST_CHECK] = 'true'
    Granite::Configuration.stubs(:allowed_hosts).returns(['slartibartfast', 'spacemanspiff'])
    agent = Granite::ControllerAgent.new
    agent.expects(:default_start).once

    agent.start
  end

  test 'controller starts if allowed_hosts is not defined' do
    if Granite::Configuration.method_defined?(:allowed_hosts)
      Granite::Configuration.send(:undef_method, :allowed_hosts)
    end
    assert_false(Granite::Configuration.method_defined?(:allowed_hosts))
    agent = Granite::ControllerAgent.new
    agent.expects(:default_start).once

    agent.start
  end


  test 'controller starts if allowed_hosts is nil' do
    Granite::Configuration.stubs(:allowed_hosts).returns(nil)
    agent = Granite::ControllerAgent.new
    agent.expects(:default_start).once

    agent.start
  end

  test 'controller starts if its hostname is allowed' do
    hostname = Socket.gethostname
    Granite::Configuration.stubs(:allowed_hosts).returns([hostname, 'slartibartfast', 'spacemanspiff'])
    agent = Granite::ControllerAgent.new
    agent.expects(:default_start).once

    agent.start
  end

  test 'controller starts if its hostname matches via regex' do
    Socket.expects(:gethostname).at_least_once.returns("ashrun000")
    Granite::Configuration.stubs(:allowed_hosts).returns(['slartibartfast', 'spacemanspiff',/^ashrun\d{3}/])
    agent = Granite::ControllerAgent.new
    agent.expects(:default_start).once

    agent.start
  end

  test 'controller does not start if its hostname doesnt match via regex' do
    Socket.expects(:gethostname).at_least_once.returns("ashrun00")
    Granite::Configuration.stubs(:allowed_hosts).returns(['slartibartfast', 'spacemanspiff',/^ashrun\d{3}/])
    agent = Granite::ControllerAgent.new
    agent.expects(:default_start).never

    agent.start
  end

  test 'controller does not start agents if the file does not exist' do
    agent_dir = Framework.root.join('app', 'agents').to_s
    agent = Granite::ControllerAgent.new

    assert_raise(Granite::InvalidAgent) {
      agent.start_agent("#{agent_dir}/agent1")
    }
  end

  test 'command server finds the correct agent to start' do
    assert_start_n_instances_of_agent_called_with_correct_args('RaiderAgent', 3, 3, 'RaiderAgent')
  end

  %w(Granite__RaiderAgent granite__raider_agent granite::raider_agent granite/raider_agent).each do |string|
    test "command server accepts agent name specified like #{string} as a start command argument" do
      assert_start_n_instances_of_agent_called_with_correct_args(string, 3, 3, 'Granite::RaiderAgent')
    end
  end

  test 'command server accepts non-modulized agent names as a start command argument' do
    assert_start_n_instances_of_agent_called_with_correct_args('RaiderTestAgent', 3, 3, 'RaiderTestAgent')
  end

  test 'command server accepts non-modulized agent names lowercased as a start command argument' do
    assert_start_n_instances_of_agent_called_with_correct_args('raider_test_agent', 3, 3, 'RaiderTestAgent')
  end

  def assert_start_n_instances_of_agent_called_with_correct_args(input_agent_name, input_agent_count, expected_agent_count, expected_agent_class_name)
    stub_configuration({})

    Granite::Agent.stubs(:agent_info).returns({})

    agent = Granite::ControllerAgent.new
    agent.stubs(:setup_heartbeat)
    agent.stubs(:register)
    agent.stubs(:unregister)
    agent.expects(:start_n_instances_of_agent).with(expected_agent_count, expected_agent_class_name)

    command = Granite::ControllerCommand.start.set_opts({:agent => input_agent_name, :count => input_agent_count}).to_job

    assert_agent_event(agent, Granite::Agent::Events::READY, lambda{|event|
      AMQP.channel.direct(Granite::ControllerAgent::COMMAND_EXCHANGE, :passive => true).publish(command.to_json, :routing_key => agent.binding_keys[2])
    })

    assert_agent_event(agent, Granite::Agent::Events::HANDLED_MESSAGE, lambda{|event|
      agent.send(:stop)
    })

    agent.start
  end

  test 'command server tries to start an agent only once if the file does not exist' do
    agent_name = 'Agent1'
    #agent_name.expects(:constantize).raises(NameError.new)

    stub_configuration

    command = Granite::ControllerCommand.start.set_opts({:agent => agent_name, :count => 2}).to_job

    controller = Granite::ControllerAgent.new

    controller.stubs(:register)
    controller.stubs(:setup_heartbeat)

    controller.expects(:agent_log_warn).with("Attempted to start an agent that could not be loaded: Agent1")

    assert_agent_event(controller, Granite::Agent::Events::HANDLED_MESSAGE, lambda{|event|
      controller.shutdown
    })

    assert_agent_event(controller, Granite::Agent::Events::READY, lambda{|event|
      AMQP.channel.direct(Granite::ControllerAgent::COMMAND_EXCHANGE, :passive => true).publish(command.to_json, :routing_key => controller.binding_keys[2])
    })

    assert_raise(Granite::InvalidAgent) {
      controller.start
    }
  end


  test 'command server stops the right number of agents' do
    Granite::Agent.stubs(:agent_info).returns({})
    stub_configuration({})

    command = Granite::ControllerCommand.stop.set_opts({:class => 'Class1', :count => 2, :signal => 15}).to_job

    controller = Granite::ControllerAgent.new
    controller.stubs(:register)
    controller.stubs(:setup_heartbeat)

    agent_hash = {1 => {:name => "Class1" , :running => true, :stopping => false}, 2 => {:name => "Class1" , :running => true, :stopping => false}, 3 => {:name => "Class3" , :running => true, :stopping => false}, 4 => {:name => "Class1" , :running => true, :stopping => false}}
    controller.instance_variable_set(:@agents, agent_hash)

    controller.expects(:stop_all_agents).never

    Process.expects(:kill).with do |a,b|
      a == 15 && (b == 1 || b == 2)
    end.twice

    assert_agent_event(controller, Granite::Agent::Events::READY, lambda{|event|
      AMQP.channel.direct(Granite::ControllerAgent::COMMAND_EXCHANGE, :passive => true).publish(command.to_json, :routing_key => controller.binding_keys[2])
    })

    assert_agent_event(controller, Granite::Agent::Events::HANDLED_MESSAGE, lambda{|event|
      controller.send(:stop)
    })

    controller.start
  end

  test 'command server restarts agents', 20 do
    command = Granite::ControllerCommand.restart.to_job
    stub_configuration
    
    controller = Granite::ControllerAgent.new

    controller.stubs(:register)
    controller.stubs(:setup_heartbeat)

    controller.expects(:start_agent).with('Granite::ControllerAgentTest::Agent1').times(2)
    controller.expects(:start_agent).with('Granite::ControllerAgentTest::Agent2').times(2)
    controller.expects(:start_agent).with('Granite::ControllerAgentTest::Agent3').times(2)
    controller.expects(:stop_all_agents).at_least_once

    assert_agent_event(controller, Granite::Agent::Events::READY, lambda{|event|
      AMQP.channel.direct(Granite::ControllerAgent::COMMAND_EXCHANGE, :passive => true).publish(command.to_json, :routing_key => controller.binding_keys[2])
    })

    assert_agent_event(controller, Granite::Agent::Events::HANDLED_MESSAGE, lambda{|event|
      EM.add_timer(1) do
        EM.stop
      end
    })
    controller.start
  end

  test 'command server restarts agents with new default settings' do
    command = Granite::ControllerCommand.restart.to_job

    stub_configuration
    controller = Granite::ControllerAgent.new
    controller.stubs(:register)
    controller.stubs(:setup_heartbeat)

    controller.expects(:start_agent).with('Granite::ControllerAgentTest::Agent1').times(2)
    controller.expects(:start_agent).with('Granite::ControllerAgentTest::Agent2').times(2)
    controller.expects(:start_agent).with('Granite::ControllerAgentTest::Agent3').times(2)
    controller.expects(:start_agent).with('Granite::ControllerAgentTest::Agent4').once
    controller.expects(:stop_all_agents).at_least_once

    assert_agent_event(controller, ::Granite::Agent::Events::READY, lambda{|event|
      stub_configuration({
        'Granite::ControllerAgentTest::Agent1' => 1, 
        'Granite::ControllerAgentTest::Agent2' => 1, 
        'Granite::ControllerAgentTest::Agent3' => 1,
        'Granite::ControllerAgentTest::Agent4' => 1
        })
      AMQP.channel.direct(Granite::ControllerAgent::COMMAND_EXCHANGE, :passive => true).publish(command.to_json, :routing_key => controller.binding_keys[2])
    })

    assert_agent_event(controller, Granite::Agent::Events::HANDLED_MESSAGE, lambda{|event|
      EM.add_timer(1) do 
        EM.stop
      end
    })

    controller.start
  end

  test 'command server stops all agents' do
    stub_configuration

    command = Granite::ControllerCommand.stop.set_opts({:signal => 15}).to_job

    controller = Granite::ControllerAgent.new

    controller.stubs(:register)
    controller.stubs(:setup_heartbeat)

    controller.expects(:start_agent).times(3)
    controller.expects(:stop_all_agents)
    controller.expects(:shutdown)

    assert_agent_event(controller, Granite::Agent::Events::HANDLED_MESSAGE, lambda{|event|
      EM.stop
    })

    assert_agent_event(controller, Granite::Agent::Events::READY, lambda{|event|
      AMQP.channel.direct(Granite::ControllerAgent::COMMAND_EXCHANGE, :passive => true).publish(command.to_json, :routing_key => controller.binding_keys[2])
    })

    controller.start
  end

  test 'command server kills agents' do
    stub_configuration

    command = Granite::ControllerCommand.stop.set_opts(:signal => 9).to_job


    controller = Granite::ControllerAgent.new
    controller.expects(:start_agent).times(3)
    controller.expects(:stop_all_agents).with(9)
    controller.expects(:handle_stopping).at_least_once
    controller.stubs(:register)
    controller.stubs(:setup_heartbeat)
    controller.expects(:shutdown)

    assert_agent_event(controller, Granite::Agent::Events::HANDLED_MESSAGE, lambda{|event|
      EM.stop
    })

    assert_agent_event(controller, Granite::Agent::Events::READY, lambda{|event|
      AMQP.channel.direct(Granite::ControllerAgent::COMMAND_EXCHANGE, :passive => true).publish(command.to_json, :routing_key => controller.binding_keys[2])
    })

    controller.start
  end

  test 'command server kills specified agent' do
    stub_configuration

    command = Granite::ControllerCommand.stop.set_opts({:signal => 9, :pid => 0}).to_job

    controller = Granite::ControllerAgent.new
    controller.expects(:start_agent).times(3)
    controller.expects(:stop_agent).with(0, 9)
    controller.stubs(:register)
    controller.stubs(:setup_heartbeat)

    assert_agent_event(controller, Granite::Agent::Events::HANDLED_MESSAGE, lambda{|event|
      EM.stop
    })

    assert_agent_event(controller, Granite::Agent::Events::READY, lambda{|event|
      AMQP.channel.direct(Granite::ControllerAgent::COMMAND_EXCHANGE, :passive => true).publish(command.to_json, :routing_key => controller.binding_keys[2])
    })

    controller.start
  end

  test 'command server lists local agents' do
    stub_configuration
    command = Granite::ControllerCommand.list.to_job

    expected_pid_hash = {
      '1' => {'name' => 'agent1', 'path' => 'path', 'command' => 'cmd'},
      '2' => {'name' => 'agent2', 'path' => 'path', 'command' => 'cmd'},
      '3' => {'name' => 'agent3', 'path' => 'path', 'command' => 'cmd'},
    }

    controller = Granite::ControllerAgent.new
    controller.stubs(:register)
    controller.stubs(:setup_heartbeat)
    controller.expects(:agents).returns(expected_pid_hash)
    controller.expects(:start_agent).times(3)

    assert_agent_event(controller, Granite::Agent::Events::READY, lambda{|event|
      reply_qname = "controller-test-reply-message-#{("%06x" % rand(0x1000000))}"

      AMQP.channel.queue(reply_qname, :durable => false, :exclusive => true, :auto_delete => true).bind(AMQP.channel.direct('amq.direct'), :key => reply_qname).subscribe(:ack => false) do |header, message|
        payload = Granite::Job.parse(message).payload
        if(payload['response'] != Granite::ControllerResponse::ACK)
          assert_equal expected_pid_hash, payload['result']
          header.ack
          EM.stop
        end
      end
      AMQP.channel.direct(Granite::ControllerAgent::COMMAND_EXCHANGE, :passive => true).publish(command.to_json, :routing_key => controller.binding_keys[2], :reply_to => reply_qname)
    })

    controller.start
  end

  # work item 27241
  test 'command server purges DEAD agents from internal data' do
    #Granite::Agent.stubs(:agent_info).returns({'agent1' => Granite::AgentInfo.new('', 1), 'agent2' => Granite::AgentInfo.new('', 1), 'agent3' => Granite::AgentInfo.new('', 1)})

    stub_configuration
    command = Granite::ControllerCommand.purge_dead.to_job
    command2 = Granite::ControllerCommand.status.to_job


    controller = Granite::ControllerAgent.new
    controller.stubs(:register)
    controller.stubs(:setup_heartbeat)
    controller.expects(:start_agent).times(3)

    # set up the individual status objects
    s1 = Granite::AgentStatus.status("agent_1", {:dead => true})
    s2 = Granite::AgentStatus.status("agent_2", {})
    s3 = Granite::AgentStatus.status("agent_3", {:dead => true})

    agent_status = {"agent_1" => s1, "agent_2" => s2, "agent_3" => s3}
    controller.instance_variable_set(:@agent_status, agent_status)

    #once our controller is ready, send the command
    assert_agent_event(controller, Granite::Agent::Events::READY, lambda{|event|
      AMQP.channel.direct(Granite::ControllerAgent::COMMAND_EXCHANGE, :passive => true).publish(command.to_json, :routing_key => controller.binding_keys[2])
    })

    handled_msg_count = 0

    # When the controller has handled our first event, we'll ask it for its agent info and assert that it matches our expectations
    assert_agent_event(controller, Granite::Agent::Events::HANDLED_MESSAGE, lambda{|event|
      reply_qname = "controller-test-reply-message-#{("%06x" % rand(0x1000000))}"

      AMQP.channel.queue(reply_qname, :durable => false, :exclusive => true, :auto_delete => true).bind(AMQP.channel.direct('amq.direct'), :key => reply_qname).subscribe(:ack => false) do |header, message|
        payload = Granite::Job.parse(message).payload
        if(payload['response'] != Granite::ControllerResponse::ACK)
          assert_not_nil(payload['result']["agent_2"])
          assert_equal(s2.to_hash.stringify_keys, payload['result']["agent_2"])
          header.ack
          EM.stop
        end
      end
      AMQP.channel.direct(Granite::ControllerAgent::COMMAND_EXCHANGE, :passive => true).publish(command2.to_json, :routing_key => controller.binding_keys[2], :reply_to => reply_qname)
    })

    controller.start
  end

  test 'command server shows all agents status' do
    Granite::Agent.stubs(:agent_info).returns({})

    stub_configuration({})

    command = Granite::ControllerCommand.status.to_job


    payload1 = generate_status_message('agent1', true, 2, [], [],'127.0.0.1', 333).to_hash
    payload2 = generate_status_message('agent2',  false,  13, [], [], '127.0.0.1', 334).to_hash
    payload3 = generate_status_message('agent3',  false,  53, [], [], '127.0.0.1', 335).to_hash
    payload4 = generate_status_message('agent4',  true,  7, [], [], '127.0.0.1', 336).to_hash

    now = Time.now
    Time.stubs(:now).returns(now)

    hash = {
      :agent1 => {:id => 'agent1', :last_updated => now.to_i, :type => "status", :host => "127.0.0.1", :pid => 333, :currently_processing_job => true, :number_of_jobs_processed => 2, :exchanges => [], :queues => []},
      :agent2 => {:id => 'agent2', :last_updated => now.to_i, :type => "status", :host => "127.0.0.1", :pid => 334, :currently_processing_job => false, :number_of_jobs_processed => 13, :exchanges => [], :queues => []},
      :agent3 => {:id => 'agent3', :last_updated => now.to_i, :type => "status", :host => "127.0.0.1", :pid => 335, :currently_processing_job => false, :number_of_jobs_processed => 53, :exchanges => [], :queues => []},
      :agent4 => {:id => 'agent4', :last_updated => (now - 30.seconds).to_i, :type => "status", :host => "127.0.0.1", :pid => 336, :currently_processing_job => true, :number_of_jobs_processed => 7,  :registered => false, :dead => true, :exchanges => [], :queues => []}
    }

    Granite::AgentMonitoring.changing_constant(:DEAD_AGENT_TIMEOUT, 1.seconds) do
      controller = Granite::ControllerAgent.new
      controller.stubs(:register)
      controller.stubs(:setup_heartbeat)

      assert_agent_event(controller, Granite::Agent::Events::READY, lambda { |event|
         controller.process_agent_heartbeat(nil, payload1.to_hash, now.to_i)
         controller.process_agent_heartbeat(nil, payload2.to_hash, now.to_i)
         controller.process_agent_heartbeat(nil, payload3.to_hash, now.to_i)
         controller.process_agent_heartbeat(nil, payload4.to_hash, now.to_i)

         assert_not_nil controller.agent_status
         assert_not_nil controller.agent_status['agent1']
         assert_not_nil controller.agent_status['agent2']
         assert_not_nil controller.agent_status['agent3']
         assert_not_nil controller.agent_status['agent4']

         controller.process_agent_heartbeat(nil, payload1.to_hash, now.to_i)
         controller.process_agent_heartbeat(nil, payload2.to_hash, now.to_i)
         controller.process_agent_heartbeat(nil, payload3.to_hash, now.to_i)

         Time.expects(:now).returns(now - 30.seconds).at_least_once
         controller.process_agent_heartbeat(nil, payload4.to_hash, now.to_i)
         Time.expects(:now).returns(now).at_least_once

         assert_not_nil controller.agent_status
         assert_not_nil controller.agent_status['agent1']
         assert_not_nil controller.agent_status['agent2']
         assert_not_nil controller.agent_status['agent3']
         assert_not_nil controller.agent_status['agent4']
      })

      assert_agent_event(controller, Granite::AgentMonitoring::Events::UNREGISTERED_AGENT, lambda{ |event|
        reply_qname = "controller-test-reply-message-#{("%06x" % rand(0x1000000))}"
        AMQP.channel.queue(reply_qname, :durable => false, :exclusive => true, :auto_delete => true).bind(AMQP.channel.direct('amq.direct'), :key => reply_qname).subscribe(:ack => false) do |header, message|

          payload = Granite::Job.parse(message).payload.deep_symbolize_keys

          if(payload[:response] != Granite::ControllerResponse::ACK)
            assert_equal hash, payload[:result]
            assert_not_nil controller.agent_status['agent4']
            assert_false controller.agent_status['agent4'].registered
            assert_true controller.agent_status['agent4'].dead
            assert_not_nil controller.dead_agents['agent4']

            header.ack
            EM.stop
          end
       end
       AMQP.channel.direct(Granite::ControllerAgent::COMMAND_EXCHANGE, :passive => true).publish(command.to_json, :routing_key => controller.binding_keys[2], :reply_to => reply_qname)
      })

      controller.start
    end
  end

  test 'binding keys' do
    agent = Granite::ControllerAgent.new
    local_ip = Granite::AgentStatus.local_ip_for_routing_key
    expected_keys = [
      'agent.#',
      "agent.#{local_ip}.#",
      "agent.#{local_ip}.ControllerAgent",
      'agent.#.ControllerAgent',
    ]
    assert_equal_arrays(expected_keys, agent.binding_keys)
  end

  test 'binding keys hash array' do
    agent = Granite::ControllerAgent.new
    binding_keys = agent.binding_keys
    hash_array = agent.binding_keys_hash_array

    assert_equal(binding_keys.size, hash_array.size)
    hash_array.each do |hash|
      assert_true(binding_keys.include?(hash[:key]))
    end
  end

  test 'find_pid_for_running_agent_of_class' do
    agent = Granite::ControllerAgent.new
    agent.instance_variable_set(:@agents, {1 => {:name => "Class1", :running => true, :stopping => false}, 2 => {:name => "Class2", :running => true, :stopping => false}, 3 => {:name => "Class3", :running => true, :stopping => false}})
    assert_equal 2, agent.find_pid_for_running_agent_of_class("Class2")

    agent.instance_variable_set(:@agents, {1 => {:name => "Class1", :running => true, :stopping => true}, 2 => {:name => "Class1", :running => false, :stopping => false}, 3 => {:name => "Class1", :running => true, :stopping => false}})
    assert_equal 3, agent.find_pid_for_running_agent_of_class("Class1")
  end

  test 'find_pid_for_agent_with_id' do
    agent = Granite::ControllerAgent.new
    status1 = Granite::AgentStatus.status("Agent1-1-1")
    status1.host = "192.168.1.1"
    status1.pid = 1
    status2 = Granite::AgentStatus.status("Agent2-2-2")
    status2.host = "192.168.1.1"
    status2.pid = 2
    status3 = Granite::AgentStatus.status("Agent3-3-3")
    status3.host = "192.168.1.2"
    status3.pid = 1

    Granite::AgentStatus.stubs(:local_ip).returns("192.168.1.1")
    agent.instance_variable_set(:@agent_status, {"Agent1-1-1" => status1,
                                                 "Agent2-2-2" => status2,
                                                 "Agent3-3-3" => status3})
    agent.instance_variable_set(:@agents, {1 => {:name => "Class1"}, 2 => {:name => "Class2"}})
    assert_equal 2, agent.find_pid_for_agent_with_id("Agent2-2-2")
  end

  test 'find_pid_for_agent_with_id returns nil if agent is not on this host' do
    agent = Granite::ControllerAgent.new
    status1 = Granite::AgentStatus.status("Agent1-1-1")
    status1.host = "192.168.1.1"
    status1.pid = 1
    status2 = Granite::AgentStatus.status("Agent2-2-2")
    status2.host = "192.168.1.1"
    status2.pid = 2
    status3 = Granite::AgentStatus.status("Agent3-3-3")
    status3.host = "192.168.1.2"
    status3.pid = 1

    Granite::AgentStatus.stubs(:local_ip).returns("192.168.1.1")
    agent.instance_variable_set(:@agent_status, {"Agent1-1-1" => status1,
                                                 "Agent2-2-2" => status2,
                                                 "Agent3-3-3" => status3})
    agent.instance_variable_set(:@agents, {1 => {:name => "Class1"}, 2 => {:name => "Class2"}})
    assert_nil agent.find_pid_for_agent_with_id("Agent3-3-3")
  end

  test 'controller starts up 1 extra agent when queue gets too big too fast' do
    agent = Granite::ControllerAgent.new
    agent.instance_variable_set(:@agents_starting, {})
    agent.instance_variable_set(:@agents_running, {'AwesomeAgent' => {:initial => 1, :running => 1, :max => 2}})
    agent.expects(:start_agent).once.with('AwesomeAgent')
    agent.expects(:stop_agent).never
    
    agent.expects(:pid_loop_value).returns( -2001.0 )
    agent.adjust_agents_for_queue_if_necessary({:error => 3, :previous_error => 1, :messages => 2000, :consumers => 1, :agent_types => ['AwesomeAgent']})
  end

  test 'controller does not start up any extra agent when queue gets too big too fast and the max number of agents are running' do
    agent = Granite::ControllerAgent.new
    agent.instance_variable_set(:@agents_starting, {})
    agent.instance_variable_set(:@agents_running, {'AwesomeAgent' => {:initial => 1, :running => 2, :max => 2}})
    agent.expects(:start_agent).never
    
    agent.expects(:pid_loop_value).returns( -3001.0 )
    agent.adjust_agents_for_queue_if_necessary({:error => 3, :previous_error => 1, :messages => 3000, :consumers => 1, :agent_types => ['AwesomeAgent']})
  end

  test 'controller does not start up a new agent if it is waiting for one to start up' do
    agent = Granite::ControllerAgent.new
    agent.instance_variable_set(:@agents_starting, {"AwesomeAgent" => 1})
    agent.instance_variable_set(:@agents_running, {'AwesomeAgent' => {:initial => 1, :running => 1, :max => 3}})
    agent.expects(:start_agent).never

    agent.expects(:pid_loop_value).returns( -2001.0 )
    agent.adjust_agents_for_queue_if_necessary({:error => 3, :previous_error => 1, :messages => 2500, :consumers => 1, :agent_types => ['AwesomeAgent']})
  end
  
  test 'controller decrements starting agent in map of starting agents when it registers' do
    agent = Granite::ControllerAgent.new
    agent.instance_variable_set(:@agents_starting, {"AwesomeAgent" => 2})
    agent.expects(:deliver_exception_notification!).never
    agent.agent_status_callback(Granite::AgentStatus.status("AwesomeAgent-test", {:agent_type => 'AwesomeAgent', :queues => {'AwesomeAgent' => {:messages => 0, :consumers => 0}}}), true)

    assert_equal 1, agent.instance_variable_get(:@agents_starting)["AwesomeAgent"]
  end

  test 'controller fires hoptoad notification if it decrements agent in map of starting agents below 0' do
    agent = Granite::ControllerAgent.new
    agent.instance_variable_set(:@agents_id_map, {})
    agent.instance_variable_set(:@agents_starting, {"AwesomeAgent" => 0})
    agent.expects(:deliver_error_notification!).once
    agent.agent_status_callback(Granite::AgentStatus.status("AwesomeAgent-test", {:agent_type => 'AwesomeAgent', :queues => {'AwesomeAgent' => {:messages => 0, :consumers => 0}}}), true)
  end

  test 'controller agent stops excess agents when queue is under control' do
    stub_configuration({'agents' => {'awesome_agent' => {:default => 1, :max => 3}}})
    agent = Granite::ControllerAgent.new
    agent.instance_variable_set(:@agents_running, {'AwesomeAgent' => {:running => 3, :initial => 1, :max => 3}})
    agent.expects(:find_pid_for_running_agent_of_class).with('AwesomeAgent').times(2).returns(111)
    agent.expects(:stop_agent).with(111).times(2)
    
    agent.expects(:pid_loop_value).returns( 0.0 )
    agent.adjust_agents_for_queue_if_necessary({:error => 3, :previous_error => 1, :messages => 10, :consumers => 3, :agent_types => ['AwesomeAgent']})
  end

  test 'controller pid processing ramps up as more messages come in' do
    id = "AwesomeAgent-test-test"
    agent = Granite::ControllerAgent.new
    agent.stubs(:proportional_gain).returns(1.0)
    agent.stubs(:derivative_gain).returns(0.0)
    agent.stubs(:integral_gain).returns(0.0001)
    now = Time.now.to_i
    errors = []

    q_data = {:integral => 0, :error => 0, :previous_error => 0, :agents => [id], :agent_types => ["AwesomeAgent"], :previous_timestamp => 0, :timestamp => now, :messages => 0}

    [1, 2, 3, 4, 10, 20, 55].each do |i|
      now += 5
      agent.update_queue_stats_hash({:messages => i * Granite::ControllerAgent::DEFAULT_ERROR_POINTS_PER_AGENT}, q_data, now)
      e = agent.pid_loop_value(q_data)
      errors << e
    end

    # the errors will grow negatively as the queue grows positively
    errors.each_cons(2){|f, s| assert_true (f > s) && f < 0 && s < 0}
  end

  test 'controller pid processing ramps down as more messages are processed' do
    id = "AwesomeAgent-test-test"
    agent = Granite::ControllerAgent.new
    agent.stubs(:proportional_gain).returns(1.0)
    agent.stubs(:derivative_gain).returns(0.0)
    agent.stubs(:integral_gain).returns(0.0001)
    now = Time.now.to_i
    errors = []

    q_data = {:integral => 0, :error => 0, :previous_error => 0, :agents => [id], :agent_types => ["AwesomeAgent"], :previous_timestamp => 0, :timestamp => now, :messages => 0}

    [3, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0].each do |i|
      now += 5
      agent.update_queue_stats_hash({:messages => i * Granite::ControllerAgent::DEFAULT_ERROR_POINTS_PER_AGENT}, q_data, now)
      e = agent.pid_loop_value(q_data)
      errors << e
    end

    errors.each_cons(2){|f, s| assert_true (f <= s && f < 0 && s< 0)}
  end

  test 'controller agent starts up multiple agents at a time' do
    id = "AwesomeAgent-test-test"
    agent = Granite::ControllerAgent.new
    agent.stubs(:proportional_gain).returns(1.0)
    agent.stubs(:derivative_gain).returns(0.0)
    agent.stubs(:integral_gain).returns(0.0001)
    now = Time.now.to_i

    q_data = {:integral => 0, :error => 0, :previous_error => 0, :agents => [id], :agent_types => ["AwesomeAgent"], :previous_timestamp => 0, :timestamp => now, :messages => 0}

    d = {0 => {:running => 1, :called => 0}, 
         200 => {:running => 1, :called => 0}, 
         1000 => {:running => 1, :called => 0}, 
         2000 => {:running => 1, :called => 1}, 
         2500 => {:running => 2, :called => 0}, 
         6700 => {:running => 2, :called => 4}, 
         10000 => {:running => 6, :called => 4}}

    agent.expects(:stop_agent).never

    d.keys.sort.each do |i|
      info = d[i]
      now += 5
      agent.expects(:pid_loop_value).returns(-i)
      agent.instance_variable_set(:@agents_running, {'AwesomeAgent' => {:initial => 1, :max => 10, :running => info[:running]}})
      agent.expects(:start_agent).times(info[:called])
      e = agent.adjust_agents_for_queue_if_necessary(q_data)
    end
  end

  test 'controller agent stops multiple agents at a time' do
    id = "AwesomeAgent-test-test"
    agent = Granite::ControllerAgent.new
    agent.stubs(:proportional_gain).returns(1.0)
    agent.stubs(:derivative_gain).returns(0.0)
    agent.stubs(:integral_gain).returns(0.0001)
    now = Time.now.to_i

    agent.expects(:start_agent).never

    q_data = {:integral => 0, :error => 0, :previous_error => 0, :agents => [id], :agent_types => ["AwesomeAgent"], :previous_timestamp => 0, :timestamp => now, :messages => 0}

    d = {0 => {:running => 1, :called => 0}, 
         200 => {:running => 1, :called => 0}, 
         1000 => {:running => 2, :called => 1}, 
         2000 => {:running => 2, :called => 0}, 
         2500 => {:running => 6, :called => 4}, 
         6700 => {:running => 10, :called => 4}, 
         10000 => {:running => 10, :called => 0}}

    d.keys.sort.reverse.each do |i|
      info = d[i]
      now += 5
      agent.expects(:pid_loop_value).returns(-i)
      agent.instance_variable_set(:@agents_running, {'AwesomeAgent' => {:initial => 1, :max => 10, :running => info[:running]}})
      agent.expects(:find_pid_for_running_agent_of_class).times(info[:called]).returns(1)
      agent.expects(:stop_agent).times(info[:called])
      e = agent.adjust_agents_for_queue_if_necessary(q_data)
    end
  end

private

  def stub_configuration(agents = {'Granite::ControllerAgentTest::Agent1' => 1, 'Granite::ControllerAgentTest::Agent2' => 1, 'Granite::ControllerAgentTest::Agent3' => 1}, allowed_hosts = nil, raider = {:max_message_retries => 3, :delay_between_retries => 1})
    Granite::Configuration.stubs(:preferred_setting).with(:agents).returns(agents)
    Granite::Configuration.stubs(:preferred_setting).with(:allowed_hosts).returns(allowed_hosts)
    Granite::Configuration.stubs(:preferred_setting).with(:raider).returns(raider)
    Granite::Configuration.stubs(:preferred_setting).with(:log_level).returns('warn')
  end
end
