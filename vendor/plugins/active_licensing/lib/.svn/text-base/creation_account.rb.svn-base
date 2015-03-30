# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.

module RosettaStone #:nodoc:
  module ActiveLicensing #:nodoc:
    # A custom RequestAndResponseHandler for API calls in the CreationAccount category.
    class CreationAccount < RequestAndResponseHandler
      # Returns an array of License hashes.
      handle :licenses do |response_hash|
        response_hash.reparse_with_options!('forcearray' => ['license'], 'forcecontent' => false)
        licenses = response_hash['licenses']['license'] || [] rescue []
        licenses.map(&:rubyize!)
      end

      # Returns an integer.
      handle :license_count do |response_hash|
        response_hash.reparse_with_options!('forcearray' => false, 'forcecontent' => false)
        response_hash['license_count'].to_i
      end

      # Returns a boolean.
      handle :authenticate do |response_hash|
        response_hash.reparse_with_options!('forcearray' => false, 'forcecontent' => false)
        response_hash['authentication'] == 'true'
      end

      # Returns a hash of Creation Account attributes
      handle :details do |response_hash|
        response_hash.reparse_with_options!('forcearray' => false, 'forcecontent' => false)
        response_hash['creation_account'].rubyize
      end

      # Returns an array of Available Product hashes.
      handle :available_products do |response_hash|
        response_hash.reparse_with_options!('forcearray' => ['available_product'], 'forcecontent' => false)
        available_products = response_hash['available_products']['available_product'] || [] rescue []

        available_products = parse_content_ranges!(available_products)

        available_products.collect(&:rubyize!)
      end

      # Returns detail information for all product pools associated with a PooledCreationAccount.
      #
      # Options:
      #   creation_account or creation_account_guid
      #      identifier or guid of the creation account
      #
      # On success, returns an array of product pools.
      # Exceptions:
      #   CreationAccountNotFound
      #   CreationAccountDoesNotAllowPools - only call this method on a PooledCreationAccount
      handle :product_pools, :use_standard_from_xml => true do |response_hash|
        response_hash['response']['product_pools'].map(&:rubyize!)
      end

      handle :find_by_activation_id do |response_hash|
        response_hash.reparse_with_options!('forcearray' => ['creation_account'], 'forcecontent' => false)
        creation_accounts = response_hash['creation_accounts']
        creation_accounts = creation_accounts && creation_accounts['creation_account'] || []
        creation_accounts.map {|account| account.rubyize! }
      end

      def is_osub_account?(creation_account_identifier)
        details(:creation_account => creation_account_identifier, :skip_license_counts => true).rubyize['type'] == 'online_subscription'
      rescue RosettaStone::ActiveLicensing::CreationAccountNotFound
        false
      end

    end # CreationAccount

    class CreationAccountNotFound < Exception; end;
  end # ActiveLicensing
end # RosettaStone
