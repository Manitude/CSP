# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2011 Rosetta Stone
# License:: All rights reserved.

# This pulse checker runs a SQL query on every keepalive request to ensure that the database
# connection is responding.
if defined?(ActiveRecord)
  class PulseChecker::ActiveRecord < PulseChecker::Base
    RAILS_IS_ABOVE_2_1 = RosettaStone::RailsVersionString >= RosettaStone::VersionString.new(2,1,0) 

    class << self
      def check!
        if RAILS_IS_ABOVE_2_1
          test_sql = 'select version from schema_migrations limit 1'
        else
          test_sql = 'select version from schema_info'
        end
        ActiveRecord::Base.connection.select_one(test_sql)
      end
    end

  end
end