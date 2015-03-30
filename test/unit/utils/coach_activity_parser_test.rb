require File.expand_path('../../../test_helper', __FILE__)

class CoachActivityParserTest < ActiveSupport::TestCase

  def setup
  	start_time = Time.at(1334176497261/1000) - 10.days
 	end_time = Time.at(1334177516235/1000) + 1.day
    @coach_activity_parser = CoachActivityParser.new(32, start_time, end_time)
  end

  test "should caculate activity report values" do
  	activity1 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at(1334176497261/1000), :event => 'coach_initialized')
 	activity2 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at(1334177193421/1000), :event => 'coach_paused')
 	activity3 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at(1334177195421/1000), :event => 'coach_resumed')
 	activity4 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at(1334177491917/1000), :event => 'coach_match_accepted')
 	activity5 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at(1334177516235/1000), :event => 'coach_ready')

 	session_details = @coach_activity_parser.parse([activity1, activity2, activity3, activity4, activity5])

 	assert_equal 16.98, session_details.total.round(2)
 	assert_equal 0.42, session_details.waiting.round(2)
 	assert_equal 32, session_details.coach_id
 	assert_equal 0.0, session_details.teaching_incomplete.round(4)
 	assert_equal 0, session_details.incomplete_sessions
 	assert_equal 0.0, session_details.teaching_complete.round(4)
 	assert_equal 16.53, session_details.polling.round(2)
 	assert_equal 0, session_details.complete_sessions
 	assert_equal 0.03, session_details.paused.round(2)
 	assert_equal 'coach_ready', session_details.last_event

  end
  
  def  test_coach_is_in_refex_player_and_polls_for_120_minutes
     activity1 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at(1334176497261/1000), :event => 'coach_initialized')
     activity2 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at((1334176497261/1000) + 2.hours), :event => 'coach_match_accepted')
     session_details = @coach_activity_parser.parse([activity1, activity2])
     assert_equal 120.0, session_details.total.round(2)
     activity1 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at(1334176497261/1000), :event => 'coach_initialized')
     activity2 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at((1334176497261/1000) + 2.hours + 1.minutes), :event => 'coach_match_accepted')
     session_details = @coach_activity_parser.parse([activity1, activity2])
     assert_equal 0.0, session_details.total.round(2)
  end

  def test_without_coach_paused_greater_than_15_minutes
     activity1 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at(1334176497261/1000 ), :event => 'coach_initialized')
 	   activity2 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at(1334176497261/1000 + 42.minutes), :event => 'coach_match_accepted')
 	   activity3 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at(1334176497261/1000  + 42.minutes + 13.minutes), :event => 'coach_ready')
 	   activity4 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at(1334176497261/1000 +42.minutes + 13.minutes + 3.minutes), :event => 'coach_end_session_complete')
 	   activity5 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at(1334176497261/1000 + 42.minutes + 13.minutes + 3.minutes + 25.minutes), :event => 'coach_initialized')
 	   activity6 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at(1334176497261/1000 + 42.minutes + 13.minutes + 3.minutes + 25.minutes+ 32.minutes), :event => 'coach_paused')
 	   activity7 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at(1334176497261/1000 + 42.minutes + 13.minutes + 3.minutes + 25.minutes+ 32.minutes+6.minutes), :event => 'coach_resumed')
 	   activity8 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at(1334176497261/1000 + 42.minutes + 13.minutes + 3.minutes + 25.minutes+ 32.minutes+6.minutes+ 17.minutes), :event => 'coach_initialized')
     session_details = @coach_activity_parser.parse([activity1, activity2, activity3, activity4, activity5, activity6, activity7, activity8 ])
     assert_equal 138.0, session_details.total.round(2)
  end
  def test_with_coach_paused_greater_than_15_minutes
     activity1 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at(1334176497261/1000 ), :event => 'coach_initialized')
     activity2 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at(1334176497261/1000 + 42.minutes), :event => 'coach_match_accepted')
     activity3 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at(1334176497261/1000  + 42.minutes + 13.minutes), :event => 'coach_ready')
     activity4 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at(1334176497261/1000 +42.minutes + 13.minutes + 3.minutes), :event => 'coach_end_session_complete')
     activity5 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at(1334176497261/1000 + 42.minutes + 13.minutes + 3.minutes + 25.minutes), :event => 'coach_initialized')
     activity6 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at(1334176497261/1000 + 42.minutes + 13.minutes + 3.minutes + 25.minutes+ 32.minutes), :event => 'coach_paused')
     activity7 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at(1334176497261/1000 + 42.minutes + 13.minutes + 3.minutes + 25.minutes+ 32.minutes+17.minutes), :event => 'coach_resumed')
     activity8 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at(1334176497261/1000 + 42.minutes + 13.minutes + 3.minutes + 25.minutes+ 32.minutes+17.minutes+ 17.minutes), :event => 'coach_initialized')
     session_details = @coach_activity_parser.parse([activity1, activity2, activity3, activity4, activity5, activity6, activity7, activity8 ])
     assert_equal 147.0, session_details.total.round(2)
  end
end