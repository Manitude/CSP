# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.

# So, the deal is, if a MySQL datetime column value is prior to 2038, ActiveRecord says it's a Time.
# After 2038, it's a DateTime.  You can't compare Time and DateTime...
# ...
# UNTIL NOW!!!
#
# >> DateTime.now > Time.now.yesterday
# => true
# >> Time.now.tomorrow > DateTime.now
# => true
module RosettaStone
  module TimeComparisonHack
    def self.included(klass)
      klass.instance_eval do
        define_method "<=>_with_type_casting" do |val|
          if val.is_a?(DateTime)
            time_as_datetime = DateTime.parse(self.to_s)
            time_as_datetime.send(:"<=>", val)
          else
            send(:"<=>_without_type_casting", val)
          end
        end

        alias_method_chain :"<=>", :type_casting
      end # end instance_eval
    end # end self.included
  end # end module

  module DateTimeComparisonHack
    def self.included(klass)
      klass.instance_eval do
        define_method "<=>_with_type_casting" do |val|
          if val.is_a?(Time)
            time_as_datetime = DateTime.parse(val.to_s)
            send(:"<=>", time_as_datetime)
          else
            send(:"<=>_without_type_casting", val)
          end
        end

        alias_method_chain :"<=>", :type_casting
      end # end instance_eval
    end  # end self.included
  end # end module
end

Time.instance_eval { include RosettaStone::TimeComparisonHack }
DateTime.instance_eval { include RosettaStone::DateTimeComparisonHack }
