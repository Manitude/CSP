# -*- encoding : utf-8 -*-
module RosettaStone
  module ActiveLicensing
    class ProductRightHash < Hash

      # This provides support for:
      # def is_rs2?
      # def is_rs3?
      # def is_application?
      # def is_eschool?
      # def is_premium_community?
      # def is_lotus?
      # etc.
      def method_missing(meth, *args, &blk)
        if (match_data = /is_(.*)\?/.match(meth.to_s))
          match_data[1].starts_with?('rs') ?
            self['product_version'] == match_data[1][2,1] :
            self['product_family'] == match_data[1]
        else
          super
        end
      end

      def is_reflex?
        is_lotus?
      end

      def is_eschool_compatible?
        is_eschool? || is_lotus?
      end

      def is_rs2_application?
        is_rs2? && is_application?
      end

      def is_rs3_application?
        is_rs3? && is_application?
      end

      def allows_unit?(unit)
        return true if self['content_ranges'] == ['all']
        return !!self['content_ranges'].detect do |content_range|
          (content_range['min_unit'].to_i..content_range['max_unit'].to_i).include?(unit)
        end
      end

      def allows_level?(level)
        return true if self['content_ranges'] == ['all']
        units = CurriculumPoint.unit_range_from_level(level).to_a
        (units - units_allowed).empty?
      end

      def units_allowed
        self['content_ranges'].collect {|content_range| (content_range['min_unit'].to_i..content_range['max_unit'].to_i).to_a }.flatten.uniq.sort
      end

      def nested_under_indifferent_access
        self
      end
    end
  end
end
