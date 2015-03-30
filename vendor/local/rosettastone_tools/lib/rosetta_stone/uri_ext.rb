# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.

module RosettaStone
  module UriModuleExtensions
    def valid?(uri_string)
      parse(uri_string) && true
    rescue URI::InvalidURIError
      return false
    end

    def valid_and_fully_specified?(uri_string)
      valid?(uri_string) && !parse(uri_string).host.blank?
    end
  end
end

URI.send(:extend, RosettaStone::UriModuleExtensions)
