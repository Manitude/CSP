# Copyright:: Copyright (c) 2012 Rosetta Stone
# License:: All rights reserved.

# Work Item 35618
# Rails 2.3 and 3+ disagree on the spelling of the TimeZone name for 'Europe/Kiev'.
# This puts mappings in for all the known spellings in the hopes of preventing
# compatibility problems.
if defined?(ActiveSupport::TimeZone)
  module RosettaStone::TimeZoneCompatibility
    original_mapping = ActiveSupport::TimeZone.send(:remove_const, :MAPPING)
    new_mapping = original_mapping.dup.merge({
      'Kyiv' => 'Europe/Kiev', # Rails 3+
      'Kyev' => 'Europe/Kiev', # Rails 2.3
      'Kiev' => 'Europe/Kiev', # for kicks
    }).each { |name, zone| name.freeze; zone.freeze }
    new_mapping.freeze
    ActiveSupport::TimeZone.const_set(:MAPPING, new_mapping)
    ActiveSupport::TimeZone::MAPPING.freeze
  end
end
