# -*- coding: utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class DummyAgent
  include Granite::Agent
  self.log_io = AgentOutputLogger::IO
  self.connection = 'test'
end

class NoRaiderAgent
  include Granite::Agent
  self.log_io = AgentOutputLogger::IO
  self.connection = 'test'

  def use_raider(exchange)
    false
  end
end


class TestActor < Granite::Actor
  attr_accessor :jobs_done

  def initialize parent
    super parent, {:exchanges => "/test_actor", :connection => 'test', :method => self.method(:process_something).to_proc, queue => {:name => klass.name.demodulize}}
  end

  def process_something(header, message)
    (self.jobs_done ||= []) << message
  end

end

class StatusTestActor < Granite::Actor
  attr_accessor :jobs_done, :exchange_options, :queue_name

  def initialize parent
    super parent, {:exchanges => "/status_test_actor", :connection => 'test', :method => self.method(:process_something).to_proc, queue => {:name => klass.name.demodulize}}
  end

  def process_something(header, message)
  end

end

class EvalTestActor < Granite::Actor
  attr_accessor :jobs_done

  def initialize parent
    super parent, {:exchanges => "/eval_test_actor", :connection => 'test', :method => self.method(:process_something).to_proc, queue => {:name => klass.name.demodulize, :exclusive => true, :auto_delete => true}}
    self.jobs_done = []
  end

  def process_something(header, message)
    if message == 'stop'
      @parent.stopping = true
    else
      out = eval(message.to_s)
      self.jobs_done << out
    end
  end

end

class MultiExchangeActor < Granite::Actor
  attr_accessor :jobs_done

  def initialize parent
    super parent, {:exchanges => ["/multi_exchange_actor_1", "/multi_exchange_actor_2", "/third_exchange"], :connection => "test", :method => self.method(:process_something).to_proc, queue => {:name => klass.name.demodulize}}
  end

  def process_something(header, message)
    self.jobs_done ||= []
    self.jobs_done << message
  end
end

class MultiParserActor < Granite::Actor
  attr_accessor :jobs_done

  def initialize parent
    super parent, {:exchanges => ["/exchange_1", "/exchange_2"], :connection => "test", :message_parsers => {"/exchange_1" => :parser_for_exchange_1, "/exchange_2" => :parser_for_exchange_2}, :method => self.method(:process_something).to_proc, queue => {:name => klass.name.demodulize}}
  end

  def process_something(header, message)
  end

  def parser_for_exchange_1(message)
  end

  def parser_for_exchange_2(message)
  end
end

class MultipleBindingsActor < Granite::Actor
  attr_accessor :jobs_done

  def initialize parent, opts={}
    super parent, {:exchanges => "/multi_binding_actor", :type => :direct, :connection => "test", :method => self.method(:process_something).to_proc, :bindings => [{:key => '1.#'}, {:key => '1.2.#'},{:key => '1.2.3'}], :queue => {:name => 'multiple_bindings'}}.merge(opts)
  end

  def process_something(header, message)
    self.jobs_done ||= []
    self.jobs_done << message
  end
end


