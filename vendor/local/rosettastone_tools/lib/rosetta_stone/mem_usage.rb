# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

module RosettaStone
  module MemUsage
    class << self
      include RosettaStone::PrefixedLogger

      # virtual set size (VSS in top, vsz in ps), in kilobytes
      def virtual
        ps_command('vsz')
      end

      # resident set size (RSS), in kilobytes
      def resident
        ps_command('rss')
      end

      def garbage_collect!
        before = virtual
        logger.info("VSS memory usage before garbage collection: #{before}kb")
        log_benchmark('running garbage collection') do
          GC.start
        end
        after = virtual
        logger.info("VSS memory usage after garbage collection: #{after}kb (freed #{before - after}kb)")
      end

    private

      def ps_command(output_format)
        `ps -p #{Process.pid} -o#{output_format}=`.strip.to_i
      end
    end
  end
end
