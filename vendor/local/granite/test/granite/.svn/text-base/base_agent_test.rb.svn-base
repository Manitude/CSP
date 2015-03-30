# -*- coding: utf-8 -*-
# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

require File.expand_path('../test_helper', File.dirname(__FILE__))

class TestBaseAgent < Granite::BaseAgent
  def process(header, message)
    @call_count ||= 0
    @call_count += 1
  end
end

class TestBaseAgentWithEverythingOverridden < Granite::BaseAgent

  self.connection = 'super_cool_connection'

  def overridden_process_method(header, message)
    @overridden_call_count ||= 0
    @overridden_call_count += 1
  end

private
  def exchange_names
    'overridden_exchange_names'
  end

  def process_method
    :overridden_process_method
  end

  def message_parsers
    {'overridden_exchange_names' => 'overridden_message_parser'}
  end
end

class TestBaseAgentWithExchangeTypeSpecified < Granite::BaseAgent
  exchange_type :direct

  def process(header, message)
  end
end

class TestBaseAgentWithDecoratorAndInstanceMethod < Granite::BaseAgent
  exchange_names 'from_decorator'

  def process(header, message)
  end

private
  def exchange_names
    'from_method'
  end
end

class TestBaseAgentWithExchangeNamesAsSplattedArgs < Granite::BaseAgent
  exchange_names 'arg1', 'arg2'

  def process(header, message)
  end
end

class TestBaseAgentWithExchangeNamesAsArray < Granite::BaseAgent
  exchange_names ['arg1', 'arg2']

  def process(header, message)
  end
end

class TestBaseAgentWithBindingsSpecified < Granite::BaseAgent
  routing_keys '#.hey.#', '#.ho.#'

  def process(header, message)
  end
end

class TestBaseAgentWithOneRoutingWordSpecified < Granite::BaseAgent
  routing_word 'cow'

  def process(header, message)
  end
end

class TestBaseAgentWithRoutingWordsSpecified < Granite::BaseAgent
  routing_words 'a', 'cow'

  def process(header, message)
  end
end

class TestBaseAgentWithRoutingWordAndRoutingKeySpecified < Granite::BaseAgent
  routing_word 'cow'
  routing_key '#.moo.#'

  def process(header, message)
  end
end

# doc:overriding_things_in_a_granite_agent
class TestBaseAgentWithDecoratorStyleOverrides < Granite::BaseAgent
  exchange_name 'awesome_exchange'
  exchange_type :direct
  routing_key '#.sweetkeyword.#'
  process_method :better_process

  def better_process(header, message)
  end
end
# !doc:overriding_things_in_a_granite_agent

class Granite::BaseAgentTest < ActiveSupport::TestCase

  def setup
    @agent = TestBaseAgent.new
  end

  test 'instance variables on classes do not leak into other classes' do
    TestBaseAgentWithExchangeTypeSpecified.new
    assert_equal :direct, TestBaseAgentWithExchangeTypeSpecified.exchange_type
    assert_equal ['#.hey.#', '#.ho.#'], TestBaseAgentWithBindingsSpecified.routing_keys
    assert_equal ['#.hey.#', '#.ho.#'], TestBaseAgentWithBindingsSpecified.routing_keys
    TestBaseAgent.new
    assert_not_equal :direct, TestBaseAgent.exchange_type
    assert_not_equal :direct, Granite::BaseAgent.exchange_type
    assert_nil TestBaseAgent.routing_keys
  end

  test 'exchange type when not set' do
    TestBaseAgent.any_instance.expects(:agentize).with do |args|
      args[:type].nil?
    end
    TestBaseAgent.new
  end

  test 'exchange type can be set' do
    TestBaseAgentWithExchangeTypeSpecified.any_instance.expects(:agentize).with do |args|
      args[:type] == :direct
    end
    TestBaseAgentWithExchangeTypeSpecified.new
  end

  test 'bindings can be set' do
    TestBaseAgentWithBindingsSpecified.any_instance.expects(:agentize).with do |args|
      args[:bindings].first[:key] == '#.hey.#'
      args[:bindings].last[:key] == '#.ho.#'
    end
    TestBaseAgentWithBindingsSpecified.new
  end

  test 'bindings can be set by specifying one routing word' do
    TestBaseAgentWithOneRoutingWordSpecified.any_instance.expects(:agentize).with do |args|
      args[:bindings].size == 1 && args[:bindings].first[:key] == '#.cow.#'
    end
    TestBaseAgentWithOneRoutingWordSpecified.new
  end

  test 'bindings can be set by specifying routing words' do
    TestBaseAgentWithRoutingWordsSpecified.any_instance.expects(:agentize).with do |args|
      args[:bindings].first[:key] == '#.a.#'
      args[:bindings].last[:key] == '#.cow.#'
    end
    TestBaseAgentWithRoutingWordsSpecified.new
  end

  test 'bindings can be set by specifying routing keys and routing words i guess' do
    TestBaseAgentWithRoutingWordAndRoutingKeySpecified.any_instance.expects(:agentize).with do |args|
      args[:bindings].first[:key] == '#.cow.#'
      args[:bindings].last[:key] == '#.moo.#'
    end
    TestBaseAgentWithRoutingWordAndRoutingKeySpecified.new
  end

  test 'base agent sets appropriate exchange_names by default' do
    assert_equal('test_base', @agent.send(:exchange_names))
    assert_true(@agent.actors.any?)
    @agent.actors.each do |actor|
      assert_equal(['test_base'], actor.exchange_names)
    end
  end

  test 'base agent sets process_method to process by default' do
    assert_equal(:process, @agent.send(:process_method))
    assert_true(@agent.actors.any?)
    @agent.actors.each do |actor|
      actor.handler.call({},{})
    end
    assert_equal(@agent.actors.size, @agent.instance_variable_get('@call_count'))
  end

  test 'overridden values' do
    assert agent = TestBaseAgentWithEverythingOverridden.new
    assert actor = agent.actors.first
    assert_equal(['overridden_exchange_names'], actor.exchange_names)
    actor.handler.call({},{})
    assert_equal(1, agent.instance_variable_get('@overridden_call_count'))
    assert_equal({'overridden_exchange_names' => 'overridden_message_parser'}, actor.message_parsers)
  end

  test 'overriden values using decorators' do
    TestBaseAgentWithDecoratorStyleOverrides.any_instance.expects(:agentize).with do |args|
      args[:method] == :better_process &&
      args[:exchanges] == 'awesome_exchange' &&
      args[:type] == :direct &&
      args[:bindings].first[:key] == '#.sweetkeyword.#'
    end
    TestBaseAgentWithDecoratorStyleOverrides.new
  end

  test 'exchange_names can be set using array, which is deprecated, or splatted args' do
    assert agent = TestBaseAgentWithExchangeNamesAsArray.new
    assert actor = agent.actors.first
    assert_equal(['arg1', 'arg2'], actor.exchange_names)

    assert agent = TestBaseAgentWithExchangeNamesAsSplattedArgs.new
    assert actor = agent.actors.first
    assert_equal(['arg1', 'arg2'], actor.exchange_names)
  end

  test 'methods override decorators' do
    assert agent = TestBaseAgentWithDecoratorAndInstanceMethod.new
    assert actor = agent.actors.first
    assert_equal(['from_method'], actor.exchange_names)
  end

  test 'connections are class specific' do
    assert_nil(TestBaseAgent.connection) # uses default connection
    assert_equal('super_cool_connection', TestBaseAgentWithEverythingOverridden.connection)
    assert_nil(Granite::BaseAgent.connection)
  end
end
