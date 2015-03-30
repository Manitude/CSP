require File.expand_path('../test_helper', File.dirname(__FILE__))

class RabbitTestProducer < Rabbit::Producer
end

class RabbitTestWithCallbacksProducer < Rabbit::Producer
  if ActiveSupport::VERSION::MAJOR < 3
    before_publish :test_before_publish_callback
    after_publish :test_after_publish_callback
  else
    set_callback :publish, :before, :test_before_publish_callback
    set_callback :publish, :after, :test_after_publish_callback
  end
end

class Rabbit::ProducerTest < ActiveSupport::TestCase

  def setup
    reload_rabbit_config! # try to clear out anything messed up my mocking the config in other tests
    Rabbit::Helpers.output_commands = false # no need to print out the commands we're running for tests
    Rabbit::Connection.test_mode = false # we want to actually talk to rabbit
  end

  def teardown
    Rabbit::Helpers.output_commands = true
    Rabbit::Connection.test_mode = true
  end

  if Rabbit::Helpers.check_system?
    test 'default exchange name' do
      assert_equal('rabbit_test', RabbitTestProducer.default_exchange_name)
      assert_equal('rabbit_test', RabbitTestProducer.exchange_name)
    end

    test 'overriding exchange name' do
      RabbitTestProducer.set_exchange('overridden')
      assert_equal('overridden', RabbitTestProducer.exchange_name)
      RabbitTestProducer.set_exchange(nil)
      assert_equal('rabbit_test', RabbitTestProducer.exchange_name)
    end

    test 'establish connection' do
      with_test_connection do |new_config|
        assert_equal(new_config.vhost, RabbitTestProducer.connection_config.vhost)
      end
    end

    test 'message compression' do
      RabbitTestProducer.enable_compression = true
      with_test_connection do |config|
        uncompressed_message = 'this will get compressed'
        RabbitTestProducer.publish(uncompressed_message)
        assert compressed_message = RabbitTestProducer.instance.instance_variable_get('@message')
        assert_not_equal(compressed_message, uncompressed_message)
        assert_equal(uncompressed_message, Rabbit::Producer.decompress(compressed_message))
      end
    end

    test 'decompress can handle more or less compressed messages' do
      message = "This really isnt compressed"
      compressed_message = RabbitTestProducer.compress(message)
      assert_equal RabbitTestProducer.decompress(message), RabbitTestProducer.decompress(compressed_message)
    end

    test 'converting message to json' do
      RabbitTestProducer.enable_compression = false
      with_test_connection do |config|
        obj = {'one' => 1}
        RabbitTestProducer.publish(obj)
        assert actual_message = RabbitTestProducer.instance.instance_variable_get('@message')
        assert_equal(obj.to_json, actual_message)
      end
    end

    test 'callbacks on before_publish and after_publish' do
      RabbitTestWithCallbacksProducer.instance.expects(:test_before_publish_callback).once
      RabbitTestWithCallbacksProducer.instance.expects(:test_after_publish_callback).once
      with_test_connection(RabbitTestWithCallbacksProducer) do |config|
        RabbitTestWithCallbacksProducer.publish('hi')
      end
    end

    test 'default publish_retry_count' do
      assert_equal(3, RabbitTestProducer.publish_retry_count)
    end

    test 'publish_retry_count is passed as reconnect_attempts when publishing' do
      begin
        orig_count = RabbitTestProducer.publish_retry_count
        RabbitTestProducer.publish_retry_count = 0
        RabbitTestProducer.any_instance.expects(:with_bunny_connection).with({:reconnect_attempts => 0}).once
        RabbitTestProducer.publish('whatever')
      ensure
        RabbitTestProducer.publish_retry_count = orig_count
      end
    end

  end

private

  def with_test_connection(producer_class = RabbitTestProducer, &block)
    with_test_user do |user, vhost|
      Rabbit::Helpers.set_permissions(user, vhost)
      config = Rabbit::Config.default_configuration
      attrs = config.instance_variable_get('@configuration_attributes')
      attrs['user'], attrs['vhost'], attrs['password'], attrs['logging'] = user, vhost, 'test', false
      producer_class.establish_connection(config)
      yield(config)
    end
  end

end
