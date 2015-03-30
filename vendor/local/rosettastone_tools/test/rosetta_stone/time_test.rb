# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::TimeTest < Test::Unit::TestCase

  def test_datetime_parsing_acts_like_time_parsing
    reference_time = Time.now.to_i
    reference_time.upto(reference_time + 1000) do |seconds_since_epoch|
      date_time_seconds = DateTime.at(seconds_since_epoch).to_i
      assert_equal seconds_since_epoch, date_time_seconds
    end
  end

  def test_to_time_works_on_a_date_time_even_with_home_run_gem
    reference_time = Time.now.to_i
    reference_time.upto(reference_time + 1000) do |seconds_since_epoch|
      time_from_date_time = DateTime.at(seconds_since_epoch).to_time
      # This demonstrates the actual problem, we just worked around it for #to_time only:
      #puts "#{seconds_since_epoch}; #{DateTime.at(seconds_since_epoch).sec}"
      assert_equal seconds_since_epoch, time_from_date_time.to_i
    end
  end

  def test_datetime_parsing_with_very_large_value
    date_time = DateTime.at(3257445103)
    assert_equal 2073, date_time.year
  end

end
