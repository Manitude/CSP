# -*- coding: utf-8 -*-
# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

require File.expand_path('../test_helper', File.dirname(__FILE__))

class TestAgent
  include Granite::Agent
  self.log_io = AgentOutputLogger::IO
  attr_accessor :jobs_done

  def initialize
    agentize :exchanges => "/test_agent", :connection => 'test', :method => :process_something
  end

  def process_something(message)
    (self.jobs_done ||= []) << message
  end

end

class StatusTestAgent
  include Granite::Agent
  self.log_io = AgentOutputLogger::IO
  attr_accessor :jobs_done

  def initialize
    agentize :exchanges => "/status_test_agent", :connection => 'test', :method => :process_something
  end

  def process_something(message)
    self.jobs_done ||= []
    exchange_options = {:type => :fanout, :durable => true, :auto_delete => false}
    Rabbit::Connection.get('test').with_bunny_connection do |b|
       b.exchange('/status_test_agent', exchange_options)
       q = b.queue('StatusTestAgent', {:exclusive => false, :durable => true})
       out = q.status.dup
       self.jobs_done << out
    end
  end

end

class EvalTestAgent
  include Granite::Agent
  self.log_io = AgentOutputLogger::IO
  attr_accessor :jobs_done

  def initialize
    agentize :exchanges => "/eval_test_agent", :connection => 'test', :method => :process_something
  end

  def process_something(message)
    self.jobs_done ||= []
    if message == 'stop'
      self.stop
      return
    else
      out = eval(message)
      self.jobs_done << out
    end
  end

end


class MultiExchangeAgent
  include Granite::Agent
  self.log_io = AgentOutputLogger::IO
  attr_accessor :jobs_done

  def initialize
    agentize :exchanges => ["/multi_exchange_agent_1", "/multi_exchange_agent_2", "/third_exchange"], :connection => "test", :method => :process_something
  end

  def process_something(message)
    self.jobs_done ||= []
    self.jobs_done << message
  end
end

class MultiParserAgent
  include Granite::Agent
  self.log_io = AgentOutputLogger::IO
  attr_accessor :jobs_done

  def initialize
    agentize :exchanges => ["/exchange_1", "/exchange_2"], :connection => "test", :message_parsers => {"/exchange_1" => :parser_for_exchange_1, "/exchange_2" => :parser_for_exchange_2}, :method => :process_something
  end

  def process_something(message)
  end

  def parser_for_exchange_1(message)
  end

  def parser_for_exchange_2(message)
  end
end

class MultiActorAgent
  include Granite::Agent
  self.log_io = AgentOutputLogger::IO

  def initialize
    agentize :exchanges => "/exchange_2", :connection => "test", :method => :process_something_1
    agentize :exchanges => "/exchange_1", :connection => "test", :method => :process_something_2, :queue => {:name => "#{klass.name.demodulize}queue2", :durable => false, :auto_delete => true}
  end

  def process_something_1(message)
  end

  def process_something_2(message)
  end
end

