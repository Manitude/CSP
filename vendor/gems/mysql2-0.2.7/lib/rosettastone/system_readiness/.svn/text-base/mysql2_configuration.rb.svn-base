# Copyright:: Copyright (c) 2011 Rosetta Stone
# License:: All rights reserved.

class SystemReadiness::Mysql2Configuration < SystemReadiness::Base
  class << self
    def verify
      return true, 'skipped; ActiveRecord is not loaded' unless defined?(ActiveRecord::Base)

      found_a_mysql2_stanza = false
      ActiveRecord::Base.configurations.each do |stanza, config|        
        return false, "The 'mysql2' adapter is loaded, but the configuration for DB stanza '#{stanza}' is using the 'mysql' adapter.  You probably want to change this to 'mysql2'." if config['adapter'] == 'mysql' 
        found_a_mysql2_stanza ||= (config['adapter'] == 'mysql2')
      end
      return false, "The 'mysql2' adapter is loaded, but no configurations are using it.  You probably want to change the adapter value from 'mysql' to 'mysql2' in your database configuration." unless found_a_mysql2_stanza

      return true, nil
    end
  end
end
