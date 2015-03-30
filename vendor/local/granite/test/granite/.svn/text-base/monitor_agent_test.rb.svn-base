require File.expand_path('../test_helper', File.dirname(__FILE__))

class Granite::MonitorAgentTest < ActiveSupport::TestCase
  VHOST_NAMES = []
  VHOSTS = %w(app1 app2 app3 app4).map do |name|
    fullname = "#{Granite.app_name.downcase}_#{name}"
    VHOST_NAMES.push(fullname)
    "/#{fullname}_test"
  end

  def setup
    Granite::MonitorAgent.log_io = AgentOutputLogger::IO
    Rabbit::Helpers.output_commands = false # no need to print out the commands we're running for tests
    Rabbit::Connection.test_mode = false

    @temp_rabbit_user = "#{Granite.app_name.downcase}_granite_test_user"
    @temp_rabbit_pass = 'testing'
    Rabbit::Helpers.add_user!(@temp_rabbit_user, @temp_rabbit_pass) unless Rabbit::Helpers.user_exists?(@temp_rabbit_user)

    default = Rabbit::Config.get(nil)

    @config = {
      'test' => default
    }

    count = 0
    VHOSTS.each do |fullname|
      name = VHOST_NAMES[count] + "_test"
      count += 1
      Rabbit::Helpers.add_vhost!(fullname) unless Rabbit::Helpers.vhost_exists?(fullname)
      Rabbit::Helpers.set_permissions(@temp_rabbit_user, fullname)
      @config[name] = stub("c#{count}", :configuration_hash => {:host => '127.0.0.1', :vhost => fullname, :user => @temp_rabbit_user, :pass => @temp_rabbit_pass}, :vhost => fullname, :name => name)
    end

    Rabbit::Config.stubs(:all_configurations).returns(@config)
  end

  def teardown
    # if you're looking for the output from the agents, see your test.log
    logger.debug AgentOutputLogger.output
    AgentOutputLogger.reset!

    VHOSTS.each do |fullname|
      Rabbit::Helpers.delete_vhost!(fullname) if Rabbit::Helpers.vhost_exists?(fullname)
    end
    Rabbit::Helpers.delete_user!(@temp_rabbit_user)
  end

  test "monitor agent groups agents by app" do
    Granite::MonitorConfiguration.stubs(:vhosts).returns(VHOST_NAMES)

    monitor = Granite::MonitorAgent.new
    monitor.stubs(:register)
    monitor.stubs(:unregister)
    monitor.stubs(:setup_heartbeat)

    stat1 = generate_status_message('app1Agent1', false, 0, {}, {}, '127.0.0.1', 1).to_job
    stat2 = generate_status_message('app1Agent2', false, 0, {}, {}, '127.0.0.1', 2).to_job
    stat3 = generate_status_message('app2Agent1', false, 0, {}, {}, '127.0.0.1', 1).to_job
    stat4 = generate_status_message('app2Agent2', false, 0, {}, {}, '127.0.0.1', 2).to_job
    stat5 = generate_status_message('app3Agent1', false, 0, {}, {}, '127.0.0.1', 1).to_job
    stat6 = generate_status_message('app3Agent2', false, 0, {}, {}, '127.0.0.1', 2).to_job
    stat7 = generate_status_message('app4Agent1', false, 0, {}, {}, '127.0.0.1', 1).to_job
    stat8 = generate_status_message('app4Agent2', false, 0, {}, {}, '127.0.0.1', 2).to_job

    assert_agent_event(monitor, Granite::Agent::Events::READY, lambda { |event|
      client1 = monitor.new_amqp_connection(@config[VHOST_NAMES[0]+ "_test"].configuration_hash.merge({:logging => false}))
      client3 = monitor.new_amqp_connection(@config[VHOST_NAMES[1]+ "_test"].configuration_hash.merge({:logging => false}))
      client5 = monitor.new_amqp_connection(@config[VHOST_NAMES[2]+ "_test"].configuration_hash.merge({:logging => false}))
      client7 = monitor.new_amqp_connection(@config[VHOST_NAMES[3]+ "_test"].configuration_hash.merge({:logging => false}))

      mq1 = monitor.new_amqp_channel client1
      mq3 = monitor.new_amqp_channel client3
      mq5 = monitor.new_amqp_channel client5
      mq7 = monitor.new_amqp_channel client7

      count = 0
      monitor.actors.each do |actor|
        count += 1
        case count
          when 1 then
            actor.handler.call({}, stat1.payload)
            actor.handler.call({}, stat2.payload)
          when 2 then
            actor.handler.call({}, stat3.payload)
            actor.handler.call({}, stat4.payload)
          when 3 then
            actor.handler.call({}, stat5.payload)
            actor.handler.call({}, stat6.payload)
          when 4 then
            actor.handler.call({}, stat7.payload)
            actor.handler.call({}, stat8.payload)
          end
      end

      assert_not_nil monitor.agent_status
      assert_equal 8, monitor.agent_status.size
      statuses = monitor.vhost_status
      assert_not_nil statuses
      assert_equal 4, statuses.size
      assert_true statuses[VHOST_NAMES[0]].is_a?(Hash)
      assert_true statuses[VHOST_NAMES[1]].is_a?(Hash)
      assert_true statuses[VHOST_NAMES[2]].is_a?(Hash)
      assert_true statuses[VHOST_NAMES[3]].is_a?(Hash)
      assert_not_nil statuses[VHOST_NAMES[0]]['app1Agent1']
      assert_not_nil statuses[VHOST_NAMES[0]]['app1Agent2']
      assert_not_nil statuses[VHOST_NAMES[1]]['app2Agent1']
      assert_not_nil statuses[VHOST_NAMES[1]]['app2Agent2']
      assert_not_nil statuses[VHOST_NAMES[2]]['app3Agent1']
      assert_not_nil statuses[VHOST_NAMES[2]]['app3Agent2']
      assert_not_nil statuses[VHOST_NAMES[3]]['app4Agent1']
      assert_not_nil statuses[VHOST_NAMES[3]]['app4Agent2']
      EM.stop
    }, 6)

    monitor.start
  end
end
