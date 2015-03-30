# -*- encoding : utf-8 -*-

# FIXME: explicitly require this here because the App configuration mocks in
# community load before rosettastone_tools the plugin, apparently
require 'framework_module'

module RosettaStone #:nodoc:
  # A mixin to add the ability to load configuration options from a default & overriding YAML file.
  module OverridableYamlSettings

    def self.included(target_class)
      target_class.send(:include, RosettaStone::YamlSettings)
      target_class.extend(ClassMethods)
    end

    module ClassMethods #:nodoc:
      # Attempts to find and read the default config file specified by the :config_file option
      # and will override any settings there with settings in the normal yml file.
      # This should be a YAML file that lives in RAILS_ROOT/config. If not passed,
      # this attempts to default to the class name, pluralized and underscored.
      #
      # Ex:
      # config/settings.yml
      # config/settings.defaults.yml
      #
      # The settings in settings.yml will supercede the settings in settings.defaults.yml
      # and the settings.yml is not required.  If there is no settings.yml, then
      # it will just use the defaults.
      #
      # Possible options:
      # :deep_merge => if set to true, performs a deep merge of the override file settings on
      #                top of the default settings. If set to false, performs a shallow merge.
      #                For instance, if the default settings provide {:a => {:b => :c}} and the
      #                override settings provide {:a => {:d => :e}}, setting :deep_merge to
      #                true results in the final settings (accessible by .all_settings or by
      #                the accessors) being {:a => {:b => :c, :d => :e}}, and setting
      #                :deep_merge to false results in the final settings being {:a => {:d => :e}}.
      # :config_file => the file to read the config from.  If none is set, then the class will
      #                 be pluralized and underscored, and a .defaults.yml will be looked for
      # :hash_reader => if set to false, then you will not be able to access a setting by saying
      #                 ClassName[:site_setting].  By default, you can access the setting this way
      # :method_access => if set to false, then you will not be able to access a setting by saying
      #                   ClassName.site_setting.  By default, you can access the setting this way
      # :use_environment => if set to true, uses the current Rails environment (Rails.env) to browse
      #                     the yaml configuration files. You can also set :use_environment to a
      #                     particular string or symbol to use that as a namespace instead. This way,
      #                     your config files can look like this:
      #
      #                     development:
      #                       host: '127.0.0.1'
      #                     production:
      #                       host: 'api.rosettastone.com'
      #
      #                     Then you can access it through the following:
      #
      #                     class App
      #                       overridable_yaml_settings(:use_environment => true)
      #                       # also possible to use a specific environment
      #                       # overridable_yaml_settings(:use_environment => 'production')
      #                     end
      #
      #                     # in development environment
      #                     App.host # => '127.0.0.1'
      #
      #                     # in production environment
      #                     App.host # => 'api.rosettastone.com'
      #
      # :require_defaults => whether an exception should be raised if the defaults configuration file
      #                      cannot be found. by default, this is set to true.
      # :defaults_root_dir => the root dir where the defaults.yml file is.  This defaults to
      #                       Rails.root, but may make more sense to be in a plugin dir, for instance
      # :expiry_in_seconds => the maximum age (in seconds) of cached information from the overriding
      #                       YAML file.  omitting this option (or setting it to nil or 0) will mean that
      #                       the overriding YAML file is read once (at class load time) and will never
      #                       reread it.  setting this to a value of N seconds triggers a reload of
      #                       that YAML file if it was last read more than N seconds ago.   setting this
      #                       to -1 (not recommended) would trigger a reload upon every access.
      def overridable_yaml_settings(opts={})
        @options = opts

        opts[:config_file] ||= self.to_s.pluralize.underscore
        base_name = opts[:config_file].sub(/\.yml$/,'').sub(/\.defaults$/,'')
        overriding_file_name = "#{base_name}.yml"

        opts[:defaults_root_dir] ||= Framework.root
        require_defaults = opts[:require_defaults].nil? ? true : opts[:require_defaults]

        # Create this accessor to make error handling a little nicer
        self.cattr_accessor :default_settings_file_name
        self.default_settings_file_name = "#{base_name}.defaults.yml"
        self.cattr_accessor :use_method_access
        self.use_method_access = !(opts[:method_access] == false)
        self.cattr_accessor :use_hash_reader
        self.use_hash_reader = !(opts[:hash_reader] == false)
        self.cattr_accessor :overridable_yaml_settings_expiry_in_seconds
        self.overridable_yaml_settings_expiry_in_seconds = opts[:expiry_in_seconds].to_i
        self.cattr_accessor :timestamp_when_overridable_yaml_settings_were_last_loaded
        self.timestamp_when_overridable_yaml_settings_were_last_loaded = Time.now

        @overridable_yaml_settings_reloader = yaml_settings(opts.merge(:config_file => overriding_file_name, :required => false, :hash_reader => false, :use_environment => opts[:use_environment]))
        yaml_settings(opts.merge(:config_file => default_settings_file_name, :root_dir => opts[:defaults_root_dir], :required => require_defaults, :hash_reader => false, :accessor => :default_settings, :use_environment => opts[:use_environment]))
        private_class_method :settings, :settings=, :default_settings, :default_settings=
        remerge_all_settings!
      end

      def reload_overridable_yaml_settings!
        raise "You must first call overridable_yaml_settings()" unless @overridable_yaml_settings_reloader
        @overridable_yaml_settings_reloader.call
        self.timestamp_when_overridable_yaml_settings_were_last_loaded = Time.now
        remerge_all_settings!
      end

      # the hash key accessor returns nil upon accessing a nonexistent key
      def [](param)
        return super unless use_hash_reader
        begin
          preferred_setting(param)
        rescue NoMethodError
          nil
        end
      end

      def method_missing(meth, *args)
        return super unless use_method_access
        preferred_setting(meth)
      rescue NoMethodError => no_method_exception
        return super if respond_to?(meth)
        raise no_method_exception
      end

      def respond_to?(meth)
        default_response = super
        return default_response if default_response == true || !use_method_access
        preferred_setting(meth)
        true
      rescue NoMethodError
        false
      end

      def all_settings
        reload_overridable_yaml_settings_if_necessary!
        @all_settings
      end

      # this will return false if you do not have the "overriding" file or if it is empty
      def has_any_overridden_settings?
        settings && settings.any?
      end

      private
      def preferred_setting(setting_name)
        if all_settings.has_key?(setting_name)
          all_settings[setting_name]
        else
          raise NoMethodError, "undefined method or setting `#{setting_name}' for #{self.to_s}:Class.  Perhaps your #{default_settings_file_name} needs a key for `#{setting_name}'?"
        end
      end

      # caches the merged settings so we don't have to recalculate the (deep_)merge repeatedly
      def remerge_all_settings!
        # the to_hash calls are because HashWithIndifferentAccess has borked #deep_merge support
        if @options[:deep_merge]
          @all_settings = default_settings.to_hash.deep_merge(settings.to_hash).with_indifferent_access
        else
          @all_settings = default_settings.merge(settings)
        end
      end

      def reload_overridable_yaml_settings_if_necessary!
        reload_overridable_yaml_settings! if overridable_yaml_settings_expired?
      end

      def overridable_yaml_settings_expired?
        return false if overridable_yaml_settings_expiry_in_seconds == 0 # 0 means reloading is disabled
        timestamp_when_overridable_yaml_settings_were_last_loaded < overridable_yaml_settings_expiry_in_seconds.seconds.ago
      end
    end # ClassMethods
  end # YamlSettings
end # RosettaStone
