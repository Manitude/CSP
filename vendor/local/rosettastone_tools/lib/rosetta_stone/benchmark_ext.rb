# -*- encoding : utf-8 -*-

module RosettaStone
  module BenchmarkTmsExtensions
    def milliseconds
      (real * 1000).round # turns 1.5387 into 1539
    end
  end
end

Benchmark::Tms.send(:include, RosettaStone::BenchmarkTmsExtensions) if defined?(Benchmark::Tms)
