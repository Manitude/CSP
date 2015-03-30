# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

if Gem.loaded_specs.keys.include?('libxml-ruby')
  class SystemReadiness::LibXML < SystemReadiness::Base
    class << self
      def verify
        require 'libxml'
        ::LibXML
        return true, ''
      rescue LoadError
        return false, "Failed to require libxml"
      rescue NameError
        return false, "LibXML binary library not loaded"
      end
    end
  end
end