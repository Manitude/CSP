require 'test_helper'

class LanguageSchedulingThresholdTest < ActiveSupport::TestCase
  
  def test_get_hours_prior_to_sesssion_override
    l1 = Language.find_by_identifier('ARA')
    l2 = Language.find_by_identifier('CHI')
    l3 = Language.find_by_identifier('HIN')
    session_language  = l1
    FactoryGirl.create(:language_scheduling_threshold, :language_id=>l1.id,:max_assignment=>50,:max_grab=>30,:hours_prior_to_sesssion_override=>2)
    FactoryGirl.create(:language_scheduling_threshold, :language_id=>l2.id,:max_assignment=>49,:max_grab=>30,:hours_prior_to_sesssion_override=>3)
    FactoryGirl.create(:language_scheduling_threshold, :language_id=>l3.id,:max_assignment=>48,:max_grab=>30,:hours_prior_to_sesssion_override=>4)
    hours_prior_to = LanguageSchedulingThreshold.get_hours_prior_to_sesssion_override(session_language.id)
    assert_equal 2, hours_prior_to
 	end
end
