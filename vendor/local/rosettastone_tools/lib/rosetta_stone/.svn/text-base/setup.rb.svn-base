# -*- encoding : utf-8 -*-
module RosettaStone
  module Setup
    class << self

      def explode_db(db, real_connection = nil)
        real_connection ||= db
        db_config = ActiveRecord::Base.configurations
        raise Exception.new('you need to setup your dblogin.yml') if db_config[real_connection].nil?
        connection_to_use = db_config[real_connection].dup
        connection_to_use['database'] = 'mysql'
        ActiveRecord::Base.establish_connection(connection_to_use)
        if !db_config.has_key?(db)
          puts "---\nSkipping #{db}: no configuration in database.yml/dblogin.yml\n"
        elsif db_config[db]['adapter'].to_s !~ /mysql/ # 'mysql' or 'mysql2'
          puts "---\nSkipping #{db}: only MySQL connections are supported (adapter was #{db_config[db]['adapter']})\n"
        else
          puts "---\nSetup for #{db}...\n"

          db_name = db_config[db]['database']
          username = db_config[db]['username']
          password = db_config[db]['password']
          host = db_config[db]['host']

          sql = []
          sql << "drop database if exists #{db_name}"
          sql << "create database #{db_name} CHARSET=utf8"
          sql << "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, CREATE VIEW, DROP, INDEX, ALTER, LOCK TABLES ON `#{db_name}`.* TO '#{username}'@'#{host}' identified by '#{password}'"

          for command in sql
            puts "SQL => #{command}"
            ActiveRecord::Base.connection.execute(command)
          end
        end
      end

      def copy_schema(from, to)
        db_config = ActiveRecord::Base.configurations
        puts "Replicating schema: '#{from}' => '#{to}'"

        begin
          ActiveRecord::Base.establish_connection(db_config[from])
          schema_sql_statements = ActiveRecord::Base.connection.structure_dump.split(';')
          version = ActiveRecord::Migrator.current_version + 1
        rescue Exception => e
          raise e, "Failure in source database (#{db_config[from].inspect}): #{e.message}"
        end

        begin
          ActiveRecord::Base.establish_connection(db_config[to])
          ActiveRecord::Base.connection.without_foreign_key_checks {|conn| conn.tables.each {|table| conn.drop_table(table) } }
        rescue Exception => e
          raise e, "Failure in destination database (#{db_config[to].inspect}): #{e.message}"
        end

        migrated_db = schema_sql_statements.any? { |statement| statement.match(/schema_migrations/) }

        schema_sql_statements.reject(&:blank?).each do |sql|
          ActiveRecord::Base.connection.without_foreign_key_checks {|conn| conn.execute(sql) }
        end
        ActiveRecord::Base.connection.assume_migrated_upto_version(version) if migrated_db
      end

      def migrate_db(environment_to_migrate)
        `#{RosettaStone::PlatformIndependentRake.rake_invocation} db:migrate RAILS_ENV=#{environment_to_migrate}`
      end

    end
  end # CI
end # RosettaStone
