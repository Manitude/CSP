require 'zlib'
require 'stringio'

module Rabbit::TestUnitExtensions

  def assert_no_messages_published(producer_class)
    assert_publishes_message(producer_class, 0)
  end

  def assert_publishes_message(producer_class, count = 1)
    bunny_mock = mock()
    exchange = mock()
    exchange.expects(:publish).times(count)
    bunny_mock.stubs(:exchange).returns(exchange)
    producer_class.any_instance.stubs(:with_bunny_connection).yields(bunny_mock)
  end

  def assert_message_is_gzipped(message)
    assert_true(is_message_gzipped?(message))
  end

  def is_message_gzipped?(message)
    RosettaStone::Compression.is_compressed?(message)
  end

  def decompress_message(message)
    RosettaStone::Compression.decompress(message)
  end

  def assert_rabbit_message(producer_class, exchange, action_proc, check_proc)
     Rabbit::Connection.test_mode = false
     producer_class.exchange_options = {:type => :fanout, :durable => false, :auto_delete => true}

     producer_class.with_bunny_connection do |bunny|

        queue = bunny.queue(RosettaStone::UUIDHelper.generate)
        exch = bunny.exchange(exchange, EventQueueCallbackProducer.exchange_options)
        queue.bind(exch)

        action_proc.call

        # Not always sure to have a message, it would be interesting to see when rabbitmq might fail here.
        assert message = queue.pop[:payload]
        message = Rabbit::Producer.decompress(message)

        check_proc.call(message)
     end

     #FIXME: we should write this, and the Rabbit::Helper.exchanges code along with it.
     #assert_no_exchange 'test_event_queue_callback_registration'

     Rabbit::Connection.test_mode = true

  end

end

# Only require test/unit when you're in the test environment
# (otherwise it seems to output "0 tests, 0 assertions, 0 failures, 0 errors"
# when running any rake task).
if Rails.test?
  require 'test/unit'
  Test::Unit::TestCase.send(:include, Rabbit::TestUnitExtensions)
end
