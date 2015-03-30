# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))
require 'rosetta_stone/system_call_helpers'

class RosettaStone::SystemCallHelpersTest < Test::Unit::TestCase
  def test_with_empty_rubyopt_unsets_environment_variable
    RosettaStone::SystemCallHelpers.with_empty_rubyopt do
      assert_equal '', `echo $RUBYOPT`.strip
    end
  end

  def test_with_empty_rubyopt_returns_the_block_result
    result = RosettaStone::SystemCallHelpers.with_empty_rubyopt do
      `echo "the result"`
    end
    assert_equal "the result", result.strip
  end
end
