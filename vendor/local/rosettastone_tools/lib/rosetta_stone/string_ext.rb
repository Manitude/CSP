# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.

module RosettaStone
  module StringExtensions

    def zero_pad(total_digits = 2)
      sprintf("%0#{total_digits}d", self.to_i)
    end

  end
end

module RosettaStone
  module MoreStringExtensions

    def to_console_string
      ::RosettaStone::ConsoleString.new(self)
    end

    def rand(number_of_chars = 1)
      (1..number_of_chars).collect { self[Kernel.rand(self.length), 1] }.join
    end

    def remove(regexp)
      sub(regexp, '')
    end

    def remove!(regexp)
      replace(remove(regexp))
    end

    def gremove(regexp)
      gsub(regexp, '')
    end

    def gremove!(regexp)
      replace(gremove(regexp))
    end

    def cardinalize(count = 1)
      count.to_s + ' ' + ((count == 1) ? self : self.pluralize)
    end

    def substr(offset, places = nil)
      offset = length - offset.abs if offset.negative?
      offset = 0 if offset.negative? # Set the offset to the start of the string if it's still negative
      places ||= length - offset
      places = (length - places.abs) - offset if places.negative?
      slice(offset, places).to_s # Because I never want nil, I want an empty string in the cases I'd get nil back
    end

    def substr!(*args)
      replace(substr(*args))
      self
    end

    def indent(spaces)
      raise ArgumentError, "Negative indentation is not supported." if spaces < 0
      raise ArgumentError, "Don't be indentin' empty strings." if empty?
      lines.to_a.map {|str| ' ' * spaces + str }.join
    end

    def left; self[0,1] || ''; end
    def right; self[-1,1] || ''; end

    # "joe".wrap_with("()")   => "(joe)"
    # "joe".wrap_with("|")    => "|joe|"
    def wrap_with(wrapper)
      wrapper.left + self + wrapper.right
    end

    # 'UpdatedAt' => 'updatedAt'
    # wow I didn't think this would be so difficult
    def uncapitalize
      # new rails uses mb_chars, old uses chars
      character_array = respond_to?(:mb_chars) ? mb_chars : chars
      (character_array.first || '').downcase.to_s + character_array.slice(1..-1).to_s
    end

    def uncapitalize!
      replace(uncapitalize)
      self
    end

    # Backported from Ruby 1.9. See official documentation[http://ruby-doc.org/core-1.9/classes/String.html]
    def ascii_only?
      !(self =~ /[^\x00-\x7f]/)
    end unless String.method_defined? :ascii_only?

    # Backported for Ruby 1.8.6
    def lines(&block)
      return to_enum(:each_line) unless block_given?
      each_line(&block)
    end unless String.method_defined? :lines
  end
end

Object.send(:include, RosettaStone::StringExtensions)
String.send(:include, RosettaStone::MoreStringExtensions)
