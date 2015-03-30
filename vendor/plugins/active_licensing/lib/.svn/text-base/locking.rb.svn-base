# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2012 Rosetta Stone
# License:: All rights reserved.

module RosettaStone #:nodoc:
  module ActiveLicensing #:nodoc:
    # A custom RequestAndResponseHandler for API calls in the Locking category.
    class Locking < RequestAndResponseHandler
      handle :access_request do |response_hash|
        response_hash.rubyize['access_request']
      end

      handle :continuation do |response_hash|
        response_hash.rubyize['message']
      end

      handle :termination do |response_hash|
        response_hash.rubyize['message']
      end
    end
  end
end
