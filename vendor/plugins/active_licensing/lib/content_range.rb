# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2009 Rosetta Stone
# License:: All rights reserved.

module RosettaStone #:nodoc:
  module ActiveLicensing #:nodoc:
    # A custom RequestAndResponseHandler for API calls in the ProductRight category.
    class ContentRange < RequestAndResponseHandler

      handle :remove_all_by_activation_id do |response_hash|
        response_hash.rubyize
      end

      # Returns a hash of CR attributes
      # extra error-handing added in work item 23781
      handle :details do |response_hash|
        original_response_hash = response_hash.dup
        response_hash.reparse_with_options!('forcearray' => false, 'forcecontent' => false)
        cr_value = response_hash['content_range']
        if cr_value
          cr_value.rubyize
        else
          raise "Error parsing response from ls_api.content_range.details: license_value: #{cr_value.inspect}: original_response_hash: #{original_response_hash.inspect}. reparsed response_hash: #{response_hash.inspect}"
        end
      end

    end # ContentRange
  end # ActiveLicensing
end # RosettaStone
