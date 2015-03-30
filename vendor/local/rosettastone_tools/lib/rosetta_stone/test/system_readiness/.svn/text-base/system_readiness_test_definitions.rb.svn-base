# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2009 Rosetta Stone
# License:: All rights reserved.

# This module defines the tests themselves.  It is intended to be included into
# a Test::Unit::TestCase (or ActiveSupport::TestCase) class.
module SystemReadiness
  module SystemReadinessTestDefinitions
    SystemReadiness::Base.with_each_subclass do |subclass|
      define_method("test system readiness for #{subclass.name}") do
        success, message = subclass.verify
        assert_true(success, message)
      end
    end
  end
end
