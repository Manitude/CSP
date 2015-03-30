# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2008 Rosetta Stone
# License:: All rights reserved.
#
# This is intended to be extended onto a :has_many association where the associated model
# has columns for "name" and "value".  The association can then be treated as if it were
# a hash.
#
# Examples:
#
# has_many :parameters, :dependent => :destroy, :extend => RosettaStone::HashAssociation
#
# my_object.parameters                =>  []
# my_object.parameters.to_hash        =>  {}
# my_object.parameters['foo']         =>  nil
# my_object.parameters['foo'] = 'bar' =>  'bar'
# my_object.parameters['foo']         =>  'bar'
# my_object.parameters.to_hash        =>  {'foo' => 'bar'}
# my_object.parameters.keys           =>  ['foo']

module RosettaStone
  module HashAssociation
    def [](attr_name)
      record = self.detect {|rec| rec.name == attr_name.to_s}
      return nil unless record
      record.value
    end

    def []=(attr_name, new_value)
      record = find_or_create_by_name(attr_name.to_s)
      record.update_attribute(:value, new_value)
    end

    def keys
      map(&:name)
    end

    def has_key?(key)
      keys.include?(key.to_s)
    end

    def to_hash
      Hash.new.tap {|hash| self.each {|record| hash[record.name] = record.value}}
    end
  end
end

