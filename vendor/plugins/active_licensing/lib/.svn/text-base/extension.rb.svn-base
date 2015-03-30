# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2009 Rosetta Stone
# License:: All rights reserved.

module RosettaStone #:nodoc:
  module ActiveLicensing #:nodoc:
    # A custom RequestAndResponseHandler for API calls in the Extension category.
    class Extension < RequestAndResponseHandler
      handle :details do |response_hash|
        response_hash['extension'].rubyize
      end

      handle :burned_between do |response_hash|
        response_hash.rubyize
      end

      handle :add do |response_hash|
        response_hash['extension'].rubyize
      end

      handle :remove_by_guid do |response_hash|
        response_hash.rubyize
      end

      handle :burn_all_by_activation_id_without_extending do |response_hash|
        response_hash.rubyize
      end

    end # ProductRight
  end # ActiveLicensing
end # RosettaStone
