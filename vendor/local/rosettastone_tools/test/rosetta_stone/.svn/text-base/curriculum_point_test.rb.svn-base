# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::CurriculumPointTest < Test::Unit::TestCase
  def setup
    @three_part = { 'level' => 3, 'unit' => 2, 'lesson' => 1 }
  end

  def test_two_part_with_level_and_unit_both_zero
    assert_conversions({"unit" => 0, "lesson" => 0}, { "level" => 0, "unit" => 0, "lesson"=> 0 })
  end

  def test_conversion_methods_should_be_reversible
    assert_equal @three_part, CurriculumPoint.three_part_from_two_part(CurriculumPoint.two_part_from_three_part(@three_part))
  end

  def test_two_part_from_three_part
    assert_conversions({"unit" => 1, "lesson" => 2}, { "level" => 1, "unit" => 1, "lesson"=> 2 })
    assert_conversions({"unit" => 4, "lesson" => 2}, { "level" => 1, "unit" => 4, "lesson"=> 2 })
    assert_conversions({"unit" => 5, "lesson" => 3}, { "level" => 2, "unit" => 1, "lesson"=> 3 })
    assert_conversions({"unit" => 6, "lesson" => 2}, { "level" => 2, "unit" => 2, "lesson"=> 2 })
    assert_conversions({"unit" => 8, "lesson" => 2}, { "level" => 2, "unit" => 4, "lesson"=> 2 })
    assert_conversions({"unit" => 9, "lesson" => 2}, { "level" => 3, "unit" => 1, "lesson"=> 2 })
    assert_conversions({"unit" => 12, "lesson" => 1}, { "level" => 3, "unit" => 4, "lesson"=> 1 })
  end

  def test_conversion_methods_raise_with_bad_input
    assert_raises(ArgumentError) { CurriculumPoint.two_part_from_three_part(';laksjdfoiajsdfij') }
    assert_raises(ArgumentError) { CurriculumPoint.two_part_from_three_part({}) }
    assert_raises(ArgumentError) { CurriculumPoint.two_part_from_three_part({'unit' => 2, 'lesson' => 3}) }
    assert_raises(ArgumentError) { CurriculumPoint.three_part_from_two_part(';laksjdfoiajsdfij') }
    assert_raises(ArgumentError) { CurriculumPoint.three_part_from_two_part({}) }
    assert_raises(ArgumentError) { CurriculumPoint.three_part_from_two_part({'level' => 2, 'lesson' => 3}) }
  end

  def test_single_number_unit_from_level_and_unit
    assert_equal 1, CurriculumPoint.single_number_unit_from_level_and_unit(1, 1)
    assert_equal 2, CurriculumPoint.single_number_unit_from_level_and_unit(1, 2)
    assert_equal 3, CurriculumPoint.single_number_unit_from_level_and_unit(1, 3)
    assert_equal 4, CurriculumPoint.single_number_unit_from_level_and_unit(1, 4)
    assert_equal 5, CurriculumPoint.single_number_unit_from_level_and_unit(2, 1)
    assert_equal 6, CurriculumPoint.single_number_unit_from_level_and_unit(2, 2)
    assert_equal 7, CurriculumPoint.single_number_unit_from_level_and_unit(2, 3)
    assert_equal 8, CurriculumPoint.single_number_unit_from_level_and_unit(2, 4)
    assert_equal 9, CurriculumPoint.single_number_unit_from_level_and_unit(3, 1)
    assert_equal 10, CurriculumPoint.single_number_unit_from_level_and_unit(3, 2)
    assert_equal 11, CurriculumPoint.single_number_unit_from_level_and_unit(3, 3)
    assert_equal 12, CurriculumPoint.single_number_unit_from_level_and_unit(3, 4)
    assert_equal 13, CurriculumPoint.single_number_unit_from_level_and_unit(4, 1)
    assert_equal 14, CurriculumPoint.single_number_unit_from_level_and_unit(4, 2)
    assert_equal 15, CurriculumPoint.single_number_unit_from_level_and_unit(4, 3)
    assert_equal 16, CurriculumPoint.single_number_unit_from_level_and_unit(4, 4)
    assert_equal 17, CurriculumPoint.single_number_unit_from_level_and_unit(5, 1)
    assert_equal 18, CurriculumPoint.single_number_unit_from_level_and_unit(5, 2)
    assert_equal 19, CurriculumPoint.single_number_unit_from_level_and_unit(5, 3)
    assert_equal 20, CurriculumPoint.single_number_unit_from_level_and_unit(5, 4)
  end

  def test_single_number_unit_from_level_and_unit_with_string_arguments
    assert_equal 20, CurriculumPoint.single_number_unit_from_level_and_unit('5', '4')
  end

  def test_level_and_unit_from_single_number_unit
    assert_equal 1, CurriculumPoint.level_and_unit_from_single_number_unit(1)[:level]
    assert_equal 1, CurriculumPoint.level_and_unit_from_single_number_unit(1)[:unit]
    assert_equal 1, CurriculumPoint.level_and_unit_from_single_number_unit(2)[:level]
    assert_equal 2, CurriculumPoint.level_and_unit_from_single_number_unit(2)[:unit]
    assert_equal 1, CurriculumPoint.level_and_unit_from_single_number_unit(3)[:level]
    assert_equal 3, CurriculumPoint.level_and_unit_from_single_number_unit(3)[:unit]
    assert_equal 1, CurriculumPoint.level_and_unit_from_single_number_unit(4)[:level]
    assert_equal 4, CurriculumPoint.level_and_unit_from_single_number_unit(4)[:unit]
    assert_equal 2, CurriculumPoint.level_and_unit_from_single_number_unit(5)[:level]
    assert_equal 1, CurriculumPoint.level_and_unit_from_single_number_unit(5)[:unit]
    assert_equal 2, CurriculumPoint.level_and_unit_from_single_number_unit(6)[:level]
    assert_equal 2, CurriculumPoint.level_and_unit_from_single_number_unit(6)[:unit]
    assert_equal 2, CurriculumPoint.level_and_unit_from_single_number_unit(7)[:level]
    assert_equal 3, CurriculumPoint.level_and_unit_from_single_number_unit(7)[:unit]
    assert_equal 2, CurriculumPoint.level_and_unit_from_single_number_unit(8)[:level]
    assert_equal 4, CurriculumPoint.level_and_unit_from_single_number_unit(8)[:unit]
    assert_equal 3, CurriculumPoint.level_and_unit_from_single_number_unit(9)[:level]
    assert_equal 1, CurriculumPoint.level_and_unit_from_single_number_unit(9)[:unit]
    assert_equal 3, CurriculumPoint.level_and_unit_from_single_number_unit(10)[:level]
    assert_equal 2, CurriculumPoint.level_and_unit_from_single_number_unit(10)[:unit]
    assert_equal 3, CurriculumPoint.level_and_unit_from_single_number_unit(11)[:level]
    assert_equal 3, CurriculumPoint.level_and_unit_from_single_number_unit(11)[:unit]
    assert_equal 3, CurriculumPoint.level_and_unit_from_single_number_unit(12)[:level]
    assert_equal 4, CurriculumPoint.level_and_unit_from_single_number_unit(12)[:unit]
    assert_equal 4, CurriculumPoint.level_and_unit_from_single_number_unit(13)[:level]
    assert_equal 1, CurriculumPoint.level_and_unit_from_single_number_unit(13)[:unit]
    assert_equal 4, CurriculumPoint.level_and_unit_from_single_number_unit(14)[:level]
    assert_equal 2, CurriculumPoint.level_and_unit_from_single_number_unit(14)[:unit]
    assert_equal 4, CurriculumPoint.level_and_unit_from_single_number_unit(15)[:level]
    assert_equal 3, CurriculumPoint.level_and_unit_from_single_number_unit(15)[:unit]
    assert_equal 4, CurriculumPoint.level_and_unit_from_single_number_unit(16)[:level]
    assert_equal 4, CurriculumPoint.level_and_unit_from_single_number_unit(16)[:unit]
    assert_equal 5, CurriculumPoint.level_and_unit_from_single_number_unit(17)[:level]
    assert_equal 1, CurriculumPoint.level_and_unit_from_single_number_unit(17)[:unit]
    assert_equal 5, CurriculumPoint.level_and_unit_from_single_number_unit(18)[:level]
    assert_equal 2, CurriculumPoint.level_and_unit_from_single_number_unit(18)[:unit]
    assert_equal 5, CurriculumPoint.level_and_unit_from_single_number_unit(19)[:level]
    assert_equal 3, CurriculumPoint.level_and_unit_from_single_number_unit(19)[:unit]
    assert_equal 5, CurriculumPoint.level_and_unit_from_single_number_unit(20)[:level]
    assert_equal 4, CurriculumPoint.level_and_unit_from_single_number_unit(20)[:unit]
  end

  def test_unit_range_from_level
    assert_equal (1..4), CurriculumPoint.unit_range_from_level(1)
    assert_equal (5..8), CurriculumPoint.unit_range_from_level(2)
    assert_equal (9..12), CurriculumPoint.unit_range_from_level(3)
    assert_equal (13..16), CurriculumPoint.unit_range_from_level(4)
    assert_equal (17..20), CurriculumPoint.unit_range_from_level(5)
  end

private
  def assert_conversions(two_part, three_part)
    assert_equal three_part, CurriculumPoint.three_part_from_two_part(two_part)
    assert_equal two_part, CurriculumPoint.two_part_from_three_part(three_part)
  end
end

