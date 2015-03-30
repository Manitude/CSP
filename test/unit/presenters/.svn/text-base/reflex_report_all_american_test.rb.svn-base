require File.expand_path('../../../test_helper', __FILE__)
require 'app/presenters/reflex_report_all_american'
require 'ostruct'

class ReflexReportAllAmericanTest < ActiveSupport::TestCase

  def test_substitution_data_kle
    create_a_coach = [create_coach_factory]
    coach_info = create_a_coach.collect {|coach_obj| {:coach_id => coach_obj.id, :name => coach_obj.full_name}}
    reflex_report_view = ReflexReportAllAmerican.new(coach_info)
    subs_data_kle = [OpenStruct.new({:requested => 1, :grabber => 1, :coach_id => reflex_report_view.data_hash[0].coach_id})]
    reflex_report_view.populate(subs_data_kle, subs_data_eng = [], coach_data = [], time_off_data = [], eve_data = [], sessions_data = [], response_feedback = [])
    reflex_report_view.substitution_data_kle
    report = ReflexReportAllAmerican.sort_based_on_full_name(reflex_report_view.data_hash)
    data = []
    create_a_coach.each do |coach|
      data << ReflexReport::ReflexSessionDetailsAllAmerican.new(coach.id,coach.full_name.strip, scheduled_totale = 0, scheduled_reflex = 0, scheduled_total = 0, taught_reflex = 0, mins_paused = 0, per_paused = 0, avg_session = 0, per_incomplete = 0, no_show_totale = 0, cancelled = 0, feedback = 0, requested_totale = 0, requested_reflex = 1, requested_total = 0, grabbed_totale = 0 , grabbed_reflex = 1, grabbed_total = 0, in_player = "N/A", requested = 0, approved = 0, denied = 0, total_time_off = 0, complete = 0, incomplete_feedbacks = 0, complete_feedbacks = 0, taught_total = 0, taught_totale = 0)
    end
    m=ReflexReportAllAmerican.sort_based_on_full_name(data)
    assert_equal report[0].grabbed_reflex,m[0].grabbed_reflex
    assert_equal report[0].requested_reflex,m[0].requested_reflex
  end

  def test_substitution_data_eng
    create_a_coach = [create_coach_factory]
    coach_info = create_a_coach.collect {|coach_obj| {:coach_id => coach_obj.id, :name => coach_obj.full_name}}
    reflex_report_view = ReflexReportAllAmerican.new(coach_info)
    subs_data_eng = [OpenStruct.new({:requested => 1, :grabber => 1, :coach_id => reflex_report_view.data_hash[0].coach_id})]
    reflex_report_view.populate(subs_data_kle=[], subs_data_eng, coach_data = [], time_off_data = [], eve_data = [], sessions_data = [], response_feedback = [])
    reflex_report_view.substitution_data_eng
    report = ReflexReportAllAmerican.sort_based_on_full_name(reflex_report_view.data_hash)
    data = []
    create_a_coach.each do |coach|
      data << ReflexReport::ReflexSessionDetailsAllAmerican.new(coach.id,coach.full_name.strip, scheduled_totale = 0, scheduled_reflex = 0, scheduled_total = 0, taught_reflex = 0, mins_paused = 0, per_paused = 0, avg_session = 0, per_incomplete = 0, no_show_totale = 0, cancelled = 0, feedback = 0, requested_totale = 1, requested_reflex = 0, requested_total = 0, grabbed_totale = 1 , grabbed_reflex = 0, grabbed_total = 0, in_player = "N/A", requested = 0, approved = 0, denied = 0, total_time_off = 0, complete = 0, incomplete_feedbacks = 0, complete_feedbacks = 0, taught_total = 0, taught_totale = 0)
    end
    m=ReflexReportAllAmerican.sort_based_on_full_name(data)
    assert_equal report[0].grabbed_totale,m[0].grabbed_totale
    assert_equal report[0].requested_totale,m[0].requested_totale
  end

  def test_coach_data
    create_a_coach = [create_coach_factory]
    coach_info = create_a_coach.collect {|coach_obj| {:coach_id => coach_obj.id, :name => coach_obj.full_name}}
    reflex_report_view = ReflexReportAllAmerican.new(coach_info)
    coach_data = [OpenStruct.new({:hours => 1, :coach_id => reflex_report_view.data_hash[0].coach_id})]
    reflex_report_view.populate(subs_data_kle = [], subs_data_eng = [], coach_data, time_off_data = [], eve_data = [], sessions_data = [], response_feedback = [])
    reflex_report_view.coach_data
    report = ReflexReportAllAmerican.sort_based_on_full_name(reflex_report_view.data_hash)
    data = []
    create_a_coach.each do |coach|
      data << ReflexReport::ReflexSessionDetailsAllAmerican.new(coach.id,coach.full_name.strip, scheduled_totale = 0, scheduled_reflex = 1, scheduled_total = 0, taught_reflex = 0, mins_paused = 0, per_paused = 0, avg_session = 0, per_incomplete = 0, no_show_totale = 0, cancelled = 0, feedback = 0, requested_totale = 1, requested_reflex = 0, requested_total = 0, grabbed_totale = 1 , grabbed_reflex = 0, grabbed_total = 0, in_player = "N/A", requested = 0, approved = 0, denied = 0, total_time_off = 0, complete = 0, incomplete_feedbacks = 0, complete_feedbacks = 0, taught_total = 0, taught_totale = 0)
    end
    m=ReflexReportAllAmerican.sort_based_on_full_name(data)
    assert_equal report[0].scheduled_reflex,m[0].scheduled_reflex
  end

  def test_time_off_data
    create_a_coach = [create_coach_factory]
    coach_info = create_a_coach.collect {|coach_obj| {:coach_id => coach_obj.id, :name => coach_obj.full_name}}
    reflex_report_view = ReflexReportAllAmerican.new(coach_info)
    time_off_data = [OpenStruct.new({:total_time_off => 1, :time_offs_requested =>1, :time_offs_denied=>1, :time_offs_approved => 1 , :coach_id => reflex_report_view.data_hash[0].coach_id})]
    reflex_report_view.populate(subs_data_kle = [], subs_data_eng = [], coach_data = [], time_off_data, eve_data = [], sessions_data = [], response_feedback = [])
    reflex_report_view.time_off_data
    report = ReflexReportAllAmerican.sort_based_on_full_name(reflex_report_view.data_hash)
    data = []
    create_a_coach.each do |coach|
      data << ReflexReport::ReflexSessionDetailsAllAmerican.new(coach.id,coach.full_name.strip, scheduled_totale = 0, scheduled_reflex = 1, scheduled_total = 0, taught_reflex = 0, mins_paused = 0, per_paused = 0, avg_session = 0, per_incomplete = 0, no_show_totale = 0, cancelled = 0, feedback = 0, requested_totale = 1, requested_reflex = 0, requested_total = 0, grabbed_totale = 1 , grabbed_reflex = 0, grabbed_total = 0, in_player = "N/A", requested = 1, approved = 1, denied = 1, total_time_off = 1, complete = 0, incomplete_feedbacks = 0, complete_feedbacks = 0, taught_total = 0, taught_totale = 0)
    end
    m=ReflexReportAllAmerican.sort_based_on_full_name(data)
    assert_equal report[0].requested,m[0].requested
    assert_equal report[0].denied,m[0].denied
    assert_equal report[0].approved,m[0].approved
   
  end
  
  def test_eve_data
    create_a_coach = [create_coach_factory]
    coach_info = create_a_coach.collect {|coach_obj| {:coach_id => coach_obj.id, :name => coach_obj.full_name}}
    reflex_report_view = ReflexReportAllAmerican.new(coach_info)
    eve_data = [OpenStruct.new({:total => 1, :paused => 1, :complete_sessions => 1, :incomplete_sessions => 1, :teaching_complete => 1, :coach_id => reflex_report_view.data_hash[0].coach_id})]
    reflex_report_view.populate(subs_data_kle = [], subs_data_eng = [], coach_data = [], time_off_data=[], eve_data, sessions_data = [], response_feedback = [])
    reflex_report_view.eve_data
    report = ReflexReportAllAmerican.sort_based_on_full_name(reflex_report_view.data_hash)
    data = []
    create_a_coach.each do |coach|
      data << ReflexReport::ReflexSessionDetailsAllAmerican.new(coach.id,coach.full_name.strip, scheduled_totale = 0, scheduled_reflex = 1, scheduled_total = 0, taught_reflex = 0.02, mins_paused = 1.0, per_paused = "100.0", avg_session = 1.0, per_incomplete = 50.0, no_show_totale = 0, cancelled = 0, feedback = 0, requested_totale = 1, requested_reflex = 0, requested_total = 0, grabbed_totale = 1 , grabbed_reflex = 0, grabbed_total = 0, in_player = "N/A", requested = 1, approved = 1, denied = 1, total_time_off = 1, complete = 1, incomplete_feedbacks = 0, complete_feedbacks = 0, taught_total = 0, taught_totale = 0)
    end
    m=ReflexReportAllAmerican.sort_based_on_full_name(data)
    assert_equal report[0].avg_session,m[0].avg_session
    assert_equal report[0].per_paused,m[0].per_paused
    assert_equal report[0].complete,m[0].complete
    assert_equal report[0].mins_paused,m[0].mins_paused
    assert_equal report[0].per_incomplete,m[0].per_incomplete
    assert_equal report[0].taught_reflex,m[0].taught_reflex
  end

  def test_sessions_data
    create_a_coach = [create_coach_factory]
    coach_info = create_a_coach.collect {|coach_obj| {:coach_id => coach_obj.id, :name => coach_obj.full_name}}
    reflex_report_view = ReflexReportAllAmerican.new(coach_info)
    sessions_data = [{'coach_id' => reflex_report_view.data_hash[0].coach_id, 'past_uncancelled_sessions_with_coach_shown_up' => 1, 'past_cancelled_sessions_with_coach_shown_up_cancelled_after_it_started' => 1, 'past_uncancelled_sessions_with_coach_no_show' => 1, 'past_cancelled_sessions_with_coach_no_show_cancelled_after_it_started' => 1, 'cancelled' => 0,'session_count' => 4, 'future_sessions' => 1, 'coach_showed_up' => 1,'seconds_prior_to_session' => 1,'not_showed_up' => 1 , 'session_cancelled_prior_to_session' =>1 , 'session_cancelled_after_session_started' =>1 }]
    reflex_report_view.populate(subs_data_kle = [], subs_data_eng = [], coach_data = [], time_off_data=[], eve_data = [], sessions_data, response_feedback = [])
    reflex_report_view.sessions_data
    report = ReflexReportAllAmerican.sort_based_on_full_name(reflex_report_view.data_hash)
    data = []
    create_a_coach.each do |coach|
      data << ReflexReport::ReflexSessionDetailsAllAmerican.new(coach.id,coach.full_name.strip, scheduled_totale = 4, scheduled_reflex = 1, scheduled_total = 0, taught_reflex = 0, mins_paused = 1.0, per_paused = "100.0", avg_session = 1.0, per_incomplete = 0, no_show_totale = 2, cancelled = 0, feedback = 0, requested_totale = 1, requested_reflex = 0, requested_total = 0, grabbed_totale = 1 , grabbed_reflex = 0, grabbed_total = 0, in_player = "N/A", requested = 1, approved = 1, denied = 1, total_time_off = 1, complete = 1, incomplete_feedbacks = 0, complete_feedbacks = 0, taught_total = 0, taught_totale = 2)
    end
    m=ReflexReportAllAmerican.sort_based_on_full_name(data)
    m[0].in_player_totals=1
    assert_equal report[0].scheduled_totale,m[0].scheduled_totale
    assert_equal report[0].no_show_totale,m[0].no_show_totale
    assert_equal report[0].in_player_totals,m[0].in_player_totals
    assert_equal report[0].taught_totale,m[0].taught_totale
    assert_equal report[0].cancelled,m[0].cancelled
  end

  def test_response_feedback
    create_a_coach = [create_coach_factory]
    coach_info = create_a_coach.collect {|coach_obj| {:coach_id => coach_obj.id, :name => coach_obj.full_name}}
    reflex_report_view = ReflexReportAllAmerican.new(coach_info)
    response_obj = Net::HTTPOK.new(true,200,"OK")
    read_body = "<?xml version='1.0' encoding='UTF-8'?><teachers type='array'>  <teacher>    <external_coach_id>#{reflex_report_view.data_hash[0].coach_id}</external_coach_id>    <total_sessions>3</total_sessions>    <evaluated_sessions>1</evaluated_sessions>  </teacher>  <teacher>    <external_coach_id>1128</external_coach_id>    <total_sessions>1</total_sessions>    <evaluated_sessions>1</evaluated_sessions>  </teacher></teachers>"
    Net::HTTPOK.any_instance.expects(:read_body).returns(read_body)
    reflex_report_view.populate(subs_data_kle = [], subs_data_eng = [], coach_data = [], time_off_data=[], eve_data = [], sessions_data = [], response_feedback = response_obj)
    reflex_report_view.response_feedback
    report = ReflexReportAllAmerican.sort_based_on_full_name(reflex_report_view.data_hash)
    data = []
    create_a_coach.each do |coach|
      data << ReflexReport::ReflexSessionDetailsAllAmerican.new(coach.id,coach.full_name.strip, scheduled_totale = 4, scheduled_reflex = 1, scheduled_total = 0, taught_reflex = 0, mins_paused = 1.0, per_paused = "100.0", avg_session = 1.0, per_incomplete = 0, no_show_totale = 2, cancelled = 4, feedback = 0, requested_totale = 1, requested_reflex = 0, requested_total = 0, grabbed_totale = 1 , grabbed_reflex = 0, grabbed_total = 0, in_player = "N/A", requested = 1, approved = 1, denied = 1, total_time_off = 1, complete = 1, incomplete_feedbacks = 2, complete_feedbacks = 1, taught_total = 0, taught_totale = 1)
    end
    m=ReflexReportAllAmerican.sort_based_on_full_name(data)
    assert_equal report[0].incomplete_feedbacks,m[0].incomplete_feedbacks
    assert_equal report[0].complete_feedbacks,m[0].complete_feedbacks
  end

  def test_sum_of_totale_and_reflex
    create_a_coach = [create_coach_factory]
    coach_info = create_a_coach.collect {|coach_obj| {:coach_id => coach_obj.id, :name => coach_obj.full_name}} 
    reflex_report_view = ReflexReportAllAmerican.new(coach_info)
    sessions_data = [{'coach_id' => reflex_report_view.data_hash[0].coach_id,'cancelled' => 0,'session_count' => 4, 'future_sessions' => 1, 'coach_showed_up' => 1,'seconds_prior_to_session' => 1, 'not_showed_up' => 0 , 'session_cancelled_prior_to_session' =>1 , 'session_cancelled_after_session_started' =>1 },{'coach_id' => reflex_report_view.data_hash[0].coach_id,'cancelled' => 1,'session_count' => 4, 'future_sessions' => 1, 'coach_showed_up' => 1,'seconds_prior_to_session' => 1,'not_showed_up' => 0 , 'session_cancelled_prior_to_session' =>1 , 'session_cancelled_after_session_started' =>1 }]
    eve_data = [OpenStruct.new({:total => 1, :paused => 1, :complete_sessions => 1, :incomplete_sessions => 1, :teaching_complete => 1, :coach_id => reflex_report_view.data_hash[0].coach_id})]
    subs_data_kle = [OpenStruct.new({:requested => 1, :grabber => 1, :coach_id => reflex_report_view.data_hash[0].coach_id})]
    subs_data_eng = [OpenStruct.new({:requested => 1, :grabber => 1, :coach_id => reflex_report_view.data_hash[0].coach_id})]
    coach_data = [OpenStruct.new({:hours => 1, :coach_id => reflex_report_view.data_hash[0].coach_id})]
    reflex_report_view.populate(subs_data_kle , subs_data_eng , coach_data, time_off_data=[], eve_data , sessions_data , response_feedback =[])
    reflex_report_view.substitution_data_kle
    reflex_report_view.substitution_data_eng
    reflex_report_view.coach_data
    reflex_report_view.eve_data
    reflex_report_view.sessions_data
    reflex_report_view.sum_of_totale_and_reflex
    report = ReflexReportAllAmerican.sort_based_on_full_name(reflex_report_view.data_hash)
    data = []
    create_a_coach.each do |coach|
      data << ReflexReport::ReflexSessionDetailsAllAmerican.new(coach.id,coach.full_name.strip, scheduled_totale = 4, scheduled_reflex = 1, scheduled_total = 5, taught_reflex = 0, mins_paused = 1.0, per_paused = "100.0", avg_session = 1.0, per_incomplete = 0, no_show_totale = 2, cancelled = 4, feedback = 0, requested_totale = 1, requested_reflex = 0, requested_total = 2, grabbed_totale = 1 , grabbed_reflex = 0, grabbed_total = 2, in_player = "N/A", requested = 1, approved = 1, denied = 1, total_time_off = 1, complete = 1, incomplete_feedbacks = 2, complete_feedbacks = 1, taught_total = 61.2, taught_totale = 1)
    end
    m=ReflexReportAllAmerican.sort_based_on_full_name(data)
    assert_equal report[0].scheduled_total,m[0].scheduled_total
    assert_equal report[0].requested_total,m[0].requested_total
    assert_equal report[0].grabbed_total,m[0].grabbed_total
    
  end

  def create_coach_factory
    create_a_coach = FactoryGirl.create(:account,:user_name => "pskumar",:full_name => "pskumar",:preferred_name => "NULL",:rs_email => "pskumar@rs.com",:type => "Coach",:bio => "I am a coach",:primary_phone => "1234567890",:primary_country_code => "1",:lotus_qualified =>true)
    create_a_coach.update_attribute(:manager_id,  Account.find_by_user_name("pskumar").id)
    create_a_coach.save
    create_a_coach
  end

  # def sort_based_on_full_name(data_hash) // Duplicate of a class method in ReflexReportAllAmerican class. So commented.
  #   data_hash.sort_by {|details_hash| details_hash.coach_name}
  # end

end
