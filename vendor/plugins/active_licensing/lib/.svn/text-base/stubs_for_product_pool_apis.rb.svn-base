# FIXME: this file should be deleted once the stubs are actually implemented
# See Work Item 48013

module RosettaStone #:nodoc:
  module ActiveLicensing #:nodoc:
    module StubsForProductPoolApis
      class << self

        def sample_product_pool_details(overrides = {})
          {
            :guid => RosettaStone::UUIDHelper.generate,
            :creation_account => {
              :identifier => 'CE::sample',
              :guid => RosettaStone::UUIDHelper.generate,
            },
            :product_bundle => {
              :name => 'TOTALe (unlimited group studio sessions)',
              :guid => RosettaStone::UUIDHelper.generate,
            },
            :expires_at => 1.year.from_now,
            :starts_at => 10.days.ago,
            :provisioner_identifier => 'EndDatePool',
            :allocations_max => 50,
            :allocations_remaining => 42,
            :product_configuration => {
              :access_ends_at => 1.year.from_now,
              :languages => ['ENG', 'ESP', 'FRA', 'DEU', 'ITA'],
              :max_languages_per_allocation => 1,
            }
          }.merge(overrides).with_indifferent_access
        end

        def sample_allocation_details(overrides = {})
          {
            :guid => RosettaStone::UUIDHelper.generate,
            :product_pool => sample_product_pool_details, # FIXME: should we really return *all* of this?
            :license_guid => RosettaStone::UUIDHelper.generate,
            :can_be_deallocated => true,
            :product_configuration => {
              :duration => '6m',
              :languages => ['ESP'],
            }
          }.merge(overrides).with_indifferent_access
        end
      end
    end
  end
end
