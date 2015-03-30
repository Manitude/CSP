# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.

module SayWithTime
  # shamelessly lifted from the ActiveRecord migration class
  def say_with_time(message)
    say(message)
    result = nil
    time = Benchmark.measure { result = yield }
    say result, :subitem if result.is_a?(String) && !result.blank?
    say "%.4fs" % time.real, :subitem
    result
  end

  def say(message, subitem=false)
    puts "#{subitem ? "   ->" : "--"} #{message}"
  end
end
