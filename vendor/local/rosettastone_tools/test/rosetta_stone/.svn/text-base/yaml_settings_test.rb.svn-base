# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::YamlSettingsTest < Test::Unit::TestCase

  class NoSettingsHere
    include RosettaStone::YamlSettings
    yaml_settings(:config_file => 'settings_without_settings.yml', :root_dir => File.dirname(__FILE__))
  end

  class ReloaderTestClass
    include RosettaStone::YamlSettings
    class << self
      attr_accessor :reloader
    end
    self.reloader = yaml_settings(:config_file => 'settings_without_settings.yml', :root_dir => File.dirname(__FILE__))
  end

  class NoConfigFileNeededHere
    include RosettaStone::YamlSettings
    yaml_settings(:config_file => 'nonexistent_settings.yml', :root_dir => File.dirname(__FILE__), :required => false)
  end

  class NoConfigFileIsPresentButItIsRequired
    include RosettaStone::YamlSettings
  end

  def test_loading_empty_yaml_file_results_in_nil_settings
    assert_equal({}, NoSettingsHere.settings)
  end

  def test_no_config_file_needed
    assert_equal({}, NoConfigFileNeededHere.settings)
  end

  def test_no_config_file_is_present
    assert_raises(ArgumentError) do
      NoConfigFileIsPresentButItIsRequired.yaml_settings(:config_file => 'nonexistent_settings.yml', :root_dir => File.dirname(__FILE__))
    end
  end

  def test_use_environment_defaults_to_current_environment_if_true
    use_env_true = create_class_with_options(:config_file => 'settings_with_environment.defaults.yml', :use_environment => true, :root_dir => File.dirname(__FILE__))
    assert_equal 'default', use_env_true[:property]
  end

  def test_use_environment_when_no_stanza_for_current_environment
    Rails.stubs(:env).returns('no_stanza_by_this_name')
    use_env_true = create_class_with_options(:config_file => 'settings_with_environment.defaults.yml', :use_environment => true, :root_dir => File.dirname(__FILE__))
    assert_nil use_env_true[:property]
  end

  def test_use_environment_uses_passed_argument_if_truthy
    use_env_truthy_development = create_class_with_options(:config_file => 'settings_with_environment.defaults.yml', :use_environment => 'development', :root_dir => File.dirname(__FILE__))
    use_env_truthy_test = create_class_with_options(:config_file => 'settings_with_environment.defaults.yml', :use_environment => 'test', :root_dir => File.dirname(__FILE__))
    assert_equal 'batman', use_env_truthy_development[:property]
    assert_equal 'default', use_env_truthy_test[:property]
  end

  def test_use_environment_with_symbol
    use_env = create_class_with_options(:config_file => 'settings_with_environment.defaults.yml', :use_environment => :development, :root_dir => File.dirname(__FILE__))
    assert_equal 'batman', use_env[:property]
  end

  def test_use_environment_specifying_stanza_that_does_not_exist_in_yaml
    use_env = create_class_with_options(:config_file => 'settings_with_environment.defaults.yml', :use_environment => 'does_not_exist', :root_dir => File.dirname(__FILE__))
    assert_nil use_env[:property]
  end

  def test_use_environment_passes_through_if_false
    use_env_false = create_class_with_options(:config_file => 'settings_with_environment.defaults.yml', :use_environment => false, :root_dir => File.dirname(__FILE__))
    use_env_unset = create_class_with_options(:config_file => 'settings_with_environment.defaults.yml', :root_dir => File.dirname(__FILE__))
    assert_nil use_env_false[:property]
    assert_nil use_env_unset[:property]
  end

  def test_reloader
    assert_equal({}, ReloaderTestClass.settings)
    YAML.expects(:load_file).once.returns({'changed_value' => true})
    ReloaderTestClass.reloader.call
    assert_equal({'changed_value' => true}, ReloaderTestClass.settings)
  end

private
  def create_class_with_options(opts={})
    example_class = Class.new
    example_class.class_eval do
      include RosettaStone::YamlSettings
      yaml_settings(opts)
    end
    example_class
  end
end
