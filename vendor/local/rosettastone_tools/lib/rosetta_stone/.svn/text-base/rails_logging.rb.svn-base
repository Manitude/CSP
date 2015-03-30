# -*- encoding : utf-8 -*-
module RosettaStone
  module RailsLogging
    if defined?(Rails) && Rails.respond_to?(:logger)
      def logger
        Rails.logger
      end

      def with_logging_switch(temporary_logger, framework=Rails)
        return unless block_given?
        usual_logger = framework.logger; framework.logger = temporary_logger
        yield
      ensure
        framework.logger = usual_logger
      end
    else
      def logger
        RAILS_DEFAULT_LOGGER
      end
    end

  end
end
Object.send(:include, RosettaStone::RailsLogging)
