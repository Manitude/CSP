require File.expand_path('../../../test_helper', __FILE__)
require 'dupe'


class CoachActivityReportUtilsTest < ActiveSupport::TestCase

  def test_blank_content_totale
      coach_id = 24
    Eschool::CoachActivity.stubs(:activity_report_for_coaches).returns([
    	{
    		'coach_id'=> coach_id,
    		'future_sessions' => 3,
    		'past_uncancelled_sessions_with_coach_shown_up' => 2,
    		'past_cancelled_sessions_with_coach_shown_up_cancelled_after_it_started' => 4,
    		'past_uncancelled_solo_sessions_with_coach_shown_up' => 1,
    		'past_cancelled_solo_sessions_with_coach_shown_up_cancelled_after_it_started' => 2,
    		'past_uncancelled_sessions_with_coach_no_show' => 1,
    		'past_cancelled_sessions_with_coach_no_show_cancelled_after_it_started' => 2,
    		'seconds_prior_to_session' => 18,
    		'future_cancelled_sessions' => 8,
    		'past_cancelled_sessions_cancelled_before_it_started' => 3
    	}
    ])
    Eschool::CoachActivity.stubs(:get_session_feedback_per_teacher_counts).returns ""
    Coach.stubs(:coach_ids_of_that_language).returns([Dupe.create(:coach, :id => coach_id, :full_name => 'KD Billa')])
    Coach.stubs(:substitution_grabbed).returns([ Dupe.create(:coach, :requested => 6, :coach_id => coach_id, :grabber => 0) ])

    report_hash = CoachActivityReportUtils.fetch_report_for_languages(['ARA'], nil, Time.now - 1.week, Time.now + 1.week)
    assert_equal 1, report_hash.size
    coach_data = report_hash[coach_id.to_s]
    assert_equal 3, 	coach_data[:scheduled_future]
    assert_equal 6, 	coach_data[:scheduled_past]
    assert_equal 1.5, 	coach_data[:scheduled_past_solo]
    assert_equal 3.0, 	coach_data[:taught_count]
    assert_equal 3, 	coach_data[:no_show]
    assert_equal 18, 	coach_data[:in_player_totals]
    assert_equal 11, 	coach_data[:cancelled_count]
  end

  def test_blank_content_all_american
    coach_id = 25
    Coach.stubs(:substitution_grabbed).returns([ Dupe.create(:coach, :requested => 6, :coach_id => coach_id, :grabber => 1) ])
    Coach.stubs(:coach_ids_of_that_language).returns([Dupe.create(:coach, :id => coach_id, :full_name => 'KD Billa')])
    CoachSession.stubs(:no_of_hours_coach_scheduled).returns([Dupe.create(:coach_session, :coach_id=>coach_id, :hours => 10, :future_sessions => 3)])
    Eschool::CoachActivity.stubs(:get_session_feedback_per_teacher_counts).returns ""
    Eschool::CoachActivity.stubs(:activity_report_for_coaches).returns([
      {
        'coach_id'=> coach_id,
        'future_sessions' => 3,
        'past_uncancelled_sessions_with_coach_shown_up' => 2,
        'past_cancelled_sessions_with_coach_shown_up_cancelled_after_it_started' => 4,
        'past_uncancelled_solo_sessions_with_coach_shown_up' => 1,
        'past_cancelled_solo_sessions_with_coach_shown_up_cancelled_after_it_started' => 2,
        'past_uncancelled_sessions_with_coach_no_show' => 1,
        'past_cancelled_sessions_with_coach_no_show_cancelled_after_it_started' => 2,
        'seconds_prior_to_session' => 18,
        'future_cancelled_sessions' => 8,
        'past_cancelled_sessions_cancelled_before_it_started' => 3
      }
    ])
    report_hash = CoachActivityReportUtils.fetch_report_for_languages(['ENG','KLE'], nil, Time.now - 1.week, Time.now + 1.week)
    assert_equal 1, report_hash.size
    coach_data  = report_hash[coach_id.to_s]
    assert_equal 3,   coach_data[:scheduled_future]
    assert_equal 6,   coach_data[:scheduled_past]
    assert_equal 1.5,   coach_data[:scheduled_past_solo]
    assert_equal 3.0,   coach_data[:taught_count]
    assert_equal 3,   coach_data[:no_show]
    assert_equal 18,  coach_data[:in_player_totals]
    assert_equal 11,  coach_data[:cancelled_count]
  end

end