# -*- encoding : utf-8 -*-
# NOTE: The mappings in CurriculumPoint.two_part_from_three_part and CurriculumPoint.three_part_from_two_part are all
#       smooth and consistent, with the exception of the "zero point" special case. We decide that we're in that special
#       case whenever the 'unit' value is zero.

class CurriculumPoint < Hash
  class << self
    def two_part_from_three_part(three_part)
      if !three_part.respond_to?(:keys) || !three_part.keys.include_all?(['lesson', 'level', 'unit'])
        raise ArgumentError, "three part curriculum points need 'level', 'unit', and 'lesson' - got #{three_part.inspect}"
      end
      level, unit, lesson = three_part['level'].to_i, three_part['unit'].to_i, three_part['lesson'].to_i
      { 'unit' => single_number_unit_from_level_and_unit(level, unit), 'lesson' => lesson_from_unit_and_lesson(unit, lesson) }
    end

    def three_part_from_two_part(two_part)
      if !two_part.respond_to?(:keys) || !two_part.keys.include_all?(['lesson', 'unit'])
        raise ArgumentError, "two part curriculum points need 'unit' and 'lesson' - got #{two_part.inspect}"
      end
      unit, lesson = two_part['unit'].to_i, two_part['lesson'].to_i
      if unit == 0
        { 'level' => 0, 'unit' => 0, 'lesson' => 0 }
      else
        zero_based_unit = unit - 1
        { 'level' => (zero_based_unit / 4) + 1, 'unit' => (zero_based_unit % 4) + 1, 'lesson' => lesson }
      end
    end

    def single_number_unit_from_level_and_unit(level, unit)
      level, unit = level.to_i, unit.to_i
      return 0 if unit == 0
      4 * (level - 1) + unit
    end

    def unit_range_from_level(level)
      start = 4 * (level.to_i - 1)
      (start + 1)..(start + 4)
    end

    def level_and_unit_from_single_number_unit(single_number_unit)
      #5 => level 2 unit 1
      #4 => level 1 unit 4
      single_number_unit = single_number_unit.to_i
      level = (Float(single_number_unit)/Float(4)).ceil
      unit = single_number_unit > 4 ? (((single_number_unit % 4) == 0 ) ? 4 : single_number_unit % 4) : single_number_unit
      {:level => level, :unit => unit}
    end

  private

    def lesson_from_unit_and_lesson(unit, lesson)
      return 0 if unit == 0
      lesson
    end
  end
end
