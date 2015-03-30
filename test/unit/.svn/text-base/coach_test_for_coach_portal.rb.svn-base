# To change this template, choose Tools | Templates
# and open the template in the editor.

#$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test_helper'
require 'coach'
class CoachTestForCoachPortal < ActiveSupport::TestCase
  fixtures :qualifications, :languages, :language_configurations, :accounts, :coach_sessions

  def test_orphaned_coaches
    assert_not_nil Coach.orphaned_coaches
  end

  def test_session_on
    #session exists
    assert_not_nil accounts(:ESPscheduledcoach).session_on(coach_sessions(:session_ESP_scheduled).session_start_time)
    #raising an error if argument passed is invalid
    assert_raise(NoMethodError){Coach.session_on('test')}
  end

  def test_next_session
    #no session exists for this coach in fixtures
    assert_not_equal(coach_sessions(:sheduled_for_KLEsheduled), accounts(:Scheduled_Coach).next_session)
    #asserting nil as the next session for this coach does not exist in fixtures
    assert_nil accounts(:Scheduled_Coach).next_session
  end

  def test_qualification_for_language
    #Qualification for this coach Exist
    assert_equal(qualifications(:KLESchdeuledCoach_qualification), accounts(:Scheduled_Coach).qualification_for_language(Language.find_by_identifier('KLE').id))
  end

  def test_coach_all_languages_max_unit_hash_when_no_language
    coach = Coach.find_by_user_name('rramesh')
    assert_equal coach, accounts(:ARA_scheduled_coach)
    lang_max_unit_hash = coach.all_languages_and_max_unit_hash
    assert_equal lang_max_unit_hash.size, 0
  end

  def test_coach_all_languages_max_unit_hash_when_one_language_and_correctness_of_value
    coach = Coach.find_by_user_name('rramesh')
    assert_equal coach, accounts(:ARA_scheduled_coach)
    language_max_unit_array = [{:language => Language['ARA'].id,:max_unit => 12}]
    create_qualifications(coach.id,language_max_unit_array)
    lang_max_unit_hash = coach.all_languages_and_max_unit_hash
    assert_equal lang_max_unit_hash.size, 1
    assert_equal lang_max_unit_hash["ARA"], "12"
  end

  def test_coach_all_languages_max_unit_hash_when_more_than_one_language_and_correctness_of_value
    coach = Coach.find_by_user_name('rramesh')
    assert_equal coach, accounts(:ARA_scheduled_coach)
    language_max_unit_array = [{:language => Language['ARA'].id,:max_unit => 12},{:language => Language['GRK'].id,:max_unit => 10},{:language => Language['HEB'].id,:max_unit => 10},{:language => Language['ENG'].id,:max_unit => 8}]
    create_qualifications(coach.id,language_max_unit_array)
    lang_max_unit_hash = coach.all_languages_and_max_unit_hash
    assert_equal lang_max_unit_hash.size, 4
    assert_equal lang_max_unit_hash["ARA"], "12"
    assert_equal lang_max_unit_hash["GRK"], "10"
    assert_equal lang_max_unit_hash["HEB"], "10"
    assert_equal lang_max_unit_hash["ENG"],  "8"
  end

end
