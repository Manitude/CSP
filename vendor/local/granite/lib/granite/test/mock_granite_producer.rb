# Use this module if you want to mock out the producer for your tests. To do so, do the following
#
# 1. Your app needs to be set up to put test/mocks/#{env} at the beginning of the load order
# 2. Create a file in test/mocks/test/producers (e.g. test/mocks/test/producers/my_producer.rb)
# 3. At the top of that file, require the real producer via something like "require 'producers/my_producer'
# 4. After that, add something like: MyProducer.send(:include,Granite::Test::MockGraniteProducer)
module Granite
  module Test
    module MockGraniteProducer
      def self.included(base)
        base.send :include, InstanceMethods
        base.extend ClassMethods
        #Make it less confusing for tests. Now the published messages won't carry over from test to test
        ActiveSupport::TestCase.send(:setup, lambda{base.send :clear_published_messages!})
      end

      module ClassMethods
        def published_messages
          @published_messages ||= []
        end

        def publish(message)
          #Act like granite would, so to_json the payload and then parse that.  This makes sure that we
          #get the nuances of serializing and deserializing (like changing symbols to strings)
          message = message.to_json unless message.is_a?(String)
          published_messages << JSON.parse(message)
        end

        def clear_published_messages!
          @published_messages = []
        end
      end

      module InstanceMethods
        def published_messages
          klass.published_messages
        end
      end
    end
  end
end
