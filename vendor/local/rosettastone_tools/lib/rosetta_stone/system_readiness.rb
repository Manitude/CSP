# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2009 Rosetta Stone
# License:: All rights reserved.

module SystemReadiness
  class Base
    class << self
      def with_each_subclass(&block)
        subclasses.map(&:to_s).sort.each do |subclass|
          yield subclass.constantize
        end
      end

      def name
        to_s.underscore.gsub("system_readiness/", '')
      end
    end
  end

  class << self
    def verify_verbose
      puts "Checking system readiness. Interesting lines will begin with 'failed' or 'warning'."
      SystemReadiness::Base.with_each_subclass do |subclass|
        success, message = subclass.verify
        if success
          print "ok\t\t#{(message.present?) ? "#{message}: " : ""}"
        else
          print "failed\t\t#{message}: "
        end
        puts subclass.name
      end
    end
  end
end
