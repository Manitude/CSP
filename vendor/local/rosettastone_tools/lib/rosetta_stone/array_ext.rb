# -*- encoding : utf-8 -*-
module RosettaStone
  module ArrayExtensions
    # Used internally to make it easy to deal with optional arguments
    # (from Rubinius)
    Undefined = Object.new

    def random
      self[Kernel.rand(size)]
    end

    def average
      map {|e| e.to_f }.sum / self.size.to_f
    end

    def median
      sorted = self.sort
      if sorted.size == 0
        raise "Can't find median of empty array"
      elsif sorted.size.even?
        lower_index = sorted.size/2 - 1
        upper_index = sorted.size/2
        return [sorted[lower_index], sorted[upper_index]].average
      else
        return sorted[self.size/2]
      end
    end

    # from http://snippets.dzone.com/posts/show/4805
    def map_to_hash
      map { |e| yield e }.inject({}) { |carry, e| carry.merge! e }
    end

    def classify_to_hash(true_key = true, false_key = false, &blk)
      self.inject({ true_key => [], false_key => [] }) do |hash, el|
        key = yield(el) ? true_key : false_key
        hash[key].replace(hash[key] << el)
        hash
      end
    end

    #  irb(main):001:0> [1,2,3,4,5,6,7,8,9].sort_like([4,1,2])
    #  => [4, 1, 2, 3, 5, 6, 7, 8, 9]
    #
    #  irb(main):002:0> [1,2,2,3,4,4,4,5,6,7,8,9].sort_like([4,1,2])
    #  => [4, 4, 4, 1, 2, 2, 3, 5, 6, 7, 8, 9]
    #
    #  irb(main):003:0> [1,2,2,3,5,6,7,8,9].sort_like([4,1,2])
    #  => [1, 2, 2, 3, 5, 6, 7, 8, 9]

    def sort_like(reference_array)
      sort do |a, b|
        ai, bi = reference_array.index(a), reference_array.index(b)
        case
        when ai && bi then ai <=> bi
        when ai || bi then ai ? -1 : 1
        else a <=> b
        end
      end
    end

    # from http://flavoriffic.blogspot.com/2008/08/freezing-deep-ruby-data-structures.html
    def deep_freeze
      each { |j| j.deep_freeze if j.respond_to? :deep_freeze }
      freeze
    end

    # backport for ruby 1.8.6 (1.8.7+ have this built in).  copied from backports gem.
    def permutation(num = Undefined)
      return to_enum(:permutation, num) unless block_given?
      num = num.equal?(Undefined) ?
        size :
        Backports.coerce_to_int(num)
      return self unless (0..size).include? num

      final_lambda = lambda do |partial, remain|
        yield partial
      end

      outer_lambda = num.enum_for(:times).inject(final_lambda) do |proc, ignore|
        lambda do |partial, remain|
          remain.each_with_index do |val, i|
            new_remain = remain.dup
            new_remain.delete_at(i)
            proc.call(partial.dup << val, new_remain)
          end
        end
      end

      outer_lambda.call([], self)
    end unless method_defined? :permutation

    # backport for ruby 1.8.6 (1.8.7+ have this built in).  copied from backports gem.
    def shuffle
      dup.shuffle!
    end unless [].respond_to?(:shuffle)

    # backport for ruby 1.8.6 (1.8.7+ have this built in).  copied from backports gem.
    def shuffle!
      raise TypeError, "can't modify frozen array" if frozen?
      size.times do |i|
        r = i + Kernel.rand(size - i)
        self[i], self[r] = self[r], self[i]
      end
      self
    end unless [].respond_to?(:shuffle!)

    def pluck_uniq(&block)
      values = map(&block).uniq
      raise RuntimeError.new("Expecting at most one unique value but found #{values.size}") if values.size > 1
      values.first
    end

    def fetch_uniq(&block)
      value = pluck_uniq(&block)
      raise RuntimeError.new("Expecting not nil but was nil") if value.nil?
      value
    end
  end
end

Array.instance_eval { include RosettaStone::ArrayExtensions }
ActiveRecord::NamedScope::Scope.instance_eval { include RosettaStone::ArrayExtensions } if defined?(ActiveRecord::NamedScope) && Rails.version.to_s < '3'
