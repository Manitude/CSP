require File.dirname(__FILE__) + '/test_helper'

class WhatInstanceAmITest < Test::Unit::TestCase

  def setup
    reset_instance_detection_singleton!
    mock_config!
  end

  def teardown
    reset_instance_detection_singleton!
  end

  def test_positive_detection_of_production
    mock_host! 'production1'
    assert_instance_is('production')
  end

  def test_positive_detection_of_staging
    mock_host! 'staging2'
    assert_instance_is('staging')
  end

  def test_positive_detection_with_regex
    mock_host! 'productionstandard10'
    assert_instance_is('production')
  end

  def test_strings_arent_treated_as_regex
    mock_host! 'production20'
    assert_unknown
  end

  def test_unknown_instance
    mock_host! 'unknownhost'
    assert_unknown
    assert_instance_is_not('production')
    assert_instance_is_not('staging')
    assert RosettaStone::InstanceDetection.instance_name.include?('unknownhost')
  end

  def test_cobra_instance
    mock_host! 'cobra'
    assert_instance_is('cobra')
    assert RosettaStone::InstanceDetection.instance_name.include?('cobra')

    #cobra could also be rshbgdev09... I'll revisit that later...
  end

  def test_asking_about_undefined_instance
    assert_raises(RuntimeError) do
      RosettaStone::InstanceDetection.undefined_instance?
    end

    assert_raises(NoMethodError) do
      RosettaStone::InstanceDetection.undefined_method
    end
  end

private
  def mock_host!(hostname)
    RosettaStone::InstanceDetection.any_instance.expects(:hostname).at_least_once.returns(hostname)
  end

  def mock_config!
    RosettaStone::InstanceDetection.any_instance.stubs(:known_instances_file_paths).returns([File.join(File.dirname(__FILE__), 'known_instances.yml')])
  end

  # Set up a new instance of the Singleton...  other tests may have polluted it.
  def reset_instance_detection_singleton!
    Singleton.__init__(RosettaStone::InstanceDetection)
  end

  def assert_instance_is(instance)
    assert_unknown(false)
    assert_equal(true, RosettaStone::InstanceDetection.instance_is?(instance))
    assert_equal(true, RosettaStone::InstanceDetection.send("#{instance}?".to_sym))
    assert_equal(instance, RosettaStone::InstanceDetection.instance_name)
    other_instance = (instance == 'production' ? 'staging' : 'production')
    assert_instance_is_not(other_instance)
  end

  def assert_instance_is_not(instance)
    assert_equal(false, RosettaStone::InstanceDetection.instance_is?(instance))
    assert_equal(false, RosettaStone::InstanceDetection.send("#{instance}?".to_sym))
    assert_not_equal(instance, RosettaStone::InstanceDetection.instance_name)
  end

  def assert_unknown(unknown = true)
    assert_equal(unknown, RosettaStone::InstanceDetection.unknown?)
  end
end
