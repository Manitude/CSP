# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.

module RosettaStone
  module HashExtensions
    module Rubyize
      SECONDS_IN_DAY = 86400
      # Takes a Hash and attempts to turn certain values from Strings into Ruby-native objects.
      def rubyize
        hsh = self.dup
        hsh.each do |k,v|
          hsh[k] = true if v == "true"
          hsh[k] = false if v == "false"
          hsh[k] = Time.at(v.to_i) rescue (DateTime.parse(Time.at(0).to_s) + (v.to_f / SECONDS_IN_DAY)) if (!v.blank? && (k.to_s =~ /_at$/ || k.to_s =~ /_by$/))
          hsh[k] = v.rubyize if v.is_a?(Hash)
        end
      end
      # Replaces this Hash with a rubyized version of itself.
      def rubyize!
        replace rubyize
      end
    end
  end
end
[Hash, HashWithIndifferentAccess].each {|klass| klass.send(:include, RosettaStone::HashExtensions::Rubyize)}
