# -*- encoding : utf-8 -*-

# lame, but this doesn't get auto-required in 2.x it seems
require 'active_support/version'

module RosettaStone
  class VersionString
    if ActiveSupport::VERSION::MAJOR > 3 || (ActiveSupport::VERSION::MAJOR == 3 && ActiveSupport::VERSION::MINOR > 0)
      class_attribute :part_names
    else
      class_inheritable_array :part_names
    end
    self.part_names = [:major, :minor, :patch_level]
    include Comparable

    def initialize(*args)
      if args.first.is_a?(Hash)
        version_hash = args.first.with_indifferent_access
        part_names.each do |name|
          instance_variable_set("@#{name}".to_sym, version_hash[name].to_i)
        end
      else
        part_names.each_with_index do |name, index|
          instance_variable_set("@#{name}".to_sym, args[index].to_i)
        end
      end
    end

    def <=>(other)
      part_names.each do |name|
        comp = (send(name) <=> other.send(name))
        return comp if comp != 0
      end
      return 0
    end

    def to_s
      part_names.collect { |pn| send(pn) }.join('.')
    end

    def inspect
      super + " <String: #{to_s}>"
    end

    def to_hash
      part_names.map_to_hash {|part_name| {part_name => send(part_name)} }
    end

    def method_missing(sym, *args, &block)
      part_names.include?(sym) ? instance_variable_get(:"@#{sym}") : super
    end

    def respond_to?(sym)
      return true if part_names.include?(sym)
      super
    end
  end
end

# shortcut that can be used when comparing Rails versions
RosettaStone::RailsVersionString = RosettaStone::VersionString.new(Rails::VERSION::MAJOR, Rails::VERSION::MINOR, Rails::VERSION::TINY) if defined?(Rails)
