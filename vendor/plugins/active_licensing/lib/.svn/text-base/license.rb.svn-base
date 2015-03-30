# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.

module RosettaStone #:nodoc:
  module ActiveLicensing #:nodoc:
    # A custom RequestAndResponseHandler for API calls in the License category.
    class License < RequestAndResponseHandler

      # Returns an array of Product Right hashes.
      handle :product_rights do |response_hash|
        response_hash.reparse_with_options!('forcearray' => ['product_right', 'content_range'], 'forcecontent' => false)
        product_rights = response_hash['product_rights']['product_right'] || [] rescue []
        product_rights = parse_content_ranges!(product_rights)
        product_rights.map { |pr| ProductRightHash.new.replace(pr).rubyize! }
      end

      handle :product_rights_with_authentication, :use_post => true do |response_hash|
        response_hash.reparse_with_options!('forcearray' => ['product_right', 'content_range'], 'forcecontent' => false)
        product_rights = response_hash['product_rights']['product_right'] || [] rescue []
        product_rights = parse_content_ranges!(product_rights)
        response_hash['product_rights'] = product_rights.map { |pr| ProductRightHash.new.replace(pr).rubyize! }
        response_hash.rubyize
      end

      handle :add_product_right do |response_hash|
        response_hash['product_right']
      end

      handle :add_or_extend_product_right do |response_hash|
        response_hash['product_right']
      end

      # Returns a hash of License attributes
      # extra error-handing added in work item 23781
      handle :details do |response_hash|
        original_response_hash = response_hash.dup
        response_hash.reparse_with_options!('forcearray' => false, 'forcecontent' => false)
        license_value = response_hash['license']
        if license_value
          license_value.rubyize
        else
          raise "Error parsing response from ls_api.details: license_value: #{license_value.inspect}: original_response_hash: #{original_response_hash.inspect}. reparsed response_hash: #{response_hash.inspect}"
        end
      end

      handle :case_insensitive_details do |response_hash|
        response_hash.reparse_with_options!('forcearray' => ['license'], 'forcecontent' => false)
        licenses = response_hash['licenses']['license'] || [] rescue []
        licenses.map(&:rubyize!)
      end

      # Returns a hash like {"authentication"=>true, "guid"=>"70ecea27-b1b8-4897-97ac-b61ba40c36e6", "license_server_version"=>"1.0", "license_identifier"=>"aharbick@aharbick.com"}
      handle :authenticate, :use_post => true do |response_hash|
        response_hash.rubyize
      end

      # returns the same kind of hash as authenticate
      handle :authenticate_with_token, :use_post => true do |response_hash|
        response_hash.rubyize
      end

      handle :extend_product_right do |response_hash|
        response_hash.rubyize
      end

      # Returns a hash like {:token => "71440aebd47d47e2bc759401f022bb5a02dde90e110a0340380f825cbaed53b859391336fe50e9327ed"}
      handle :get_token do |response|
        {:token => response['content'].to_s.strip}.with_indifferent_access
      end

      # Returns a boolean
      handle :exists do |response_hash|
        response_hash.rubyize['exists']
      end

      # Returns a string
      handle :start_session do |response_hash|
        response_hash.rubyize['session_key']
      end

      # Returns a boolean
      handle :session_exists do |response_hash|
        response_hash.rubyize['exists']
      end

      handle :previous_identifiers do |response_hash|
        response_hash.reparse_with_options!('forcearray' => ['previous_identifier'], 'forcecontent' => false)
        response = {}
        response[:identifier] = response_hash['license']['identifier']
        response[:previous_identifier] = response_hash['license']['previous_identifier'] || []
        response
      end

      handle :change_password, :use_post => true

      # Returns a boolean
      def is_authenticated?(options)
        auth = RosettaStone::ActiveLicensing::Base.instance.license.authenticate(options)
        auth.nil? ? false : auth.rubyize["authentication"]
      end

      def creation_account_identifier_for(license_identifier)
        details(:license => license_identifier).rubyize['creation_account_identifier']
      rescue RosettaStone::ActiveLicensing::LicenseNotFound
        nil
      end

      # basically a wrapper around create_osub, since it's not obvious that an empty array means "with no product rights"
      def create_osub_with_no_product_rights(license_name, license_password, test = false, guid = nil)
        create_osub(license_name, license_password, [], test, guid)
      end

      # returns the multicall response (as an array of hashes) or raises RosettaStone::ActiveLicensing::LicenseServerException
      #
      def create_osub(license_name, license_password, product_right_items, test = false, guid = nil)
        # In multicall mode, the API calls to the LS are queued up and do not initially return a value. Thus, this call needs to
        # be made outside the multicall block to force the local variable to have a value in the block below.
        license_exists = exists(:license => license_name)
        current_rights = (license_exists)? product_rights(:license => license_name) : []

        RosettaStone::ActiveLicensing::Base.instance.multicall do
          license_exists ?
            license.change_password(:license => license_name, :password => license_password) :
            license.add(:creation_account => "OSUBs", :license => license_name, :password => license_password, :test => test, :guid => guid)

          product_right_items.each do |product_right|
            # Adding duplicate params here to compare/merge with license.product_rights response
            # Kind of sad that request params don't match the response ones
            api_options = {'license' => license_name, 'product' => product_right.language_code,
              'product_identifier' => product_right.language_code, 'version' => product_right.app_version,
              'product_version' => product_right.app_version}

            family = (product_right.respond_to?(:family_code))? product_right.family_code : 'application'
            api_options.merge!('family' => family, 'product_family' => family)

            existing = current_rights.detect {|r| r['product_identifier'] == api_options['product'] &&
              r['product_version'] == api_options['version'] && r['product_family'] == api_options['family']}

            if existing
              license.extend_product_right(api_options.merge('offset' => "#{product_right.duration_code.to_i}m7d"))
            else
              license.add_product_right(api_options.merge('ends_at' =>
                                                          (Time.now.to_i + 7.days + product_right.duration_code.to_i.months).to_i))
              # Remember to register that we just added new right
              # Or rather that we will add it later (thanks to multicall)
              current_rights << api_options
            end
          end
        end
      end

      # accepts one of token, guid and password, license and password, or password (which is treated as a token)
      def authenticate_with(options)
        base_params = options.only(:originating_ip_address)
        if options.has_key?(:token)
          authenticate_with_token(base_params.merge(:token => options[:token]))
        elsif options.has_key?(:guid) && options.has_key?(:password)
          authenticate(base_params.merge(:guid => options[:guid], :password => options[:password]))
        elsif options.has_key?(:license) && options.has_key?(:password)
          authenticate(base_params.merge(:license => options[:license], :password => options[:password]))
        elsif options.has_key?(:password) # This is a hack. It assumes that if all we get is a password, it's actually an auth token.
          authenticate_with_token(base_params.merge(:token => options[:password]))
        else
          raise RosettaStone::ActiveLicensing::ParametersException.new("Invalid Parameters: keys: " + options.keys.inspect)
        end
      end

      # Returns details for all allocations that are associated with a given
      # end user account. From this information, allocations can be filtered
      # down (to just a single creation account or product pool) and then
      # displayed graphically or deallocated.
      #
      # Note that a license may have product access that isn't represented by
      # allocated products returned in this list (i.e., consumer-purchased
      # product access).
      #
      # OPTIONS
      #
      # guid
      #   guid of the license to get allocation details for
      #
      # On success, return an array of allocation details.
      # On failure, raises an exception:
      #   License not found
      handle :allocations, :use_standard_from_xml => true do |response_hash|
        response_hash['response']['allocations'].map(&:rubyize!)
      end

    end # License
  end # ActiveLicensing
end # RosettaStone
