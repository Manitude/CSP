# -*- encoding : utf-8 -*-

class SystemReadiness::MysqlConnectivity < SystemReadiness::Base
  if defined?(ActiveRecord::Base)
    class MysqlConnectivityChecker < ActiveRecord::Base; end
  end

  class << self
    def verify
      if defined?(DISABLE_MYSQL_CONNECTIVITY_SYSTEM_READINESS_CHECK) || !defined?(ActiveRecord::Base)
        return true, 'skipped; ActiveRecord is not loaded (or this check was explicitly disabled)'
      end

      stanza = nil
      stanzas_to_verify = (defined?(MYSQL_CONNECTIONS_TO_VERIFY_FOR_SYSTEM_READINESS) && MYSQL_CONNECTIONS_TO_VERIFY_FOR_SYSTEM_READINESS) || [nil]
      stanzas_to_verify.each do |stanza|
        logger.info("Verifying MySQL connectivity for #{stanza || 'default connection'}")
        MysqlConnectivityChecker.establish_connection(stanza)
        MysqlConnectivityChecker.connection.tables
        database = MysqlConnectivityChecker.connection.current_database
        create_statement = create_database_statement(database)
        unless create_statement.include?('DEFAULT CHARACTER SET utf8')
          return false, "it appears that the database's default character set is not UTF8 for database #{database}: #{create_statement}.  You probably want to change the server default and recreate the database."
        end
        MysqlConnectivityChecker.connection.disconnect!
      end
      return true, nil
    rescue Exception => exception
      return false, "failed to establish MySQL connection for #{stanza || 'default connection'}: #{exception}"
    end

    def create_database_statement(database)
      if defined?(Mysql2)
        MysqlConnectivityChecker.connection.execute("show create database `#{database}`;").to_a.first.to_s
      else
        MysqlConnectivityChecker.connection.select_value("show create database `#{database}`;")
      end
    end

  end
end
