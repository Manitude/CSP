# -*- coding: utf-8 -*-
# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

require File.expand_path('../test_helper', File.dirname(__FILE__))

class Granite::RaiderAgentTest < ActiveSupport::TestCase

  def setup
    Granite::RaiderAgent.log_io = AgentOutputLogger::IO
    Rabbit::Helpers.output_commands = false # no need to print out the commands we're running for tests
    Rabbit::Connection.test_mode = false
    Rabbit::Connection.get('test').with_bunny_connection do |bunny|
      bunny.exchange('/test', :auto_delete => false, :durable => true)
      bunny.queue('test-queue', :auto_delete => false, :durable => true)
    end
  end

  def teardown
    purge_all_queues!
  end

  test "raider agent handles unexpected exception in parsing job and moves on" do
    reQer = Granite::RaiderAgent.new
    job = Granite::Job.create('test')
    Granite::Job.expects(:parse).once.raises(Granite::Job::MalformedMessage) # simulate failure to parse message

    Granite::Configuration.stubs(:raider).returns({:delay_between_retries => 0.25, :max_message_retries => 3})
    reQer.stubs(:register)
    reQer.stubs(:unregister)
    reQer.stubs(:setup_heartbeat)
    reQer.stubs(:valid_raider_message?).returns(true)
    reQer.expects(:deliver_error_notification!).once

    assert_agent_event(reQer, Granite::Agent::Events::READY, lambda {|event|
      AMQP::Queue.any_instance.expects(:publish).never

      header = AMQP::Header.new(nil, nil, {:reply_to => 'test-queue'})
      header.expects(:ack).at_least_once # important: make sure the agent moves on to the next message
      reQer.process(header, job.to_json, job.timestamp)
    })

    assert_agent_event(reQer, Granite::RaiderAgent::Events::DISCARDED_MESSAGE, lambda {|event|
      shutdown_raider(reQer) #hard-stop EM to avoid mucking with expectations (i.e., add_timer is called in handle_stopping)
    })

    reQer.start
  end

  test "raider agent increments retried message" do
    reQer = Granite::RaiderAgent.new
    job = Granite::Job.create('test')

    assert_equal(0, job.retries)

    Granite::Configuration.stubs(:raider).returns({:delay_between_retries => 0.25, :max_message_retries => 3})
    reQer.stubs(:register)
    reQer.stubs(:unregister)
    reQer.stubs(:setup_heartbeat)
    reQer.stubs(:valid_raider_message?).returns(true)

    assert_agent_event(reQer, Granite::Agent::Events::READY, lambda {|event|
      default = AMQP::Exchange.default
      AMQP::Channel.any_instance.expects(:default_exchange).returns(default)
      default.expects(:publish).once.with do |job_json, options|
        job = ActiveSupport::JSON.decode(job_json)
        job['retries'] == 1 # make sure the retry count has bumped to 1
      end

      header = mock('header') do
        expects(:reply_to).returns("#{Rails.env}::test-queue").at_least_once
        expects(:ack).at_least_once
      end
      reQer.process(header, job.to_json, job.timestamp)
    })

    assert_agent_event(reQer, Granite::RaiderAgent::Events::REQUEUED_MESSAGE, lambda {|event|
      EM.add_timer(0.5) do
        shutdown_raider(reQer)
      end
    })

    reQer.start
  end

  test "raider agent sends message to original queue" do
    reQer = Granite::RaiderAgent.new
    reQer.stubs(:valid_raider_message?).returns(true)
    job = Granite::Job.create('test')

    Granite::Configuration.stubs(:raider).returns({:delay_between_retries => 0.25, :max_message_retries => 3})


    assert_agent_event(reQer, Granite::Agent::Events::READY, lambda {|event|
      default = AMQP::Exchange.default
      AMQP::Channel.any_instance.expects(:default_exchange).returns(default)
      default.expects(:publish)

      header = mock('mock_amqp_header')

      header = mock('header') do
        expects(:reply_to).returns("#{Rails.env}::test-queue").at_least_once
        expects(:ack).at_least_once
      end

      reQer.process(header, job.to_json, job.timestamp)
    })

    assert_agent_event(reQer, Granite::RaiderAgent::Events::REQUEUED_MESSAGE, lambda {|event|
      EM.add_timer(0.5) do
        shutdown_raider(reQer)
      end
    })

    reQer.start
  end

  test "raider agent re-enqueues message after specified delay" do
    now = Time.now
    Time.stubs(:now).returns(now) # freeze time so the delay will be predictable
    reQer = Granite::RaiderAgent.new
    reQer.stubs(:valid_raider_message?).returns(true)
    job = Granite::Job.create('test')

    Granite::Configuration.stubs(:raider).returns({:delay_between_retries => 1, :max_message_retries => 3})

    assert_agent_event(reQer, Granite::Agent::Events::READY, lambda {|event|
      EM.expects(:add_timer).with(1)
      header = mock('mock_amqp_header')

      reQer.process(header, job.to_json, job.timestamp)

      shutdown_raider(reQer)
    })
    reQer.start
  end

  test "raider agent accepts an array of delays instead of just a simple value with retries" do
    now = Time.now
    Time.stubs(:now).returns(now) # freeze time so the delay will be predictable
    reQer = Granite::RaiderAgent.new
    reQer.stubs(:valid_raider_message?).returns(true)
    job = Granite::Job.create('test')
    delays = [1,2,30,909]
    Granite::Configuration.stubs(:raider).returns({:delay_between_retries => delays, :max_message_retries => 3})

    delays.each_with_index do |delay, iii|
      assert_agent_event(reQer, Granite::Agent::Events::READY, lambda {|event|
        EM.expects(:add_timer).with(delay)

        header = mock('header') do
          stubs(:reply_to).returns("#{Rails.env}::test-queue")
          stubs(:ack)
        end

        job.retries = iii
        reQer.process(header, job.to_json, job.timestamp)

        shutdown_raider(reQer)
      })
    end
    reQer.start

  end

  test "raider agent publishes to deadletter and reports messages after maximum retries" do
    reQer = Granite::RaiderAgent.new
    reQer.stubs(:valid_raider_message?).returns(true)
    job = Granite::Job.create('test')

    job.retries = 0

    Granite::Configuration.stubs(:raider).returns({:delay_between_retries => 1, :max_message_retries => 0})

    assert_agent_event(reQer, Granite::Agent::Events::READY, lambda {|event|
      HoptoadNotifier.expects(:notify) if defined?(HoptoadNotifier)
      header = mock('mock_amqp_header')
      header.expects(:ack)

      reQer.process(header, job.to_json, job.timestamp)
    })

    assert_agent_event(reQer, Granite::RaiderAgent::Events::DISCARDED_MESSAGE, lambda {|event|
      EM.add_timer(0.3) do
        reQer.instance_variable_get(:@dead_queue).status do |msgs, consumers|
          assert_equal 1, msgs
          shutdown_raider(reQer)
        end
      end
    })

    reQer.start
  end

  test "raider agent caches amqp connections" do
    reQer = Granite::RaiderAgent.new
    reQer.stubs(:valid_raider_message?).returns(true)
    job = Granite::Job.create('test')

    Granite::Configuration.stubs(:raider).returns({:delay_between_retries => 0.25, :max_message_retries => 3})


    assert_equal 0, reQer.instance_variable_get(:@amqp_channels_hash).size

    header = nil
    default = nil

    assert_agent_event(reQer, Granite::Agent::Events::READY, lambda {|event|
      default = AMQP::Exchange.default
      AMQP::Channel.any_instance.expects(:default_exchange).returns(default).twice
      default.expects(:publish).with(anything, {:routing_key => 'test-queue'}).twice

      header = mock('header') do
        expects(:reply_to).returns("#{Rails.env}::test-queue").at_least_once
        expects(:ack).at_least_once
      end

      reQer.expects(:deliver_error_notification!).never

      assert_nothing_raised do
        reQer.process(header, job.to_json, job.timestamp)
      end
    })

    count = 0
    assert_agent_event(reQer, Granite::RaiderAgent::Events::REQUEUED_MESSAGE, lambda {|event|
      count += 1
      assert_equal 1, reQer.instance_variable_get(:@amqp_channels_hash).size
      if count >= 2
        EM.add_timer(0.5) do
          shutdown_raider(reQer)
        end
      else
        assert_nothing_raised do
          reQer.process(header, job.to_json, job.timestamp)
        end
      end
    })

    reQer.start
  end

  # the primary test for this test case is that it doesn't time out, which it would if RaiderAgent is not
  # working right
  test "raider agent stops if the agent is not republishing without waiting for current job to finish" do
    reQer = Granite::RaiderAgent.new
    reQer.stubs(:valid_raider_message?).returns(true)
    job = Granite::Job.create('test')

    job.retries = 0

    Granite::Configuration.stubs(:raider).returns({:delay_between_retries => 3600, :max_message_retries => 1})

    assert_agent_event(reQer, Granite::Agent::Events::READY, lambda {|event|
      header = mock('mock_amqp_header')
      header.expects(:ack).never

      reQer.process(header, job.to_json, job.timestamp)

      shutdown_raider(reQer)
    })

    reQer.start
  end

  test "raider agent stops when the agent is done republishing" do
    reQer = Granite::RaiderAgent.new
    reQer.stubs(:valid_raider_message?).returns(true)
    job = Granite::Job.create('test')

    job.retries = 0

    Granite::Configuration.stubs(:raider).returns({:delay_between_retries => 1, :max_message_retries => 1})

    assert_agent_event(reQer, Granite::RaiderAgent::Events::REQUEUING_MESSAGE, lambda {|event|
      shutdown_raider(reQer)
    })

    assert_agent_event(reQer, Granite::Agent::Events::READY, lambda {|event|
      header = mock('mock_amqp_header')
      header.expects(:ack).once

      reQer.process(header, job.to_json, job.timestamp)
    })

    assert_agent_event(reQer, Granite::RaiderAgent::Events::REQUEUED_MESSAGE, lambda {|event|
      #doesn't need to do anything, just make sure we get this message
    })

    reQer.start
  end

  # BEST TEST EVER.
  test 'skip_ack_header? is true' do
    assert_true(Granite::RaiderAgent.new.skip_ack_header?(nil))
  end

  test 'raider adjusts delay to account for time spent in the queue' do
    reQer = Granite::RaiderAgent.new
    reQer.stubs(:valid_raider_message?).returns(true)
    job = Granite::Job.create('test')
    now = Time.now
    Time.stubs(:now).returns(now)
    job.timestamp = 5.seconds.ago
    job = Granite::Job.parse(job.to_json) # Work Item 20258: exercise parse since there was a bug 

    Granite::Configuration.stubs(:raider).returns({:delay_between_retries => 8, :max_message_retries => 3})

    assert_agent_event(reQer, Granite::Agent::Events::READY, lambda {|event|
      EM.expects(:add_timer).with(3)
      header = mock('mock_amqp_header') #, :reply_to => "#{Rails.env}::test-queue")

      assert_nothing_raised do
        reQer.process(header, job.to_json, job.timestamp)
      end

      shutdown_raider(reQer)
    })
    reQer.start
  end

  test 'raider requeues messages immediately if they have been enqueued for longer than the delay' do
    reQer = Granite::RaiderAgent.new
    reQer.stubs(:valid_raider_message?).returns(true)
    job = Granite::Job.create('test')
    job.timestamp = 5.seconds.ago
    job = Granite::Job.parse(job.to_json) # Work Item 20258: exercise parse since there was a bug 

    Granite::Configuration.stubs(:raider).returns({:delay_between_retries => 1, :max_message_retries => 3})

    assert_agent_event(reQer, Granite::Agent::Events::READY, lambda {|event|
      EM.expects(:add_timer).never
      reQer.expects(:republish_message)

      header = mock('mock_amqp_header')

      reQer.process(header, job.to_json, job.timestamp)

      shutdown_raider(reQer)
    })
    reQer.start
  end

  test 'raider ensures the time before republishing is no longer than the configured delay' do
    reQer = Granite::RaiderAgent.new
    reQer.stubs(:valid_raider_message?).returns(true)
    job = Granite::Job.create('test')
    now = Time.now
    Time.stubs(:now).returns(now)
    job.timestamp = 11111111111111111111111111111111111111

    Granite::Configuration.stubs(:raider).returns({:delay_between_retries => 8, :max_message_retries => 3})

    assert_agent_event(reQer, Granite::Agent::Events::READY, lambda {|event|
      EM.expects(:add_timer).with(8)

      header = mock('header') do
        stubs(:reply_to).returns("#{Rails.env}::test-queue")
        stubs(:ack)
      end
      reQer.expects(:republish_message).never
      reQer.expects(:handle_message_cleanup).never

      reQer.process(header, job.to_json, job.timestamp)

      shutdown_raider(reQer)
    })
    reQer.start
  end

  test 'raider throws MalformedRaiderMessageError if reply_to is not populated' do
    reQer = Granite::RaiderAgent.new
    job = Granite::Job.create('test')
    job.timestamp = 5.seconds.ago

    Granite::Configuration.stubs(:raider).returns({:delay_between_retries => 1, :max_message_retries => 3})

    assert_agent_event(reQer, Granite::Agent::Events::READY, lambda {|event|
      EM.expects(:add_timer).never

      header = stub('AMQP::Header', :reply_to => nil)

      reQer.expects(:deliver_error_notification!).with do |exception, header, message, handler|
        exception.is_a? Granite::RaiderAgent::MalformedRaiderMessageError
      end

      reQer.process(header, job.to_json, job.timestamp)

      shutdown_raider(reQer)
    })
    reQer.start
  end

  test 'raider throws MalformedRaiderMessageError if header cannot be acked' do
    reQer = Granite::RaiderAgent.new
    job = Granite::Job.create('test')
    job.timestamp = 5.seconds.ago

    Granite::Configuration.stubs(:raider).returns({:delay_between_retries => 1, :max_message_retries => 3})

    assert_agent_event(reQer, Granite::Agent::Events::READY, lambda {|event|
      EM.expects(:add_timer).never

      header = stub('AMQP::Header', :reply_to => nil)
      header.expects(:respond_to?).with(:ack).returns(false)

      reQer.expects(:deliver_error_notification!).with do |exception, header, message, handler|
        exception.is_a? Granite::RaiderAgent::MalformedRaiderMessageError
      end

      reQer.process(header, job.to_json, job.timestamp)

      shutdown_raider(reQer)
    })
    reQer.start
  end

private
  def shutdown_raider(reQer)
    reQer.amqp_connections.each do |conn|
      conn.close
    end
    EM.stop
  end
end
