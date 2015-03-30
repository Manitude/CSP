# Copyright:: Copyright (c) 2012 Rosetta Stone
# License:: All rights reserved.
#
# See Work Item 30243
# This fixes an issue in ActiveRecord where every insert on a join table in a HABTM
# association would trigger a query like:
#
#   describe `indexed_substrings_licenses`
#
# Unfortunately that query is not just pesky; it's fairly expensive in MySQL because
# it requires an on-disk temporary table to be created.
# (see http://bugs.mysql.com/bug.php?id=56812)
#
# The problem was that the has_primary_key? method tries to cache the result of whether
# the join table has a primary key (as determined by running the describe query), but
# fails to cache this result when there is no primary key (because it's nil).
#
# This issue affects at least Rails 2.3.x and 3.0.x.  It might not be an issue in Rails
# 3.2 (the code looks different there...).  I didn't check 3.1.
#
# The license server has a test for this fix in test/unit/substring_indexable_test.rb
if (RosettaStone::RailsVersionString >= RosettaStone::VersionString.new(2,3,0) &&
    RosettaStone::RailsVersionString <  RosettaStone::VersionString.new(3,1,0) &&
    defined?(ActiveRecord::Base))

  # trigger the class to load from Rails first:
  ActiveRecord::Associations::HasAndBelongsToManyAssociation

  # override the offending method:
  module ActiveRecord
    module Associations
      class HasAndBelongsToManyAssociation

        # the only difference from the original is the "!!" at the beginning of the last
        # line, which enables it to cache the nil value as false to prevent re-running
        # the describe query.
        def has_primary_key?
          return @has_primary_key unless @has_primary_key.nil?
          @has_primary_key = (@owner.connection.supports_primary_key? &&
            !!@owner.connection.primary_key(@reflection.options[:join_table]))
        end

      end
    end
  end
end