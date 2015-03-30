# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.

# Somewhat like http://eigenclass.org/hiki.rb?Rename+and+reject+methods+from+included+modules, but
# I want different behaviour. I don't want to have to exclude things, I'd rather specify things from
# a module to pull in.
require 'rosetta_stone/object_ext'

module RosettaStone
  module ClassExtensions
  private
    # Extracts specified methods from a module rather than including the entire thing.
    # Example usage:
    #
    #   class Foo
    #     extract_from_module Enumerable, :methods => [:find_all, :sort]
    #   end
    #
    # Only `find_all` and `sort` will be pulled into Foo as instance methods.
    def extract_from_module(mod, options = {})
      new_mod = RosettaStone::ModuleExtraction.extract(mod, options)
      include new_mod
    end
  end
end

module RosettaStone
  module HashArgumentHelpers
    def verify_args(hash, *keys)
      raise(ArgumentError, "verify_args can only be used against an object that responds to .has_key?.") unless hash.respond_to?(:has_key?)
      keys.each { |key| raise(ArgumentError, "Argument list must contain key '#{key}'.") unless hash.has_key?(key) }
    end
  end
end

module RosettaStone
  module HashKeyAccessors

    def hash_key_accessor(*args)
      hash_key_reader(*args)
      hash_key_writer(*args)
    end

    def hash_key_reader(options = {})
      verify_args options, :name, :keys
      hash_name, keys = options[:name], options[:keys]
      make_accessor_public = options[:public]

      define_method(hash_name) do
        instance_variable_get(:"@#{hash_name}") || instance_variable_set(:"@#{hash_name}", {})
      end

      if !make_accessor_public
        private hash_name
      end

      keys.each do |key|
        define_method(key) { send(hash_name)[key.to_sym] }
      end
    end

    def hash_key_writer(options = {})
      verify_args options, :name, :keys
      hash_name, keys = options[:name], options[:keys]
      keys.each do |key|
        define_method(:"#{key}=") do |value|
          (instance_variable_get(:"@#{hash_name}") || instance_variable_set(:"@#{hash_name}", {}))[key.to_sym] = value
        end
      end
    end

  end
end

module RosettaStone
  module ModuleExtraction

    # Extracts instance methods from a module and returns them in an anonymous module.
    def self.extract(mod, options = {})
      # One of the rare cases where duck typing be damned! I really do want a Module.
      raise ArgumentError, "'#{mod.inspect}' is not a Module." unless mod.class == Module
      raise ArgumentError, "At least one method must be specified in option :methods" if options[:methods].nil? || (options[:methods].is_a?(Array) && options[:methods].empty?)
      methods = options[:methods].is_a?(Array) ? options[:methods] : [options[:methods]]
      check_methods(mod, methods)
      anon_mod = create_anonymous_module(mod, methods)
      anon_mod
    end

  private
    # Checks that the methods specified to be extracted are in fact defined in the module provided. This means they must
    # actually be defined in that module, and not have ended up in there by way of the inclusion of another module. e.g.
    #
    #   module Foo
    #    def bar; return 'bar'; end
    #   end
    #
    #   module Baz
    #     include Foo
    #     def snafu; return 'snafu'; end
    #   end
    #
    # In this case, `extract_from_module Baz, :methods => :bar` would raise an exception. This is a ruby limitation that
    # may be worked around later if necessary.
    def self.check_methods(mod, methods)
      module_methods = (mod.public_instance_methods(false) + mod.private_instance_methods(false) + mod.protected_instance_methods(false)).flatten.map(&:to_s)
      methods.each do |method_name|
        raise ArgumentError, "Method '#{method_name}' doesn't exist in #{mod.inspect}" unless module_methods.include?(method_name.to_s)
      end
    end

    # Changes the 'inspect' method on the anonymous module so that it shows what it was extracted from originally. I may
    # just extend Module and return my custom Module class with a redefined inspect rather than doing this in the future.
    def self.fix_inspect!(parent, new_mod)
      inspect_string = "Module extracted from #{parent.inspect}"
      new_mod.singleton_class.send(:define_method, :inspect) { inspect_string }
    end

    # Creates an anonymous module by duplicating the specified module, removes any unwanted methods, and fixes the inspect string.
    def self.create_anonymous_module(parent, methods_to_keep)
      mod = parent.dup
      remove_unwanted_methods!(mod, methods_to_keep)
      fix_inspect!(parent, mod)
      mod
    end

    # Iterates through the methods defined in the module and removes them all if they aren't present in methods_to_keep.
    def self.remove_unwanted_methods!(mod, methods_to_keep)
      mod_methods = (mod.public_instance_methods(false) + mod.private_instance_methods(false) + mod.protected_instance_methods(false)).flatten.map(&:to_s)
      (mod_methods - methods_to_keep.map(&:to_s)).each { |method_name| mod.send(:remove_method, method_name) }
    end

  end
end

Class.send(:include, RosettaStone::ClassExtensions)
Class.send(:include, RosettaStone::HashKeyAccessors)
Object.send(:include, RosettaStone::HashArgumentHelpers)
