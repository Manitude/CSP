require File.dirname(__FILE__) + '/../test_helper'
require 'report_controller'

class ReportControllerTest < ActionController::TestCase
  fixtures :accounts, :languages
  
  def test_page_opens
    post :index
    assert_response  :success
  end

  def test_count_coaches_qualified_to_teach
    post :get_qualified_coaches_for_language,
      :lang_identifier => "ARA"
    assert_response  :success
    assert_equal "<b>8</b> active coaches are qualified to teach <b>#{@arabic.display_name}</b>", @response.body

  end

  def test_count_coaches_qualified_to_teach_for_english
    Coach.delete_all
    create_coach_with_qualifications('rajkumar', ['ENG'])
    create_coach_with_qualifications('rajkumarone', ['ENG'])
    post :get_qualified_coaches_for_language,
      :lang_identifier => "ENG"
    assert_response  :success
    assert_equal "<b>2</b> active coaches are qualified to teach <b>English (American)</b>", @response.body #Shouldn't count that same guy twice

  end

  def test_blank_report_skeleton
    Eschool::CoachActivity.stubs(:activity_report_for_coaches).returns([])
    xhr :post, :get_report_ui,
      :lang_identifier => "ARA", :region => "", :timeframe => "Today"
    assert_response  :success
    # TODO : Change the AJAX calling way and then assert the fields
    #
    #assert_tag 'table', :attributes => {:id => 'coach_report_table'}
    #assert_select "thead" , 1 do
    #  assert_select "tr" , 2 # two headers
    #end
    #
    #assert_select "tbody" , 1 do
    #  assert_select "tr" , 8 # eight ARA coaches
    #end
    #
    #assert_select "tfoot" , 1 do
    #  assert_select "tr" , 1 # one footer
    #end

  end

  def test_report_session_count_when_there_are_sessions
    coach_activity_obj = []
    lang_coaches = Language.find_by_identifier('GRK').coaches
    lang_coaches.each do |coach|
      coach.delete unless coach.user_name == 'jramanathan'
    end
    
    a = accounts(:jramanathan)
    ca = {
      'seconds_prior_to_session' =>nil,
      'coach_showed_up' => "1",
      'future_sessions' => "4",
      'session_count'   => "11",
      'full_name'      => a.full_name,
      'cancelled'       => "0",
      'coach_id'        => a.id }
    coach_activity_obj << ca
    Eschool::CoachActivity.stubs(:activity_report_for_coaches).returns(coach_activity_obj)
    xhr :post, :get_report_ui,
      :lang_identifier => "GRK", :region => "", :timeframe => "Custom",
      :start_date => "#{(Time.now - 1.day).strftime("%B %d, %Y")}",
      :end_date   => "#{(Time.now + 1.day).strftime("%B %d, %Y")}"
    assert_response  :success
    # TODO : Change the AJAX calling way and then assert the fields
    #assert_tag 'table', :attributes => {:id => 'coach_report_table'}
    #
    #assert_select "tbody" , 1 do
    #  assert_select "tr" do
    #    assert_select "td", :text => "Jramanathan"
    #    assert_select "td", :text => "7 / 4"   #7 past,4 future, totally 11
    #  end
    #end
    #
    #assert_select "tfoot" , 1 do
    #  assert_select "tr" do
    #    assert_select "th", :text => "Language Total"
    #    assert_select "th", :text => "7/4" #since only one coach's session
    #  end
    #end

  end

  def test_show_some_fields_as_na_when_there_are_no_past_sessions
    coach_activity_obj = []
    lang_coaches = Language.find_by_identifier('GRK').coaches
    lang_coaches.each do |coach|
      coach.delete unless coach.user_name == 'jramanathan'
    end
    
    a = accounts(:jramanathan)
    ca = {
      'seconds_prior_to_session' =>nil,
      'coach_showed_up' => "0",
      'future_sessions' => "2",
      'session_count'   => "0",
      'full_name'       => a.full_name,
      'cancelled'       => "0",
      'coach_id'        => a.id
    }
    coach_activity_obj << ca
    Eschool::CoachActivity.stubs(:activity_report_for_coaches).returns(coach_activity_obj)

    xhr :post, :get_report_ui,
      :lang_identifier => "GRK", :region => "", :timeframe => "Custom",
      :start_date => "#{(Time.now - 1.day).strftime("%B %d, %Y")}",
      :end_date   => "#{(Time.now + 1.day).strftime("%B %d, %Y")}"
    assert_response  :success
                        # TODO : Change the AJAX calling way and then assert the fields
    #assert_tag 'table', :attributes => {:id => 'coach_report_table'}
    #
    #assert_select "tbody" , 1 do
    #  assert_select "tr", 1 do
    #    assert_select "td", :text => "Jramanathan"
    #    assert_select "td", :text => "N/A"
    #  end
    #end

  end

  def test_solo_session_data_point_present
    Eschool::CoachActivity.stubs(:activity_report_for_coaches).returns([])
    xhr :post, :get_report_ui,
      :lang_identifier => "ARA", :region => "", :timeframe => "Today"
    assert_response  :success
    assert_not_nil @response.body.index("<table id=\\\"coach_report_table\\\"")
    assert_not_nil @response.body.index("<th class=\\\"thl14 activity_report_cell\\\">Solo (Hrs)</th>")
    assert_not_nil @response.body.index("<td class=\\\"td14\\\">")
    assert_not_nil @response.body.index("<th class=\\\"tfd14\\\">")
  end


  private
  
  def create_language_qualifications_for(coach_list, lang_identifier)
    max_unit = lang_identifier == "KLE" ? 1 : 8
    language_max_unit_array = [{:language => Language[lang_identifier].id, :max_unit => max_unit}]
    coach_list.each do |coach|
      create_qualifications(coach.id,language_max_unit_array)
    end
  end
  
  def setup
    login_as_coach_manager
#    Qualification.delete_all # I don't want others to interfere
    @arabic       = languages(:language_001) #for some joy Arabic is called as 'language_001'
    @eng_american = languages(:ENG)
    @advanced_eng = languages(:KLE)
    @coachara1 = accounts(:coachara1)
    @coachara2 = accounts(:coachara2)
    create_language_qualifications_for([@coachara1, @coachara2], "ARA")

  end

end
