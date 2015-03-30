require 'test_helper'

class SupportLanguageTest < ActiveSupport::TestCase
  
  def test_language_display_name
    language = FactoryGirl.create(:support_language)
    assert_equal SupportLanguage.display_name(language.language_code), language.name
  end

  def test_language_code
    language = FactoryGirl.create(:support_language)
    assert_equal SupportLanguage.language_code(language.name), language.language_code
  end

  def test_language_code_empty
    assert_nil SupportLanguage.language_code('')
  end

  def test_language_name_empty
    assert_nil SupportLanguage.display_name('')
  end

  def test_should_return_supported_languages
    FactoryGirl.create(:support_language)
    languages = SupportLanguage.supported_languages
    assert_include languages, ['All', 'None']
    assert_include languages, ['English', 'en-US']
  end

end

