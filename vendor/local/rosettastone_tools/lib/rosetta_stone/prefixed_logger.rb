# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2009 Rosetta Stone
# License:: All rights reserved.
#
# This provides an easy mechanism to have your log messages prefixed with:
#  * a timestamp
#  * the name of the class that is issuing the message
#  * the PID of the current ruby process
#
# To use this functionality, simply insert:
#
#   include RosettaStone::PrefixedLogger
#
# into your class.  Note that you can put that line within a class << self
# block if you want to log from class methods instead of instance methods.
#
# After including into your class, write log messages by simply using
# logger.debug, logger.error, etc. like you normally would.
#
module RosettaStone
  class LogPrefixer
    def initialize(source = nil)
      @name_prefix = (source.is_a?(Module) ? source : source.class).to_s
    end

    def method_missing(log_level, *args)
      if recognized_levels.include?(log_level)
        message = args.first.to_s
        Framework.logger.send(log_level, [log_prefix, message].join)
      else
        # some other method, pass it through (e.g. debug?, info?)
        Framework.logger.send(log_level, *args)
      end
    end

    def log_prefix
      "#{Time.now.to_s(:db)} - #{@name_prefix} (pid #{Process.pid}): "
    end

    # these seem to be hardcoded in rails' logger.rb too?
    def recognized_levels
      [:debug, :info, :error, :fatal]
    end
  end

  module PrefixedLogger
    module LoggerOverride
      def logger
        rosetta_stone_prefixed_logger
      end
    end

    def self.included(base)
      # for controller classes, we don't override `logger` because it changes the formatting of the standard
      # rails log messages.  however, we still use the prefixed logger for log_benchmark(), even in controllers.
      # alias_method doesn't work here for reasons I don't understand
      #alias_method(:logger, :rosetta_stone_prefixed_logger)
      base.send(:include, LoggerOverride) unless defined?(ActionController::Base) && base < ActionController::Base
    end
  protected
    def rosetta_stone_prefixed_logger
      @rosetta_stone_prefixed_logger ||= RosettaStone::LogPrefixer.new(self)
    end

    def log_benchmark(message = 'unspecified operation', &block)
      RosettaStone::Benchmark.log(message, rosetta_stone_prefixed_logger, &block)
    end
  end
end
