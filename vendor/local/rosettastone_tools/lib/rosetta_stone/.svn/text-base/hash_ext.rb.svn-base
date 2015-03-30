# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.

module RosettaStone
  module HashExtensions
    def extract_keys(*keys)
      new_hash = {}
      keys.each { |key| new_hash[key] = self[key] }
      new_hash
    end

    # http://pastie.caboo.se/10707
    # Usage { :a => 1, :b => 2, :c => 3}.except(:a) -> { :b => 2, :c => 3}
    def except(*keys)
      keys = keys.dup.map(&:to_sym)
      self.reject do |k,v|
        keys.include? k.to_sym
      end
    end

    # Usage { :a => 1, :b => 2, :c => 3}.only(:a) -> {:a => 1}
    def only(*keys)
      keys = keys.dup.map(&:to_sym)
      self.reject do |k,v|
        !keys.include? k.to_sym
      end
    end

    # remove keys with nil values
    def compact
      delete_if { |key, value| value.nil? }
    end

    # Usage {:a => 1, :b => 2}.remap(:a => :c, :b => :d)
    #       # => {:c => 1, :d => 1}
    def remap(remap_hash = {})
      inject({}) do |h,(k,v)|
        nk = (block_given?) ? yield(k) : remap_hash[k]
        nk ? h[nk] = v : h[k] = v
        h
      end
    end

    def downcased_keys
      self.inject({}) {|hash,item| hash.merge({item.first.to_s.downcase => item.last})}
    end

    def map_to_hash
      map { |k,v| yield(k,v) }.inject({}) { |carry, h| carry.merge! h }
    end

    # .dup and .clone on a hash don't actually clone objects at the second (and deeper) level
    # of the hash.  this is inefficient but effective.
    def deep_copy
      Marshal.load(Marshal.dump(self))
    end

    # from http://flavoriffic.blogspot.com/2008/08/freezing-deep-ruby-data-structures.html
    def deep_freeze
      each { |k,v| v.deep_freeze if v.respond_to? :deep_freeze }
      freeze
    end

    def deep_symbolize_keys
      inject({}) { |result, (key, value)|
        value = value.deep_symbolize_keys if value.is_a? Hash
        result[(key.to_sym rescue key) || key] = value
        result
      }
    end

    def deep_stringify_keys
      inject({}) { |result, (key, value)|
        value = value.deep_stringify_keys if value.is_a? Hash
        result[(key.to_s rescue key) || key] = value
        result
      }
    end

    def deep_flatten(delimiter = "/")
      inject({}) { |result, (key, value)|
        if value.is_a? Hash
          sub_hashed = value.deep_flatten(delimiter)
          sub_hashed.keys.each do |skey|
            result["#{key}#{delimiter}#{skey}"] = sub_hashed[skey]
          end
          result
        else
          result[key] = value
          result
        end
      }
    end

    def harvest_values(search_key)
      inject([]) do |result, (key, value)|
        result << value.harvest_values(search_key) if value.is_a? Hash
        result << value if key.to_sym == search_key
        result
      end.if_hot(&:flatten)
    end

    def filter_parameters(*filter_words)
      parameter_filter = Regexp.new(filter_words.map(&:to_s).join('|'), true) if filter_words.length > 0
      filtered_parameters = {}
      self.each do |key, value|
       if key.to_s =~ parameter_filter
          filtered_parameters[key] = '[FILTERED]'
        elsif value.is_a?(Hash)
          filtered_parameters[key] = value.filter_parameters(*filter_words)
        elsif value.is_a?(Array)
          filtered_parameters[key] = value.map do |item|
            case item
            when Hash, Array
              item.filter_parameters(*filter_words)
            else
              item
            end
          end
        else
          filtered_parameters[key] = value
        end
      end

      filtered_parameters
    end

  end
end
Hash.send(:include, RosettaStone::HashExtensions)
HashWithIndifferentAccess.send(:include, RosettaStone::HashExtensions)
