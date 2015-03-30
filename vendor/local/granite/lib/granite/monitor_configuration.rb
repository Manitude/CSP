class Granite::MonitorConfiguration
  include RosettaStone::OverridableYamlSettings

  plugin_path = File.join('vendor', 'plugins', 'granite', 'config')
  gem_path = File.join('vendor', 'gems', 'granite', 'config')
  config_path = File.exists?(plugin_path) ? plugin_path : gem_path
  # path for overridable_yaml_settings is relative to RAILS_ROOT/config
  overridable_yaml_settings(:config_file => File.join('..', config_path, 'granite_monitor'), :hash_reader => false)
end
