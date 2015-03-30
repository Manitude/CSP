# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2012 Rosetta Stone
# License:: All rights reserved.

module RosettaStone #:nodoc:
  module ActiveLicensing #:nodoc:
    # A custom RequestAndResponseHandler for API calls in the Consumable category.
    class Consumable < RequestAndResponseHandler
      handle :details do |response_hash|
        response_hash['consumable'].rubyize
      end

      handle :change_expires_at do |response_hash|
        response_hash['consumable'].rubyize
      end

      handle :add do |response_hash|
        if response_hash['consumable']
          response_hash['consumable'].rubyize
        else
          response_hash.reparse_with_options!('forcearray' => ['consumable'], 'forcecontent' => false)
          consumables = response_hash['consumables']['consumable'] || []
          consumables.map(&:rubyize!)
        end
      end

    end # Consumable
  end # ActiveLicensing
end # RosettaStone
