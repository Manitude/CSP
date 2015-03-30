# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::StringExtTest < Test::Unit::TestCase

  def test_to_console_string
    assert(''.to_console_string.is_a?(::RosettaStone::ConsoleString))
  end

  def test_left
    assert_equal('', ''.left)
    assert_equal('A', 'A'.left)
    assert_equal('A', 'ABC'.left)
  end

  def test_right
    assert_equal('', ''.right)
    assert_equal('A', 'A'.right)
    assert_equal('C', 'ABC'.right)
  end

  def test_uncapitalize
    assert_equal('updatedAt', 'UpdatedAt'.uncapitalize)
    assert_equal('', ''.uncapitalize)
    assert_equal('x', 'x'.uncapitalize)
    assert_equal('x', 'X'.uncapitalize)
    assert_equal('aAAA', 'AAAA'.uncapitalize)
  end

  def test_uncapitalize_with_utf8_characters
    assert_equal('â', 'Â'.uncapitalize)
    assert_equal('üAAA', 'ÜAAA'.uncapitalize)
  end

  def test_uncapitalize!
    s = 'UpdatedAt'
    s.uncapitalize!
    assert_equal('updatedAt', s)
  end

  def test_lines_without_block
    assert_equal_arrays(["a\n", "b\n"], "a\nb\n".lines.to_a)
  end

  def test_lines_with_block
    count = 0
    "a\nb\n".lines { |line| count += 1 }
    assert_equal(2, count)
  end
end
