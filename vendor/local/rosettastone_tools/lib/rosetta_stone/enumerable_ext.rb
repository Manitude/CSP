# -*- encoding : utf-8 -*-
module Enumerable
  # Used internally to make it easy to deal with optional arguments
  # (from Rubinius)
  Undefined = Object.new

  #This was a new method in 1.8.7. There have been countless times where people have
  #used this in a mixed 1.8.6/7 environment, and eventually it's going to bite us, so... stop that!
  def count(item = Undefined)
    seq = 0
    if item != Undefined
      each { |o| seq += 1 if item == o }
    elsif block_given?
      each { |o| seq += 1 if yield(o) }
    else
      each { seq += 1 }
    end
    seq
  end unless method_defined? :count

  alias_method :reduce, :inject unless method_defined? :reduce

  def includes_any?(enumerable)
    raise ArgumentError, 'Argument for includes_any? must be enumerable.' unless enumerable.respond_to?(:any?)
    enumerable.any? {|member| self.include?(member)  }
  end
  alias_method :include_any?, :includes_any?

  def includes_none?(enumerable)
    !includes_any?(enumerable)
  end
  alias_method :include_none?, :includes_none?

  def includes_all?(enumerable)
    raise ArgumentError, 'Argument for includes_all? must be enumerable.' unless enumerable.respond_to?(:all?)
    enumerable.all? {|member| self.include?(member)  }
  end
  alias_method :include_all?, :includes_all?
  
  
  # A simple helper method for maping a detected value without having to carry the state required  
  # by the two separate detect and map calls:
  #
  # for example, instead of saying:
  # detected_element = enumerable.detect{ |element| <selection criteria> } 
  # result = nil
  # if detected_element
  #   result = mapping_logic(detected_element)
  # else
  #   result = default_value
  # end
  #
  # you can say:
  # result = enumerable.map_detected(default_value) do |element| 
  #   if <selection criteria> 
  #     mapping_logic(element)
  #   end
  # end
  # 
  # the latter feels a little bit cleaner 
  def map_detected(default=nil)
    raise ArgumentError, "no block provided" unless block_given?
    result = nil
    each do |element|
      break if result = yield(element)
    end
    result ? result : default
  end

  # Rails 2.3+ defines Enumerable#none? for us, so only add this method if necessary
  unless instance_methods.map(&:to_s).include?('none?')
    def none?(*args, &blk)
      !any?(*args, &blk)
    end
  end
end
