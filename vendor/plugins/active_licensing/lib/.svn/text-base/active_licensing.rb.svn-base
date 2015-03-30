if defined?(Rails::Railtie) # Rails 3

  module RosettaStone
    module ActiveLicensing
      class Railtie < Rails::Railtie

        initializer 'active_licensing.load' do |app|
          require 'base'
        end
      end
    end
  end

else

  require 'active_support'
  require 'active_support/core_ext'
  require 'singleton'
  require 'rosettastone_tools'
  require 'base'

end
