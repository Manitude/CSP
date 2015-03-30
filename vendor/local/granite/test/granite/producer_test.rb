# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

require File.expand_path('../test_helper', File.dirname(__FILE__))

class Granite::ProducerTest < ActiveSupport::TestCase

  def setup
    Rabbit::Helpers.output_commands = false # no need to print out the commands we're running for tests
    Rabbit::Connection.test_mode = false
    @exchange_options = {:type => :fanout, :durable => true, :auto_delete => false}
    Granite::Producer.set_exchange("/test_agent")
    clear_queue
  end

  def teardown
    mocha_teardown
    purge_all_queues!
  end

  if Rabbit::Helpers.check_system?

    test 'granite job has a timestamp and a job guid' do
      now = Time.now
      Time.stubs(:now).returns(now)
      mess = "do this job"
      Rabbit::Connection.get('test').with_bunny_connection do |b|
        queue = b.queue('something', :durable => true, :auto_delete => false)
        exchange = b.exchange("/test_agent", @exchange_options)
        queue.bind('/test_agent')
        Granite::Producer.publish(mess)
        message = queue.pop
        payload = message[:payload]
        assert_not_equal :queue_empty, payload
        job =  Granite::Job.parse(payload)
        assert_equal now.to_i, job.timestamp.to_i
        assert_equal mess, job.payload
        assert job.job_guid
      end
    end

    test 'granite job generates a different guid every time' do
      mess = "do this job"
      Granite::Producer.publish(mess)
      Granite::Producer.publish(mess)
      Rabbit::Connection.get('test').with_bunny_connection do |b|
        queue = b.queue('something', :durable => true, :auto_delete => false)
        exchange = b.exchange("/test_agent", @exchange_options)
        queue.bind('/test_agent')
        one = queue.pop[:payload]
        two = queue.pop[:payload]
        assert_not_equal Granite::Job.parse(one).job_guid, Granite::Job.parse(two).job_guid
      end
    end

    test 'does not raise publish exception when false' do
      assert_false Granite::Producer.raise_publish_exceptions
      Rabbit::Connection.any_instance.stubs(:with_bunny_connection).raises(Rabbit::Error)
      assert_nothing_raised do
        assert_false Granite::Producer.publish('message')
      end
    end

    test 'raise publish exception when true' do
      Granite::Producer.raise_publish_exceptions = true
      assert_true Granite::Producer.raise_publish_exceptions
      Rabbit::Connection.any_instance.stubs(:with_bunny_connection).raises(Rabbit::Error)
      assert_raises(Rabbit::Error) do
        Granite::Producer.publish('message')
      end
    end

  end

  private

  def clear_queue
    Rabbit::Connection.get('test').with_bunny_connection do |b|
      queue = b.queue('something', :durable => true, :auto_delete => false)
      exchange = b.exchange("/test_agent", @exchange_options)
      queue.bind('/test_agent')
      payload = nil
      while payload != :queue_empty do
        payload = queue.pop[:payload]
      end
    end
    assert_queue_empty('something')
  rescue Exception => exception
    puts "WARNING: #{exception.message}, fine."
  end

end
