# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.

module RosettaStone
  module TimeExtensions
    MAX_SECONDS = 2 ** 31 - 1

    module ClassMethods
      def max
        self.at(MAX_SECONDS)
      end

      def zero
        self.at(0)
      end

      def rand(years_back=5)
        t = at((now.to_i-(Kernel.rand*years_back*31536000)).div(86400)*86400+(Kernel.rand*86400))
        t - t.gmt_offset
      end
    end

    def milliseconds
      (to_f * 1000).to_i
    end

    def beginning_of_hour
      change(:min => 0, :sec => 0, :usec => 0)
    end
    alias_method :at_beginning_of_hour, :beginning_of_hour
  end

  module TimeComparisons
    def is_before?(time)
      self < time
    end

    def is_after?(time)
      !is_before?(time)
    end

    def past?
      is_before?(Time.now)
    end

    def future?
      is_after?(Time.now)
    end
  end

  module DateTimeExtensions
    module ClassMethods
      def at(seconds_since_epoch)
        Time.zero.to_datetime.advance(:seconds => seconds_since_epoch)
      end
    end

    # instance method backported from rails 2.3.14, replacing the implementation from https://trac.lan.flt/webdev/changeset/14305, only if the method isn't already defined, like in the OLLCs
    if !DateTime.new.respond_to?(:to_i)
      def to_i
        seconds_per_day = 86_400
        (self - ::DateTime.civil(1970)) * seconds_per_day
      end
    end
  end

end

Time.extend(RosettaStone::TimeExtensions::ClassMethods)
Time.send(:include, RosettaStone::TimeExtensions)
DateTime.instance_eval { include RosettaStone::DateTimeExtensions }
DateTime.extend(RosettaStone::DateTimeExtensions::ClassMethods)

# ActiveSupport::TimeWithZone makes its appearance at Rails 2.1.0; if it's defined, we need to include TimeComparisons in it

classes_that_need_time_comparisons = [Date, Time, DateTime] + (defined?(ActiveSupport::TimeWithZone) ? [ActiveSupport::TimeWithZone] : [])
classes_that_need_time_comparisons.each {|c| c.send(:include, RosettaStone::TimeComparisons)}
