# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::RosettastoneToolsTest < Test::Unit::TestCase

  def test_time_comparisons_work
    earlier_time = Time.at(1000000000)
    later_time = Time.at(2000000000)
    assert earlier_time.is_before?(later_time)
    assert later_time.is_after?(later_time)
  end

  def test_maximum_time_method_works
    assert_nothing_raised { Time.max }
    assert Time.max.is_after?(Time.now)
  end

  def test_past_time_method_works
    assert 1.second.ago.past?
    assert !1.second.from_now.past?
  end

  def test_future_time_method_works
    assert !1.second.ago.future?
    assert 1.second.from_now.future?
  end

  def test_zero_time_method_works
    assert_nothing_raised { Time.zero }
    assert Time.zero.is_before?(Time.now)
    assert Time.zero.is_before?(Time.max)
  end

  def test_includes_any_method_works
    assert Enumerable.instance_methods.map(&:to_s).include?('includes_any?')
    assert_raises(ArgumentError) { [1,2,3].includes_any?(2) }
    assert [1,2,3].includes_any?([2,4])
    assert [1,2,3].includes_any?([2,3])
    assert ![1,2,3].includes_any?([5,6])
  end

  def test_includes_all_method_works
    assert Enumerable.instance_methods.map(&:to_s).include?('includes_all?')
    assert_raises(ArgumentError) { [1,2,3].includes_any?(2) }
    assert ![1,2,3].includes_all?([2,4])
    assert [1,2,3].includes_all?([2])
    assert ![1,2,3].includes_all?([5,6])
    assert ![1,2,3].includes_all?([2,6])
  end

  def test_zero_pad_works
    assert_equal "09", "9".zero_pad
    assert_equal "00", "0".zero_pad
    assert_equal "23", "23".zero_pad
    assert_equal "023", "23".zero_pad(3)
  end

  def test_zero_pad_works_even_when_numeric_string_is_greater_than_ninety_nine
    assert_equal "100", "100".zero_pad
  end

  def test_indent_works_even_if_indent_is_zero
    three_lines = "Sentences are.\nReading occurs.\nYou love it.\n"
    assert_equal "    Sentences are.\n    Reading occurs.\n    You love it.\n", three_lines.indent(4)
    assert_equal three_lines, three_lines.indent(0)
  end

  def test_indent_works_on_string_without_newlines
    assert_equal "   I am a lonely sentence.", "I am a lonely sentence.".indent(3)
  end

  def test_indent_preserves_newline_on_end_of_one_line_string
    assert_equal "  I am a lonely sentence.\n", "I am a lonely sentence.\n".indent(2)
  end

  def test_indent_raises_on_bad_input
    assert_raises(ArgumentError) { 'Goodness!'.indent(-1) }  unless Rails.version.match(/^3\./)
    assert_raises(ArgumentError) { ''.indent(42) } unless Rails.version.match(/^3\./)
  end

  def test_wrap_with
    assert_equal "(joe)", "joe".wrap_with("()")
    assert_equal "|joe|", "joe".wrap_with("|")
    assert_equal "fjoel", "joe".wrap_with("fool")   # AKA the Spolsky test
  end
end
