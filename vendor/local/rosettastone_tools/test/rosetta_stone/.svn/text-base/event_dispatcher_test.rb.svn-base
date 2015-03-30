# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))
require 'rosetta_stone/event_dispatcher'

class TestEventDispatcher
  include RosettaStone::EventDispatcher
end

class TestEvent
  include RosettaStone::EventDispatcher::Event

  def initialize(type)
    @event_type = type
  end
end

class RosettaStone::EventDispatcherTest < ActiveSupport::TestCase

  def setup
    @dispatcher = TestEventDispatcher.new
  end

  def teardown
    @dispatcher = nil
  end

  test "listeners are added for the correct event" do
    l = lambda{|event| }

    event = TestEvent.new('event')

    @dispatcher.add_event_listener event.event_type, l

    assert_not_nil @dispatcher.listeners
    assert_not_nil @dispatcher.listeners[event.event_type]
    assert_true @dispatcher.listeners[event.event_type].is_a?(Array)
    assert_equal 1, @dispatcher.listeners[event.event_type].size
    assert_true @dispatcher.listeners[event.event_type].include?(l)
  end

  test "listeners are removed for the correct event" do
    l = lambda{|event| }
    event = TestEvent.new 'event'
    event2 = TestEvent.new 'event2'

    @dispatcher.add_event_listener event.event_type, l
    @dispatcher.add_event_listener event2.event_type, l

    assert_not_nil @dispatcher.listeners
    assert_not_nil @dispatcher.listeners[event.event_type]
    assert_true @dispatcher.listeners[event.event_type].is_a?(Array)
    assert_equal 1, @dispatcher.listeners[event.event_type].size
    assert_true @dispatcher.listeners[event.event_type].include?(l)

    assert_not_nil @dispatcher.listeners[event2.event_type]
    assert_true @dispatcher.listeners[event2.event_type].is_a?(Array)
    assert_equal 1, @dispatcher.listeners[event2.event_type].size
    assert_true @dispatcher.listeners[event2.event_type].include?(l)

    @dispatcher.remove_event_listener event.event_type, l

    assert_not_nil @dispatcher.listeners
    assert_not_nil @dispatcher.listeners[event.event_type]
    assert_true @dispatcher.listeners[event.event_type].is_a?(Array)
    assert_equal 0, @dispatcher.listeners[event.event_type].size
    assert_false @dispatcher.listeners[event.event_type].include?(l)

    assert_not_nil @dispatcher.listeners[event2.event_type]
    assert_true @dispatcher.listeners[event2.event_type].is_a?(Array)
    assert_equal 1, @dispatcher.listeners[event2.event_type].size
    assert_true @dispatcher.listeners[event2.event_type].include?(l)
  end

  test "listeners are run for the correct event" do
    l = lambda{|event| }
    event = TestEvent.new 'event'
    @dispatcher.add_event_listener event.event_type, l

    l.expects(:call)

    @dispatcher.fire_event event
  end
end
