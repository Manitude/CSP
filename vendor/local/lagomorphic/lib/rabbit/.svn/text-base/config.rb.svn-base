# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

class Rabbit::Config
  include RosettaStone::OverridableYamlSettings
  overridable_yaml_settings(:config_file => 'rabbit.yml', :hash_reader => false)
  cattr_accessor :all_configurations
  self.all_configurations = {}.with_indifferent_access
  #include RosettaStone::HashKeyAccessors # WHAT, you don't have to include this because it's already included in Class?!?  Gabe!
  attr_reader :name

  class << self
    def get(configuration = nil)
      # nil => default_configuration
      return default_configuration if configuration.nil?
      # accept a Rabbit::Config instance
      return configuration if configuration.is_a?(self) # RUBY!
      # accept the string 'all'
      return self.all_configurations if configuration =~ /all/i
      # accept a configuration name (as string or symbol)
      raise RuntimeError, "Invalid configuration specified: '#{configuration}'" unless self[configuration]
      self[configuration]
    end

    # convenience method for accessing the "default" connection config
    def default_configuration
      all_configurations[Framework.env]
    end

    def default_values
      {
        :user => 'guest',
        :password => 'guest',
        :host => '127.0.0.1',
        :vhost => default_vhost_name,
        :logging => false,
      }.with_indifferent_access
    end

    def default_vhost_name
      "/#{default_app_name}_#{Framework.env}"
    end

    def default_app_name
      File.basename(Framework.root)
    end

    def [](configuration_name)
      all_configurations[configuration_name]
    end
  end
  hash_key_reader(:name => :configuration_attributes, :keys => default_values.keys)

  def initialize(configuration_name)
    @configuration_attributes = klass.default_values.merge(klass.all_settings[configuration_name]) # the instance variable is used by the hash_key_reader
    @name = configuration_name
  end

  def configuration_hash(remap_password_to_pass = false)
    return @configuration_attributes.remap('password' => 'pass').to_hash.symbolize_keys if remap_password_to_pass
    @configuration_attributes.to_hash.symbolize_keys
  end

  # set up all_configurations at class load time
  all_settings.keys.each do |configuration_name|
    self.all_configurations[configuration_name] = new(configuration_name)
  end
end
