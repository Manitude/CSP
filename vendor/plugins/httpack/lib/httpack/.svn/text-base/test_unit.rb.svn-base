module PlanetArgon          # :nodoc:
  module HttPack            # :nodoc:
    module HttpAssertions   # :nodoc:
      def self.included mod # :nodoc:
        mod.send :include, InstanceMethods
      end

      module InstanceMethods
        # Available content types for #assert_response_content_type.
        RESPONSE_CONTENT_TYPES = {
          'js' => 'text/javascript; charset=UTF-8'
        }

        # Functional tests: assert an action's response is of the appropriate type.
        def assert_response_content_type type
          assert_equal RESPONSE_CONTENT_TYPES[type.to_s], @response.headers["Content-Type"]
        end
      end
    end
  end
end

Test::Unit::TestCase.send :include, PlanetArgon::HttPack::HttpAssertions
