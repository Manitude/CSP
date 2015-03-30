# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

require File.expand_path('../test_helper', File.dirname(__FILE__))

class Granite::PidHelperTest < ActiveSupport::TestCase
  def setup
    @purge = true
    Rabbit::Connection.test_mode = false
    Rabbit::Helpers.output_commands = false # no need to print out the commands we're running for tests
    Granite::PidHelper.delete_controller_pid_file
  end

  def teardown
    EM.stop if EM.reactor_running?
    purge_all_queues! if @purge
  end

  test "waiting for agents quits with error if it takes too long" do
    Granite::PidHelper.expects(:list!).at_least_once.returns([true])
    Granite::PidHelper.wait_timeout = 1
    assert_raise Granite::AgentRestartTimeout do
      Granite::PidHelper.wait_for_processes_to_die
    end
  end

  test "get_agent_env_vars only finds reasonable vars" do
    ENV.stubs(:keys).returns([
      'SSH_AGENT_PID',
      'ControllerAgent',
      'AGENT_007',
      'progress_agent',
      'SSH_AGENT'])

    agents = Granite::PidHelper.get_agent_env_vars
    assert_equal 3, agents.size
    assert_equal 3, (['ControllerAgent', 'progress_agent', 'SSH_AGENT'] & agents).size
  end

  test "comm_timeout finds correct vars" do
    assert_equal 0, (ENV.keys.grep /granite_timeout/).size
    Granite::PidHelper.stubs(:load_average).returns(0)

    assert_equal Granite::PidHelper::CONTROLLER_COMMAND_RESPONSE_TIMEOUT, Granite::PidHelper.comm_timeout


    ENV['granite_timeout'] = "a"
    assert_equal Granite::PidHelper::CONTROLLER_COMMAND_RESPONSE_TIMEOUT, Granite::PidHelper.comm_timeout

    ENV['granite_timeout'] = '2000'
    assert_equal 2000, Granite::PidHelper.comm_timeout

    ENV.delete('granite_timeout')
    Granite::PidHelper.stubs(:load_average).returns(6.5)
    assert_equal 28, Granite::PidHelper.comm_timeout

  end

  test "communication timeout kills agents if kill_on_timeout is set" do
    Granite::PidHelper.expects(:controller_running?).returns(true).at_least_once
    Granite::PidHelper.expects(:stop!)
    Granite::PidHelper.stubs(:comm_timeout).returns(1)

    Bunny::Exchange.any_instance.stubs(:publish)

    ENV['kill_on_timeout'] = '1'
    command = Granite::ControllerCommand.list

    Granite::PidHelper.send_command_to_controller(command)
  end

  test "communication timeout does not kill agents if kill_on_timeout is not set" do
    Granite::PidHelper.expects(:controller_running?).returns(true).at_least_once
    Granite::PidHelper.expects(:stop!).never
    Granite::PidHelper.stubs(:comm_timeout).returns(1)

    Bunny::Exchange.any_instance.stubs(:publish)

    ENV.delete('kill_on_timeout')
    command = Granite::ControllerCommand.list

    Granite::PidHelper.send_command_to_controller(command)
  end

  # work item 27241
  test "purge dead agents sends purge_agent command" do
    command = Granite::ControllerCommand.purge_dead
    Granite::ControllerCommand.expects(:purge_dead).returns(command)

    Granite::PidHelper.expects(:send_command_to_controller).with(command)
    Granite::PidHelper.purge_dead_agents
  end

  test "target_controller returns the local Controllers routing key by default" do
    assert_equal 0, (ENV.keys.grep /controller/).size
    assert_equal "agent.#{Granite::AgentStatus.local_ip_for_routing_key}.ControllerAgent", Granite::PidHelper.target_controller
  end

  test "target_controller returns the shared command queue routing key when controller is one" do
    ENV["controller"] = "one"
    assert_equal Granite::ControllerAgent::SHARED_COMMAND_ROUTING_KEY, Granite::PidHelper.target_controller
    ENV.delete('controller')
  end

  test "target_controller returns the routing key for all controllers when controller is all" do
    ENV["controller"] = "all"
    assert_equal "agent.#.ControllerAgent", Granite::PidHelper.target_controller
    ENV.delete('controller')
  end

  test "target_controller returns the specified Controller routing key when controller is an ip" do
    ENV["controller"] = "192.168.1.101"
    assert_equal "agent.192_168_1_101.ControllerAgent", Granite::PidHelper.target_controller
    ENV.delete('controller')
  end

  test 'controller_running? returns the correct value' do
    @purge = false
    Granite::PidHelper.stubs(:target_controller).returns("agent.#{Granite::AgentStatus.local_ip_for_routing_key}.ControllerAgent").returns("agent.#{Granite::AgentStatus.local_ip_for_routing_key}.ControllerAgent").returns("agent.192_168_1_1.ControllerAgent").returns("agent.192_168_1_1.ControllerAgent").returns("agent.#.ControllerAgent").returns("agent.#.ControllerAgentSharedCommands")

    queue = mock('Queue')
    Bunny::Client.any_instance.stubs(:queue).returns(nil).then.returns(queue)

    #the queue and process both don't exist
    assert_false Granite::PidHelper.controller_running? #the controller was not specified (local) but queue is non-existent

    Granite::PidHelper.expects(:local_controller_process_running?).once.returns(true)

    assert_true Granite::PidHelper.controller_running? #the controller was not specified (local) and process exists

    assert_false Granite::PidHelper.controller_running? #the controller was specified (non-local) but shared queue is non-existent

    assert_true Granite::PidHelper.controller_running? #the controller was specified (non-local) and queue exists

    assert_true Granite::PidHelper.controller_running? #the controller was specified (all) and queue exists

    assert_true Granite::PidHelper.controller_running? #the controller was specified (one) and queue exists
  end

  test 'PidHelper refuses to send commands to agents if App.name is not set' do
    Granite.expects(:app_name).returns('App')
    assert_raises RuntimeError do
      command = Granite::ControllerCommand.list

      Granite::PidHelper.send_command_to_controller(command)
    end
  end

  test 'PidHelper deletes pid file if it exists but does not have a pid in it' do
    file = File.new(Granite::PidHelper.controller_pid_file, "w+")
    assert_true(File.exist?(file.path))

    Granite::PidHelper.stubs(:controller_pid_file).returns(file.path)

    File.any_instance.expects(:gets).returns(nil)

    File.expects(:delete).with(Granite::PidHelper.controller_pid_file)

    assert_equal(0, Granite::PidHelper.controller_pid)
  end

  test 'PidHlper deletes pid file if the pid in it is not running' do
    Granite::PidHelper.expects(:controller_pid).returns(999999999)
    Granite::PidHelper.expects(:controller_process_info).returns(["PS COLUMN HEADERS"])

    File.expects(:exist?).with(Granite::PidHelper.controller_pid_file).returns(true)
    File.expects(:delete).with(Granite::PidHelper.controller_pid_file)

    assert_false(Granite::PidHelper.local_controller_process_running?)
  end
end