class Granite::AgentTest < ActiveSupport::TestCase

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

  test 'get_filename_for_agent_class returns correct file for non-modulized classname' do
    Object.const_set(:AwesomeAgent, Class.new )
    Granite::Agent.expects(:all_agent_files).returns(["/foo/bar/awesome_agent.rb"])
    assert_equal '/foo/bar/awesome_agent.rb', Granite::Agent.get_filename_for_agent_class('AwesomeAgent')
  end

  test 'get_filename_for_agent_class returns correct file for modulized classname' do
    Granite::Agent.expects(:all_agent_files).returns(["/foo/bar/awesome_agent.rb"])
    assert_equal '/foo/bar/awesome_agent.rb', Granite::Agent.get_filename_for_agent_class('Bar::AwesomeAgent')
  end

  test 'logger level is set properly if config value is non-existant' do
    Granite::Configuration.stubs(:preferred_setting).with(:log_level).raises(RuntimeError.new("Booyah"))
    wkr = TestAgent.new
    wkr.expects(:setup_traps)
    EM.expects(:run)
    logger.expects(:level=).with(Logger::Severity::WARN)
    wkr.default_start
  end

  test 'logger level is set properly if config value is invalid' do
    Granite::Configuration.stubs(:preferred_setting).with(:log_level).returns("fatale")
    wkr = TestAgent.new
    wkr.expects(:setup_traps)
    EM.expects(:run)
    logger.expects(:level=).with(Logger::Severity::WARN)
    wkr.default_start
  end

  test 'logger level is set properly from config value' do
    Granite::Configuration.stubs(:preferred_setting).with(:log_level).returns("fatal")
    wkr = TestAgent.new
    wkr.expects(:setup_traps)
    EM.expects(:run)
    logger.expects(:level=).with(Logger::Severity::FATAL)
    wkr.default_start
  end

  if Rabbit::Helpers.check_system?

    test "agents create an actor for each call to agentize" do
      agent = MultiActorAgent.new
      assert_agent_event(agent, Granite::Agent::Events::READY, lambda { |event|
        assert_equal(2, agent.actors.size)
        EM.stop
      })
      agent.start
    end

    test "granite agents register themselves" do
      TestAgent.any_instance.expects(:identity).at_least_once.returns("tester")

      job = generate_status_message("tester", false, 0, [], []).to_job

      Granite::Job.expects(:create).returns(job).at_least_once

      wkr = TestAgent.new
      Granite::AgentStatus.expects(:local_ip).returns('127.0.0.1').at_least_once


      assert_agent_event(wkr, Granite::Agent::Events::REGISTERED, lambda { |event|
        EM.stop
      })
      wkr.start do
        wkr.init_status_exchange
        wkr.status_exchange.expects(:publish).with(job.to_json, {:persistent => false}).at_least_once
      end
    end

    # This test seems to take about 10 seconds on my Dual-Core i7 MBP, so setting the timeout
    test "granite agents unregister themselves", 12 do
      TestAgent.any_instance.expects(:identity).at_least_once.returns("tester")

      status = Granite::AgentStatus.unregister("tester")
      job = status.to_job
      status.expects(:to_job).returns(job)

      Granite::AgentStatus.expects(:unregister).returns(status)
      Granite::AgentStatus.expects(:local_ip).returns('127.0.0.1').at_least_once

      wkr = TestAgent.new

      assert_agent_event(wkr, Granite::Agent::Events::READY, lambda { |event|
        wkr.status_exchange.expects(:publish).with(job.to_json, {:persistent => false}).at_least_once
        wkr.shutdown # must call agent.stop instead of AMQP.stop so that the agent knows to unregister itself
      })

      wkr.start do
        wkr.init_status_exchange
      end

    end

    test "granite agents send periodic status updates" do
      TestAgent.any_instance.expects(:identity).at_least_once.returns("tester")

      Granite::Agent.changing_constant(:HEARTBEAT_INTERVAL, 0.2) do
        status = generate_status_message("tester", false, 0, [], []).to_job
        Granite::AgentStatus.any_instance.expects(:to_job).at_least_once.returns(status)

        wkr = TestAgent.new


        assert_agent_event(wkr, Granite::Agent::Events::READY, lambda { |event|
          EM.stop
        })
        wkr.start do
          wkr.init_status_exchange
          wkr.status_exchange.expects(:publish).with(status.to_json, {:persistent => false}).at_least_once
        end
      end
    end

    test "agents get all queue status" do
      expected = {'queue1' => {:messages => 1, :consumers => 1}, 'queue2' => {:messages => 101, :consumers => 43}}

      agent = MultiActorAgent.new

      agent.start do
        q1 = AMQP.channel.queue('queue1', :durable => false, :auto_delete => true)
        q2 = AMQP.channel.queue('queue2', :durable => false, :auto_delete => true)

        assert_agent_event(agent, Granite::Agent::Events::READY, lambda { |event|
          agent.actors[0].expects(:queue).returns(q1)
          agent.actors[1].expects(:queue).returns(q2)

          q1.expects(:status).yields(1, 1)
          q2.expects(:status).yields(101, 43)

          agent.queues Proc.new {|hash| assert_equal expected, hash; EM.stop}
        })
      end
    end

    test "deliver exception notification decompresses the message, so they make more sense" do
      wkr = TestAgent.new
      job = {"timestamp" => Time.now.to_i, "job_guid" => "1223", "payload" => "GOGOGOG", "retries" => 0, "protocol_version" => 1}
      mangled_job = job.to_json.gsub('{', '|')
      compressed_message = RosettaStone::Compression.compress(mangled_job)
      exception = Exception.new("test")
      header = {:bork => 'bork'}
      method = 'testing'

      RosettaStone::GenericExceptionNotifier.expects(:deliver_exception_notification).with() do |exception, options| 
        mangled_job == options[:parameters][:message]
      end
      wkr.deliver_error_notification!(exception, header, compressed_message, method)
    end

    test "deliver exception notification decoded the message, so they make more sense" do
      wkr = TestAgent.new
      job = {"timestamp" => Time.now.to_i, "job_guid" => "1223", "payload" => "GOGOGOG", "retries" => 0, "protocol_version" => 1}
      compressed_message = RosettaStone::Compression.compress(job.to_json)
      exception = Exception.new("test")
      header = {:bork => 'bork'}
      method = 'testing'

      RosettaStone::GenericExceptionNotifier.expects(:deliver_exception_notification).with() do |exception, options|
        job == options[:parameters][:message]
      end
      wkr.deliver_error_notification!(exception, header, compressed_message, method)
    end

    test "connecting to pre-existing exchange with wrong parameters reconnects as passive" do
      wkr = TestAgent.new
      args = Rabbit::Config.get().configuration_hash.symbolize_keys.merge(:logging => false)

      EM.run do
        connection = AMQP.connection = AMQP.connect(args)
        channel = wkr.new_amqp_channel(connection)
        channel2 = wkr.new_amqp_channel(connection)
        channel3 = wkr.new_amqp_channel(connection)

        wkr.declare_exchange(channel, 'failure_exchange', {:type => :fanout, :durable => false, :auto_delete => true})

        # this timer is so the callback for the first exchange declaration can be called before we declare it again
        EM.add_timer(0.5) do
          wkr.expects(:new_amqp_channel).returns(channel3)

          wkr.declare_exchange(channel2, 'failure_exchange', {:type => :direct, :durable => true})
          wkr.expects(:declare_exchange).with(channel3, 'failure_exchange', {:type => :direct, :durable => true, :passive => true})

          EM.add_timer(0.5) do
            EM.stop
          end
        end
      end
    end


    test "connecting to pre-existing queue with wrong parameters reconnects as passive" do
      wkr = TestAgent.new
      args = Rabbit::Config.get().configuration_hash.symbolize_keys.merge(:logging => false)

      EM.run do
        connection = AMQP.connection = AMQP.connect(args)
        channel = wkr.new_amqp_channel(connection)
        queue = wkr.declare_queue(channel, 'failure_queue', Granite::Actor::DEFAULT_QUEUE_OPTS.merge({:durable => false}))

        channel2 = wkr.new_amqp_channel(connection)

        channel3 = wkr.new_amqp_channel(connection)

        # Note: currently, and oddly, it seems that the channel that fails is actually the first channel that declared the queue, NOT
        # the channel that redeclared the queue. Weird
        queue = wkr.declare_queue(channel2, 'failure_queue', Granite::Actor::DEFAULT_QUEUE_OPTS.merge({:durable => true}))
        wkr.expects(:new_amqp_channel).returns(channel3)
        
        # the FIRST queue to declare the queue throws the exception, so it's the parameters the queue was first declared with that are repeated
        wkr.expects(:declare_queue).with do |channel, queue, options| 
          channel == channel3 && queue == 'failure_queue' && options[:passive] == true # note that durable is set to true with new amqp and false for older amqp
        end

        EM.add_timer(0.5) do
          EM.stop
        end
      end
    end

#    Without diving into EM's guts, I can't see a way to test this in automated testing
#    test "agent reconnects after network disruption" do
#      flunk
#    end

    [AMQP::TCPConnectionFailed.new({}, "on purpose"), AMQP::PossibleAuthenticationFailureError.new({})].each do |exception|
      test "agent shutsdown gracefully if connection throws #{exception.class.name}" do
        wkr = TestAgent.new
        AMQP.expects(:connect).raises(exception)
        wkr.expects(:agent_log_error).once
        wkr.expects(:deliver_error_notification!)

        assert_nothing_raised do
          wkr.start
        end
      end


      test "agent shutsdown gracefully if connection for status throws  #{exception.class.name}" do
        wkr = TestAgent.new

        assert_nothing_raised do
          wkr.start do
            AMQP.expects(:connect).raises(exception)
            wkr.expects(:agent_log_error).once
            wkr.expects(:deliver_error_notification!)
            wkr.expects(:register).never
            EM.expects(:add_periodic_timer).never
          end
        end
      end
    end
  end

end
