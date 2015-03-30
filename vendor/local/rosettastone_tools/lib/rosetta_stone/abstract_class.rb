# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.

# Allows for the definition of Abstract Classes (classes that cannot be instantiated, but whose subclasses are concrete)
#
# Note: this doesn't seem to work with Ruby 1.9, and I'm not sure it's worth fixing.  I recommended deprecating the use
# of this module.
module AbstractClass
  def self.included(klass)
    klass.send(:private_class_method, :new)
    class << klass
      def inherited(subklass)
        super
        subklass.send(:public_class_method, :new)
      end
    end
  end
end
