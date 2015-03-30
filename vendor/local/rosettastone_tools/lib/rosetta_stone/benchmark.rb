# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

module RosettaStone
  module Benchmark
    mattr_accessor :most_recent_benchmark

    class << self
      def log(message = 'unspecified operation', logger_to_use = nil)
        logger_to_use ||= logger
        result = nil
        self.most_recent_benchmark = ::Benchmark.measure { result = yield }.milliseconds
        logger_to_use.info('[benchmark] %s (%.0fms)' % [message, most_recent_benchmark])
        result
      end
    end
  end
end
