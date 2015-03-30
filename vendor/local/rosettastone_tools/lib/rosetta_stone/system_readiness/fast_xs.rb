# -*- encoding : utf-8 -*-

if Gem.loaded_specs.keys.include?('fast_xs')
  class SystemReadiness::FastXs < SystemReadiness::Base
    class << self
      def verify
        # if Rails aliased the to_xs method (see xchar.rb) then we should be good
        result = String.new.respond_to?(:original_xs)
        return false, "It appears that Rails is not using fast_xs.  Try ./compile_native_library.rb in the fast_xs gem." unless result
        return result, ''
      end
    end
  end
end