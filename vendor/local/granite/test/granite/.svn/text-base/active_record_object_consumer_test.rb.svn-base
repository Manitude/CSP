require File.expand_path('../test_helper', File.dirname(__FILE__))

class TestActiveRecordObjectConsumer
  include Granite::ActiveRecordObjectConsumer
end

class ActiveRecordObjectConsumerTest < ActiveSupport::TestCase

  if defined?(ActiveRecord)
    test 'delay_if_appropriate does not wait when the updated_at has already passed' do
      TestActiveRecordObjectConsumer.seconds_to_delay_past_updated_at = 1
      consumer = TestActiveRecordObjectConsumer.new
      consumer.expects(:sleep).never
      consumer.delay_if_appropriate(2.seconds.ago.to_i)
    end

    test 'delay_if_appropriate waits when updated_at is now' do
      time = Time.now
      Time.stubs(:now).returns(time)
      TestActiveRecordObjectConsumer.seconds_to_delay_past_updated_at = 2
      consumer = TestActiveRecordObjectConsumer.new
      consumer.expects(:sleep).once.with(2)
      consumer.delay_if_appropriate(time.to_i)
    end

    test 'delay_if_appropriate does not wait when seconds_to_delay_past_updated_at is nil' do
      time = Time.now
      Time.stubs(:now).returns(time)
      TestActiveRecordObjectConsumer.seconds_to_delay_past_updated_at = nil
      consumer = TestActiveRecordObjectConsumer.new
      consumer.expects(:sleep).never
      consumer.delay_if_appropriate(time.to_i)
    end

    test 'delay_if_appropriate does not wait when seconds_to_delay_past_updated_at is 0' do
      time = Time.now
      Time.stubs(:now).returns(time)
      TestActiveRecordObjectConsumer.seconds_to_delay_past_updated_at = 0
      consumer = TestActiveRecordObjectConsumer.new
      consumer.expects(:sleep).never
      consumer.delay_if_appropriate(time.to_i)
    end

    test 'delay_if_appropriate waits when seconds_to_delay_past_updated_at crosses now' do
      time = Time.now
      Time.stubs(:now).returns(time)
      TestActiveRecordObjectConsumer.seconds_to_delay_past_updated_at = 4
      consumer = TestActiveRecordObjectConsumer.new
      consumer.expects(:sleep).once.with(2)
      consumer.delay_if_appropriate((time - 2.seconds).to_i)
    end

    test 'find_updated_active_record_object rejects payloads without all expected keys' do
      consumer = TestActiveRecordObjectConsumer.new
      payload = {'class' => "BogusClassName", 'id' => 123}
      assert_raise(ArgumentError){
        consumer.find_updated_active_record_object(payload)
      }
    end

    test 'find_updated_active_record_object tries max times then raises' do
      consumer = TestActiveRecordObjectConsumer.new
      now = Time.now.to_i
      className = "TestARClass"
      object = stub(className) {
        stubs(:updated_at).returns(now)
        expects(:find).times(3).returns(nil)
      }

      className.stubs(:constantize).returns(object)
      payload = {'class' => className, 'id' => 0, 'updated_at' => now}
      consumer.stubs(:delay_if_appropriate)
      consumer.expects(:sleep).times(2)

      assert_raise(Granite::ActiveRecordObjectConsumer::RecordNotUpdated) do
        consumer.find_updated_active_record_object(payload)
      end
    end

    test 'find_updated_active_record_object updates record if all things are good' do
      consumer = TestActiveRecordObjectConsumer.new
      now = Time.now.to_i
      className = "TestARClass"
      object = stub(className) {
        stubs(:updated_at).returns(now)
        expects(:find).returns(self)
      }

      payload = {'class' => className, 'id' => 0, 'updated_at' => now - 2}
      className.stubs(:constantize).returns(object)
      consumer.stubs(:delay_if_appropriate)
      consumer.find_updated_active_record_object(payload)
    end

    test 'find_updated_active_record_object raises if updated_at in record is greater' do
      consumer = TestActiveRecordObjectConsumer.new
      now = Time.now.to_i
      className = "TestARClass"
      object = stub(className) {
        stubs(:updated_at).returns(now)
        expects(:find).returns(self).times(3)
      }

      payload = {'class' => className, 'id' => 0, 'updated_at' => now + 2}
      className.stubs(:constantize).returns(object)
      consumer.stubs(:delay_if_appropriate)
      consumer.expects(:sleep).times(2)
      assert_raise(Granite::ActiveRecordObjectConsumer::RecordNotUpdated) do
        consumer.find_updated_active_record_object(payload)
      end
    end

    test 'find_updated_active_record_object raises if record is not found' do
      consumer = TestActiveRecordObjectConsumer.new
      now = Time.now.to_i
      className = "TestARClass"
      object = stub(className) {
        stubs(:updated_at).returns(now)
        expects(:find).raises(ActiveRecord::RecordNotFound).times(3)
      }

      payload = {'class' => className, 'id' => 0, 'updated_at' => now}
      className.stubs(:constantize).returns(object)
      consumer.stubs(:delay_if_appropriate)
      consumer.stubs(:sleep)
      assert_raise(ActiveRecord::RecordNotFound) do
        consumer.find_updated_active_record_object(payload)
      end
    end
  end
end
