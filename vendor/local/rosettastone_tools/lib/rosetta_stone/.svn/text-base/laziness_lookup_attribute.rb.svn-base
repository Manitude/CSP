# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.

# In your model, do something like:
# laziness_lookup_attribute :subdomain
# Then, Model['something'] will do Model.find_by_subdomain('something')
module RosettaStone
  module LazinessLookupAttribute
    module ClassMethods

      def laziness_lookup_attribute(attr)
        singleton_class_eval do
          define_method('[]') do |ident|
            send("find_by_#{attr}", ident)
          end
        end
      end

    end # ClassMethods
  end   # LazinessLookupAttribute
end     # RosettaStone

ActiveRecord::Base.extend(RosettaStone::LazinessLookupAttribute::ClassMethods) if defined?(ActiveRecord)
