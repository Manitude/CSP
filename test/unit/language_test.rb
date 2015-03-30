require File.expand_path('../../test_helper', __FILE__)

class LanguageTest < ActiveSupport::TestCase

  fixtures :languages

  test "all sorted by name" do
    lang_array = []
    delete_all_languages_for_test
    Language.create(:identifier=>"CHI",:type=>"TotaleLanguage")
    Language.create(:identifier=>"ARA",:type=>"TotaleLanguage")
    lang_array = Language.all_sorted_by_name
    assert_equal("ARA" , lang_array[0].identifier)
    assert_equal("CHI" , lang_array[1].identifier)
  end


  test "options" do
    lang_array = []
    delete_all_languages_for_test
    create_lotus_language()
    create_non_lotus_language("ARA")
    create_michelin_language
    lang_array = Language.options
    assert_equal("KLE",Language.find(:all,:conditions=>{:id => lang_array[0][1].to_i}).first.identifier)
  end

  def test_options_with_identifiers 
    lang_array = []
    delete_all_languages_for_test
    create_lotus_language()
    create_non_lotus_language("ARA")
    lang_array = Language.options_with_identifiers
    assert_equal("KLE",lang_array[0][1])
  end

  def test_options_with_identifiers_for_pll
    lang_to_remove = "'ARA','CHI'"
    lang_array1 = Language.all
    lang_array2 = Language.options_with_identifiers_for_pll(lang_to_remove) 
    # lang_aray2.size - 1 is done to compensate the count of "Select a language" which gets added during
    # options_with_identifiers_for_pll
    assert_equal(lang_array1.size-2,lang_array2.size-1) 
  end

  test "display name" do
    lang_array = []
    delete_all_languages_for_test
    create_lotus_language()
    lang = Language.first
    assert_equal("Advanced English",lang.display_name)
  end

  test "max level and unit" do
    lang_array = []
    delete_all_languages_for_test
    create_non_lotus_language("ARA")
    lang_value = Language.first.max_level
    lang_unit = Language.first.max_unit
    assert_equal(UNITS_PER_LEVEL*lang_value,lang_unit)
  end

  def test_lotus_languages_returs_empty_array_when_no_language_is_there
    delete_all_languages_for_test
    language = Language.lotus_languages
    assert_equal language, []
  end

  def test_lotus_languages_returs_empty_array_when_no_reflex_language_is_there
    delete_all_languages_for_test
    create_non_lotus_language("ARA")
    language = Language.lotus_languages
    assert_equal language, []
  end

  def test_lotus_languages_returs_kle_when_only_reflex_language_is_there
    delete_all_languages_for_test
    create_lotus_language()
    language = Language.lotus_languages
    assert_equal language[0].is_lotus? , true
  end

  def test_lotus_languages_returs_only_kle_when_both_reflex_and_totalae_language_is_there
    delete_all_languages_for_test
    create_lotus_language()
    create_non_lotus_language("ARA")
    language = Language.lotus_languages
    assert_equal language.size,1
    assert_equal language[0].is_lotus?  , true
  end

  test "should_return_session_languages" do
    session_languages = Language.session_languages
    assert_include session_languages, %w(All All)
    assert_include session_languages, %w(KLE KLE)
    assert_include session_languages, %w(JLE JLE)
    assert_include session_languages, ['All - AEB ', 'AEB']
    assert_include session_languages, ['AEB US', 'AUS']
    assert_include session_languages, ['AEB UK', 'AUK']

    assert_equal 31, session_languages.size

  end

  test "modify language options should not include the learners languages" do
    modify_languages = Language.options_with_identifiers_for_pll("'FRA','DEU'")
    assert_false modify_languages.include?(["French", "FRA"])
    assert_false modify_languages.include?(["German", "DEU"])
  end

  test "modify language options should not include KLE by default" do
    modify_languages = Language.options_with_identifiers_for_pll("''")
    assert_false modify_languages.include?(['KLE', 'KLE'])
  end

  def test_already_pushed_to_eschool?
    last_pushed_week = Time.now + 2.weeks
    datetime = Time.now.beginning_of_week
    assert_true TimeUtils.beginning_of_week(last_pushed_week) >= TimeUtils.beginning_of_week(datetime)
    datetime = Time.now - 1.week
    assert_true TimeUtils.beginning_of_week(last_pushed_week) >= TimeUtils.beginning_of_week(datetime)
  end
  
end
