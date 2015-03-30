require File.dirname(__FILE__) + '/../test_helper'

class Qualification_test < ActiveSupport::TestCase

  fixtures :qualifications, :languages

  def setup
    Qualification.delete_all
  end

  def test_language_of_a_qualification
    coach = FactoryGirl.create(:coach, :user_name => 'coach7418', :type => 'Coach')
    qual = FactoryGirl.create(:qualification, :coach_id => coach.id, :language_id => Language['KLE'].id, :max_unit => 1)
    assert_equal("KLE",qual.language.identifier)
  end

  def test_units_label_of_a_qualification
    coach = create_coach_with_qualifications("psubramanian", ['TGL', 'KLE'])
    lang = Language.find_by_identifier("TGL")
    lang1 = Language.find_by_identifier("KLE")
    qual = Qualification.create(:language_id => lang.id, :coach_id => coach.id, :max_unit => 8)
    assert_equal("1..8",qual.units_label)
    qual1 = Qualification.create(:language_id => lang1.id, :coach_id => coach.id, :max_unit => 12)
    assert_equal("N/A",qual1.units_label)
  end

  def test_language_label_of_a_qualification
    coach = create_coach_with_qualifications("coach", ['TGL'])
    lang = Language.find_by_identifier("TGL")
    qual = Qualification.create(:language_id => lang.id, :coach_id => coach.id, :max_unit=>8)
    assert_equal("Filipino (Tagalog)", qual.language_label)
    assert_equal("Filipino (Tagalog) - units : 1..8", qual.label)
  end

  def test_for_must_language_present
    coach = FactoryGirl.create(:coach, :user_name => 'coach7418', :type => 'Coach')
    qual = FactoryGirl.build(:qualification, :coach_id => coach.id, :language_id => nil, :max_unit => 1)
    assert_false qual.valid?
    assert_equal ["must be present"], qual.errors[:language]
  end

  def ignore_test_for_unique_language
    lang = Language.find_by_identifier("KLE")
    coach = FactoryGirl.create(:coach, :user_name => 'coach7418', :type => 'Coach')
    qual = Qualification.create(:language_id => lang.id, :coach_id => coach.id, :max_unit=>8)
    assert_false qual.valid?
    assert_equal ["has already been set for this qualification"], qual.errors[:language]
  end

  def test_qualifications_with_max_unit_zero
    lang = Language.find_by_identifier("TGL")
    coach = FactoryGirl.create(:coach, :user_name => 'coach7418', :type => 'Coach')
    qual = FactoryGirl.build(:qualification,:language_id => lang.id, :coach_id => coach.id, :max_unit=>0)
    assert_false qual.valid?
    assert_equal ["must be greater than zero for coach."], qual.errors[:max_unit]
  end

  def test_qualifications_which_exceeds_max_unit
    lang = Language.find_by_identifier("KLE")
    coach = FactoryGirl.create(:coach, :user_name => 'coach7418', :type => 'Coach')
    qual = FactoryGirl.build(:qualification,:language_id => lang.id, :coach_id => coach.id, :max_unit=>21)
    assert_false qual.valid?
    assert_equal ["The maximum unit you selected exceeds the maximum unit offered for #{qual.language.display_name}. Please select the correct maximum unit."], qual.errors[:base]
  end

  def test_max_unit_should_not_be_nil_for_coach
    lang = Language.find_by_identifier("KLE")
    coach = FactoryGirl.create(:coach, :user_name => 'coach7418', :type => 'Coach')
    qual = FactoryGirl.build(:qualification,:language_id => lang.id, :coach_id => coach.id, :max_unit=>nil)
    assert_false qual.valid?
    assert_equal ["must be greater than zero for coach."], qual.errors[:max_unit]
  end

  def test_max_unit_should_not_be_anything_other_than_nil_for_manager
    coach = FactoryGirl.create(:coach, :user_name => 'coach7418', :type => 'CoachManager')
    qual = FactoryGirl.build(:qualification, :coach_id => coach.id, :language_id => Language['ARA'].id, :max_unit => 1)
    assert_false qual.valid?
    assert_equal ["must be blank for manager."], qual.errors[:max_unit]
  end

  def test_max_unit_should_be_nil_for_manager
    coach = FactoryGirl.create(:coach, :user_name => 'coach7418', :type => 'CoachManager')
    qual = FactoryGirl.create(:qualification, :coach_id => coach.id, :language_id => Language['ARA'].id, :max_unit => nil)
    assert_equal [], qual.errors[:max_unit]
  end

end