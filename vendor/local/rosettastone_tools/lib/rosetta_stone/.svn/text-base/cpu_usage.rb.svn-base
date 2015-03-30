# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

module RosettaStone
  module CpuUsage
    class << self
      include RosettaStone::PrefixedLogger

      # from man ps: "The CPU utilization of the process; this is a decaying average over up to a minute of previous (real) time."
      def percent
        ps_command('%cpu').to_f
      end

      # wall clock uptime of the process, in seconds
      def elapsed_time_since_process_start
        time_format_to_seconds(ps_command('etime'))
      end

      # user + system CPU time, accumulated since the process started, in seconds
      def cpu_time_since_process_start
        user_cpu_time_since_process_start + system_cpu_time_since_process_start
      end

      # in seconds
      def user_cpu_time_since_process_start
        Process.times.utime
      end

      # in seconds
      def system_cpu_time_since_process_start
        Process.times.stime
      end

    private

      def ps_command(output_format)
        `ps -p #{Process.pid} -o"#{output_format}="`.strip
      end

      # 34:51.26    => 2091.26
      # 03:40:36    => 13236
      # 2-06:51:49  => 197509
      # 27-00:42:46 => 2335366
      def time_format_to_seconds(ps_time)
        segments = ps_time.to_s.strip.split(/[:-]/)
        seconds = 0.0
        [1, 60, 3600, 86400].each_with_index do |seconds_for_unit, index|
          segments[(index + 1) * -1].if_hot {|value| seconds += (value.to_f * seconds_for_unit) }
        end
        seconds
      end
    end
  end
end
