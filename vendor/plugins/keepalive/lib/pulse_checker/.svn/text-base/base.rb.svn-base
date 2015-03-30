# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2011 Rosetta Stone
# License:: All rights reserved.

# To add a pulse checker, define a class that descends from PulseChecker::Base and
# implement a check! class method that will raise on failure.
module PulseChecker
  class Base
    class << self
      def with_each_subclass(&block)
        subclasses.map(&:to_s).sort.each do |subclass|
          yield subclass.constantize
        end
      end

      def name
        to_s.underscore.gsub("pulse_checker/", '')
      end
    end
  end

  class << self
    include RosettaStone::PrefixedLogger

    def check_all!
      PulseChecker::Base.with_each_subclass do |subclass|
        logger.debug "checking #{subclass.name}... "
        subclass.check!
      end
    end
  end
end
