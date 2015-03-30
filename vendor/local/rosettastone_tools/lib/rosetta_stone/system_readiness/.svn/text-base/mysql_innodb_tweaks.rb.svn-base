# -*- encoding : utf-8 -*-
#
class SystemReadiness::MysqlInnodbTweaks < SystemReadiness::Base

  if defined?(ActiveRecord::Base)
    class MysqlInnodbTweaksChecker < ActiveRecord::Base; end
  end

  class << self
    def verify
      if defined?(DISABLE_MYSQL_INNODB_TWEAKS_SYSTEM_READINESS_CHECK) || !defined?(ActiveRecord::Base)
        return true, 'skipped; ActiveRecord is not loaded (or this check was explicitly disabled)'
      end

      size = max_allowed_packet_size

      if size > 16_000_000
        return true, nil
      else
        return false, "max_allowed_packet was too small (#{size}). check your innodbtweaks (https://opx.lan.flt/wiki/InnodbTweaksForMysql)"
      end
    rescue Exception => exception
      return false, "got exception: #{exception}"
    end # def verify

  private
    def max_allowed_packet_size
      MysqlInnodbTweaksChecker.connection.select_all("show global variables like '%max_allowed_packet%';").first['Value'].to_i
    end

  end
end
