require File.expand_path('../../test_helper', __FILE__)

class ReflexActivityTest < ActiveSupport::TestCase
 
 def test_should_fetch_records_for_a_coach
 	FactoryGirl.create(:reflex_activity, :coach_id => 32, :timestamp => Time.now - 13.minutes, :event => 'coach_initialized')
 	FactoryGirl.create(:reflex_activity, :coach_id => 32, :timestamp => Time.now - 11.minutes, :event => 'coach_paused')
 	FactoryGirl.create(:reflex_activity, :coach_id => 32, :timestamp => Time.now - 9.minutes, :event => 'coach_resumed')
 	FactoryGirl.create(:reflex_activity, :coach_id => 32, :timestamp => Time.now - 7.minutes, :event => 'coach_match_accepted')
 	FactoryGirl.create(:reflex_activity, :coach_id => 32, :timestamp => Time.now - 5.minutes, :event => 'coach_ready')

 	activities = ReflexActivity.for_coaches([32], Time.now - 1.day, Time.now+1.day)
 	assert_equal 5, activities.size
 end

 def test_should_fetch_records_between_a_date_for_a_coach
 	FactoryGirl.create(:reflex_activity, :coach_id => 32, :timestamp => Time.now - 1.month, :event => 'coach_initialized')
 	FactoryGirl.create(:reflex_activity, :coach_id => 32, :timestamp => Time.now - 1.day, :event => 'coach_paused')
 	FactoryGirl.create(:reflex_activity, :coach_id => 32, :timestamp => Time.now - 2.days, :event => 'coach_resumed')
 	FactoryGirl.create(:reflex_activity, :coach_id => 32, :timestamp => Time.now - 3.days, :event => 'coach_match_accepted')
 	activities = ReflexActivity.for_coaches([32], Time.now - 4.days, Time.now)

 	assert_equal 3, activities.size
 end

 def test_should_fetch_records_for_coaches
 	FactoryGirl.create(:reflex_activity, :coach_id => 32, :timestamp => Time.now - 20.minutes, :event => 'coach_initialized')
 	FactoryGirl.create(:reflex_activity, :coach_id => 32, :timestamp => Time.now - 18.minutes, :event => 'coach_paused')
 	FactoryGirl.create(:reflex_activity, :coach_id => 42, :timestamp => Time.now - 16.minutes, :event => 'coach_resumed')
 	FactoryGirl.create(:reflex_activity, :coach_id => 42, :timestamp => Time.now - 14.minutes, :event => 'coach_match_accepted')
 	FactoryGirl.create(:reflex_activity, :coach_id => 42, :timestamp => Time.now - 12.minutes, :event => 'coach_ready')
 	FactoryGirl.create(:reflex_activity, :coach_id => 52, :timestamp => Time.now - 10.minutes, :event => 'coach_resumed')
 	FactoryGirl.create(:reflex_activity, :coach_id => 52, :timestamp => Time.now - 8.minutes, :event => 'coach_match_accepted')
 	FactoryGirl.create(:reflex_activity, :coach_id => 52, :timestamp => Time.now - 6.minutes, :event => 'coach_ready')

 	activities = ReflexActivity.for_coaches([32, 42], Time.now - 1.day, Time.now + 1.day)
 	assert_equal 5, activities.size
 end

 def test_for_next_event
 	FactoryGirl.create(:reflex_activity, :coach_id => 32, :timestamp => Time.now - 20.minutes, :event => 'coach_intialized')
 	event1 = FactoryGirl.create(:reflex_activity, :coach_id => 32, :timestamp => Time.now - 18.minutes, :event => 'coach_paused')
 	FactoryGirl.create(:reflex_activity, :coach_id => 42, :timestamp => Time.now - 16.minutes, :event => 'coach_resumed')
 	event2 = FactoryGirl.create(:reflex_activity, :coach_id => 32, :timestamp => Time.now - 10.minutes, :event => 'coach_resumed')
 	result = event1.next_event
 	assert_equal result,event2
 end
 
 def test_for_login_events
 	start_time = Time.now.beginning_of_hour
 	event5 = FactoryGirl.create(:reflex_activity, :coach_id => 32, :timestamp => start_time - 25.minutes, :event => 'coach_initialized')
 	accept = FactoryGirl.create(:reflex_activity, :coach_id => 32, :timestamp => start_time - 20.minutes, :event => 'coach_match_accepted')
 	read = FactoryGirl.create(:reflex_activity, :coach_id => 32, :timestamp => start_time - 18.minutes, :event => 'coach_ready')
 	event4 = FactoryGirl.create(:reflex_activity, :coach_id => 32, :timestamp => start_time - 16.minutes, :event => 'coach_initialized')
 	event3 = FactoryGirl.create(:reflex_activity, :coach_id => 32, :timestamp => start_time - 14.minutes, :event => 'coach_initialized')
 	paused = FactoryGirl.create(:reflex_activity, :coach_id => 32, :timestamp => start_time - 12.minutes, :event => 'coach_paused')
 	main_event = FactoryGirl.create(:reflex_activity, :coach_id => 32, :timestamp => start_time - 10.minutes, :event => 'coach_initialized')
 	resumed = FactoryGirl.create(:reflex_activity, :coach_id => 32, :timestamp => start_time - 8.minutes, :event => 'coach_resumed')
 	event2 = FactoryGirl.create(:reflex_activity, :coach_id => 32, :timestamp => start_time - 6.minutes, :event => 'coach_initialized')
 	event1 = FactoryGirl.create(:reflex_activity, :coach_id => 32, :timestamp => start_time - 4.minutes, :event => 'coach_initialized')

 	result_for_single = ReflexActivity.last_login_attempts('32',1)
 	assert_equal result_for_single[0],event1.timestamp

 	result_for_five = ReflexActivity.last_login_attempts('32')
 	assert_equal result_for_five[0],event1.timestamp
 	assert_equal result_for_five[1],event2.timestamp
 	assert_equal result_for_five[2],event3.timestamp
 	assert_equal result_for_five[3],event4.timestamp
 	assert_equal result_for_five[4],event5.timestamp

 end

end

