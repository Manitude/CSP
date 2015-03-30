# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.

module RosettaStone #:nodoc:
  # A mixin to add the ability to load configuration option from a YAML file.
  # This only supports Hash data in your YAML file.  If you want a YAML file with an Array or something else, don't use this mixin.
  module YamlSettings
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods #:nodoc:
      # Attempts to find and read the config file specified by the :config_file option. This should be a YAML file that lives in RAILS_ROOT/config. If not passed,
      # this attempts to default to the class name, pluralized and underscored.
      def yaml_settings(opts={})
        opts[:config_file] ||= "#{to_s.pluralize.underscore}.yml"
        opts[:required] = true unless opts.has_key?(:required) # pass :required => false to have settings be an empty hash if the config file does not exist (instead of raising)
        opts[:root_dir] ||= Framework.root

        accessor_name = opts[:accessor] || :settings
        cattr_accessor accessor_name

        config_file_path = Pathname.new(File.join(opts[:root_dir], 'config', opts[:config_file]))

        config_loader = Proc.new do
          if config_file_path.cleanpath.exist?
            raw_yaml_data = YAML::load_file(config_file_path) || {}
            yaml_data =
              if opts[:use_environment] === true
                raw_yaml_data[Rails.env]
              elsif opts[:use_environment]
                raw_yaml_data[opts[:use_environment].to_s]
              else
                raw_yaml_data
              end
            send("#{accessor_name}=", (yaml_data || {}).with_indifferent_access)
          elsif opts[:required]
            raise ArgumentError, "Could not load config file: #{config_file_path.cleanpath}"
          else # not required and not found
            send("#{accessor_name}=", {}.with_indifferent_access)
          end
        end
        config_loader.call # trigger initial load of the YAML file (note that you can re-invoke this later at will)

        unless opts[:hash_reader] == false
          # Convenience method so you don't have to type Whatever.settings[:key], you can just do Whatever[:key].
          singleton_class_eval do
            define_method(:"[]") do |param|
              self.send(accessor_name)[param]
            end
          end # singleton_class_eval
        end
        # return the loader proc, which you may run .call on at any time in order to reload the YAML file
        config_loader
      end

    end # ClassMethods
  end # YamlSettings
end # RosettaStone
