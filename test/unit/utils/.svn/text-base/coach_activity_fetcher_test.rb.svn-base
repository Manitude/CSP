require File.expand_path('../../../test_helper', __FILE__)

class CoachActivityFetcherTest < ActiveSupport::TestCase
 
 test "should fetch records for a coach" do
 	activity1 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at(1334176497261/1000), :event => 'coach_initialized')
 	activity2 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at(1334177193421/1000), :event => 'coach_paused')
 	activity3 = FactoryGirl.build(:reflex_activity, :coach_id => 32, :timestamp => Time.at(1334177195421/1000), :event => 'coach_resumed')
 	activity4 = FactoryGirl.build(:reflex_activity, :coach_id => 42, :timestamp => Time.at(1334177491917/1000), :event => 'coach_match_accepted')
 	activity5 = FactoryGirl.build(:reflex_activity, :coach_id => 42, :timestamp => Time.at(1334177516235/1000), :event => 'coach_ready')
 	start_time = Time.at(1334176497261/1000) - 10.days
 	end_time = Time.at(1334177516235/1000) + 1.day
 	
 	ReflexActivity.expects(:for_coaches).with([32, 42], start_time, end_time).returns([activity1, activity2, activity3, activity4, activity5])

 	coach_activities = CoachActivityFetcher.new([32, 42], start_time, end_time).coach_session_details
 	
 	coach_activities.each { |activity| assert_true activity.kind_of? ReflexSessionDetails}

 	assert_equal 2, coach_activities.size
 	
 end
end

