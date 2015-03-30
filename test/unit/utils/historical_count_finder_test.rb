require File.expand_path('../../../test_helper', __FILE__)
require File.expand_path('../../../../app/utils/historical_count_finder.rb', __FILE__)
# require 'utils/historical_count_finder.rb'
require 'ostruct'

class HistoricalCountFinderTest < ActiveSupport::TestCase

  def setup
    Thread.stubs(:current).returns(:current_user => OpenStruct.new(:time_zone => 'America/New_York'))
  end
  
  def test_should_give_appropriate_this_week_date
    session_start_time = '2012-08-08 04:00:00 UTC'.to_time
    start_time = '2012-08-19 04:00:00 UTC'.to_time
    this_week_time = HistoricalCountFinder.new.calculate_this_week_time(start_time, session_start_time)
    assert_equal('2012-08-22 04:00:00 UTC'.to_time, this_week_time)
  end

  def test_should_give_appropriate_this_week_date_edge_case1
    session_start_time = '2012-08-19 01:00:00 UTC'.to_time
    start_time = '2012-08-19 04:00:00 UTC'.to_time
    this_week_time = HistoricalCountFinder.new.calculate_this_week_time(start_time, session_start_time)
    assert_equal('2012-08-26 01:00:00 UTC'.to_time, this_week_time)
  end

   def test_should_give_appropriate_this_week_date_edge_case2
    session_start_time = '2012-08-19 03:00:00 UTC'.to_time
    start_time = '2012-08-19 04:00:00 UTC'.to_time
    this_week_time = HistoricalCountFinder.new.calculate_this_week_time(start_time, session_start_time)
    assert_equal('2012-08-26 03:00:00 UTC'.to_time, this_week_time)
  end

  def test_should_give_appropriate_this_week_date_edge_case3
    session_start_time = 'Sun, 22 Jul 2012 02:00:00 UTC'.to_time
    start_time = 'Sun Aug 12 04:00:00 UTC 2012'.to_time
    this_week_time = HistoricalCountFinder.new.calculate_this_week_time(start_time, session_start_time)
    assert_equal('2012-08-19 02:00:00 UTC'.to_time, this_week_time)
  end

  # def test_should_return_2_for_equally_distributed_sessions_across_weeks
  #   sessions = []
  #   ['2012-07-28 02:00:00'.to_time, '2012-08-18 02:00:00'.to_time, '2012-08-11 02:00:00'.to_time, '2012-08-04 02:00:00'.to_time].each do |time|
  #       sessions << OpenStruct.new(:session_start_time => time, :count_of_sessions => 2)
  #   end
  #   CoachSession.stubs(:find_historical_sessions_between).returns(sessions)
  #   sessions_hash = Hash.new { |hash, key| hash[key] = {:historical_sessions_count => 0} }
  #   HistoricalCountFinder.new.find('Sun Aug 19 00:00:00 UTC 2012'.to_time, sessions_hash, nil)
  #   assert_equal(8, sessions_hash['Sat Aug 25 02:00:00 UTC 2012'.to_time.to_i][:historical_sessions_count])
  # end
end
