# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::ObjectExtTest < Test::Unit::TestCase

  def test_to_embedded_json_should_work
    json = {'foo' => 'bar'}.to_embedded_json
    assert_true json.is_a?(String)
    assert_true json.present?
    if ''.respond_to?(:html_safe)
      assert_true json.html_safe?
    end
  end

  def test_to_embedded_json_should_json_escape
    assert_equal '"\""', '"'.to_embedded_json
  end

  def test_me_should_return_self_if_no_block_given
    assert_equal "self", "self".me
  end

  def test_me_should_return_block_evaluation_if_block_given
    assert_equal "evaluation", "self".me { "evaluation" }
  end

  def test_only_if_should_return_self_if_no_block_given
    assert_equal "awesome", "awesome".only_if
  end

  def test_only_if_should_return_self_if_true_block_given
    assert_equal "awesome", "awesome".only_if { true }
    assert_equal "awesome", "awesome".only_if {|caller| caller.is_a?(String) }
    assert_equal 3, 3.only_if(&:odd?)
  end

  def test_only_if_should_return_nil_if_false_block_given
    assert_nil "awesome".only_if { false }
    assert_nil "awesome".only_if { nil }
    assert_nil "awesome".only_if {|caller| caller.respond_to?(:keys) }
    assert_nil 3.only_if(&:even?)
  end

  def test_try_to
    assert_equal(nil, nil.try_to(:method_does_not_exit))
    assert_equal('hi', 'hi'.try_to(:method_does_not_exit))
    assert_equal('HI', 'hi'.try_to(:upcase))
  end

  def test_try_to_with_arguments
    assert_equal(2, 1.try_to(:*, 2))
    assert_equal('hi, there', %w(hi there).try_to(:join, ', '))
    assert_equal('nope', 'nope'.try_to(:this_is_not_a_method, '23', 24))
  end

  def test_retry_on_exception_will_retry_on_all_exceptions_by_default
    RosettaStone::GenericExceptionNotifier.expects(:deliver_exception_notification).never
    execution_count = 0
    assert_raise RuntimeError do
      retry_on_exception do
        execution_count += 1
        raise "My Exception"
      end
    end
    assert_equal 2, execution_count
  end

  def test_retry_on_exception_will_retry_only_for_specified_exceptions
    RosettaStone::GenericExceptionNotifier.expects(:deliver_exception_notification).never
    execution_count = 0
    assert_raise RuntimeError do
      retry_on_exception([ArgumentError]) do
        execution_count += 1
        raise "Not an ArgumentError"
      end
    end
    assert_equal 1, execution_count

    execution_count = 0
    assert_raise ArgumentError do
      retry_on_exception([ArgumentError]) do
        execution_count += 1
        raise ArgumentError.new
      end
    end
    assert_equal 2, execution_count
  end

  def test_retry_on_exception_will_retry_the_specified_number_of_times
    RosettaStone::GenericExceptionNotifier.expects(:deliver_exception_notification).never
    execution_count = 0
    expected_number_of_executions = 4
    assert_raise RuntimeError do
      retry_on_exception([Exception], expected_number_of_executions) do
        execution_count += 1
        raise "Normal Exception"
      end
    end
    assert_equal expected_number_of_executions, execution_count
  end

  def test_retry_on_exception_will_throw_exception_to_exception_notifier_if_desired
    RosettaStone::GenericExceptionNotifier.expects(:deliver_exception_notification).twice
    assert_raise RuntimeError do
      retry_on_exception([Exception], 2, true) do
        raise "Normal Exception"
      end
    end
  end

  def test_retry_on_exception_will_suppress_exception_notification
    RosettaStone::GenericExceptionNotifier.expects(:deliver_exception_notification).never
    assert_raise RuntimeError do
      retry_on_exception([Exception], 2, false) do
        raise "Normal Exception"
      end
    end
  end

  def test_retry_on_exception_will_execute_reset_procedure_if_included
    expected_number_of_executions = 4
    RosettaStone::GenericExceptionNotifier.expects(:deliver_exception_notification).times(expected_number_of_executions)
    num_resets = 0
    reset_proc = Proc.new{num_resets += 1}
    assert_raise RuntimeError do
      retry_on_exception([Exception], expected_number_of_executions, true, reset_proc) do
        raise "Normal Exception"
      end
    end
    assert_equal expected_number_of_executions - 1, num_resets
  end

  def test_retry_on_exception_will_return_desired_result
    expected_result = "This is what I want!"
    result = retry_on_exception do
      expected_result
    end
    assert_equal expected_result, result
  end
end
