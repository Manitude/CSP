module RosettaStone
  module TimeZoneTestHelper
    class << self
      def database_now
        database_time = ActiveRecord::Base.connection.select_value('select now()') # Mysql2Adapter
        # Time.parse will use ruby's TZ by default, so append UTC to the time string if we think the DB is in UTC:
        database_time = Time.parse(database_time + (database_timezone_offset == 0 ? ' UTC' : '')) if database_time.is_a?(String) # MysqlAdapter
        database_time
      end

      def time_that_active_record_would_apply_to_created_at
        ActiveRecord::Base.default_timezone == :utc ? Time.now.utc : Time.now
      end

      # in minutes
      def active_record_timezone_offset
        time_that_active_record_would_apply_to_created_at.utc_offset
      end

      # in minutes
      def database_timezone_offset
        ActiveRecord::Base.connection.select_value('select time_to_sec(timediff(now(), utc_timestamp()));').to_i
      end

      def ruby_timezone_offset
        Time.now.utc_offset
      end
    end
  end
end
