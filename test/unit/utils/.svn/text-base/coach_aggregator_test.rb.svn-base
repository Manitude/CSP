require File.expand_path('../../../test_helper', __FILE__)
require 'app/utils/coach_aggregator'
require 'app/utils/coach_activity_parser'

class CoachAggregatorTest < ActiveSupport::TestCase

  def setup
    @coach_aggregator = CoachAggregator.new
  end
  test "should add only eve activity" do
    assert_false @coach_aggregator.add(CoachActivityParser.new(nil, nil, nil))
    assert_true @coach_aggregator.add(ReflexActivity.new)
  end

  test "should create 2 keys containing coach ids" do
    first_event = FactoryGirl.build(:reflex_activity, :coach_id => 32)
    second_event = FactoryGirl.build(:reflex_activity, :coach_id => 32)
    third_event = FactoryGirl.build(:reflex_activity, :coach_id => 34)
    assert_true @coach_aggregator.add(first_event)
    assert_true @coach_aggregator.add(second_event)
    assert_true @coach_aggregator.add(third_event)

    assert_equal 2, @coach_aggregator.size
    assert_equal 1, @coach_aggregator.for(34).size
    assert_equal 2, @coach_aggregator.for(32).size

  end

  test "should sort events by timestamp" do
    events = []
    event_5_mins_ago = OpenStruct.new({:id => 1, :timestamp => (Time.now - 5.minutes).to_i})
    event_10_mins_ago = OpenStruct.new({:id => 2, :timestamp => (Time.now - 10.minutes).to_i})
    event_now = OpenStruct.new({:id => 3, :timestamp => Time.now.to_i })
    events << event_10_mins_ago << event_5_mins_ago << event_now
    assert_equal [event_10_mins_ago, event_5_mins_ago, event_now], events
  end

end
