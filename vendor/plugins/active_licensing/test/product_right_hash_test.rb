# -*- encoding : utf-8 -*-
require File.expand_path('test_helper', File.dirname(__FILE__))

class RosettaStone::ActiveLicensing::ProductRightHashTest < Test::Unit::TestCase
  include RosettaStone::ActiveLicensing

  def test_is_application
    pr = ProductRightHash.new.replace({'product_identifier' => 'ESP', 'product_version' => '3', 'product_family' => 'application'})
    assert pr.is_application?
  end

  def test_is_application_for_eschool_or_premium_community
    pr = ProductRightHash.new.replace({'product_identifier' => 'ESP', 'product_version' => '3', 'product_family' => 'eschool'})
    assert !pr.is_application?

    pr = ProductRightHash.new.replace({'product_identifier' => 'ESP', 'product_version' => '3', 'product_family' => 'premium_community'})
    assert !pr.is_application?
  end

  def test_is_rs3_for_rs3_osub
    pr = ProductRightHash.new.replace({'product_identifier' => 'GLE', 'product_version' => '3'})
    assert pr.is_rs3?
  end

  def test_is_rs3_for_not_rs3
    pr = ProductRightHash.new.replace({'product_identifier' => 'KIS', 'product_version' => '2'})
    assert !pr.is_rs3?

    pr = ProductRightHash.new.replace({'product_identifier' => 'ESP', 'product_version' => '2'})
    assert !pr.is_rs3?
  end

  def test_is_rs2_for_rs2_osub
    pr = ProductRightHash.new.replace({'product_identifier' => 'KIS', 'product_version' => '2'})
    assert pr.is_rs2?
  end

  def test_is_rs2_for_not_rs2
    pr = ProductRightHash.new.replace({'product_identifier' => 'ESP', 'product_version' => '3'})
    assert !pr.is_rs2?

    pr = ProductRightHash.new.replace({'product_identifier' => 'GLE', 'product_version' => '3'})
    assert !pr.is_rs2?
  end

  def test_is_eschool_for_eschool
    pr = ProductRightHash.new.replace({'product_identifier' => 'ESP', 'product_version' => '3', 'product_family' => 'eschool'})
    assert pr.is_eschool?
  end

  def test_is_eschool_for_not_eschool
    pr = ProductRightHash.new.replace({'product_identifier' => 'ESP', 'product_version' => '3', 'product_family' => 'premium_community'})
    assert !pr.is_eschool?

    pr = ProductRightHash.new.replace({'product_identifier' => 'KIS', 'product_version' => '2', 'product_family' => 'application'})
    assert !pr.is_eschool?
  end

  def test_is_lotus_and_is_reflex_for_lotus
    pr = ProductRightHash.new.replace({'product_identifier' => 'ESP', 'product_version' => '3', 'product_family' => 'lotus'})
    assert_true pr.is_lotus?
    assert_true pr.is_reflex?
  end

  def test_is_lotus_and_is_reflex_for_not_lotus
    pr = ProductRightHash.new.replace({'product_identifier' => 'ESP', 'product_version' => '3', 'product_family' => 'premium_community'})
    assert_false pr.is_lotus?
    assert_false pr.is_reflex?

    pr = ProductRightHash.new.replace({'product_identifier' => 'KIS', 'product_version' => '2', 'product_family' => 'application'})
    assert_false pr.is_lotus?
    assert_false pr.is_reflex?
  end

  def test_allows_unit
    pr = ProductRightHash.new.replace({"content_ranges"=>[{"max_unit"=>"4", "min_unit"=>"1"}, {"max_unit"=>"9", "min_unit"=>"5"}]})
    (1..9).each do |ii|
      assert pr.allows_unit?(ii), "Unit #{ii} should be allowed."
    end
    (10..20).each do |ii|
      assert !pr.allows_unit?(ii), "Unit #{ii} should not be allowed."
    end
  end

  def test_allows_level
    pr = ProductRightHash.new.replace({"content_ranges"=>[{"max_unit"=>"4", "min_unit"=>"1"}, {"max_unit"=>"9", "min_unit"=>"5"}]})
     (1..2).each do |ii|
       assert pr.allows_level?(ii), "Level #{ii} should be allowed."
     end
     (3..20).each do |ii|
       assert !pr.allows_level?(ii), "Level #{ii} should not be allowed."
     end
  end

  def test_units_allowed
    pr = ProductRightHash.new.replace({"content_ranges"=>[{"max_unit"=>"2", "min_unit"=>"1"}, {"max_unit"=>"4", "min_unit"=>"3"}]})
    assert_equal((1..4).to_a, pr.units_allowed)
  end

  def test_all_content_ranges_allows_all
    pr = ProductRightHash.new.replace({"content_ranges"=>['all']})
    (1..100).each do |ii|
      assert pr.allows_unit?(ii)
      assert pr.allows_level?(ii)
    end
  end


end
