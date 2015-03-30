# -*- encoding : utf-8 -*-

# Checks for the presence of the binary mysql gem
class SystemReadiness::MysqlBindings < SystemReadiness::Base
  class << self
    def verify
      return true, 'skipped; ActiveRecord is not loaded' unless defined?(ActiveRecord::Base)
      return true, 'skipped; no configurations are using the mysql adapter' if ActiveRecord::Base.configurations.values.compact.none? {|config| config['adapter'] == 'mysql' }
      require_library_or_gem('mysql')
      return true, nil
    rescue MissingSourceFile
      return false, 'failed to load mysql bindings'
    end
  end
end
