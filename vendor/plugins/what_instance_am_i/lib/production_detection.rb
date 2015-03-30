# Copyright:: Copyright (c) 2008 Rosetta Stone
# License:: All rights reserved.

module RosettaStone
  module ProductionDetection
    class << self

      # This method detects if we're on a production instance.  If the instance is unknown, falls back to guessing 
      # from the Rails environment, erring on the side of defaulting to production (that way it's safer if new 
      # production boxes are added without maintaining known_instances.yml)
      #
      # ------------------
      # This method only returns false if we know for sure that we're *not* on production
      # ------------------
      def could_be_on_production?
        return true if RosettaStone::InstanceDetection.production? # positive confirmation of being on a production box
        return true if RosettaStone::InstanceDetection.preproduction? # treat pre-prod as production
        return false if !RosettaStone::InstanceDetection.unknown? # positive confirmation that we're on a non-production box
        # if we get here, we're on an unknown instance, so use the Rails environment (defaulting to production for any instance running in production mode)
        return (rails_env == 'production')
      end

      # ------------------
      # This method only returns false if we know for sure that we *are* on production
      # ------------------
      def could_be_not_on_production?
        return !(RosettaStone::InstanceDetection.production? || RosettaStone::InstanceDetection.preproduction?)
      end

      def could_be_on_staging?
        return true if RosettaStone::InstanceDetection.staging?
        return false if !RosettaStone::InstanceDetection.unknown? # positive confirmation that we're on a non-staging box
        # if we get here, we're on an unknown instance, so use the Rails environment (defaulting to true for any instance running in production mode)
        return (rails_env == 'production')
      end

      def could_be_on_production_or_staging?
        could_be_on_production? || could_be_on_staging?
      end

    private
      # putting in a method so it's mockable in tests
      def rails_env
        Rails.env
      end
    end
  end
end
