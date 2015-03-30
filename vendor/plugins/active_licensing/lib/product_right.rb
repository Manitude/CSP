# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2009 Rosetta Stone
# License:: All rights reserved.

module RosettaStone #:nodoc:
  module ActiveLicensing #:nodoc:
    # A custom RequestAndResponseHandler for API calls in the ProductRight category.
    class ProductRight < RequestAndResponseHandler

      handle :details do |response_hash|
        response_hash['product_right'].rubyize
      end

      handle :extensions do |response_hash|
        response_hash.reparse_with_options!('forcearray' => ['extension'], 'forcecontent' => false)
        extensions = response_hash['extensions']['extension'] || []
        extensions.map { |e| e.rubyize }
      end

      handle :find_by_activation_id do |response_hash|
        response_hash.reparse_with_options!('forcearray' => ['product_right'], 'forcecontent' => false)
        rights = response_hash['product_rights']
        rights = rights && rights['product_right'] || []
        rights.map {|right| right.rubyize! }
      end

      handle :update_product_identifier do |response_hash|
        response_hash.reparse_with_options!('forcearray' => ['product_right'], 'forcecontent' => false)
        rights = response_hash['product_right'] || []
        rights.map {|right| right.rubyize! }
      end

      handle :projected_consumables do |response_hash|
        response_hash.reparse_with_options!('forcearray' => ['consumable'], 'forcecontent' => false)
        consumables = response_hash["consumables"]["consumable"] || []
        consumables.map {|consumable| consumable.rubyize! }
      end

      handle :consumables do |response_hash|
        response_hash.reparse_with_options!('forcearray' => ['consumable'], 'forcecontent' => false)
        consumables = response_hash["consumables"]["consumable"] || []
        consumables.map {|consumable| consumable.rubyize! }
      end
    end # ProductRight
  end # ActiveLicensing
end # RosettaStone
