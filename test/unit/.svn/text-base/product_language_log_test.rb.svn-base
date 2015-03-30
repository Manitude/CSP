require File.expand_path('../../test_helper', __FILE__)

class ProductLanguageLogTest < ActiveSupport::TestCase

  def test_should_validate_the_reason_text_blank

    pll1 = FactoryGirl.build(:product_language_log, :reason => nil)
    pll1.save
    assert_true pll1.errors[:base].include?("Reason can't be blank")

    pll2 = FactoryGirl.build(:product_language_log, :reason => "")
    pll2.save
    assert_true pll1.errors[:base].include?("Reason can't be blank")

    pll3 = FactoryGirl.build(:product_language_log, :reason => "Please enter reason for language change")
    pll3.save
    assert_true pll1.errors[:base].include?("Reason can't be blank")

    pll4 = FactoryGirl.build(:product_language_log, :reason => "bla bla", :changed_language => "JPN")
    pll4.save
    assert [], pll4.errors[:base]
  end

  def test_should_validate_the_language_blank

    pll2 = FactoryGirl.build(:product_language_log, :changed_language => nil)
    pll2.save
    assert_true pll2.errors[:base].include?("New language can't be blank")

    pll3 = FactoryGirl.build(:product_language_log)
    pll3.save
    assert [], pll3.errors[:base]
  end

  def test_should_validate_the_language_and_text_blank
    pll1 = FactoryGirl.build(:product_language_log, :reason => nil, :changed_language => nil)
    pll1.save
    assert_true pll1.errors[:base].include?("New language can't be blank")
    assert_true pll1.errors[:base].include?("Reason can't be blank")
  end
  
end
