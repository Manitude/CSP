require File.expand_path('../test_helper', File.dirname(__FILE__))

class TestActiveRecordObjectProducer < Granite::Producer
  include Granite::ActiveRecordObjectPublisher
end

class ActiveRecordObjectPublisherTest < ActiveSupport::TestCase

  if defined?(ActiveRecord)
    test 'before_publish gets set up properly' do
      if ActiveSupport::VERSION::MAJOR < 3
        assert_true(TestActiveRecordObjectProducer.before_publish_callback_chain.map(&:method).map(&:to_sym).include?(:serialize_active_record_objects))
      else
        assert_true(TestActiveRecordObjectProducer._publish_callbacks.map(&:filter).include?(:serialize_active_record_objects))
      end
    end

    test 'serialization' do
      time = Time.now.to_i
      payload = payload_after_serialization(:object => mock_ar_object(:updated_at => time))
      assert_equal({'class' => 'ProductRight', 'id' => 1, 'updated_at' => time.to_i}, payload)
    end

    test 'serialization retains extra attributes' do
      time = Time.now.to_i
      extra_payload_attributes = {:extra_1 => 1, :extra_2 => 2}
      payload = payload_after_serialization({:object => mock_ar_object(:updated_at => time)}.merge(extra_payload_attributes))
      assert_equal({'class' => 'ProductRight', 'id' => 1, 'updated_at' => time.to_i, 'extra_1' => 1, 'extra_2' => 2}, payload)
    end

    test 'serialization with object and class_prefix' do
      time = Time.now.to_i
      payload = payload_after_serialization({:object => mock_ar_object(:updated_at => time), :object_class_prefix => 'ReadOnly::'})
      assert_equal({'class' => 'ReadOnly::ProductRight', 'id' => 1, 'updated_at' => time.to_i}, payload)
    end

    test 'serialization with another AR object and class_prefix' do
      time = Time.now.to_i
      payload = payload_after_serialization({:product_right => mock_ar_object(:updated_at => time), :product_right_class_prefix => 'ReadOnly::'})
      assert_equal({'product_right_class' => 'ReadOnly::ProductRight', 'product_right_id' => 1, 'product_right_updated_at' => time.to_i}, payload)
    end

    test 'serialization with other ar objects' do
      time = Time.now.to_i
      payload_attributes = {
        :object => mock_ar_object(:updated_at => time),
        :extra_1 => 1,
        :extra_2 => 2,
        :another_ar_object => mock_ar_object(:updated_at => time, :class => 'License', :id => 12),
        :yet_another_ar_object => mock_ar_object(:updated_at => time, :class => 'Extension', :id => 123),
      }
      payload = payload_after_serialization(payload_attributes)
      assert_equal({
        'class' => 'ProductRight',
        'id' => 1,
        'updated_at' => time.to_i,
        'extra_1' => 1,
        'extra_2' => 2,
        'another_ar_object_class' => 'License',
        'another_ar_object_id' => 12,
        'another_ar_object_updated_at' => time.to_i,
        'yet_another_ar_object_class' => 'Extension',
        'yet_another_ar_object_id' => 123,
        'yet_another_ar_object_updated_at' => time.to_i,
      }, payload)
    end

    test 'serialization does nothing if not a hash' do
      payload = payload_after_serialization(1)
      assert_equal(1, payload)
    end

    test 'serialization does nothing if no object' do
      payload = payload_after_serialization({:one => true})
      assert_equal({:one => true}.with_indifferent_access, payload)
    end
  end

private

  def payload_after_serialization(message)
    message = Granite::Job.create(message)
    TestActiveRecordObjectProducer.instance.instance_variable_set('@message', message)
    TestActiveRecordObjectProducer.instance.serialize_active_record_objects
    assert payload = TestActiveRecordObjectProducer.instance.instance_variable_get('@message').payload
    payload
  end

  def mock_ar_object(options = {})
    mock_object = mock do
      expects(:class).at_least_once.returns(options[:class] || 'ProductRight')
      expects(:id).returns(options[:id] || 1)
      expects(:updated_at).returns(options[:updated_at] || Time.now.to_i)
    end
    mock_object.instance_eval do
      def is_a?(other_class)
        other_class == ActiveRecord::Base
      end
    end
    mock_object
  end
end
