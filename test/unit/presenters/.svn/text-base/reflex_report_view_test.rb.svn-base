require File.expand_path('../../../test_helper', __FILE__)
require 'app/presenters/reflex_report_view.rb'
require 'ostruct'
class ReflexReportViewTest < ActiveSupport::TestCase
  
  def test_substitution_data
    create_a_coach = [FactoryGirl.create(:coach)]
    reflex_report_view = ReflexReportView.new(create_a_coach)
    subs_data = [OpenStruct.new({:requested => 1, :grabber => 1, :coach_id => reflex_report_view.data_hash[0].coach_id})]
    reflex_report_view.populate(subs_data, coach_data = [], time_off_data = [], eve_data= [])
    reflex_report_view.substitution_data
    report = reflex_report_view.sort_based_on_full_name
    coaches = report["coaches"]
    data = []
    create_a_coach.each do |coach|
      data << ReflexReport::ReflexSessionDetails.new(coach.id,coach.full_name.strip,0,1,1)
    end
    m = sort_based_on_full_name(data)
    m_coach = m["coaches"]
    
    assert_equal coaches[0].grabbed,m_coach[0].grabbed
    assert_equal coaches[0].substitution,m_coach[0].substitution
  end

  def test_coach_data
    create_a_coach = [FactoryGirl.create(:coach)]
    reflex_report_view = ReflexReportView.new(create_a_coach)
    coach_data = [OpenStruct.new({:hours => 1 , :coach_id => reflex_report_view.data_hash[0].coach_id})]
    reflex_report_view.populate(subs_data = [], coach_data, time_off_data = [], eve_data= [])
    reflex_report_view.coach_data
    report = reflex_report_view.sort_based_on_full_name
    coaches = report["coaches"]
    data = []
    create_a_coach.each do |coach|
      data << ReflexReport::ReflexSessionDetails.new(coach.id,coach.full_name.strip,0.5)
    end
    m=sort_based_on_full_name(data)
    m_coach = m["coaches"]
    assert_equal coaches[0].hours_count,m_coach[0].hours_count
  end

  def test_time_off_data
    create_a_coach = [FactoryGirl.create(:coach)]
    reflex_report_view = ReflexReportView.new(create_a_coach)
    time_off_data = [OpenStruct.new({:total_time_off => 0, :time_offs_requested => 1, :time_offs_denied => 1, :time_offs_approved => 1, :coach_id => reflex_report_view.data_hash[0].coach_id})]
    reflex_report_view.populate(subs_data = [], coach_data = [], time_off_data, eve_data= [])
    reflex_report_view.time_off_data
    report = reflex_report_view.sort_based_on_full_name
    coaches = report["coaches"]
    data = []
    create_a_coach.each do |coach|
      data << ReflexReport::ReflexSessionDetails.new(coach.id,coach.full_name.strip,0,0,0,1,1,1,0,0,0,0,0,0,0)
    end
    m=sort_based_on_full_name(data)
    m_coach = m["coaches"]
    assert_equal coaches[0].requested,m_coach[0].requested
    assert_equal coaches[0].denied,m_coach[0].denied
    assert_equal coaches[0].approved,m_coach[0].approved
    assert_equal coaches[0].total_time_off,m_coach[0].total_time_off
  end
  
  def test_eve_data
    create_a_coach = [FactoryGirl.create(:coach)]
    reflex_report_view = ReflexReportView.new(create_a_coach)
    eve_data = [OpenStruct.new({:total => 1, :paused => 1, :complete_sessions => 1, :incomplete_sessions => 1, :teaching_complete => 1, :coach_id => reflex_report_view.data_hash[0].coach_id})]
    reflex_report_view.populate(subs_data = [], coach_data = [], time_off_data = [], eve_data)
    reflex_report_view.eve_data
    report = reflex_report_view.sort_based_on_full_name
    coaches = report["coaches"]
    data = []
    create_a_coach.each do |coach|
      data << ReflexReport::ReflexSessionDetails.new(coach.id,coach.full_name.strip,0,0,0,1,1,1,0,1.0,"100.0",1.0,50.0,1,1.0)
    end
    m=sort_based_on_full_name(data)
    m_coach = m["coaches"]
    assert_equal coaches[0].avg_session,m_coach[0].avg_session
    assert_equal coaches[0].per_paused,m_coach[0].per_paused
    assert_equal coaches[0].complete,m_coach[0].complete
    assert_equal coaches[0].paused,m_coach[0].paused
    assert_equal coaches[0].incomplete,m_coach[0].incomplete
  end

  def sort_based_on_full_name(data_hash)
    {"coaches"=>data_hash.sort_by {|details_hash| details_hash.coach_name}}
  end

end
