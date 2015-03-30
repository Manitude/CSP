require File.expand_path('../coach_activity_parser', __FILE__)
require File.expand_path('../reflex_activity_utils', __FILE__)
require File.expand_path('../coach_aggregator', __FILE__)

class CoachActivityFetcher
  include ReflexActivityUtils

  def initialize(coach_ids, start_date = (Time.now - 100032.hours), end_date = Time.now)
    @coach_ids = coach_ids
    @start_date = start_date
    @end_date = end_date
  end

  def coach_session_details
    coach_aggregator = CoachAggregator.new
    ReflexActivity.for_coaches(@coach_ids, @start_date, @end_date).each do |activity|
      coach_aggregator.add(activity)
    end
    coach_aggregator.parse(@start_date, @end_date)
  end
end
