# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::ProductLanguagesTest < Test::Unit::TestCase
  def setup
    mocha_setup # ensure mocha is ready, even for rspec apps
  end

  def teardown
    mocha_teardown # ensure mocha is cleaned up, even for rspec apps
  end

  def test_iso_code_for_for_nonexistent_language
    assert_nil ProductLanguages.iso_code_for("HEY")
  end

  def test_iso_code_for_for_nil
    assert_nil ProductLanguages.iso_code_for(nil)
  end

  def test_iso_code_for_doesnt_raise_for_all_valid_language_codes
    assert_nothing_raised do
      ProductLanguages.valid_codes.each do |code|
        ProductLanguages.iso_code_for(code)
      end
    end
  end

  def test_iso_code_for_for_basic_sanity
    assert_equal 'en-US', ProductLanguages.iso_code_for('ENG')
    assert_equal 'es-419', ProductLanguages.iso_code_for('ESP')
  end

  def test_valid_code
    assert_true ProductLanguages.valid_code?('ENG')
    assert_false ProductLanguages.valid_code?('sheep')
  end

  def test_display_name_from_iso_code
    assert_equal '', ProductLanguages.display_name_from_iso_code('monkey')
    assert_equal 'English (American)', ProductLanguages.display_name_from_iso_code('en-US', :translation => false)
  end

  def test_name_and_version_for_when_language_code_not_found
    assert_equal('', ProductLanguages.send(:name_and_version_for, 'XXX/3', :translation => false))
  end

  def test_name_and_version_for_when_language_code_found
    assert_equal('Arabic V3', ProductLanguages.send(:name_and_version_for, 'ARA/3', :translation => false))
  end

  def test_rs3_level_4_and_5_iso_codes
    ProductLanguages.stubs(:rs3_level_4_and_5_language_codes).returns(%w(ENG ESP))
    assert_equal ['en-US', 'es-419'], ProductLanguages.rs3_level_4_and_5_iso_codes
  end

  def test_that_we_have_iso_codes_for_all_standard_rs3_languages
    ProductLanguages.rs3_standard_language_codes.each do |rs3_code|
      assert(!ProductLanguages.iso_code_for(rs3_code).blank?, "Expected to have an ISO code for #{rs3_code}")
    end
  end

  # NOTE: we are making assumptions that we can do iso_code <-> rs_code mapping
  # unambiguously - if this test fails, you better know what you are doing!
  def test_that_iso_codes_are_unique
    assert_equal_arrays(ProductLanguages.valid_iso_codes.uniq, ProductLanguages.valid_iso_codes)
  end

  # NOTE: we are making assumptions that we can do iso_code <-> rs_code mapping
  # unambiguously - if this test fails, you better know what you are doing!
  def test_that_iso_codes_and_rs_codes_do_not_overlap
    all_codes = ProductLanguages.valid_codes + ProductLanguages.valid_iso_codes
    assert_equal_arrays(all_codes.uniq, all_codes)
  end

  def test_valid_iso_codes
    assert_equal_arrays(ProductLanguages::LANGUAGE_DATA.map {|three_letter_code, values| values[:iso_code]}.compact, ProductLanguages.valid_iso_codes)
  end

  def test_rs_code_from_iso_code_with_nonexistent_code
    assert_nil(ProductLanguages.rs_code_from_iso_code('your mama'))
  end

  def test_rs_code_from_iso_code_with_string
    assert_equal('ESP', ProductLanguages.rs_code_from_iso_code('es-419'))
  end

  def test_rs_code_from_iso_code_with_symbol
    assert_equal('ARA', ProductLanguages.rs_code_from_iso_code(:ar))
  end

  def test_oe_language_codes
    codes = ProductLanguages.oe_language_codes
    assert ProductLanguages.rs3_standard_language_codes.size >= codes.size
    assert_equal_arrays ["LAT", "DAR", "IND", "PAS", "KIS", "URD"], (ProductLanguages.rs3_standard_language_codes - codes)
  end

  def test_valid_oe_iso_codes
    codes = ProductLanguages.valid_oe_iso_codes
    assert_equal ProductLanguages.oe_language_codes.size, codes.size
    assert codes.all?{ |iso| ProductLanguages.valid_iso_codes.include?(iso)}
  end

  def test_valid_reflex_iso_codes
    codes = ProductLanguages.valid_reflex_iso_codes
    assert_equal ProductLanguages.reflex_language_codes.size, codes.size
    assert codes.all?{ |iso| ProductLanguages.valid_iso_codes.include?(iso)}
  end

  def test_parature_code_for
    assert_equal '4113', ProductLanguages.parature_code_for('ENG')
    assert_equal '4115', ProductLanguages.parature_code_for('ESP')
    assert_nil ProductLanguages.parature_code_for('CYM')
  end

  def test_language_code_for_rs3_course_identifier_in_the_normal_case
    assert_equal('FRA', ProductLanguages.language_code_for_rs3_course_identifier('SK-FRA-L1-NA-PE-NA-NA-Y-3'))
    assert_equal('ME-ARA', ProductLanguages.language_code_for_rs3_course_identifier('SK-ARA-L1-NA-ME-NA-NA-Y-3'))
  end

  def test_language_code_for_rs3_course_identifier_in_unexpected_cases
    assert_nil(ProductLanguages.language_code_for_rs3_course_identifier(nil))
    assert_nil(ProductLanguages.language_code_for_rs3_course_identifier(''))
    assert_nil(ProductLanguages.language_code_for_rs3_course_identifier('SK-XXX-L1-NA-PE-NA-NA-Y-3'))
  end

  def test_level_for_rs3_course_identifier_in_the_normal_case
    assert_equal('2', ProductLanguages.level_for_rs3_course_identifier('SK-FRA-L2-NA-PE-NA-NA-Y-3'))
    assert_equal('1', ProductLanguages.level_for_rs3_course_identifier('SK-ARA-L1-NA-ME-NA-NA-Y-3'))
    assert_equal('10', ProductLanguages.level_for_rs3_course_identifier('SK-ARA-L10-NA-CE-NA-NA-Y-3'))
  end

  def test_level_for_rs3_course_identifier_in_unexpected_cases
    assert_nil(ProductLanguages.level_for_rs3_course_identifier(nil))
    assert_nil(ProductLanguages.level_for_rs3_course_identifier(''))
    assert_nil(ProductLanguages.level_for_rs3_course_identifier('SK-ARA-L-NA-PE-NA-NA-Y-3'))
  end

  def test_edition_for_rs3_course_identifier_in_normal_cases
    assert_equal('PE', ProductLanguages.edition_for_rs3_course_identifier('SK-FRA-L2-NA-PE-NA-NA-Y-3'))
    assert_equal('ME', ProductLanguages.edition_for_rs3_course_identifier('SK-ARA-L1-NA-ME-NA-NA-Y-3'))
  end

  def test_edition_for_rs3_course_identifier_in_unexpected_cases
    assert_nil(ProductLanguages.edition_for_rs3_course_identifier(nil))
    assert_nil(ProductLanguages.edition_for_rs3_course_identifier(''))
    assert_nil(ProductLanguages.edition_for_rs3_course_identifier('SK-ARA'))
  end

  def test_has_level_4_and_5_question_mark
    assert_false(ProductLanguages.has_level_4_and_5?("HI< I'm Clearly923 inval#id"))
    assert_false(ProductLanguages.has_level_4_and_5?(''))
    assert_false(ProductLanguages.has_level_4_and_5?(nil))
    assert_false(ProductLanguages.has_level_4_and_5?('E'))
    assert_true(ProductLanguages.has_level_4_and_5?("ESP"))
    assert_true(ProductLanguages.has_level_4_and_5?("es-419"))
    assert_true(ProductLanguages.has_level_4_and_5?("DEU"))
    assert_true(ProductLanguages.has_level_4_and_5?("ENG"))
    assert_true(ProductLanguages.has_level_4_and_5?("en-US"))
    assert_false(ProductLanguages.has_level_4_and_5?("KIS"))
  end

  def test_max_v3_unit_for_rs_code
    {
      'CTM' => 8,
      'NAV' => 8,
      'ENG' => 20,
      'ESP' => 20,
      'KIS' => 4,
      'POR' => 12,
      'CHI' => 20,
      'DEU' => 20,
      'URD' => 4,
      'IRQ' => 4,
      'ME-ARA' => 4,
      'ME-URD' => 4,
      'ME-IRQ' => 4,
      'ME-KIS' => 4,
      'BLAH' => nil,
      'ara' => 12,
      :ind => 4,
    }.each do |rs_code, expected_max_unit|
      assert_equal(expected_max_unit, ProductLanguages.max_v3_unit_for_rs_code(rs_code), "Max unit for #{rs_code} expected to be #{expected_max_unit}")
    end
  end

  def test_max_v3_level_for_rs_code
    {
      'CTM' => 2,
      'NAV' => 2,
      'ENG' => 5,
      'ESP' => 5,
      'KIS' => 1,
      'POR' => 3,
      'CHI' => 5,
      'DEU' => 5,
      'URD' => 1,
      'IRQ' => 1,
      'ME-ARA' => 1,
      'ME-URD' => 1,
      'ME-IRQ' => 1,
      'ME-KIS' => 1,
      'BLAH' => nil,
      'ara' => 3,
      :ind => 1,
    }.each do |rs_code, expected_max_level|
      assert_equal(expected_max_level, ProductLanguages.max_v3_level_for_rs_code(rs_code), "Max level for #{rs_code} expected to be #{expected_max_level}")
    end
  end

  def test_military_edition_language_codes
    assert_equal_arrays(%w(ME-ARA ME-IRQ ME-URD ME-IND ME-KIS ME-DAR ME-PAS), ProductLanguages.military_edition_language_codes)
  end

  def test_specific_display_names_that_are_different_between_rs2_and_rs3_versions_of_the_same_language
    assert_equal 'English (UK)', ProductLanguages.display_name_from_code_and_version('EBR', 2)
    assert_equal 'English (British)', ProductLanguages.display_name_from_code_and_version('EBR', 3)

    assert_equal 'English (US)', ProductLanguages.display_name_from_code_and_version('ENG', 2)
    assert_equal 'English (American)', ProductLanguages.display_name_from_code_and_version('ENG', 3)

    assert_equal 'Farsi', ProductLanguages.display_name_from_code_and_version('FAR', 2)
    assert_equal 'Persian (Farsi)', ProductLanguages.display_name_from_code_and_version('FAR', 3)

    assert_equal 'Portuguese', ProductLanguages.display_name_from_code_and_version('POR', 2)
    assert_equal 'Portuguese (Brazil)', ProductLanguages.display_name_from_code_and_version('POR', 3)

    assert_equal 'Tagalog', ProductLanguages.display_name_from_code_and_version('TGL', 2)
    assert_equal 'Filipino (Tagalog)', ProductLanguages.display_name_from_code_and_version('TGL', 3)
  end

  def test_reflex_language_codes
    %w(jle JLE KLE).each do |reflex_code|
      assert_true(ProductLanguages.is_reflex_language_code?(reflex_code))
    end
    [nil, '', 'ara',' ARA', 'DEU', 'asdlkjfsd'].each do |not_reflex_code|
      assert_false(ProductLanguages.is_reflex_language_code?(not_reflex_code))
    end
  end

  def test_default_score_threshold_for_rs3_course_identifier_and_path_type_with_bad_path_type
    assert_raises(RuntimeError) do
      ProductLanguages.default_score_threshold_for_rs3_course_identifier_and_path_type('blah', 'blah')
    end
  end

  def test_default_score_threshold_for_rs3_course_identifier_and_path_type_with_pt_eng
    %w(general grammar pronunciation).each do |path_type|
      assert_equal(0.5, ProductLanguages.default_score_threshold_for_rs3_course_identifier_and_path_type('SK-ENG-L1-NA-PT-NA-NA-Y-3', path_type))
    end
  end

  def test_default_score_threshold_for_rs3_course_identifier_and_path_type
    %w(grammar reading reading_color).each do |path_type|
      assert_equal(0.9, ProductLanguages.default_score_threshold_for_rs3_course_identifier_and_path_type('SK-ENG-L1-NA-PE-NA-NA-Y-3', path_type))
    end
    %w(general review lagged_review).each do |path_type|
      assert_equal(0.85, ProductLanguages.default_score_threshold_for_rs3_course_identifier_and_path_type('SK-ENG-L1-NA-PE-NA-NA-Y-3', path_type))
    end
    %w(production_milestone pronunciation).each do |path_type|
      assert_equal(0.75, ProductLanguages.default_score_threshold_for_rs3_course_identifier_and_path_type('SK-ENG-L1-NA-PE-NA-NA-Y-3', path_type))
    end
  end

  def test_valid_rs3_path_type
    [nil, '', 'invalid'].each do |invalid_path_type|
      assert_false(ProductLanguages.valid_rs3_path_type?(invalid_path_type))
    end
    %w(lagged_review early_reading reading production_milestone general review pronunciation reading_color speaking vocabulary writing).each do |valid_path_type|
      assert_true(ProductLanguages.valid_rs3_path_type?(valid_path_type))
    end
  end

  def test_demo_rs3_content
    [nil, -1, '', 0, 1000].each do |invalid_unit_or_lesson|
      [ ['KOR', invalid_unit_or_lesson, 1], ['KOR', '1', invalid_unit_or_lesson] ].each do |argument_set|
        assert_raises(ArgumentError) do
          ProductLanguages.demo_rs3_content?(*argument_set)
        end
      end
    end

    {
      [1,1] => true,
      [1,2] => false,
      [1,3] => false,
      [1,4] => false,
      [1,5] => false,
      [2,1] => false,
      [3,1] => false,
      [4,1] => false,
      [5,1] => true,
      [5,2] => false,
      [6,1] => false,
      [9,1] => true,
      [13,1] => true,
      [17,1] => true,
      [20,1] => false,
    }.each do |unit_and_lesson, expected_demo|
      assert_equal(expected_demo, ProductLanguages.demo_rs3_content?('EBR', *unit_and_lesson), "Expected demo to be #{expected_demo} for unit and lesson #{unit_and_lesson.inspect}")
    end
  end
end
