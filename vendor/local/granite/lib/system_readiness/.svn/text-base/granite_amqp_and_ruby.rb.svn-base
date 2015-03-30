# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

class SystemReadiness::GraniteAmqpAndRuby < SystemReadiness::Base
  class Check
    def func
      true
    end
  end
  class SuperCheck < Check
    def func
      lambda{super}.call
    end
  end
  class << self
    def verify
      begin
        SuperCheck.new.func
      rescue NoMethodError
        return false, "The version of Ruby you're using doesn't allow a Proc/lambda to call super. This will mean that AMQP will not work. Upgrade, fool!"
      end
      if Gem.loaded_specs["amqp"].version < Gem::Version.new("0.7.0")
        return false, "Your version of the AMQP gem is not supported by granite. Please update to >= 0.7.0"
      end
      return true, ''
    end
  end
end
