# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::BenchmarkTest < Test::Unit::TestCase

  def test_benchmark
    with_clean_log_file do
      RosettaStone::Benchmark.log('BenchmarkTest') do
        sleep(0.1)
      end
      assert_match(/\[benchmark\] BenchmarkTest \(\d+ms\)/, log_file_entries)
    end
  end

end
