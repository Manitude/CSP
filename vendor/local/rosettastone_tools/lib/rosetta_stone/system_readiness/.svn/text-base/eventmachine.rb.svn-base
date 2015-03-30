# -*- encoding : utf-8 -*-

if Gem.loaded_specs.keys.include?('eventmachine')
  class SystemReadiness::Eventmachine < SystemReadiness::Base
    class << self
      def verify
        if Gem.loaded_specs['eventmachine'].version <= Gem::Version.new('0.12.11')
          return true, '' if $eventmachine_library == :extension
          return false, "EventMachine is loaded as '#{$eventmachine_library}'.  Fix this by running './compile_native_library.rb' from the eventmachine vendor/gems directory"
        else
          return true, '$eventmachine_library not tested, since the bundled eventmachine gem is not the version we typically embed in vendor/gems'
        end
      end
    end
  end
end