class Granite::ActorTest < ActiveSupport::TestCase
  def setup
    Rabbit::Helpers.output_commands = false # no need to print out the commands we're running for tests
    Rabbit::Connection.test_mode = false
    @stop_job = Granite::Job.create('stop').to_json
    @parent = DummyAgent.new
    @parent.headers = 0
    @parent.number_of_jobs_processed = 0
    @consumer_config = Rabbit::Config.get('test').configuration_hash(true) # remaps :password to :pass
  end

  def teardown
    # if you're looking for the output from the actors, see your test.log
    logger.debug AgentOutputLogger.output
    AgentOutputLogger.reset!
    purge_all_queues!
  end

  if Rabbit::Helpers.check_system?
    test 'actors can listen to multiple exchanges at the same time' do
      EM.run do
        connection = AMQP.connection = @parent.new_amqp_connection(@consumer_config.to_hash.symbolize_keys.merge(:logging => false)) 
        ch = AMQP.channel = @parent.new_amqp_channel(connection) 

        wkr = MultiExchangeActor.new @parent

        assert_agent_event(wkr, Granite::Actor::Events::SUBSCRIBED.event_type, lambda { |event|
          wkr.exchanges.each do |exchange_name, exchange|
            exchange.publish(Granite::Job.create(exchange_name).to_json)
          end
        })

        events_handled = 0

        assert_agent_event(wkr, Granite::Actor::Events::HANDLED_MESSAGE.event_type, lambda { |event|
          events_handled += 1
          if events_handled == wkr.exchanges.size
            wkr.exchanges.each_key do |exchange_name|
              assert wkr.jobs_done.include?(exchange_name)
            end
            @parent.stopping = true
          end
        })
        wkr.subscribe
      end
    end

    test 'actors can parse messages from multiple exchanges with different parser' do
      EM.run do
        connection = AMQP.connection = @parent.new_amqp_connection(@consumer_config.to_hash.symbolize_keys.merge(:logging => false)) 
        ch = AMQP.channel = @parent.new_amqp_channel(connection) 
        wkr = MultiParserActor.new @parent

        wkr.message_parsers.each_value do |parser|
          wkr.expects(parser).once
        end

        assert_agent_event(wkr, Granite::Actor::Events::SUBSCRIBED.event_type, lambda { |event|
          wkr.exchanges.each do |exchange_name, exchange|
            exchange.publish(Granite::Job.create(exchange_name).to_json)
          end
        })

        events_handled = 0

        assert_agent_event(wkr, Granite::Actor::Events::HANDLED_MESSAGE.event_type, lambda { |event|
          events_handled += 1
          if events_handled == wkr.exchanges.size
            @parent.stopping = true
          end
        })

        wkr.subscribe
      end
    end

    test 'publishing to the consumer exchange gets the job done.' do
      eunique = "YOUR STRING OF NOT BEING ANYWHERE ELSE"

      EM.run do
        connection = AMQP.connection = @parent.new_amqp_connection(@consumer_config.to_hash.symbolize_keys.merge(:logging => false)) 
        ch = AMQP.channel = @parent.new_amqp_channel(connection) 
        wkr = TestActor.new @parent

        assert_agent_event(wkr, Granite::Actor::Events::SUBSCRIBED.event_type, lambda { |event|
          assert_equal 1, wkr.exchanges.size
          exchange = wkr.exchanges.values[0]
          exchange.publish(Granite::Job.create(eunique).to_json)
        })

        assert_agent_event(wkr, Granite::Actor::Events::HANDLED_MESSAGE.event_type, lambda { |event|
          assert_equal(eunique, wkr.jobs_done.first)
          @parent.stopping = true
        })

        wkr.subscribe
      end
      assert true
    end

    test 'actor blocks and then pulls the next job' do
      wkr = StatusTestActor.new @parent

      assert_agent_event(wkr, Granite::Actor::Events::SUBSCRIBED.event_type, lambda { |event|
        assert_equal 1, wkr.exchanges.size
        exchange = wkr.exchanges.values[0]
        assert_equal('/status_test_actor', exchange.name)
        2.times do |i|
          exchange.publish(Granite::Job.create("hey#{i}").to_json)
        end
      })

      events_handled = 0
      assert_agent_event(wkr, Granite::Actor::Events::HANDLED_MESSAGE.event_type, lambda { |event|
        events_handled += 1
        if events_handled == 1
          assert_equal 1, Rabbit::Helpers.message_count(wkr.queue.name)
        else
          assert_equal(0, Rabbit::Helpers.message_count(wkr.queue.name))
          @parent.stopping = true
        end
      })

      EM.run do
        connection = AMQP.connection = @parent.new_amqp_connection(@consumer_config.to_hash.symbolize_keys.merge(:logging => false)) 
        ch = AMQP.channel = @parent.new_amqp_channel(connection) 

        assert_queue_empty(@parent.class.name.demodulize)

        wkr.subscribe
      end
    end

    test 'a thousand messages do not break everything', 30 do
      carl_sagan_impression = 1000

      q_name = @parent.class.name.demodulize
      wkr = EvalTestActor.new @parent
      qname = "DummyAgent"
      EM.run do
        connection = AMQP.connection = @parent.new_amqp_connection(@consumer_config.to_hash.symbolize_keys.merge(:logging => false))
        AMQP.channel = @parent.new_amqp_channel(connection)

        assert_agent_event(wkr, Granite::Actor::Events::SUBSCRIBED, lambda { |event|
          assert_equal 1, wkr.exchanges.size
          exchange = wkr.exchanges.values[0]
          carl_sagan_impression.times do |i|
            exchange.publish(Granite::Job.create(i).to_json)
          end
          exchange.publish(@stop_job)
        })
        wkr.subscribe
      end
      
      assert_equal 0, Rabbit::Helpers.message_count(qname)
      assert_equal(carl_sagan_impression, wkr.jobs_done.length)
      assert_false Rabbit::Helpers.message_in_queue?(@stop_job, wkr.queue.name)
    end

    # Publishes 1000 messages and THEN consumes them
    test 'a thousand messages do not break everything part deux', 30 do
      carl_sagan_impression = 1000

      q_name = @parent.class.name.demodulize
      wkr = EvalTestActor.new @parent
      EM.run do
        connection = AMQP.connection = @parent.new_amqp_connection(@consumer_config.to_hash.symbolize_keys.merge(:logging => false)) 
        ch = AMQP.channel = @parent.new_amqp_channel(connection) 

        q = ch.queue(q_name, Granite::Actor::DEFAULT_QUEUE_OPTS) do
          exchange = ch.fanout("/eval_test_actor", {:durable => true}) do
            q.bind(exchange) do
              begin
                carl_sagan_impression.times do |i|
                  job = Granite::Job.create("true")
                  json = job.to_json
                  Granite::Job.parse(json)
                  q.publish(json)
                end
              rescue => e
                fail e.inspect
              end

              EM.add_timer(0.5) do
                q.status do |msgs, consumers|
                  assert_equal carl_sagan_impression, msgs;
                  q.publish(@stop_job)
                  wkr.subscribe
                end
              end
            end
          end
        end
      end
      assert_false Rabbit::Helpers.message_in_queue?(@stop_job, wkr.queue.name)
      assert_equal 0, Rabbit::Helpers.message_count(q_name)
      assert_equal(carl_sagan_impression, wkr.jobs_done.length)
    end

    test 'when actors raise an exception they dont reënqueue their job but they notify hoptoad' do
      RosettaStone::GenericExceptionNotifier.expects(:deliver_exception_notification)
      eval_job = Granite::Job.create("raise 'YourMom'").to_json
      wkr = EvalTestActor.new @parent

      EM.run do
        connection = AMQP.connection = @parent.new_amqp_connection(@consumer_config.to_hash.symbolize_keys.merge(:logging => false)) 
        ch = AMQP.channel = @parent.new_amqp_channel(connection) 

        assert_agent_event(wkr, Granite::Actor::Events::SUBSCRIBED.event_type, lambda { |event|
          assert_equal 1, wkr.exchanges.size
          exchange = wkr.exchanges.values[0]
          exchange.publish(eval_job)
        })
        assert_agent_event(wkr, Granite::Actor::Events::HANDLED_MESSAGE.event_type, lambda { |event|
          @parent.stopping = true
        })
        wkr.subscribe
      end
      assert_false Rabbit::Helpers.message_in_queue?(eval_job, wkr.queue.name)
    end

    test 'when actors stop they finish their job' do
      wkr = EvalTestActor.new @parent

      EM.run do
        connection = AMQP.connection = @parent.new_amqp_connection(@consumer_config.to_hash.symbolize_keys.merge(:logging => false)) 
        ch = AMQP.channel = @parent.new_amqp_channel(connection) 
        assert_agent_event(wkr, Granite::Actor::Events::SUBSCRIBED.event_type, lambda { |event|
          assert_equal 1, wkr.exchanges.size
          exchange = wkr.exchanges.values[0]
          exchange.publish(@stop_job)
        })
        wkr.subscribe
      end
      assert_false Rabbit::Helpers.message_in_queue?(@stop_job, wkr.queue.name)
    end

    test "granite actor exceptions should notify hoptoad and call actor's handler" do
      RosettaStone::GenericExceptionNotifier.expects(:deliver_exception_notification).once
      wkr = EvalTestActor.new @parent

      assert_agent_event(wkr, Granite::Actor::Events::SUBSCRIBED.event_type, lambda { |event|
        assert_equal 1, wkr.exchanges.size
        exchange = wkr.exchanges.values[0]
        exchange.publish(Granite::Job.create("raise 'asplode'").to_json)
      })

      assert_agent_event(wkr, Granite::Actor::Events::HANDLED_MESSAGE.event_type, lambda { |event|
        @parent.stopping = true
      })

      EM.run do
        connection = AMQP.connection = @parent.new_amqp_connection(@consumer_config.to_hash.symbolize_keys.merge(:logging => false)) 
        ch = AMQP.channel = @parent.new_amqp_channel(connection) 

        wkr.subscribe
      end
    end

    test "granite actor handles with multiple bindings correctly" do
      wkr = MultipleBindingsActor.new @parent
      wkr.handler.expects(:call).times(3)

      num_msgs = 0
      assert_agent_event(wkr, Granite::Actor::Events::HANDLED_MESSAGE.event_type, lambda { |event|
        num_msgs += 1
        if num_msgs >= 3
          @parent.stopping = true
        end
      })

      EM.run do
        connection = AMQP.connection = @parent.new_amqp_connection(@consumer_config.to_hash.symbolize_keys.merge(:logging => false)) 
        AMQP.channel = @parent.new_amqp_channel(connection) 

        wkr.subscribe
        exchange = wkr.exchanges.values[0]

        exchange.publish(Granite::Job.create("job 1").to_json, :routing_key => '1.#')
        exchange.publish(Granite::Job.create("job 2").to_json, :routing_key => '1.2.#')
        exchange.publish(Granite::Job.create("job 3").to_json, :routing_key => '1.2.3')
      end
    end

    test "multiple bindings route messages to correct agents" do
      wkr1 = MultipleBindingsActor.new(@parent, {:queue => {:name => 'wkr1'}})
      wkr1.handler.expects(:call).with(anything, "job 1")
      wkr1.handler.expects(:call).with(anything, "job 2")

      wkr2 = MultipleBindingsActor.new(@parent, {:queue => {:name => 'wkr2'}, :bindings => [{:key => '1.#'}, {:key => '1.2.#'}, {:key => '1.2.2'}]})
      wkr2.handler.expects(:call).with(anything, "job 1")
      wkr2.handler.expects(:call).with(anything, "job 2")

      wkr3 = MultipleBindingsActor.new(@parent, {:queue => {:name => 'wkr3'}, :bindings => [{:key => '1.#'}, {:key => '1.3.#'}, {:key => '1.3.2'}]})
      wkr3.handler.expects(:call).with(anything, "job 1")
      wkr3.handler.expects(:call).with(anything, "job 3")
      wkr3.handler.expects(:call).with(anything, "job 4")

      wkr4 = MultipleBindingsActor.new(@parent, {:queue => {:name => 'wkr4'}, :bindings => [{:key => '1.#'}, {:key => '1.3.#'}, {:key => '1.3.3'}]})
      wkr4.handler.expects(:call).with(anything, "job 1")
      wkr4.handler.expects(:call).with(anything, "job 3")


      num_msgs = 0
      l = lambda { |event|
        num_msgs += 1
        if num_msgs >= 9
          @parent.stopping = true
        end
      }

      assert_agent_event(wkr1,Granite::Actor::Events::HANDLED_MESSAGE.event_type, l)
      assert_agent_event(wkr2,Granite::Actor::Events::HANDLED_MESSAGE.event_type, l)
      assert_agent_event(wkr3,Granite::Actor::Events::HANDLED_MESSAGE.event_type, l)
      assert_agent_event(wkr4,Granite::Actor::Events::HANDLED_MESSAGE.event_type, l)

      EM.run do
        connection = AMQP.connection = @parent.new_amqp_connection(@consumer_config.to_hash.symbolize_keys.merge(:logging => false)) 
        ch = AMQP.channel = @parent.new_amqp_channel(connection) 

        wkr1.subscribe
        wkr2.subscribe
        wkr3.subscribe
        wkr4.subscribe

        exchange = wkr1.exchanges.values[0]

        exchange.publish(Granite::Job.create("job 1").to_json, :routing_key => '1.#') # everyone gets this
        exchange.publish(Granite::Job.create("job 2").to_json, :routing_key => '1.2.#') # only wkr1 and wkr2 get this
        exchange.publish(Granite::Job.create("job 3").to_json, :routing_key => '1.3.#') # only wkr3 and wkr4 get this
        exchange.publish(Granite::Job.create("job 4").to_json, :routing_key => '1.3.2') # only wkr3 gets this

      end
    end

    test "actor sends failed message to raider and notifies hoptoad" do
      eval_job = Granite::Job.create("raise 'YourMom'").to_json
      wkr = EvalTestActor.new @parent

      @parent.stubs(:register)
      @parent.stubs(:unregister)
      @parent.stubs(:setup_heartbeat)

      RosettaStone::GenericExceptionNotifier.expects(:deliver_exception_notification)

      EM.run do
        connection = AMQP.connection = @parent.new_amqp_connection(@consumer_config.to_hash.symbolize_keys.merge(:logging => false)) 
        ch = AMQP.channel = @parent.new_amqp_channel(connection) 

        assert_agent_event(wkr, Granite::Actor::Events::SUBSCRIBED.event_type, lambda { |event|

          assert_equal 1, wkr.exchanges.size

          exchange = wkr.exchanges.values[0]
          exchange.publish(eval_job)
        })

        assert_agent_event(wkr, Granite::Actor::Events::RECEIVED_MESSAGE, lambda { |event|
          AMQP::Exchange.expects(:new).with(anything, :fanout, Granite::Agent::RAIDER_EXCHANGE, anything).returns(mock('mock_exchange', :publish => nil, :after_recovery => nil))
        })

        assert_agent_event(wkr, Granite::Actor::Events::HANDLED_MESSAGE, lambda { |event|
          assert_true wkr.send(:publishing_this_message_to_raider?)
          @parent.stopping = true
        })

        wkr.subscribe
      end
    end

    test "actor delays if necessary" do
      wkr = EvalTestActor.new @parent
      wkr.instance_variable_set("@publishing_this_message_to_raider", true)
      wkr.expects(:with_cleanup_delay)
      wkr.send(:with_delay_to_give_em_a_chance_to_publish_to_raider_if_necessary) {}
    end

    test "actor does not delay if not necessary" do
      wkr = EvalTestActor.new @parent
      wkr.expects(:with_cleanup_delay).never
      wkr.send(:with_delay_to_give_em_a_chance_to_publish_to_raider_if_necessary) {}
    end

    test "actor does not send failed message to raider when parent says not to" do

      eval_job = Granite::Job.create("raise 'YourMom'").to_json
      parent = NoRaiderAgent.new
      parent.headers = 0
      parent.number_of_jobs_processed = 0
      parent.stubs(:register)
      parent.stubs(:unregister)
      parent.stubs(:setup_heartbeat)

      wkr = EvalTestActor.new parent

      RosettaStone::GenericExceptionNotifier.expects(:deliver_exception_notification)

      assert_agent_event(wkr, Granite::Actor::Events::SUBSCRIBED.event_type, lambda { |event|
        assert_equal 1, wkr.exchanges.size
        exchange = wkr.exchanges.values[0]
        exchange.publish(eval_job)
      })

      assert_agent_event(wkr, Granite::Actor::Events::RECEIVED_MESSAGE, lambda { |event|
        AMQP::Exchange.expects(:new).with(anything, anything, anything, anything).never
      })

      assert_agent_event(wkr, Granite::Actor::Events::HANDLED_MESSAGE, lambda { |event|
        assert_false wkr.send(:publishing_this_message_to_raider?)

        parent.stopping = true
        EM.stop #hard-stop here to avoid the agent trying to unregister itself which will cause it to violate the above expectation
      })

      EM.run do
        connection = AMQP.connection = parent.new_amqp_connection(@consumer_config.to_hash.symbolize_keys.merge(:logging => false)) 
        ch = AMQP.channel = parent.new_amqp_channel(connection) 

        wkr.subscribe
      end
    end

    if defined?(ActiveRecord)
      # when we embed mysql2 gem into apps, it is already properly loaded, but the old mysql gem is not always loaded
      begin
        require 'mysql'
      rescue MissingSourceFile
      end

      if defined?(Mysql::Error) || defined?(Mysql2::Error)
        test "actor resets mysql connection when a mysql error occurs" do
          exception_to_raise = (defined?(Mysql::Error) ? Mysql::Error : Mysql2::Error).to_s
          eval_job = Granite::Job.create("raise #{exception_to_raise}.new('fake mysql error')").to_json
          parent = NoRaiderAgent.new
          parent.headers = 0
          parent.number_of_jobs_processed = 0
          parent.stubs(:register)
          parent.stubs(:unregister)
          parent.stubs(:setup_heartbeat)

          wkr = EvalTestActor.new parent

          RosettaStone::GenericExceptionNotifier.expects(:deliver_exception_notification)
          ActiveRecord::Base.expects(:clear_active_connections!).once

          assert_agent_event(wkr, Granite::Actor::Events::SUBSCRIBED.event_type, lambda { |event|
            assert_equal 1, wkr.exchanges.size

            exchange = wkr.exchanges.values[0]
            exchange.publish(eval_job)
          })

          assert_agent_event(wkr, Granite::Actor::Events::HANDLED_MESSAGE, lambda { |event|
            parent.stopping = true
            EM.stop
          })

          EM.run do
            connection = AMQP.connection = parent.new_amqp_connection(@consumer_config.to_hash.symbolize_keys.merge(:logging => false)) 
            ch = AMQP.channel = parent.new_amqp_channel(connection) 
            wkr.subscribe
          end
        end
      end
    end

    test "actor does not ack message if parent sets skip_ack_header to true" do
      job = Granite::Job.create("raise 'YourMom'").to_json
      parent = DummyAgent.new
      parent.headers = 0
      parent.number_of_jobs_processed = 0
      parent.stubs(:register)
      parent.stubs(:unregister)
      parent.stubs(:setup_heartbeat)
      parent.stubs(:skip_ack_header?).returns(true)

      wkr = TestActor.new parent

      assert_agent_event(wkr, Granite::Actor::Events::SUBSCRIBED.event_type, lambda { |event|
        assert_equal 1, wkr.exchanges.size
        exchange = wkr.exchanges.values[0]
        exchange.publish(job)
      })

      assert_agent_event(wkr, Granite::Actor::Events::RECEIVED_MESSAGE, lambda { |event|
        EM.next_tick do
          assert_equal(1, wkr.jobs_done.length)
          @parent.stopping = true
          @parent.handle_stopping
        end
      })

      AMQP::Header.any_instance.expects(:ack).never

      EM.run do
        connection = AMQP.connection = @parent.new_amqp_connection(@consumer_config.to_hash.symbolize_keys.merge(:logging => false)) 
        ch = AMQP.channel = @parent.new_amqp_channel(connection) 

        wkr.subscribe
      end
    end

    [AMQP::TCPConnectionFailed.new({}, "on purpose"), AMQP::PossibleAuthenticationFailureError.new({})].each do |exception|
      test "agent shutsdown gracefully if connection for raider throws  #{exception.class.name}" do
        eval_job = Granite::Job.create("raise 'YourMom'").to_json
        wkr = EvalTestActor.new @parent
        @parent.actors = [wkr]

        @parent.stubs(:register)
        @parent.stubs(:unregister)
        @parent.stubs(:setup_heartbeat)
        @parent.expects(:deliver_error_notification!).at_least_once
        @parent.expects(:agent_log_error).once

        assert_agent_event(wkr, Granite::Actor::Events::SUBSCRIBED.event_type, lambda { |event|
          assert_equal 1, wkr.exchanges.size

          exchange = wkr.exchanges.values[0]
          exchange.publish(eval_job)
        })

        assert_agent_event(wkr, Granite::Actor::Events::RECEIVED_MESSAGE, lambda { |event|
          AMQP.expects(:connect).raises(AMQP::PossibleAuthenticationFailureError.new({}))
          AMQP::Exchange.any_instance.expects(:publish).never
          AMQP::Header.any_instance.expects(:ack).never
        })

        @parent.start
      end
    end
  end
end
