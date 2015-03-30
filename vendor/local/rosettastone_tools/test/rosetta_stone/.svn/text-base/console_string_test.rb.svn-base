# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::ConsoleStringTest < Test::Unit::TestCase

  def mock_string
    ::RosettaStone::ConsoleString.new("helloworld")
  end

  def test_functionality
    assert_equal("\e[31mhelloworld\e[0m", mock_string.red)
  end

  def test_colorize_does_not_change_self
    old_id = mock_string.object_id
    new_id = mock_string.colorize('anything').object_id
    assert_not_equal(old_id, new_id)
  end

  def test_colorize_changes_self
    s = mock_string
    old_id = s.object_id
    new_id = s.colorize!('anything').object_id
    assert_equal(old_id, new_id)
  end

end
