# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))
require 'rosetta_stone/time_with_offset'

if defined?(ActiveSupport::TimeZone) # Rails 2.0 doesn't have this

  class RosettaStone::TimeWithOffsetTest < Test::Unit::TestCase

    def test_offsets_at_year_boundary
      close_to_year_start = RosettaStone::TimeWithOffset.new(Time.parse('2010/01/01 12:00:00 UTC'), -11.hours)
      spans_year_start = RosettaStone::TimeWithOffset.new(Time.parse('2010/01/01 12:00:00 UTC'), -13.hours)
      close_to_year_end = RosettaStone::TimeWithOffset.new(Time.parse('2010/12/31 12:00:00 UTC'), 11.hours)
      spans_year_end = RosettaStone::TimeWithOffset.new(Time.parse('2010/12/31 12:00:00 UTC'), 13.hours)
      assert_offsets(0, 0, 0, close_to_year_start)
      assert_offsets(-1, -1, -1, spans_year_start)
      assert_offsets(0, 0, 0, close_to_year_end)
      assert_offsets(1, 1, 1, spans_year_end)
    end

    def test_offsets_at_month_boundary
      close_to_month_start = RosettaStone::TimeWithOffset.new(Time.parse('2010/02/01 12:00:00 UTC'), -11.hours)
      spans_month_start = RosettaStone::TimeWithOffset.new(Time.parse('2010/02/01 12:00:00 UTC'), -13.hours)
      close_to_month_end = RosettaStone::TimeWithOffset.new(Time.parse('2010/1/31 12:00:00 UTC'), 11.hours)
      spans_month_end = RosettaStone::TimeWithOffset.new(Time.parse('2010/1/31 12:00:00 UTC'), 13.hours)
      assert_offsets(0, 0, 0, close_to_month_start)
      assert_offsets(-1, -1, 0, spans_month_start)
      assert_offsets(0, 0, 0, close_to_month_end)
      assert_offsets(1, 1, 0, spans_month_end)
    end

    def test_offsets_at_day_boundary
      close_to_day_start = RosettaStone::TimeWithOffset.new(Time.parse('2010/02/06 12:00:00 UTC'), -11.hours)
      spans_day_start = RosettaStone::TimeWithOffset.new(Time.parse('2010/02/06 12:00:00 UTC'), -13.hours)
      close_to_day_end = RosettaStone::TimeWithOffset.new(Time.parse('2010/02/06 12:00:00 UTC'), 11.hours)
      spans_day_end = RosettaStone::TimeWithOffset.new(Time.parse('2010/02/06 12:00:00 UTC'), 13.hours)
      assert_offsets(0, 0, 0, close_to_day_start)
      assert_offsets(-1, 0, 0, spans_day_start)
      assert_offsets(0, 0, 0, close_to_day_end)
      assert_offsets(1, 0, 0, spans_day_end)
    end

    def test_midnight_when_day_offset_is_0
      time_zone = 'Europe/Berlin'
      offset = 1.hours
      utc_time = Time.parse('2010/02/06 12:00:00 UTC')
      offset_time = utc_time.in_time_zone(time_zone)
      assert_equal(offset, offset_time.utc_offset) #sanity check
      assert_equal(0, RosettaStone::TimeWithOffset.new(utc_time, offset).day_offset)
      assert_equal(offset_time.midnight, RosettaStone::TimeWithOffset.new(utc_time, offset).midnight.utc)
      assert_equal(offset_time.midnight, RosettaStone::TimeWithOffset.new(utc_time, offset).start_of_day.utc) #alias
      assert_equal(offset_time.midnight, RosettaStone::TimeWithOffset.new(utc_time, offset).beginning_of_day.utc) #alias
    end

    def test_midnight_when_day_offset_is_1
      time_zone = 'Asia/Seoul'
      offset = 9.hours
      utc_time = Time.parse('2010/02/06 18:00:00 UTC')
      offset_time = utc_time.in_time_zone(time_zone)
      assert_equal(offset, offset_time.utc_offset) #sanity check
      assert_equal(1, RosettaStone::TimeWithOffset.new(utc_time, offset).day_offset)
      assert_equal(offset_time.midnight.utc, RosettaStone::TimeWithOffset.new(utc_time, offset).midnight.utc)
    end

    def test_midnight_when_day_offset_is_negative_1
      time_zone = 'America/New_York'
      offset = -5.hours
      utc_time = Time.parse('2010/02/06 2:00:00 UTC')
      offset_time = utc_time.in_time_zone(time_zone)
      assert_equal(offset, offset_time.utc_offset) #sanity check
      assert_equal(-1, RosettaStone::TimeWithOffset.new(utc_time, offset).day_offset)
      assert_equal(offset_time.midnight.utc, RosettaStone::TimeWithOffset.new(utc_time, offset).midnight.utc)
    end

    def test_hour_when_day_offset_is_0
      time_zone = 'Europe/Berlin'
      offset = 1.hours
      utc_time = Time.parse('2010/02/06 12:00:00 UTC')
      offset_time = utc_time.in_time_zone(time_zone)
      assert_equal(offset, offset_time.utc_offset) #sanity check
      assert_equal(0, RosettaStone::TimeWithOffset.new(utc_time, offset).day_offset)
      assert_equal(offset_time.hour, RosettaStone::TimeWithOffset.new(utc_time, offset).hour)
    end

    def test_hour_when_day_offset_is_1
      time_zone = 'Asia/Seoul'
      offset = 9.hours
      utc_time = Time.parse('2010/02/06 18:00:00 UTC')
      offset_time = utc_time.in_time_zone(time_zone)
      assert_equal(offset, offset_time.utc_offset) #sanity check
      assert_equal(1, RosettaStone::TimeWithOffset.new(utc_time, offset).day_offset)
      assert_equal(offset_time.hour, RosettaStone::TimeWithOffset.new(utc_time, offset).hour)
    end

    def test_hour_when_day_offset_is_negative_1
      time_zone = 'America/New_York'
      offset = -5.hours
      utc_time = Time.parse('2010/02/06 2:00:00 UTC')
      offset_time = utc_time.in_time_zone(time_zone)
      assert_equal(offset, offset_time.utc_offset) #sanity check
      assert_equal(-1, RosettaStone::TimeWithOffset.new(utc_time, offset).day_offset)
      assert_equal(offset_time.hour, RosettaStone::TimeWithOffset.new(utc_time, offset).hour)
    end

    def test_minus
      time_1 = Time.parse('2011/01/01 12:00:00 UTC')
      time_2 = time_1 - 123
      time_with_offset_1 = RosettaStone::TimeWithOffset.new(time_1, 273)
      time_with_offset_2 = time_with_offset_1 - 123
      assert_equal time_2, time_with_offset_2.utc_time
    end

    def test_minus_with_a_time
      time_1 = Time.parse('2011/01/01 12:00:00 UTC')
      time_2 = Time.parse('2011/01/01 13:00:00 UTC')
      assert_equal 1.hour, RosettaStone::TimeWithOffset.new(time_2, 273) - RosettaStone::TimeWithOffset.new(time_1, 12)
      assert_equal -1.hour, RosettaStone::TimeWithOffset.new(time_1, 273) - RosettaStone::TimeWithOffset.new(time_2, 12)
    end

    def test_plus
      time_1 = Time.parse('2011/01/01 12:00:00 UTC')
      time_2 = time_1 + 321
      time_with_offset_1 = RosettaStone::TimeWithOffset.new(time_1, 273)
      time_with_offset_2 = time_with_offset_1 + 321
      assert_equal time_2, time_with_offset_2.utc_time
    end

    def test_wday_in_the_middle_of_the_week
      time_zone = 'Asia/Seoul'
      offset = 9.hours
      utc_time = Time.parse('2012/01/27 18:00:00 UTC') # Friday
      offset_time = utc_time.in_time_zone(time_zone)
      assert_equal(offset, offset_time.utc_offset) #sanity check
      assert_equal(5, utc_time.wday) #sanity_check
      assert_equal(6, RosettaStone::TimeWithOffset.new(utc_time, offset).wday) # it's already tomorrow in Korea
    end

    def test_wday_on_saturday
      time_zone = 'Asia/Seoul'
      offset = 9.hours
      utc_time = Time.parse('2012/01/28 18:00:00 UTC') # Saturday
      offset_time = utc_time.in_time_zone(time_zone)
      assert_equal(offset, offset_time.utc_offset) #sanity check
      assert_equal(6, utc_time.wday) #sanity_check
      assert_equal(0, RosettaStone::TimeWithOffset.new(utc_time, offset).wday) # it's already tomorrow in Korea
    end

    def test_wday_on_sunday
      time_zone = 'America/New_York'
      offset = -5.hours
      utc_time = Time.parse('2012/01/29 2:00:00 UTC') # Sunday
      offset_time = utc_time.in_time_zone(time_zone)
      assert_equal(offset, offset_time.utc_offset) #sanity check
      assert_equal(0, utc_time.wday) #sanity_check
      assert_equal(6, RosettaStone::TimeWithOffset.new(utc_time, offset).wday) # it's already tomorrow in Korea
    end

    def test_end_of_day
      time_zone = 'Asia/Seoul'
      offset = 9.hours
      utc_time = Time.parse('2012/01/27 18:00:00 UTC') # 3 AM in Korea
      expected_time = Time.parse('2012/01/28 14:59:59 UTC') # end of day in korea
      offset_time = utc_time.in_time_zone(time_zone)
      assert_equal(offset, offset_time.utc_offset) #sanity check
      assert_equal(expected_time, RosettaStone::TimeWithOffset.new(utc_time, offset).end_of_day.utc)
    end

    def test_comparisons
      time = Time.now

      assert RosettaStone::TimeWithOffset.new(time, 1000*rand) == RosettaStone::TimeWithOffset.new(time, 1000*rand)
      assert RosettaStone::TimeWithOffset.new(time, 1000*rand) < RosettaStone::TimeWithOffset.new(time + 1.minute, 1000*rand)
      assert RosettaStone::TimeWithOffset.new(time, 1000*rand) > RosettaStone::TimeWithOffset.new(time - 1.minute, 1000*rand)
    end

  private

    def assert_offsets(day_offset, month_offset, year_offset, time)
      assert_equal(year_offset, time.year_offset, "Unexpected year offset" )
      assert_equal(month_offset, time.month_offset, "Unexpected month offset" )
      assert_equal(day_offset, time.day_offset, "Unexpected day offset" )
    end

  end
end
