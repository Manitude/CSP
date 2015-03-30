# -*- encoding : utf-8 -*-
#
# work item 26446: moving the system readiness suite associated with the mysql2 gem from the
# gem itself to rosettastone_tools. This allows us to have a gem that's functionally identical
# to an installed version of the public gem so that we can switch it out in the future. And
# so teams using the public distribution won't encounter any changes if they switch to our
# version.

mysql2_library_loaded = defined?(Mysql2)
mysql2_system_readiness_test_loaded = defined?(SystemReadiness::Mysql2Configuration)

if mysql2_library_loaded && !mysql2_system_readiness_test_loaded
  class SystemReadiness::Mysql2Configuration < SystemReadiness::Base
    class << self
      def verify
        return true, 'skipped; ActiveRecord is not loaded' unless defined?(ActiveRecord::Base)

        found_a_mysql2_stanza = false
        ActiveRecord::Base.configurations.each do |stanza, config|
          next unless config # a stanza can have a nil configuration value if it wants...
          return false, "The 'mysql2' adapter is loaded, but the configuration for DB stanza '#{stanza}' is using the 'mysql' adapter.  You probably want to change this to 'mysql2'." if config['adapter'] == 'mysql'
          found_a_mysql2_stanza ||= (config['adapter'] == 'mysql2')
        end
        return false, "The 'mysql2' adapter is loaded, but no configurations are using it.  You probably want to change the adapter value from 'mysql' to 'mysql2' in your database configuration." unless found_a_mysql2_stanza

        return true, nil
      end
    end
  end
end
