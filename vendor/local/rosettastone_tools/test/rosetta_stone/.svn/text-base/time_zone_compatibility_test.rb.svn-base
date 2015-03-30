# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

if defined?(ActiveSupport::TimeZone) # Rails 2.0 doesn't have this

  class RosettaStone::TimeZoneCompatibilityTest < Test::Unit::TestCase

    def test_various_spellings_for_kiev_all_work
      assert_not_nil(ActiveSupport::TimeZone.new('Kyev'))
      assert_not_nil(ActiveSupport::TimeZone.new('Kyiv'))
      assert_not_nil(ActiveSupport::TimeZone.new('Kiev'))
    end
  end
end
