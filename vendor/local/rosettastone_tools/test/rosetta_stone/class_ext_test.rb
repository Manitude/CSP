# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::HashArgumentHelperTest < Test::Unit::TestCase

  class SomeTestClass
    def some_instance_method(args = {})
      verify_args args, :one, :two, :three
      return args
    end

    def self.some_class_method(args = {})
      verify_args args, :one, :two, :three
      return args
    end
  end

  module SomeTestModule
    def self.some_module_method(args = {})
      verify_args args, :one, :two, :three
      return args
    end
  end

  def test_key_checking
    # Tests the key checking
    arg_error = nil
    test_instance = SomeTestClass.new
    assert_raises(ArgumentError) do
      begin
        test_instance.some_instance_method(:one => 'word', :two => 'up')
      rescue ArgumentError => arg_error
        raise arg_error
      end
    end
    assert_equal "Argument list must contain key 'three'.", arg_error.message

    # Tests that keys can exist but have a nil value and still be valid.
    arg_hash = {:one => 'one', :two => 'two', :three => nil}
    assert_equal arg_hash, test_instance.some_instance_method(arg_hash)

    # Tests non-has-key objects dont work
    assert_raises(ArgumentError) do
      begin
        test_instance.some_instance_method(Object.new)
      rescue ArgumentError => arg_error
        raise arg_error
      end
    end
    assert_equal "verify_args can only be used against an object that responds to .has_key?.", arg_error.message
  end

  def test_method_works_in_all_applicable_usage_cases
    arg_hash = {:one => 'one', :two => 'two', :three => nil}
    test_instance = SomeTestClass.new

    assert_equal arg_hash, test_instance.some_instance_method(arg_hash)
    assert_equal arg_hash, SomeTestClass.some_class_method(arg_hash)
    assert_equal arg_hash, SomeTestModule.some_module_method(arg_hash)
  end

end

class RosettaStone::HashKeyAccessorTest < Test::Unit::TestCase

  class MusicBoxPlayerMachineThingWord
    hash_key_accessor :name => :dimensions, :keys => [:height, :width]
    hash_key_reader   :name => :mad_tunes,  :keys => [:greensleeves, :fur_elise]
    hash_key_writer   :name => :bad_tunes,  :keys => [:adams_song, :sk8r_boi]
  end

  def setup
    @mb = MusicBoxPlayerMachineThingWord.new
  end

  def test_accessor
    assert_equal @mb.send(:dimensions), {}
    # Should be private
    assert_raise(NoMethodError) { @mb.dimensions }
    @mb.height = 'mad high'
    @mb.width =  'mad wide'
    assert_equal @mb.height, 'mad high'
    assert_equal @mb.width, 'mad wide'
    assert_equal 2, @mb.send(:dimensions).size
  end

end

class RosettaStone::ModuleExtractionTest < Test::Unit::TestCase
  module SomeTestModule
    def foo; 'bar'; end
    def bar; 'foo'; end
  end

  module AnotherTestModule
    def foo; 'foo'; end
    def bar; 'bar'; end
    def baz; 'baz'; end
  end

  class SomeTestClass
    # To make testing easier
    public_class_method :extract_from_module
    def foo; 'nada'; end
  end

  class AnotherTestClass; public_class_method :extract_from_module; end
  class TesterClass; public_class_method :extract_from_module; end

  def test_raises_with_bad_arguments
    assert_raise(ArgumentError) { AnotherTestClass.extract_from_module('Woops', :methods => :test) }
    assert_raise(ArgumentError) { AnotherTestClass.extract_from_module(Enumerable) }
    assert_raise(ArgumentError) { AnotherTestClass.extract_from_module(Enumerable, :methods => :nonexistent) }
    assert_nothing_raised { TesterClass.extract_from_module(Enumerable, :methods => [:find_all, :include?]) }
  end

  def test_method_extraction
    AnotherTestClass.extract_from_module(AnotherTestModule, :methods => :foo)

    test_obj = AnotherTestClass.new
    assert_equal 'foo', test_obj.foo
    assert_raise(NoMethodError) { test_obj.bar }

    test_obj = SomeTestClass.new
    assert_equal 'nada', test_obj.foo

    SomeTestClass.extract_from_module(SomeTestModule, :methods => [:foo, :bar])
    test_obj = SomeTestClass.new
    assert_equal 'nada', test_obj.foo
    assert_equal 'foo', test_obj.bar

    SomeTestClass.extract_from_module(AnotherTestModule, :methods => [:foo, :bar])
    test_obj = SomeTestClass.new
    assert_equal 'nada', test_obj.foo
    assert_equal 'bar', test_obj.bar

    SomeTestClass.extract_from_module(AnotherTestModule, :methods => [:baz])
    test_obj = SomeTestClass.new
    assert_equal 'nada', test_obj.foo
    assert_equal 'bar', test_obj.bar
    assert_equal 'baz', test_obj.baz
  end

end
