# This class is meant to describe the current application reflexively.
require 'lion_ext/query'
require 'active_support/okjson'
ActiveResource::Base.logger = logger

class ConfigurationError < StandardError; end

class App
  class << self

    def name
      'Coachportal'
    end

    def method_missing(meth, *args)
      app_config = ApplicationConfiguration.find_by_setting_type(meth.to_s)
      if app_config
        if app_config.data_type == 'boolean'
          return (app_config.value == "Enable")
        elsif app_config.data_type == 'integer'
          return app_config.value.to_i
        else
          return app_config.value
        end
      end
     super
    rescue NoMethodError
      raise NoMethodError, "undefined method `#{meth}' for #{self.to_s}:Class. You might need it in application configuration."
    end
  end
end
