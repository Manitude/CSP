# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2008 Rosetta Stone
# License:: All rights reserved.

# Honestly, I don't know how someone can claim to have reimplemented Hash without has_key?
# This should really go as a patch to Rails.
if defined?(ActiveSupport::OrderedHash) && !ActiveSupport::OrderedHash.instance_methods.map(&:to_s).include?('has_key?')
  module RosettaStone
    module OrderedHashExtensions
      def has_key?(key)
        keys.include?(key)
      end
    end
  end
  ActiveSupport::OrderedHash.send(:include, RosettaStone::OrderedHashExtensions)
end
