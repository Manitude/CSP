# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2013 Rosetta Stone
# License:: All rights reserved.

module RosettaStone #:nodoc:
  module ActiveLicensing #:nodoc:
    # A custom RequestAndResponseHandler for API calls in the ProductPools category.
    class ProductPool < RequestAndResponseHandler

      # Creates a new product pool for the given creation account.
      #
      # Options
      #
      # creation_account OR creation_account_guid
      #   the identifier or guid of the creation account
      # provisioner_identifier
      #   the identifier of the provisioner, which picks the licensing model (end-date or duration)
      # allocations_max
      #   the size of the pool
      # product_bundle_guid
      #   the guid of the product bundle, which picks the product family (Course, TOTALe)
      # starts_at
      #   the date at which the pool can be allocated from
      # expires_at
      #   the date at which the pool expires and no more allocations can be made
      # product_configuration (optional)
      #   a set of provisioning parameters that shoud apply to all allocations, eg
      #     {:duration => '3m', :languages => ['ENG', 'ESP'], :max_languages_per_allocation => 1}
      # guid (optional)
      #   optionally specify the guid of the product pool to create.  if not specified, the license
      #   server will automatically generate a guid.
      #
      # On success, returns the details of the newly created pool.
      # On failure, raises an exception.
      #   Creation account not found
      #   Provisioner not found
      #   Product bundle not found
      #   Expires At is before Ends At
      #   Unknown provisioner configuration key
      #   Invalid provisoner configuration value

      handle :add, :use_post => true, :use_standard_from_xml => true do |response_hash|
        response_hash['response']['product_pool'].rubyize
      end

      # Returns the details of the product pool specified by guid
      #
      # Options
      #
      # guid
      #   specifies the guid of the product pool
      #
      # On success, returns the details of the product pool.
      # On failure, raises an exception.
      #   ProductPoolNotFound
      handle :details, :use_standard_from_xml => true do |response_hash|
        response_hash['response']['product_pool'].rubyize
      end

      # Removes a product pool from its creation account. This is only possible if all allocations have been
      # deallocated. The returned product pool details will have a `deleted` of `true`.
      #
      # OPTIONS
      #
      # guid
      #   guid of the product pool
      #
      # On success, returns the details of the (now deleted) product pool.
      # On failure, raises an exception.
      #   Product Pool not found
      #   Product Pool has allocations
      handle :remove, :use_post => true, :use_standard_from_xml => true do |response_hash|
        response_hash['response']['product_pool'].rubyize
      end

      # Changes attributes or provisioning parameters for the pool. This is cheap for a recently created pool, but
      # can be a very expensive operation if many existing allocations need to be updated.
      #
      # The provisioner and product bundle can't be changed. (Or allocations_remaining, obviously.)
      #
      # Use case: Oops. That pool should also allow the user to learn Italian. Add ITA to the list of available languages.
      # Use case: Institution buys 34 more seats. Increase their allocation max. (Could also make a new pool with 34 available allocations.)
      # Use case: Ooops... please give us 2 more weeks of access while we work out a renewal. Set access_ends_at two weeks
      #   out from its current value.
      #
      # OPTIONS
      #   guid
      #     guid of the product pool
      #   starts_at (optional), expires_at (optional)
      #     The new starts_at or expires_at, which control the time range in which allocations and deallocations can be performed.
      #     Expressed in seconds since the epoch.
      #   allocations_max (optional)
      #     The new maximum number of allocations. Cannot be set to less than the current number of allocations.
      #   product_configuration (optional)
      #     Hash of provisioning parameters with their new values. Omit configuration keys you do not wish to change, or the entire
      #     product_configuration hash if no provisioning parameters are changing.
      #
      # ISSUES
      #   Actually changing some of the provisioner parameters might take a really long time. Background it?
      #
      # On success, returns the details of the updated product pool.
      # On failure, raises an exception.
      #   Product pool not found
      #   Allocations max less than allocations current
      #   Invalid product configuration
      handle :update, :use_post => true, :use_standard_from_xml => true do |response_hash|
        response_hash['response']['product_pool'].rubyize
      end

      # Allocates a product (in the Oracle sense, not the license server Product sense -
      # this is bad terminology, maybe 'entitlement' is better) from a product pool
      # onto a end user account (aka a license) and decrements the pool's allocations_remaining by 1.
      # You will typically need to provide a
      # set of provisioning parameters to specify details (like which language(s) to
      # give the end user account) that aren't supplied by the product pool or product bundle.
      #
      # OPTIONS
      #   guid
      #     guid of the product pool
      #   license_guid
      #     guid of the end user account (aka license)
      #   product_configuration
      #     A hash of provisioning parameters to merge with the product
      #     configuration of the product pool. For TOTALe and Course,
      #     you probably want something like
      #       {:languages => ['ENG']}
      #     This will instruct the provisioner to give English-US.
      #     Omit keys you do not wish to override. Keys can't be removed.
      # On success, returns the details of the newly created allocation.
      # Several possible failure modes:
      #   Creation account not found
      #   License not found
      #   Creation account not allowed to provision products on this license
      #     (test vs. non-test, restricted vs. non-restricted)
      #   No allocations left
      #   Insufficient product configuration for allocation
      #   Invalid product configuration
      #   Product configuration key is not changeable
      # This is a static stub for now.
      handle :allocate, :use_post => true, :use_standard_from_xml => true do |response_hash|
        response_hash['response']['allocation'].rubyize
      end

      # Returns an allocation back to the pool from whence it came and increments
      # the pool's allocations_remaining by 1. Removes
      # whatever the allocation granted to the end user account.
      #
      # The product pool may disallow the deallocation action. For example, a duration pool will
      # only allow deallocations during a short 'grace period' after the allocation takes place.
      # This is to prevent admins from pulling an almost-used up duration product off of one user
      # and then reallocating to another user with full duration, but still have a limited 'undo'
      # capability in case of mistakes.
      #
      # OPTIONS
      #
      #   allocation_guid
      #     guid of the allocation to deallocate
      #
      # On success, returns the details of the (now deleted) allocation.
      # On failure, raises an exception.
      #   Allocation not found
      #   Deallocation not allowed
      handle :deallocate, :use_post => true, :use_standard_from_xml => true do |response_hash|
        response_hash['response']['allocation'].rubyize
      end

      # Returns details a single allocation.
      #
      # OPTIONS
      #
      # alloction_guid
      #   guid of the allocation to get details for
      # On success, returns the details of the given alloction.
      # On failure, raises an exception.
      #   Allocation not found
      handle :allocation, :use_standard_from_xml => true do |response_hash|
        response_hash['response']['allocation'].rubyize
      end

      # Returns details for all allocations from the specified product pool.
      #
      # OPTIONS
      #
      # guid
      #   guid of the product pool to get allocation details for
      # page (optional)
      #   specify the page number for pagination through the allocation list
      # per_page (optional)
      #   specify number of results per page
      #
      # On success, returns an array of allocation details or a page structure with one page of allocation details.
      # On failure, raises an exception.
      #   Product pool not found
      handle :allocations, :use_standard_from_xml => true do |response_hash|
        if (response_hash['response']['allocations'])
          response_hash['response']['allocations'].map(&:rubyize!)
        else
          page = response_hash['response']['page']
          page['allocations'].each(&:rubyize!)
          page
        end
      end

    end
  end
end

