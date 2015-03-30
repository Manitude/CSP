# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

begin
  unless Framework.test?
    require 'uuidtools'
  end
rescue LoadError
  raise 'You must require the uuidtools gem in order to use this module'
end

# This file is here for two reasons:
#  * uuidtools moved everything into a module starting in version 2.0, so
#    you either use UUIDTools::UUID or UUID depending on the version in your app
#  * UUIDTools::UUID.random_create.to_s feels silly.  not that
#    RosettaStone::UUIDHelper.generate is much better, but at least that will
#    work reliably in all our apps...
module RosettaStone
  class UUIDHelper
    FORMAT_DESCRIPTION = 'Valid UUID format is XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX where each character is either a digit or a lower case letter from "a" through "f".'
    class << self
      def generate
        uuid_class.random_create.to_s
      end

      def from_hexdigest(hexdigest)
        uuid_class.parse_hexdigest(hexdigest).to_s
      end

      def to_hexdigest(guid)
        uuid_class.parse(guid).hexdigest
      end

      def uuid_class
        return UUIDTools::UUID if defined?(UUIDTools)
        return UUID if defined?(UUID)
      end

      def has_uuidtools?
        defined?(UUIDTools) || defined?(UUID)
      end

      def looks_like_guid?(guid)
        !!guid.to_s.match(/^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/)
      end

    end
  end
end

class String
  def looks_like_guid?
    RosettaStone::UUIDHelper.looks_like_guid?(self)
  end
end
