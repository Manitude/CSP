# This module is intended to be included into the monitoring controller in your app to provide
# the base functionality for defining checks and rendering responses.
require 'set'

module RosettaStone
  module MonitoringController
    module Base
      def self.included(controller_class)
        controller_class.cattr_accessor :checks
        controller_class.checks = Set.new
        controller_class.extend(ClassMethods)
      end

      module ClassMethods
        def define_check(check_name, options = {}, &check_definition)
          self.checks << [check_name, options.with_indifferent_access]
          define_method(check_name, &check_definition)
        end
      end

      def index
        @checks = klass.checks
      end

    private

      def respond_with(text = '')
        text = yield if block_given?
        render(:text => text.to_s, :layout => false)
      end

    end
  end
end
