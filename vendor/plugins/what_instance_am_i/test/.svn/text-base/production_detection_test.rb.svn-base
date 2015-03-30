require File.dirname(__FILE__) + '/test_helper'

class ProductionDetectionTest < Test::Unit::TestCase

  def setup
    # ensure that we never actually load the config; that is, that all the calls are mocked 
    # in the context of these tests
    RosettaStone::InstanceDetection.any_instance.expects(:known_instances_file_paths).never
  end

  # --------------
  # could_be_on_production?
  # --------------  
  def test_not_on_production_in_test_mode_on_unknown_box
    production_and_unknown!(false, true)
    rails_env!('test')
    assert_equal(false, RosettaStone::ProductionDetection.could_be_on_production?)
  end

  def test_not_on_production_in_dev_mode_on_unknown_box
    production_and_unknown!(false, true)
    rails_env!('development')
    assert_equal(false, RosettaStone::ProductionDetection.could_be_on_production?)
  end

  def test_not_on_production_in_production_mode_on_unknown_box
    production_and_unknown!(false, true)
    rails_env!('production')
    assert_equal(true, RosettaStone::ProductionDetection.could_be_on_production?)
  end

  def test_not_on_production_on_known_not_prod_box
    production_and_unknown!(false, false)
    assert_equal(false, RosettaStone::ProductionDetection.could_be_on_production?)
  end

  def test_on_production_on_a_known_production_box
    production_and_unknown!(true, false)
    assert_equal(true, RosettaStone::ProductionDetection.could_be_on_production?)
  end

  def test_preproduction_could_be_on_production
    preproduction!
    assert_equal(true, RosettaStone::ProductionDetection.could_be_on_production?)
  end

  # --------------
  # could_be_on_staging?
  # --------------

  def test_could_be_on_staging_when_positively_on_staging
    staging!
    assert_true(RosettaStone::ProductionDetection.could_be_on_staging?)
  end

  def test_could_be_on_staging_when_positively_not_on_staging
    staging!(false)
    unknown!(false)
    assert_false(RosettaStone::ProductionDetection.could_be_on_staging?)
  end

  def test_could_be_on_staging_when_unknown_and_development_mode
    staging!(false)
    unknown!
    rails_env!('development')
    assert_false(RosettaStone::ProductionDetection.could_be_on_staging?)
  end

  def test_could_be_on_staging_when_unknown_and_test_mode
    staging!(false)
    unknown!
    rails_env!('test')
    assert_false(RosettaStone::ProductionDetection.could_be_on_staging?)
  end

  def test_could_be_on_staging_when_unknown_and_production_mode
    staging!(false)
    unknown!
    rails_env!('production')
    assert_true(RosettaStone::ProductionDetection.could_be_on_staging?)
  end

  # --------------
  # could_be_not_on_production?
  # --------------  
  def test_not_on_production_when_unknown
    production!(false)
    preproduction!(false)
    assert_equal(true, RosettaStone::ProductionDetection.could_be_not_on_production?)
  end

  def test_on_production_when_known_production_box
    production!(true)
    assert_equal(false, RosettaStone::ProductionDetection.could_be_not_on_production?)
  end

  def test_preproduction_could_not_be_on_production
    preproduction!
    assert_equal(false, RosettaStone::ProductionDetection.could_be_not_on_production?)
  end

  # --------------
  # could_be_on_production_or_staging?
  # --------------

  def test_could_be_on_production_or_staging_when_production
    RosettaStone::ProductionDetection.expects(:could_be_on_production?).returns(true)
    assert_true(RosettaStone::ProductionDetection.could_be_on_production_or_staging?)
  end

  def test_could_be_on_production_or_staging_when_staging
    RosettaStone::ProductionDetection.expects(:could_be_on_production?).returns(false)
    RosettaStone::ProductionDetection.expects(:could_be_on_staging?).returns(true)
    assert_true(RosettaStone::ProductionDetection.could_be_on_production_or_staging?)
  end

  def test_could_be_on_production_or_staging_when_neither
    RosettaStone::ProductionDetection.expects(:could_be_on_production?).returns(false)
    RosettaStone::ProductionDetection.expects(:could_be_on_staging?).returns(false)
    assert_false(RosettaStone::ProductionDetection.could_be_on_production_or_staging?)
  end

private
  def production_and_unknown!(production = false, unknown = true)
    production!(production)
    RosettaStone::InstanceDetection.expects(:preproduction?).returns(false) unless production
    unknown!(unknown) unless production
  end

  def production!(production)
    RosettaStone::InstanceDetection.expects(:production?).returns(production)
  end

  def staging!(staging = true)
    RosettaStone::InstanceDetection.expects(:staging?).returns(staging)
  end

  def unknown!(unknown = true)
    RosettaStone::InstanceDetection.expects(:unknown?).returns(unknown)
  end

  def preproduction!(preproduction = true)
    production!(false) if preproduction
    RosettaStone::InstanceDetection.expects(:preproduction?).returns(preproduction)
  end

  def rails_env!(env = 'test')
    RosettaStone::ProductionDetection.expects(:rails_env).returns(env)
  end
end
