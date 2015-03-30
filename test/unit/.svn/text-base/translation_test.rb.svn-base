require File.dirname(__FILE__) + '/../test_helper'

# tests that test our tests
class TranslationTest < ActiveSupport::TestCase
  include Lion::TranslationTest

  def test_all_product_languages_have_translations
    ProductLanguages.all_language_data.each do |lcode|
      assert_nothing_raised do
        unharvested_translate(lcode.last[:translation_key])
      end
    end
  end

  def test_all_v3_product_languages_have_translations
    # not using oe_language_codes here because we already have translations for these... why not keep them here?
    ProductLanguages.rs3_standard_language_codes.each do |lcode|
      assert_nothing_raised do
        ProductLanguages.display_name_from_code_and_version(lcode, 3)
      end
    end
  end

  def test_all_languages_in_the_system_have_translations
    Language.all.each do |lang|
      next if (lang.type != "TotaleLanguage") #skip non-totale langs since these languages are customized now
      english_name = ProductLanguages.display_name_from_code_and_version(lang.identifier, 3, :translation => false)
      assert(!english_name.blank?) # sanity check to make sure that it is a valid language in ProductLanguages
      assert_nothing_raised do
        assert(!translate_from_default_locale_string(english_name).blank?)
      end
    end
  end

end
