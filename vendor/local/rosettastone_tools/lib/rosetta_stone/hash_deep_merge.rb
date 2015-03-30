# a backport of hash deep merge for Rails < 2.3
# Implementation copied from the ActiveSupport 3 library
module RosettaStone
  module HashDeepMerge

    def deep_merge!(other_hash)
      other_hash.each_pair do |k,v|
        tv = self[k]
        self[k] = tv.is_a?(Hash) && v.is_a?(Hash) ? tv.deep_merge(v) : v
      end
      self
    end

    def deep_merge(other_hash)
      dup.deep_merge!(other_hash)
    end

  end
end

unless Hash.instance_methods.include?(:deep_merge)
  Hash.send(:include, RosettaStone::HashDeepMerge)
end
