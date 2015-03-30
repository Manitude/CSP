require File.expand_path('../test_helper', File.dirname(__FILE__))

class MonitorTestAgent
  include Granite::Agent
  include Granite::AgentMonitoring

  self.log_io = AgentOutputLogger::IO
  def initialize
    agentize({:exchanges => Granite::Agent::STATUS_EXCHANGE, :method => :process_agent_heartbeat}.merge(Granite::Agent::STATUS_EXCHANGE_OPTIONS))
  end

  def start(&blk)
    self.add_event_listener(Granite::Agent::Events::READY, lambda {|event| setup_dead_agent_finder})
    default_start(&blk)
  end

  def use_raider(exchange)
    false
  end
end

class Granite::AgentMonitoringTest < ActiveSupport::TestCase
  def setup
    Rabbit::Helpers.output_commands = false # no need to print out the commands we're running for tests
    Rabbit::Connection.test_mode = false
    @stop_job = Granite::Job.create('stop').to_json
    @do_purge = true
  end

  def teardown
    # if you're looking for the output from the agents, see your test.log
    logger.debug AgentOutputLogger.output
    AgentOutputLogger.reset!
    purge_all_queues! if @do_purge
  end

  test "monitor removes timed out agents" do
    Granite::Agent.stubs(:agent_info).returns({})
    status = generate_status_message("test_id", true, 12, ['testagent'], ['test-agent-id'])
    now = Time.now
    Time.expects(:now).returns(now - 30.seconds).at_least_once


    Granite::AgentMonitoring.changing_constant(:DEAD_AGENT_TIMEOUT, 0.5) do
      monitor = prepare_monitor_agent

      assert_agent_event(monitor, Granite::Agent::Events::READY, lambda { |event|
        monitor.process_agent_heartbeat({}, status.to_hash, now.to_i)

        assert_not_nil monitor.agent_status
        assert_not_nil monitor.agent_status['test_id']
        assert_true monitor.dead_agents.empty?
        assert_equal (now - 30.seconds).to_i, monitor.agent_status['test_id'].last_updated

        Time.expects(:now).returns(now + 30.seconds).at_least_once
      })

      assert_agent_event(monitor, Granite::AgentMonitoring::Events::UNREGISTERED_AGENT, lambda { |event|
        assert_false monitor.dead_agents.empty?
        assert_not_nil monitor.dead_agents['test_id']
        assert_nil monitor.unregistered_agents['test_id']

        EM.stop
      })

      monitor.start
    end
  end

  # in order to make this test pass, i had to delete the :method from the @exchange_opts, so the exchange in this test is created with the same options
  # @handler = settings.delete(:method) # in actor.rb
  # i think it started failing because the agent was calling itself ready before the exchange was actually created on the server previously
  test "monitor updates agents registration" do
    Granite::Agent.stubs(:agent_info).returns({})
    Granite::Configuration.stubs(:preferred_setting).with(:log_level).returns('warn')
    Granite::Configuration.stubs(:preferred_setting).with(:agents).returns({})
    Granite::Configuration.stubs(:preferred_setting).with(:raider).returns({:max_message_retries => 3, :delay_between_retries => 1})
    reg = generate_status_message('test-agent-id', false, 0, [], []).to_job

    monitor = prepare_monitor_agent

    assert_agent_event(monitor, Granite::Agent::Events::READY, lambda { |event|
      AMQP.channel.fanout(Granite::Agent::STATUS_EXCHANGE, Granite::Agent::STATUS_EXCHANGE_OPTIONS).publish(reg.to_json)
    })

    num_msgs = 0
    assert_agent_event(monitor, Granite::Agent::Events::HANDLED_MESSAGE, lambda { |event|
      num_msgs += 1
      if num_msgs == 1
        assert_not_nil monitor.agent_status
        assert_not_nil monitor.agent_status['test-agent-id']
        assert_true monitor.agent_status["test-agent-id"].is_a?(Granite::AgentStatus)

        unreg = Granite::AgentStatus.new(Granite::AgentStatus::UNREGISTER, 'test-agent-id').to_job
        AMQP.channel.fanout(Granite::Agent::STATUS_EXCHANGE, Granite::Agent::STATUS_EXCHANGE_OPTIONS).publish(unreg.to_json)
      else
        EM.stop
      end
    })

    assert_agent_event(monitor, Granite::AgentMonitoring::Events::AGENT_STATUS, lambda { |event|
      assert_not_nil monitor.agent_status
      assert_nil monitor.dead_agents['test-agent-id'] # don't record dead agents that have explicitly unregistered
      assert_not_nil monitor.unregistered_agents['test-agent-id'] # record agents that have explicitly unregistered
    })

    monitor.start
  end

  test "monitor updates queues" do
    Granite::Agent.stubs(:agent_info).returns({})
    Granite::Configuration.stubs(:preferred_setting).with(:log_level).returns('warn')
    Granite::Configuration.stubs(:preferred_setting).with(:agents).returns({})
    Granite::Configuration.stubs(:preferred_setting).with(:raider).returns({:max_message_retries => 3, :delay_between_retries => 1})
    reg = generate_status_message('test-agent-id', false, 0, [], ['TestAgent']).to_job

    monitor = prepare_monitor_agent

    assert_agent_event(monitor, Granite::Agent::Events::READY, lambda { |event|
      AMQP.channel.fanout(Granite::Agent::STATUS_EXCHANGE, Granite::Agent::STATUS_EXCHANGE_OPTIONS).publish(reg.to_json)
    })

    num_msgs = 0
    assert_agent_event(monitor, Granite::Agent::Events::HANDLED_MESSAGE, lambda { |event|
      num_msgs += 1
      if num_msgs == 1
        assert_not_nil monitor.agent_status
        assert_not_nil monitor.agent_status['test-agent-id']
        assert_true monitor.agent_status["test-agent-id"].is_a?(Granite::AgentStatus)

        unreg = Granite::AgentStatus.new(Granite::AgentStatus::UNREGISTER, 'test-agent-id').to_job
        AMQP.channel.fanout(Granite::Agent::STATUS_EXCHANGE, Granite::Agent::STATUS_EXCHANGE_OPTIONS).publish(unreg.to_json)
      else
        EM.stop
      end
    })

    assert_agent_event(monitor, Granite::AgentMonitoring::Events::AGENT_STATUS, lambda { |event|
      assert_not_nil monitor.agent_status
      assert_nil monitor.dead_agents['test-agent-id'] # don't record dead agents that have explicitly unregistered
      assert_not_nil monitor.unregistered_agents['test-agent-id'] # record agents that have explicitly unregistered
    })

    monitor.start
  end

  test "monitor updates agents status" do
    Granite::Agent.stubs(:agent_info).returns({})
    Granite::Configuration.stubs(:preferred_setting).with(:log_level).returns('warn')
    Granite::Configuration.stubs(:preferred_setting).with(:agents).returns({})
    Granite::Configuration.stubs(:preferred_setting).with(:raider).returns({:max_message_retries => 3, :delay_between_retries => 1})
    status = generate_status_message("test-agent-id", false, 100, ['/test-agent'], [])
    job = status.to_job

    now = Time.now

    monitor = prepare_monitor_agent

    assert_agent_event(monitor, Granite::Agent::Events::READY, lambda { |event|
      AMQP.channel.fanout(Granite::Agent::STATUS_EXCHANGE, Granite::Agent::STATUS_EXCHANGE_OPTIONS).publish(job.to_json)
    })

    assert_agent_event(monitor, Granite::AgentMonitoring::Events::AGENT_STATUS, lambda { |event|
      assert_not_nil monitor.agent_status["test-agent-id"]
      assert_true monitor.agent_status["test-agent-id"].last_updated >= now.to_i
    })

    assert_agent_event(monitor, Granite::Agent::Events::HANDLED_MESSAGE, lambda { |event|
      EM.stop
    })

    monitor.start
  end

  test "unregistering an non-registered agent does not break anything" do
    Granite::Agent.stubs(:agent_info).returns({})
    Granite::Configuration.stubs(:preferred_setting).with(:log_level).returns('warn')
    Granite::Configuration.stubs(:preferred_setting).with(:agents).returns({})
    Granite::Configuration.stubs(:preferred_setting).with(:raider).returns({:max_message_retries => 3, :delay_between_retries => 1})

    monitor = prepare_monitor_agent

    assert_nothing_raised do
      assert_agent_event(monitor, Granite::Agent::Events::READY, lambda { |event|
        unreg = Granite::AgentStatus.new(Granite::AgentStatus::UNREGISTER, 'test-agent-id').to_job
        AMQP.channel.fanout(Granite::Agent::STATUS_EXCHANGE, Granite::Agent::STATUS_EXCHANGE_OPTIONS).publish(unreg.to_json)
      })

      assert_agent_event(monitor, Granite::Agent::Events::HANDLED_MESSAGE, lambda { |event|
        assert_not_nil monitor.agent_status
        assert_nil monitor.agent_status['test-agent-id']

        EM.stop
      })

      monitor.start
    end
  end
  
  # work item 27241
  test "purge_dead_agents removes dead agents from the list" do
    Granite::Agent.stubs(:agent_info).returns({})
    Granite::Configuration.stubs(:preferred_setting).with(:agents).returns({})
    Granite::Configuration.stubs(:preferred_setting).with(:raider).returns({:max_message_retries => 3, :delay_between_retries => 1})

    monitor = prepare_monitor_agent
    s1 = Granite::AgentStatus.status("agent_1", {:dead => true})
    s2 = Granite::AgentStatus.status("agent_2", {})
    s3 = Granite::AgentStatus.status("agent_3", {:dead => true})

    agent_status = {"agent_1" => s1, "agent_2" => s2, "agent_3" => s3}
    monitor.instance_variable_set(:@agent_status, agent_status)

    assert_equal agent_status, monitor.agent_status
    monitor.purge_dead_agents

    assert_equal({"agent_2" => s2}, monitor.agent_status)
  end

private

  def prepare_monitor_agent
    monitor = MonitorTestAgent.new
    monitor.stubs(:register)
    monitor.stubs(:setup_heartbeat)
    monitor
  end
end
