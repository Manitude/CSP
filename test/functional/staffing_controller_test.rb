require File.expand_path('../../test_helper', __FILE__)

class StaffingControllerTest < ActionController::TestCase
  
  def setup
    login_as_custom_user(AdGroup.coach_manager, 'test21')
  end

  def test_showuld_render_view_report_page
    get :view_report
    assert_response :success
    assert_select 'select#staffing_report_week'
    assert_select 'select#staffing_report_date'
  end

  def test_report_table_format
    get :view_report
    assert_response :success
    time_zone = Time.now.in_time_zone("Eastern Time (US & Canada)").strftime("%Z");
    assert_tag 'table', :attributes => {:id => 'staffing_report_table'}
    assert_select "thead" , 1 do
      assert_select "th" , 9  #nine columns
      assert_select "th" , :text => time_zone+' Date/Time'
      assert_select "th" , :text => 'KST Date/Time'
      assert_select "th" , :text => 'Time Slot ('+time_zone+')'
      assert_select "th" , :text => 'Requests Projected'
      assert_select "th" , :text => 'Actual Scheduled'
      assert_select "th" , :text => 'Delta'
      assert_select "th" , :text => 'Extra Sessions Scheduled'
      assert_select "th" , :text => 'Extra Sessions Grabbed'
      assert_select "th" , :text => 'Actions'
    end
  end

  def test_get_report_data_for_a_week
    file = FactoryGirl.create(:staffing_file_info, :start_of_the_week => '2012-05-27 10:00:00', :status => 'Success')
    FactoryGirl.create(:staffing_data, :slot_time => '2025-05-20 10:00:00'.to_time, :staffing_file_info_id => file.id)
    FactoryGirl.create(:staffing_data, :slot_time => '2025-05-20 11:00:00'.to_time, :staffing_file_info_id => file.id)
    FactoryGirl.create(:staffing_data, :slot_time => '2025-05-20 12:00:00'.to_time, :staffing_file_info_id => file.id)

    FactoryGirl.create(:coach_session, :language_identifier => 'KLE', :eschool_session_id => 251, :session_start_time => '2025-05-20 10:00:00'.to_time, :type=>"ConfirmedSession")
    session1 = FactoryGirl.create(:extra_session, :type => 'ExtraSession', :language_identifier => 'KLE', :eschool_session_id => 252, :session_start_time => '2025-05-20 10:00:00'.to_time)
    sub = FactoryGirl.create(:substitution, :session_type => 'ExtraSession', :coach_session_id => session1.id, :grabbed => 1)
    post :get_report_data_for_a_week, :week_id => file.id
    assert_response :success
    report_data = (JSON.parse(@response.body))["report_data"][0]["staffing_data"]
    assert_equal '06:00 AM', report_data["timeslot"]
    assert_equal '05/20/2025 06:00 AM', report_data["timeslot_est"]
    assert_equal '05/20/2025 07:00 PM', report_data["timeslot_kst"]
    assert_equal -9, report_data["delta"]
    assert_equal 'Tue, 05/20/2025', report_data["date_of_the_slot"]
    assert_equal 1, report_data["actual_scheduled"]
    assert_equal 1, report_data["extra_sessions_scheduled"]
    assert_equal 1, report_data["extra_sessions_grabbed"]
    assert_equal '#B0D89E', report_data["row_color"]
  end

  def test_populate_color_scheme
    file = FactoryGirl.create(:staffing_file_info, :start_of_the_week => '2012-05-27 10:00:00', :status => 'Success')
    FactoryGirl.create(:staffing_data, :slot_time => '2025-05-20 10:00:00'.to_time, :number_of_coaches => 2, :staffing_file_info_id => file.id)
    FactoryGirl.create(:staffing_data, :slot_time => '2025-05-20 11:00:00'.to_time, :number_of_coaches => 5, :staffing_file_info_id => file.id)
    FactoryGirl.create(:staffing_data, :slot_time => '2025-05-20 12:00:00'.to_time, :number_of_coaches => 8, :staffing_file_info_id => file.id)
    FactoryGirl.create(:staffing_data, :slot_time => '2025-05-20 13:00:00'.to_time, :number_of_coaches => 0, :staffing_file_info_id => file.id)
    FactoryGirl.create(:staffing_data, :slot_time => '2025-05-20 14:00:00'.to_time, :number_of_coaches => -1, :staffing_file_info_id => file.id)
    FactoryGirl.create(:staffing_data, :slot_time => '2025-05-20 15:00:00'.to_time, :number_of_coaches => -4, :staffing_file_info_id => file.id)
    FactoryGirl.create(:staffing_data, :slot_time => '2025-05-20 16:00:00'.to_time, :number_of_coaches => -9, :staffing_file_info_id => file.id)

    post :get_report_data_for_a_week, :week_id => file.id
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_equal '#E6EFB9', json_response["report_data"][0]["staffing_data"]["row_color"]
    assert_equal '#CAE19A', json_response["report_data"][1]["staffing_data"]["row_color"]
    assert_equal '#F8F49B', json_response["report_data"][4]["staffing_data"]["row_color"]
    assert_equal '#F79C7B', json_response["report_data"][6]["staffing_data"]["row_color"]
  end

  def test_export_staffing_data_as_csv
    file = FactoryGirl.create(:staffing_file_info, :start_of_the_week => '2012-05-27 10:00:00', :status => 'Success')
    FactoryGirl.create(:staffing_data, :slot_time => '2025-05-20 10:00:00'.to_time, :number_of_coaches => 2, :staffing_file_info_id => file.id)
    FactoryGirl.create(:staffing_data, :slot_time => '2025-05-20 11:00:00'.to_time, :number_of_coaches => 5, :staffing_file_info_id => file.id)

    post :export_staffing_report, :week_id => file.id
    assert_response :success
  end

  def test_show_create_extra_session_popup_reflex_smr
    language = Language.find_by_identifier("KLE")
    language = FactoryGirl.create(:language, :identifier=> 'KLE', :is_lotus => 1) unless language
    coach = FactoryGirl.create(:account, :user_name => 5.random_letters, :type => 'Coach', :rs_email => "rs_email#{2.random_letters}@rosettastone.com")
    qualification = FactoryGirl.create(:qualification, :coach_id => coach.id , :language_id => language.id ,:max_unit => language.max_unit)
    get :show_create_extra_session_popup_reflex_smr, :lang_identifier=>"KLE", :start_time=>"06-14-2012 04:00 AM"
    json_response = JSON.parse(@response.body)
    assert_equal "THU 06/14/12 12:00AM", json_response["session_start_time"].to_s
  end

  def test_create_extra_session_reflex_smr
    post :create_extra_session_reflex_smr, :lang_id=>Language.find_by_identifier("KLE"), :start_time=>"06/14/2012 04:00 AM", :excluded_coaches=>""
    assert_response :success
    assert_equal "Extra Session created successfully." ,@response.body
  end

end
