require File.dirname(__FILE__) + '/../../test_helper'
require 'report/reflexes_controller'
require 'ostruct'

class Report::ReflexesControllerTest< ActionController::TestCase

  def test_generate
    login_as_custom_user(AdGroup.coach_manager, 'test')
    Coach.delete_all
    coach = create_coach_with_qualifications("pskumar", ['KLE'])
    coach_session1 = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :language_identifier => "KLE", :session_start_time => Time.now.utc.beginning_of_hour + 1.day)
    coach_session2 = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :language_identifier => "KLE", :session_start_time => Time.now.utc.beginning_of_hour + 2.day)
    response = get :generate, {:start_date => Time.now.utc.strftime("%F"), :end_date => (Time.now.utc+5.days).strftime("%F")}
    assert_response :success
    assert_tag 'table', :attributes => {:id => 'coach_report_table'}
    assert_select "tbody" , 1 do
      assert_select "td", :text => "pskumar"
      assert_select "td", :text => "1.0"
    end
    substitution = FactoryGirl.create(:substitution, :coach_id => coach.id, :grabber_coach_id => coach.id, :grabbed => 1, :coach_session_id => coach_session1.id) 
    substitution.save! 
    unavailability_template = FactoryGirl.build(:unavailable_despite_template, :coach_id => coach.id, :start_date => Time.now.utc+3.days, :end_date => Time.now.utc + 4.days, :unavailability_type => 0, :approval_status => 1 ) 
    unavailability_template.save(:validate => false)
    response = get :generate, {:start_date => Time.now.utc.strftime("%F"), :end_date => (Time.now.utc+5.days).strftime("%F")}
    assert_response :success
    assert_tag 'table', :attributes => {:id => 'coach_report_table'}
    assert_select "tbody" , 1 do
      assert_select "td", :text => "pskumar", :count=>1
      assert_select "td", :text => "1.0", :count=>1
      assert_select "td", :text => "1/1", :count=>1
    end
  end
  
  def test_generate_eng_empty_skeleton
    login_as_custom_user(AdGroup.coach_manager, 'test')
    Coach.stubs(:time_off).returns([])
    CoachSession.stubs(:no_of_hours_coach_scheduled).returns([])
    Coach.stubs(:substitution_grabbed).returns([])
    Coach.stubs(:substitution_grabbed).returns([])
    CoachActivityFetcher.any_instance.stubs(:coach_session_details).returns([])
    Eschool::CoachActivity.stubs(:activity_report_for_coaches).returns([])
    response_obj = Net::HTTPOK.new(true,200,"OK")
    Eschool::Coach.stubs(:get_session_feedback_per_teacher_counts).returns(response_obj)
    read_body = "<?xml version='1.0' encoding='UTF-8'?>"
    Net::HTTPOK.any_instance.stubs(:read_body).returns(read_body)
    ReflexReportAllAmerican.any_instance.expects(:get_complete_all_american_english_report).returns([])
    response = get :generate_eng, {:start_date => "2020-04-01", :end_date => "2020-05-01"}
    assert_response :success
    assert_tag 'table', :attributes => {:id => 'coach_report_table'}
    assert_select "table" , 1 do
      assert_select "tr", :count =>3
      assert_select "td", :count =>24
    end
  end

end
