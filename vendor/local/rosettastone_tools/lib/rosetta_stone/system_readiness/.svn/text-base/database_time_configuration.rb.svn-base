require 'rosetta_stone/time_zone_test_helper'

class SystemReadiness::DatabaseTimeConfiguration < SystemReadiness::Base
  class << self
    def verify
      unless defined?(ActiveRecord::Base)
        return true, 'skipped; ActiveRecord is not loaded'
      end
      now = RosettaStone::TimeZoneTestHelper.time_that_active_record_would_apply_to_created_at
      db_now = RosettaStone::TimeZoneTestHelper.database_now
      if (now - db_now).abs > 5.seconds
        return false, "ActiveRecord time and database time out of sync. This may be due to a time sync issue or due to the database being misconfigured. AR time: #{now}. DB time: #{db_now}."
      end

      ar_tz = RosettaStone::TimeZoneTestHelper.active_record_timezone_offset
      db_tz = RosettaStone::TimeZoneTestHelper.database_timezone_offset
      rb_tz = RosettaStone::TimeZoneTestHelper.ruby_timezone_offset

      tz_offset_string = "ActiveRecord: #{ar_tz}. Database: #{db_tz}. Ruby: #{rb_tz}."
      if ar_tz != db_tz 
        return false, "Time zone offset mismatch: #{tz_offset_string}"
      elsif ar_tz != rb_tz
        puts "warning\t\tRuby time zone is different from ActiveRecord and the database: #{tz_offset_string}"
      end
      return true, nil
    end
  end
end
