# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2011 Rosetta Stone
# License:: All rights reserved.

module RosettaStone
  # extending string class instead of reopening because of
  # the convenience methods; don't want to spam on String itself,
  # but for those who don't mind, you can just run the following:
  #     class String; include ::RosettaStone::ConsoleStringInstaceMethods; end
  class ConsoleString < String
    def self.color_codes
      {
        :bold => 1,
        :red => 31,
        :green => 32,
        :yellow => 33,
        :blue => 34,
        :purple => 35
      }
    end

    def self.colors
      color_codes.inject({}) do |h, (k,v)|
        h[k] = "\e[#{v}m"
        h
      end
    end

    module InstanceMethods
      ConsoleString.colors.each do |color, code|
        define_method(color) do
          colorize(code)
        end
        define_method(:"#{color}!") do
          colorize!(code)
        end
      end

      def colorize(code)
        dup.colorize!(code)
      end

      def colorize!(code)
        replace "#{code}#{to_s}\e[0m"
      end
    end

    include InstanceMethods
  end
end
