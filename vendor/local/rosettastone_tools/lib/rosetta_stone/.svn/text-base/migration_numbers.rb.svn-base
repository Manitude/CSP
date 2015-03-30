# -*- encoding : utf-8 -*-
if Rails::VERSION::MAJOR < 2
  # MigrationNumbers
  module ActiveRecord
    class Migration
      class << self
        # Execute this migration in the named direction
        def migrate(direction, number)
          return unless respond_to?(direction)

          case direction
            when :up   then announce "migrating %03d" % number
            when :down then announce "reverting %03d" % number
          end

          result = nil
          time = Benchmark.measure { result = send("real_#{direction}") }

          case direction
            when :up   then announce "migrated (%.4fs)" % time.real; write
            when :down then announce "reverted (%.4fs)" % time.real; write
          end

          result
        end
      end
    end

    class Migrator#:nodoc:
      def migrate
        migration_classes.each do |(version, migration_class)|
          Base.logger.info("Reached target version: #{@target_version}") and break if reached_target_version?(version)
          next if irrelevant_migration?(version)

          Base.logger.info "Migrating to #{migration_class} (#{version})"
          migration_class.migrate(@direction, version)
          set_schema_version(version)
        end
      end
    end
  end
end # if Rails::VERSION::MAJOR < 2
