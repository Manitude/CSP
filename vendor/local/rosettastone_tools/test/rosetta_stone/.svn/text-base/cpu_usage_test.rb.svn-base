# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::CpuUsageTest < Test::Unit::TestCase

  [:percent, :elapsed_time_since_process_start, :cpu_time_since_process_start, :user_cpu_time_since_process_start, :system_cpu_time_since_process_start].each do |method|
    define_method("test_#{method}") do
      assert value = RosettaStone::CpuUsage.send(method)
      assert_true(value.is_a?(Float), "Expected #{value.inspect} to be a Float")
      assert_true(value >= 0.0)
    end
  end

  def test_time_format_to_seconds
    {
      '34:51.26'    => 2091.26,
      '03:40:36'    => 13236.0,
      '2-06:51:49'  => 197509.0,
      '27-00:42:46' => 2335366.0,
    }.each do |ps_time, seconds|
      assert_equal(seconds, RosettaStone::CpuUsage.send(:time_format_to_seconds, ps_time))
    end
  end
end
