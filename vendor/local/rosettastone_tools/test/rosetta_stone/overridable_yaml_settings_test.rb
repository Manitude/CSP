# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::OverridableYamlSettingsTest < Test::Unit::TestCase

  def setup
    mocha_setup # ensure mocha is ready, even for rspec apps
    Rails.stubs(:root).returns(File.dirname(__FILE__))
  end

  def teardown
    mocha_teardown # ensure mocha is cleaned up, even for rspec apps
  end

  def test_that_settings_and_default_settings_are_private
    example_class = create_class_with_options(:config_file => 'settings')
    %w(settings settings= default_settings default_settings=).each do |meth|
      assert_false(example_class.respond_to?(meth))
      assert_true(example_class.private_methods.map(&:to_s).include?(meth))
    end
  end

  def test_normal_override
    example_class = create_class_with_options(:config_file => 'settings')
    assert_true example_class[:overridden]
    assert_true example_class.overridden
    assert_true example_class.respond_to?(:overridden)
    assert_false example_class.respond_to?(:fake_function)
  end

  def test_override_with_no_hash_reader
    example_class = create_class_with_options(:config_file => 'settings', :hash_reader => false)
    assert_raise(NoMethodError){example_class[:overridden]}
    assert_true example_class.overridden
  end

  def test_override_with_no_method_access
    example_class = create_class_with_options(:config_file => 'settings', :method_access => false)
    assert_true example_class[:overridden]
    assert_raise(NoMethodError){example_class.overridden}
  end

  def test_override_with_no_method_access_and_no_hash_reader
    example_class = create_class_with_options(:config_file => 'settings', :method_access => false, :hash_reader => false)
    assert_raise(NoMethodError){example_class[:overridden]}
    assert_raise(NoMethodError){example_class.overridden}
    assert_true example_class.all_settings[:overridden]
    assert_false example_class.respond_to?(:overridden)
  end

  def test_settings_without_defaults_fatal_errors
    assert_raise(ArgumentError) do
      example_class = create_class_with_options(:config_file => 'settings_without_defaults_file')
    end
  end

  def test_settings_without_defaults_does_not_fatal_error_with_no_require_defaults_file
    assert_nothing_raised do
      example_class = create_class_with_options(:config_file => 'settings_without_defaults_file', :require_defaults => false)
      assert_equal 'bar', example_class.foo
    end
  end

  def test_no_override_normal
    example_class = create_class_with_options(:config_file => 'settings_without_override')
    assert_equal false, example_class[:overridden]
    assert_equal false, example_class.overridden
  end

  def test_non_nonexistent_file_throws_error
    assert_raise(ArgumentError){create_class_with_options(:config_file => 'not_a_file')}
  end

  def test_different_file_names
    example_class = create_class_with_options(:config_file => 'settings')
    assert_true example_class.overridden
    example_class = create_class_with_options(:config_file => 'settings.yml')
    assert_true example_class.overridden
    example_class = create_class_with_options(:config_file => 'settings.defaults.yml')
    assert_true example_class.overridden
  end

  def test_non_root_defaults_file
    #Even though we're mocking rails root to be nonexistent, we should still
    #be able to pick up the defaults yml
    Rails.stubs(:root).at_least_once.returns('/tmp')
    example_class = create_class_with_options(:config_file => 'settings', :defaults_root_dir => File.dirname(__FILE__))
    assert_false example_class.overridden
  end

  def test_all_settings_with_no_override
    example_class = create_class_with_options(:config_file => 'settings_without_override')
    all_settings = example_class.all_settings
    assert_true(all_settings.is_a?(Hash))
    assert_equal(1, all_settings.keys.size)
    assert_false(all_settings[:overridden])
    assert_false(example_class.has_any_overridden_settings?)
  end

  def test_all_settings_with_override
    example_class = create_class_with_options(:config_file => 'settings', :hash_reader => false)
    all_settings = example_class.all_settings
    assert_true(all_settings.is_a?(Hash))
    assert_equal(2, all_settings.keys.size)
    assert_true(all_settings[:overridden])
    assert_true(example_class.has_any_overridden_settings?)
  end

  def test_all_settings_is_with_indifferent_access
    example_class = create_class_with_options(:config_file => 'settings', :hash_reader => false)
    assert_true(example_class.all_settings['overridden'])
    assert_true(example_class.all_settings[:overridden])
  end

  def test_reloading_config
    example_class = create_class_with_options(:config_file => 'settings', :hash_reader => false)
    assert_true(example_class.all_settings['overridden'])
    YAML.expects(:load_file).once.returns({'changed_after_reload' => true})
    example_class.reload_overridable_yaml_settings!
    assert_true(example_class.all_settings['changed_after_reload'])
    assert_false(example_class.all_settings['overridden'])
  end

  def test_various_ways_to_disable_expiry
    no_expiry_option = create_class_with_options(:config_file => 'settings')
    assert_equal(0, no_expiry_option.overridable_yaml_settings_expiry_in_seconds)
    expiry_option_nil = create_class_with_options(:config_file => 'settings', :expiry_in_seconds => nil)
    assert_equal(0, expiry_option_nil.overridable_yaml_settings_expiry_in_seconds)
    expiry_option_zero = create_class_with_options(:config_file => 'settings', :expiry_in_seconds => 0)
    assert_equal(0, expiry_option_zero.overridable_yaml_settings_expiry_in_seconds)
  end

  def test_various_ways_to_enable_expiry
    with_an_integer = create_class_with_options(:config_file => 'settings', :expiry_in_seconds => 2400)
    assert_equal(2400, with_an_integer.overridable_yaml_settings_expiry_in_seconds)
    with_a_string = create_class_with_options(:config_file => 'settings', :expiry_in_seconds => '100')
    assert_equal(100, with_a_string.overridable_yaml_settings_expiry_in_seconds)
    with_a_negative_integer = create_class_with_options(:config_file => 'settings', :expiry_in_seconds => -1)
    assert_equal(-1, with_a_negative_integer.overridable_yaml_settings_expiry_in_seconds)
  end

  def test_does_not_expire_when_expiry_is_disabled
    no_expiry = create_class_with_options(:config_file => 'settings')
    # fake that it was loaded a long time ago:
    no_expiry.timestamp_when_overridable_yaml_settings_were_last_loaded = 2.days.ago
    assert_false(no_expiry.send(:overridable_yaml_settings_expired?))
    no_expiry.expects(:reload_overridable_yaml_settings!).never
    assert_true no_expiry[:overridden]
  end

  def test_does_not_reload_when_not_expired
    with_expiry = create_class_with_options(:config_file => 'settings', :expiry_in_seconds => 3600)
    with_expiry.expects(:reload_overridable_yaml_settings!).never
    assert_true with_expiry[:overridden]
    assert_true with_expiry[:overridden]
  end

  def test_reloads_when_expired
    with_expiry = create_class_with_options(:config_file => 'settings', :expiry_in_seconds => 3600)
    with_expiry.timestamp_when_overridable_yaml_settings_were_last_loaded = 2.days.ago
    # ensure that the timestamp got updated
    assert_true with_expiry[:overridden]
    assert_true with_expiry.timestamp_when_overridable_yaml_settings_were_last_loaded > 5.seconds.ago
    with_expiry.expects(:reload_overridable_yaml_settings!).never # doesn't reload again
    assert_true with_expiry[:overridden]
  end

  # See config/settings.defaults.yml and config/settings.yml for schemas. In summary:
  #
  # defaults: {:deep_merge_test => {:not_overridden => 1, :overridden => 1}}
  # overrides: {:deep_merge_test => {:overridden => 2, :original => 2}}
  def test_deep_merge_not_set_defaults_to_shallow_merge
    nil_merge = create_class_with_options(:config_file => 'settings')
    assert_equal nil, nil_merge[:deep_merge_test][:not_overridden]
    assert_equal 2, nil_merge[:deep_merge_test][:overridden]
    assert_equal 2, nil_merge[:deep_merge_test][:original]
  end

  def test_deep_merge_set_to_false_results_in_shallow_merge
    shallow_merge = create_class_with_options(:config_file => 'settings', :deep_merge => false)
    assert_equal nil, shallow_merge[:deep_merge_test][:not_overridden]
    assert_equal 2, shallow_merge[:deep_merge_test][:overridden]
    assert_equal 2, shallow_merge[:deep_merge_test][:original]
  end

  def test_deep_merge_set_to_true_results_in_deep_merge
    deep_merge = create_class_with_options(:config_file => 'settings', :deep_merge => true)
    assert_equal 1, deep_merge[:deep_merge_test][:not_overridden]
    assert_equal 2, deep_merge[:deep_merge_test][:overridden]
    assert_equal 2, deep_merge[:deep_merge_test][:original]
  end

  def test_use_environment_overrides_as_expected
    use_environment_with_override = create_class_with_options(:config_file => 'settings_with_environment', :use_environment => true)
    assert_equal 'overridden', use_environment_with_override[:property]
  end

  def test_use_environment_overrides_with_deep_merge_as_expected
    use_environment_with_override_with_deep_merge = create_class_with_options(:config_file => 'settings_with_environment', :use_environment => true, :deep_merge => true)
    assert_equal 'overridden', use_environment_with_override_with_deep_merge[:property]
    assert_equal 'default', use_environment_with_override_with_deep_merge[:property_not_overridden]
  end

  def test_use_environment_without_environment_specified_in_override
    Rails.stubs(:env).returns('not_overridden')
    use_environment_with_override = create_class_with_options(:config_file => 'settings_with_environment', :use_environment => true)
    assert_equal 'spongebob', use_environment_with_override[:not_overridden_property]
  end

  def test_hash_key_accessor_returns_nil_on_nonexistent_key
    example_class = create_class_with_options(:config_file => 'settings')
    assert_nil example_class['nonexistent_key']
  end

private

  def create_class_with_options(opts={})
    example_class = Class.new
    example_class.class_eval do
      include RosettaStone::OverridableYamlSettings
      overridable_yaml_settings(opts)
    end
    example_class
  end
end
