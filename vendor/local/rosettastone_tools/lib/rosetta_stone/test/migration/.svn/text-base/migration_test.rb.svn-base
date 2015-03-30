# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2008 Rosetta Stone
# License:: All rights reserved.
require File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'test', 'test_helper')

if defined?(ActiveRecord)
  class RosettaStone::MigrationTest < Test::Unit::TestCase
    # this test merely asserts that all migrations (down to maximum_undownable_migration; 0 by default)
    # can be downed and re-upped without raising
    def test_all_migrations_can_be_downed
      assert_nothing_raised do
        ActiveRecord::Migration.suppress_messages do
          ActiveRecord::Migrator.migrate(migrations_path, maximum_undownable_migration)
        end
      end
    ensure
      ActiveRecord::Migration.suppress_messages do
        ActiveRecord::Migrator.migrate(migrations_path)
      end
    end

    private
    # if migrations in a given application cannot be expected to migrate all the way down
    # to zero, define the MAXIMUM_UNDOWNABLE_MIGRATION number in the app
    def maximum_undownable_migration
      defined?(MAXIMUM_UNDOWNABLE_MIGRATION) ? MAXIMUM_UNDOWNABLE_MIGRATION : 0
    end

    def migrations_path
      File.join(Rails.root, 'db', 'migrate')
    end
  end
end
