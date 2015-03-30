#!/usr/bin/env ruby

require 'test/unit'
require 'ruby-prof'

# test for http://redmine.ruby-lang.org/issues/show/3660 and others that show 1.9.1 not having correct return methods..

class SingletonTest < Test::Unit::TestCase
  def test_singleton
    result = RubyProf.profile do
      a = [1,2,3]
      a.each{ |n|
      }
    end
    printer = RubyProf::FlatPrinter.new(result)
    output = ENV['SHOW_RUBY_PROF_PRINTER_OUTPUT'] == "1" ? STDOUT : ''
    output = STDOUT
    printer.print(output)
  end
end
