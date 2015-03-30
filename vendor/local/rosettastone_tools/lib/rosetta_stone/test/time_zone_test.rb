# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

# These tests are intended to provide an early warning that your app & db are not appropriately configured with respect to time zones.
if defined?(ActiveRecord::Base)
  require 'rosetta_stone/time_zone_test_helper'

  module RosettaStone
    module TimeZoneTest
      def test_that_the_database_time_is_within_90_seconds_of_ruby_time
        now, database_now = TimeZoneTestHelper.time_that_active_record_would_apply_to_created_at, TimeZoneTestHelper.database_now
        assert_true(
          (now - database_now).abs < 90,
          %Q[Your database time is not the same as your app time; verify that your time zones are configured properly:
             database time: #{database_now}
             rails time: #{now}]
        )
      end

      def test_that_the_timezone_offset_in_the_database_connection_matches_the_timezone_offset_of_active_record
        ar, database = TimeZoneTestHelper.active_record_timezone_offset, TimeZoneTestHelper.database_timezone_offset
        assert_equal(ar, database, "Timezone offset in ActiveRecord (#{ar} minutes) not the same as the DB (#{database} minutes)")
      end

      def test_that_timezone_offset_of_ruby_matches_the_timezone_offset_of_active_record
        return if defined?(I_KNOW_THAT_THE_TIMEZONE_OFFSET_OF_RUBY_DOES_NOT_MATCH_ACTIVE_RECORD)
        ar, ruby = TimeZoneTestHelper.active_record_timezone_offset, TimeZoneTestHelper.ruby_timezone_offset
        assert_equal(ruby, ar, "Timezone offset in ActiveRecord (#{ar} minutes) not the same as ruby (#{ruby} minutes)")
      end
    end
  end
end
