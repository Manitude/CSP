require File.expand_path('../../test_helper', __FILE__)
require File.expand_path('../../test_data', __FILE__)

class ManagerPortalControllerTest < ActionController::TestCase
  #fixtures :accounts, :languages, :coach_sessions, :unavailable_despite_templates
  #fixtures :languages

  def test_login_as_manager_and_check_for_manager
    user = login_as_custom_user(AdGroup.coach_manager, 'test21')
    assert_true user.is_manager?
  end

  def test_login_as_learner_dashboard_user_and_check_for_manager
    user = login_as_custom_user(AdGroup.led_user, 'test21')
    assert_false user.is_manager?
  end

  def test_login_as_moderator_and_check_for_manager
    user = login_as_custom_user(AdGroup.community_moderator, 'test21')
    assert_false user.is_manager?
  end

  def test_login_as_admin_and_check_for_manager
    user = login_as_custom_user(AdGroup.admin, 'test21')
    assert_false user.is_manager?
  end

  def test_login_as_coach_and_check_for_manager
    user = login_as_custom_user(AdGroup.coach, 'test21')
    assert_false user.is_manager?
  end

  def test_login_as_support_user_and_check_for_manager
    user = login_as_custom_user(AdGroup.support_user, 'test21')
    assert_false user.is_manager?
  end

  def test_login_as_support_lead_and_check_for_manager
    user = login_as_custom_user(AdGroup.support_lead, 'test21')
    assert_false user.is_manager?
  end

  # This test is incomplete.
  def test_substitutions_report_without_records
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    create_substituion_within(1.hour)
    create_substituion_within(2.hour)
    get :substitutions_report
    assert_response :success
    # We removing incomplete  selector.
    post :substitutions_report, {"duration"=>"All", "GenerateReport"=>"GenerateReport", "start_date"=>"August 18, 2011", "coach_id"=>"", "action"=>"substitutions_report", "lang_id"=>"", "grabber_coach_id"=>"--", "controller"=>"manager_portal", "end_date"=>"August 18, 2011", "grabbed_within"=>"Show All"}
    assert_template "shared/_substitutions_report_partial"
    assert_tag 'div', :attributes => {:id => 'substitutions_table'}
    assert_tag 'table', :attributes => {:id => 'sub_report_table'}
    assert_select "th" , 9
    assert_select "td" , 18
    assert_select "tr" , 3
    post :substitutions_report, {"duration"=>"All", "GenerateReport"=>"GenerateReport", "start_date"=>"August 18, 2011", "coach_id"=>"", "action"=>"substitutions_report", "lang_id"=>"", "grabber_coach_id"=>"--", "controller"=>"manager_portal", "end_date"=>"August 18, 2011", "grabbed_within"=>"Show All","hidden_lang_id"=>""}
  end

  def test_fetch_mail_address
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    get :fetch_mail_address, {"id"=>"all"}
    assert_response :success
    user = login_as_custom_user(AdGroup.support_lead, 'test21')
    get :fetch_mail_address, {"id"=>"all"}
    assert_response :success
  end
  def test_send_mail_to_coaches
    user = login_as_custom_user(AdGroup.support_lead, 'test21')
    @request.env['HTTP_REFERER'] = 'http://coachportal.rosettastone.com'
    post :send_mail_to_coaches, {"subject" => "This is test", "body" => "testing send mail to coaches", "to" => "epandiyan@gmail.com"}#, {'HTTP_REFERER'=>dashboard_url}
    assert_response :redirect
  end
  def test_get_teachers_for_manager_in_language
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    get :get_teachers_for_manager_in_language, {"lang_identifier" => "ENG"}
    assert_response :success
    get :get_teachers_for_manager_in_language, {"lang_identifier" => "all"}
    assert_response :success
  end
  def test_get_teachers_for_language
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    get :get_teachers_for_language, {"lang_identifier" => "ENG"}
    assert_response :success
  end
  def test_get_time_off_ui
    #@request.env['HTTP_REFERER'] = 'http://coachportal.rosettastone.com'
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    xhr :post, :get_time_off_ui, {"timeframe" => "Last month", "start_date"=>"January 18, 2014", "end_date"=>"July 18, 2014", "lang_identifier" => "ENG", "time_off_status" => "Approved"}
    assert_response :success
  end
  def test_export_time_off_report
    #@request.env['HTTP_REFERER'] = 'http://coachportal.rosettastone.com'
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    post :export_time_off_report, {"timeframe_hidden" => "Last month", "start_date_hidden"=>"January 18, 2014", "end_date_hidden"=>"July 18, 2014", "lang_identifier_hidden" => "ENG", "time_off_status_hidden" => "Approved"}
    assert_response :success
  end

  def test_export_to_csv
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    get :export_to_csv, {"lang_id_hidden" => "", "coach_id_hidden" => "Extra Sessions", "duration_hidden" => "Last month", "start_date_hidden"=>"January 18, 2014", "end_date_hidden"=>"July 18, 2014", "grabber_coach_id_hidden" => "", "grabbed_within_hidden" => "More than 3 days","send" => "true"}
    assert_response :success
    get :export_to_csv, {"lang_id_hidden" => "", "coach_id_hidden" => "Extra Sessions", "duration_hidden" => "Yesterday", "start_date_hidden"=>"January 18, 2014", "end_date_hidden"=>"July 18, 2014", "grabber_coach_id_hidden" => "", "grabbed_within_hidden" => "One hour","send" => "true"}
    assert_response :success
    get :export_to_csv, {"lang_id_hidden" => "", "coach_id_hidden" => "Extra Sessions", "duration_hidden" => "Today", "start_date_hidden"=>"January 18, 2014", "end_date_hidden"=>"July 18, 2014", "grabber_coach_id_hidden" => "", "grabbed_within_hidden" => "2 hours","send" => "false"}
    assert_response :success
    get :export_to_csv, {"lang_id_hidden" => "", "coach_id_hidden" => "Extra Sessions", "duration_hidden" => "Tomorrow", "start_date_hidden"=>"January 18, 2014", "end_date_hidden"=>"July 18, 2014", "grabber_coach_id_hidden" => "", "grabbed_within_hidden" => "12 hours","send" => "true"}
    assert_response :success
    get :export_to_csv, {"lang_id_hidden" => "", "coach_id_hidden" => "Extra Sessions", "duration_hidden" => "Next Week", "start_date_hidden"=>"January 18, 2014", "end_date_hidden"=>"July 18, 2014", "grabber_coach_id_hidden" => "", "grabbed_within_hidden" => "24 hours","send" => "true"}
    assert_response :success
    get :export_to_csv, {"lang_id_hidden" => "", "coach_id_hidden" => "Extra Sessions", "duration_hidden" => "Next Month", "start_date_hidden"=>"January 18, 2014", "end_date_hidden"=>"July 18, 2014", "grabber_coach_id_hidden" => "", "grabbed_within_hidden" => "48 hours","send" => "true"}
    assert_response :success
    get :export_to_csv, {"lang_id_hidden" => "", "coach_id_hidden" => "Extra Sessions", "duration_hidden" => "Last month", "start_date_hidden"=>"January 18, 2014", "end_date_hidden"=>"July 18, 2014", "grabber_coach_id_hidden" => "", "grabbed_within_hidden" => "72 hours","send" => "true"}
    assert_response :success
    get :export_to_csv, {"lang_id_hidden" => "", "coach_id_hidden" => "Extra Sessions", "duration_hidden" => "Last month", "start_date_hidden"=>"January 18, 2014", "end_date_hidden"=>"July 18, 2014", "grabber_coach_id_hidden" => "", "grabbed_within_hidden" => "36 hours","send" => "true"}
    assert_response :success
    get :export_to_csv, {"lang_id_hidden" => "", "coach_id_hidden" => "Extra Sessions", "duration_hidden" => "Last month", "start_date_hidden"=>"January 18, 2014", "end_date_hidden"=>"July 18, 2014", "grabber_coach_id_hidden" => "", "grabbed_within_hidden" => "Open","send" => "true"}
    assert_response :success
  end



  def test_substitutions_report_without_records
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    get :substitutions_report
    assert_response :success
    # We removing incomplete selector.
    post :substitutions_report, {"duration"=>"Last week", "GenerateReport"=>"GenerateReport", "start_date"=>"August 18, 2011", "coach_id"=>"", "action"=>"substitutions_report", "lang_id"=>"", "grabber_coach_id"=>"--", "controller"=>"manager_portal", "end_date"=>"August 18, 2011", "grabbed_within"=>"Show All"}
    assert_template "shared/_substitutions_report_partial"
    assert_true response.body.include?("substitutions_table")
    assert_true response.body.include?("There are currently no substitution reports.")
  end


  def test_login_as_coach_from_manager_and_login_back_as_super_user_and_check_for_notice
    user = login_as_custom_user(AdGroup.coach_manager, 'skumar')
    User.stubs(:authenticate).returns user #Simulate a success authentication
    coach = create_coach_with_qualifications
    @controller = ManagerPortalController.new
    get :sign_in_as_my_coach, :coach_id => coach.id
    assert_response :redirect
    assert_equal "Signed in as #{coach.user_name}.", flash[:notice]
    @controller = CoachPortalController.new
    get :sign_in_as_super_user
    assert_response :redirect
    assert_equal "Signed back in as skumar from #{coach.user_name}", flash[:notice]
  end

  def test_week_view
    Coach.any_instance.stubs(:threshold_reached?).returns([false,false])
    stub_eschool_call_for_find_by_id({})
    #eschool_session_objs = []
    session_xml = <<EOF
    <eschool_sessions>
      <eschool_session>
        <eschool_session_id>123456</eschool_session_id>
        <language>ARA</language>
        <level>1</level>
        <unit>1</unit>
        <teacher>dutchfellow1</teacher>
        <start_time time_zone="UTC">2025-06-13 12:00:00</start_time>
        <duration_in_seconds>3600</duration_in_seconds>
        <cancelled>false</cancelled>
        <number_of_seats>4</number_of_seats>
        <learners_signed_up>1</learners_signed_up>
        <students_attended>0</students_attended>
        <wildcard>true</wildcard>
        <teacher_confirmed>false</teacher_confirmed>
        <wildcard_units>1,2,3,4,5,6,7,8,9,10,11,12</wildcard_units>
        <wildcard_locked>false</wildcard_locked>
        <teacher_confirmed>true</teacher_confirmed>
        <learner_details type="array">
        </learner_details>
        <launch_session_url>
          javascript:launchOnline('http://studio.rosettastone.com/launch?app%5Bcancellation_grace_period_in_seconds%5D=3000&amp;app%5Bclass_definition_url%5D=rsus%3A%2F%2Feschool_en-US_U_01&amp;app%5Beschool_session_id%5D=8492&amp;app%5Bfull_name%5D=coach1&amp;app%5Binstruction_end_time%5D=2011-01-21T05%3A50%3A00-05%3A00&amp;app%5Blaunch_controller_mode%5D=teacher&amp;app%5Broom_password%5D=PoL1kad0ts&amp;app%5Broom_user_name%5D=cocomo-eschool-dev%40rosettastone.com&amp;app%5Bscheduler_api_endpoint%5D=http%3A%2F%2Fstudio.rosettastone.com%2Fapi%2F&amp;app%5Bseconds_before_end_to_show_countdown_timer%5D=300&amp;app%5Bskip_audio_setup%5D=false&amp;app%5Bstart_time%5D=2011-01-21T05%3A00%3A00-05%3A00&amp;app%5Bsystem_recommendations_url%5D=http%3A%2F%2Flaunch.rosettastone.com%2Fen%2Fsystem_recommendations%2Fcommunity&amp;app%5Bteacher_id%5D=182&amp;app%5Bteacher_picture_url%5D=http%3A%2F%2Feschool.rosettastone.com%2Fimages%2Fdefault_teacher_image.jpg&amp;app%5Btime_after_start_to_allow_cancellation_in_seconds%5D=36&amp;app%5Bvideo_quality%5D=100&amp;app%5Bweb_services_access_key%5D=248acbe6a91020199a9b5adb609468316eb3e14eba4c9d628b9625bc1ced0bbfd58b2e8996cab88d3fecd1d914a383ea71fc8cbc7c87c73781bce576609bbb5041765984d29cfa90069b1bb5ca8a98b171acd51d829662f32037062d823d20c80e2b549e6f03b097f3c127774ef015b496d2a7468a3d5802e836d8eaea3ee633')
        </launch_session_url>
        <average_attendance>0.0</average_attendance>
        <external_village_id>8</external_village_id>
      </eschool_session>
   </eschool_sessions>
EOF
    eschool_session_objs = parse_session_xml_to_array_of_objects(session_xml)
    coach = nil
    user = login_as_custom_user(AdGroup.coach_manager, 'skumar')
    create_coach_with_qualifications('dutchfellow', ['KLE'],user.id)
    User.stubs(:authenticate).returns user #Simulate a success authentication
    coach_manager = CoachManager.find_by_user_name('skumar')
    coach_manager.coaches.each do |coach_record|
      if coach_record.rs_email == "dutchfellow@rosettastone.com"
        coach = coach_record
      end
    end

    assert coach

    if coach_manager && coach
      @controller = ManagerPortalController.new
      Eschool::Session.stubs(:find_by_ids).returns(eschool_session_objs)
      #test for lotus_sessions
      get(:week_view, {'start_date' => "2025-06-09", 'coach_id' => coach.id, 'lang_identifier' => "KLE", 'filter_language' => 'KLE', 'external_village_id' => "all"})
      assert_response 302
      assert_true response.body.include?("redirected")
    end
  end

  def test_week_view_for_all_languages
    Coach.any_instance.stubs(:threshold_reached?).returns([false,false])
    stub_eschool_call_for_find_by_id({})
    session_xml = <<EOF
    <eschool_sessions>
      <eschool_session>
        <eschool_session_id>123456</eschool_session_id>
        <language>ARA</language>
        <level>1</level>
        <unit>1</unit>
        <teacher>dutchfellow1</teacher>
        <start_time time_zone="UTC">2025-06-13 12:00:00</start_time>
        <duration_in_seconds>3600</duration_in_seconds>
        <cancelled>false</cancelled>
        <number_of_seats>4</number_of_seats>
        <learners_signed_up>1</learners_signed_up>
        <students_attended>0</students_attended>
        <wildcard>true</wildcard>
        <teacher_confirmed>false</teacher_confirmed>
        <wildcard_units>1,2,3,4,5,6,7,8,9,10,11,12</wildcard_units>
        <wildcard_locked>false</wildcard_locked>
        <teacher_confirmed>true</teacher_confirmed>
        <learner_details type="array">
        </learner_details>
        <launch_session_url>
          javascript:launchOnline('http://studio.rosettastone.com/launch?app%5Bcancellation_grace_period_in_seconds%5D=3000&amp;app%5Bclass_definition_url%5D=rsus%3A%2F%2Feschool_en-US_U_01&amp;app%5Beschool_session_id%5D=8492&amp;app%5Bfull_name%5D=coach1&amp;app%5Binstruction_end_time%5D=2011-01-21T05%3A50%3A00-05%3A00&amp;app%5Blaunch_controller_mode%5D=teacher&amp;app%5Broom_password%5D=PoL1kad0ts&amp;app%5Broom_user_name%5D=cocomo-eschool-dev%40rosettastone.com&amp;app%5Bscheduler_api_endpoint%5D=http%3A%2F%2Fstudio.rosettastone.com%2Fapi%2F&amp;app%5Bseconds_before_end_to_show_countdown_timer%5D=300&amp;app%5Bskip_audio_setup%5D=false&amp;app%5Bstart_time%5D=2011-01-21T05%3A00%3A00-05%3A00&amp;app%5Bsystem_recommendations_url%5D=http%3A%2F%2Flaunch.rosettastone.com%2Fen%2Fsystem_recommendations%2Fcommunity&amp;app%5Bteacher_id%5D=182&amp;app%5Bteacher_picture_url%5D=http%3A%2F%2Feschool.rosettastone.com%2Fimages%2Fdefault_teacher_image.jpg&amp;app%5Btime_after_start_to_allow_cancellation_in_seconds%5D=36&amp;app%5Bvideo_quality%5D=100&amp;app%5Bweb_services_access_key%5D=248acbe6a91020199a9b5adb609468316eb3e14eba4c9d628b9625bc1ced0bbfd58b2e8996cab88d3fecd1d914a383ea71fc8cbc7c87c73781bce576609bbb5041765984d29cfa90069b1bb5ca8a98b171acd51d829662f32037062d823d20c80e2b549e6f03b097f3c127774ef015b496d2a7468a3d5802e836d8eaea3ee633')
        </launch_session_url>
        <average_attendance>0.0</average_attendance>
        <external_village_id>8</external_village_id>
      </eschool_session>
   </eschool_sessions>
EOF
    eschool_session_objs = parse_session_xml_to_array_of_objects(session_xml)
    coach = nil
    user = login_as_custom_user(AdGroup.coach_manager, 'skumar')
    User.stubs(:authenticate).returns user #Simulate a success authentication
    create_coach_with_qualifications('dutchfellow', ['KLE'],user.id)
    coach_manager = CoachManager.find_by_user_name('skumar')
    coach_manager.coaches.each do |coach_record|
      if coach_record.rs_email == "dutchfellow@rs.com" || "dutchfellow@rosettastone.com"
        coach = coach_record
      end
    end

    assert coach

    if coach_manager && coach
      @controller = ManagerPortalController.new
      Eschool::Session.stubs(:find_by_ids).returns(eschool_session_objs)
      #test for lotus_sessions
      get(:week_view, {'start_date' => "2025-06-09", 'coach_id' => coach.id, 'lang_identifier' => "KLE", 'filter_language' => 'all', 'external_village_id' => "all"})
      assert_response 302 
      assert_true response.body.include?("redirected")
    end
  end



 

  def test_coach_display_order_in_assign_coaches_page
    coach_manager=login_as_custom_user(AdGroup.coach_manager, 'skumar')
    create_coach_with_qualifications('DutchCoach', ['KLE'],coach_manager.id)
    create_coach_with_qualifications('Dutchfellow', ['KLE'],coach_manager.id)
    create_coach_with_qualifications('KLEavailable', ['KLE'],coach_manager.id)
    create_coach_with_qualifications('Psubramanian', ['KLE'],coach_manager.id)
    create_coach_with_qualifications('Snallamuthu', ['KLE'],coach_manager.id)
    create_coach_with_qualifications('Ssitoke', ['KLE'],coach_manager.id)
    get :assign_coaches
    content =  css_select("form#assign-coaches1").to_s
    index_of_dutch_coach = content.index("<b>DutchCoach</b></p>")
    index_of_dutch_fellow = content.index("<b>Dutchfellow</b></p>")
    index_of_kle_available = content.index("<b>KLEavailable</b></p>")
    index_of_psubramanian = content.index("<b>Psubramanian</b></p>")
    index_of_snallamuthu = content.index("<b>Snallamuthu</b></p>")
    index_of_ssitoke = content.index("<b>Ssitoke</b></p>")
    assert_true( index_of_dutch_coach < index_of_dutch_fellow)
    assert_true( index_of_dutch_fellow < index_of_kle_available)
    assert_true( index_of_kle_available < index_of_psubramanian)
    assert_true( index_of_psubramanian < index_of_snallamuthu)
    assert_true( index_of_snallamuthu < index_of_ssitoke)
  end

  def test_coach_display_order_in_view_coach_profiles_page
    coach_manager=login_as_custom_user(AdGroup.coach_manager, 'skumar')
    create_coach_with_qualifications('DutchCoach', ['KLE'],coach_manager.id)
    create_coach_with_qualifications('Dutchfellow', ['KLE'],coach_manager.id)
    create_coach_with_qualifications('KLEavailable', ['KLE'],coach_manager.id)
    create_coach_with_qualifications('Psubramanian', ['KLE'],coach_manager.id)
    create_coach_with_qualifications('Snallamuthu', ['KLE'],coach_manager.id)
    create_coach_with_qualifications('Ssitoke', ['KLE'],coach_manager.id)
    get :view_coach_profiles
    content = css_select("select#coach_id").to_s
    index_of_dutch_coach = content.index("DutchCoach")
    index_of_dutch_fellow = content.index("Dutchfellow")
    index_of_kle_available = content.index("KLEavailable")
    index_of_psubramanian = content.index("Psubramanian")
    index_of_snallamuthu = content.index("Snallamuthu")
    index_of_ssitoke = content.index("Ssitoke")
    assert_true( index_of_dutch_coach < index_of_dutch_fellow)
    assert_true( index_of_dutch_fellow < index_of_kle_available)
    assert_true( index_of_kle_available < index_of_psubramanian)
    assert_true( index_of_psubramanian < index_of_snallamuthu)
    assert_true( index_of_snallamuthu < index_of_ssitoke)
  end

  def test_coach_display_order_in_week_view_page
    login_as_custom_user(AdGroup.coach_manager, 'skumar')
    get :week_view
    assert_equal response.status,302
  end

  def test_coach_selected_in_select_box_when_selecting_a_coach_in_view_coach_profiles_page
    login_as_custom_user(AdGroup.coach_manager, 'skumar')
    test_coach = create_coach_with_qualifications
    create_non_lotus_language("TMM-MCH-L")
    get :view_coach_profiles ,:coach_id => test_coach.id
    assert_select 'select[id="coach_id"]', :count => 1 do
      assert_select 'option[selected="selected"]', :text => test_coach.full_name, :count => 1
    end
  end

  def test_coach_selected_in_select_box_without_selecting_a_coach_in_view_coach_profiles_page
    login_as_custom_user(AdGroup.coach_manager, 'skumar')
    get :view_coach_profiles
    assert_select 'select[id="coach_id"]', :count => 1 do
      assert_select 'option[selected="selected"]', :count => 0
    end
  end

  def test_notifications_with_no_params
    login_as_custom_user(AdGroup.coach_manager, 'skumar')
    get :notifications
    assert_response :success
    assert_select "table[id='notifications_table']", 0
    assert_select "p[class='notice']", 1
  end


  def test_notifications_posted_today
    user = login_as_custom_user(AdGroup.coach_manager, 'skumar')
    SystemNotification.delete_all
    notification1 = SystemNotification.create({:notification_id => 1, :recipient_id => user.id, :recipient_type => "Account", :raw_message => "test comments"})
    get :notifications, {:postedFrom => "Today", :coachToShow => ""}
    assert_response :success
    assert_select "table[id='notifications_table']", 1
    assert_select "p[class='notice']", 0
    assert_select "td[class='notification_msg_for_manager']", 1
    notification1.update_attribute('created_at', notification1.created_at - 2.day)
    get :notifications, {:postedFrom => "Yesterday", :coachToShow => ""}
    assert_response :success
    assert_select "table[id='notifications_table']", 0
    assert_select "td[class='notification_msg_for_manager']", 0
    assert_select "p[class='notice']", 1

  end


  def test_notifications_posted_yesterday
    user = login_as_custom_user(AdGroup.coach_manager, 'skumar')
    SystemNotification.create({:notification_id => 1, :recipient_id => user.id, :recipient_type => "Account", :raw_message => "test comments", :created_at => Time.now.utc - 23.hours})
    get :notifications, {:postedFrom => "Yesterday", :coachToShow => ""}
    assert_response :success
    assert_select "table[id='notifications_table']", 1
    assert_select "td[class='notification_msg_for_manager']", 1
    assert_select "p[class='notice']", 0

  end


  def test_notifications_posted_before_yesterday
    user = login_as_custom_user(AdGroup.coach_manager, 'skumar')
    create_coach_with_qualifications('DutchCoach', ['KLE'],user.id)
    notification1 = SystemNotification.create({:notification_id => 1, :recipient_id => user.id, :recipient_type => "Account", :target_id => Coach.first.id, :raw_message => "test comments", :created_at => Time.now.utc - 2.days})
    get :notifications, {:postedFrom => "Today", :coachToShow => ""}
    assert_response :success
    assert_select "table[id='notifications_table']", 0
    assert_select "td[class='notification_msg_for_manager'][id=#{notification1.id}]", 0
    assert_select "p[class='notice']", 1

  end


  def test_notifications_filtering_template_changes_only
    user = login_as_custom_user(AdGroup.coach_manager, 'skumar')
    coach = create_a_coach_and_assign_a_template_to_him
    availability_template = CoachAvailabilityTemplate.find_by_coach_id(coach.id)
    notification1 = SystemNotification.create({:notification_id => 1, :recipient_id => user.id, :recipient_type => "Account", :target_id => availability_template.id})
    NotificationRecipient.create({:notification_id => notification1.id, :name => "Coach Manager", :rel_recipient_obj => "coach.all_managers"})

    get :notifications, {:excludeTemplateChanges => "1", :postedFrom => "Today", :coachToShow => ""}
    assert_response :success
    assert_select "table[id='notifications_table']", 0
    assert_select "td[class='notification_msg_for_manager']", 0
    assert_select "p[class='notice']", 1
    get :notifications, {:postedFrom => "Today", :coachToShow => ""}
    assert_response :success
    assert_select "table[id='notifications_table']", 1
    assert_select "td[class='notification_msg_for_manager']", 1
    assert_select "p[class='notice']", 0

  end

  def test_notifications_filtering_with_a_coach
    user = login_as_custom_user(AdGroup.coach_manager, 'skumar')
    coach = create_a_coach_and_assign_a_template_to_him
    availability_template = CoachAvailabilityTemplate.find_by_coach_id(coach.id)
    SystemNotification.create({:notification_id => 1, :recipient_id => user.id, :recipient_type => "Account", :target_id => availability_template.id})
    NotificationRecipient.create({:notification_id => 1, :name => "Coach Manager", :rel_recipient_obj => "coach.all_managers"})

    get :notifications, {:excludeTimeOffRequests => "1", :postedFrom => "Today", :coachToShow => coach.id+1 }
    assert_response :success
    assert_select "table[id='notifications_table']", 0
    assert_select "td[class='notification_msg_for_manager']", 0
    assert_select "p[class='notice']", 1

    get :notifications, {:postedFrom => "Today", :coachToShow => coach.id }
    assert_response :success
    assert_select "table[id='notifications_table']", 1
    assert_select "td[class='notification_msg_for_manager']", 1
    assert_select "p[class='notice']", 0

    get :notifications, {:postedFrom => "Today", :coachToShow => "" }
    assert_response :success
    assert_select "table[id='notifications_table']", 1
    assert_select "td[class='notification_msg_for_manager']", 1
    assert_select "p[class='notice']", 0

  end


  def test_notifications_ahould_not_show_substitions
    user = login_as_custom_user(AdGroup.coach_manager, 'skumar')
    coach = create_a_coach_and_assign_a_template_to_him
    availability_template = CoachAvailabilityTemplate.find_by_coach_id(coach.id)
    notification1 = SystemNotification.create({:notification_id => 17, :recipient_id => user.id, :recipient_type => "Account", :target_id => availability_template.id})
    NotificationRecipient.create({:notification_id => 17, :name => "Coach Manager", :rel_recipient_obj => "coach.all_managers"})

    get :notifications, {:excludeTemplateChanges => "1", :excludeTimeOffRequests => "1", :postedFrom => "Today", :coachToShow => "" }
    assert_response :success
    assert_select "table[id='notifications_table']", 0
    assert_select "td[class='notification_msg_for_manager'][id=#{notification1.id}]", 0
    assert_select "p[class='notice']", 1

    get :notifications, {:excludeTemplateChanges => "1", :postedFrom => "Today", :coachToShow => "" }
    assert_response :success
    assert_select "table[id='notifications_table']", 0
    assert_select "td[class='notification_msg_for_manager'][id=#{notification1.id}]", 0
    assert_select "p[class='notice']", 1

    get :notifications, {:excludeTimeOffRequests => "1", :postedFrom => "Today", :coachToShow => "" }
    assert_response :success
    assert_select "table[id='notifications_table']", 0
    assert_select "td[class='notification_msg_for_manager'][id=#{notification1.id}]", 0
    assert_select "p[class='notice']", 1

    get :notifications, {:postedFrom => "Today", :coachToShow => "" }
    assert_response :success
    assert_select "table[id='notifications_table']", 0
    assert_select "td[class='notification_msg_for_manager'][id=#{notification1.id}]", 0
    assert_select "p[class='notice']", 1

  end

  

  def test_inactivate_coach
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    stub_eschool_call_for_find_by_id({:learners_signed_up => 0})
    Eschool::Session.stubs(:cancel).returns true
    stub_eschool_call_for_profile_creation_with_success
    coach = create_a_coach_and_assign_a_template_to_him
    create_sessions_for_coach(coach, 3)
    coach_session = coach.coach_sessions.first
    CoachRecurringSchedule.create(:day_index => coach_session.session_start_time.utc.strftime('%w'),:recurring_start_date => coach_session.session_start_time.utc,:start_time => coach_session.session_start_time.utc.strftime("%H:%M:%S"),:language_id => coach_session.language.id,:coach_id => coach_session.coach.id)

    assert_equal 1, coach.availability_templates.size
    assert_equal 3, coach.coach_sessions.size
    assert_equal 0, coach.availability_modifications.size
    assert_equal 1, coach.recurring_schedules.size
    assert_nil coach.recurring_schedules.first.recurring_end_date
    BackgroundTask.delete_all
    assert_difference('Delayed::Job.count') do
      post :inactivate_coach, {:coach_id => coach.id, :check_box_value => 'false'}
    end

    b_task = BackgroundTask.first
    assert_equal 1, BackgroundTask.all.size
    assert_equal "Queued", b_task.state
    Delayed::Worker.new.work_off
    coach.reload
    b_task = BackgroundTask.first
    assert_equal 1, BackgroundTask.all.size
    assert_equal "Completed", b_task.state
    assert_equal false, b_task.locked
    assert_equal coach.id, b_task.referer_id
    assert_equal "Coach Activation", b_task.background_type
    assert_equal "test21", b_task.triggered_by
    assert_nil b_task.error

    assert_equal 0, coach.availability_templates.size
    assert_equal 3, coach.coach_sessions.size
    assert_equal 0, coach.availability_modifications.size
    assert_equal 1, coach.recurring_schedules.size
    assert_not_nil coach.recurring_schedules.first.recurring_end_date
    BackgroundTask.delete_all
    BackgroundTask.create(:referer_id => coach.id, :state => 'Queued', :error => nil, :background_type => 'Coach Activation', :triggered_by => 'test21', :locked => 1 )
    post :inactivate_coach, {:coach_id => coach.id, :check_box_value => 'false'}
    assert_equal 0,Delayed::Job.count

  end

  def test_view_profile_for_locked_coach
    coach_manager = login_as_custom_user(AdGroup.coach_manager, 'test21')
    Qualification.any_instance.stubs(:units_label).returns('N/A')
    create_non_lotus_language("TMM-MCH-L")
    Qualification.any_instance.stubs(:language_label).returns('N/A')
    coach = create_coach_with_qualifications('ssitoke', ['KLE', 'ARA'],coach_manager.id)
    BackgroundTask.delete_all
    bt = BackgroundTask.create(:referer_id => coach.id, :state => 'completed', :error => nil, :background_type => 'Coach Activation', :triggered_by => 'test21', :locked => 0 )
    post :view_coach_profiles, :coach_id => coach.id
    assert_equal false, assigns(:locked)
    bt.update_attributes(:referer_id => coach.id, :state => 'Queued', :error => nil, :background_type => 'Coach Activation', :triggered_by => 'test21', :locked => 1 )
    post :view_coach_profiles, :coach_id => coach.id
    assert_equal true, assigns(:locked)
    bt.update_attribute(:state , 'Started')
    post :view_coach_profiles, :coach_id => coach.id
    assert_equal true, assigns(:locked)
  end

  def test_manage_languages_without_any_qualification
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    get :manage_languages
    assert_select "input[type=checkbox]", :count => (Language.all.size - 1) 
    assert_response :success
  end

  def test_manage_languages_with_a_language
    coach_manager = login_as_custom_user(AdGroup.coach_manager, 'test21')
    arabic_lang_id = Language.find_by_identifier('ARA').id
    coach_manager.add_qualifications_for(arabic_lang_id)
    get :manage_languages
    assert_select "input[type=checkbox]", :count => Language.all.size - 2
    assert_select "a[href='remove-language?id=#{arabic_lang_id}']", "Remove",  :count => 1
    assert_response :success
  end

  def test_adding_and_removing_languages
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    arabic_lang_id = Language.find_by_identifier('ARA').id
    ManagerPortalController.any_instance.stubs(:update_manager_profile).returns('OK')

    get :manage_languages
    assert_select "input[type=checkbox]", :count => Language.all.size - 1
    assert_response :success

    post :manage_languages, {:lang_ids => [arabic_lang_id]}
    assert_select "input[type=checkbox]", :count => Language.all.size - 2
    assert_select "a[href='remove-language?id=#{arabic_lang_id}']", "Remove",  :count => 1
    assert_response :success

    get :manage_languages
    assert_select "input[type=checkbox]", :count => Language.all.size - 2
    assert_select "a[href='remove-language?id=#{arabic_lang_id}']", "Remove",  :count => 1
    assert_response :success

    get :remove_language, {:id => arabic_lang_id}
    assert_response :redirect

    get :manage_languages
    assert_select "input[type=checkbox]", :count => Language.all.size - 1
    assert_response :success
  end

  def teardown
    Account.delete_all
  end

  #def test_fetch_mail_address
    #coach1 = create_coach_with_qualifications('rajkumarOne', ['FRA'])
    #coach2 = create_coach_with_qualifications('rajkumarTwo', ['FRA'])
    #language = Language.find_by_identifier('FRA')
    #session_start_time = Time.now.beginning_of_hour.utc + 2.hour
    #FactoryGirl.create(:confirmed_session, :coach_id => coach1.id, :language_identifier => 'FRA', :session_start_time => session_start_time)
    #FactoryGirl.create(:confirmed_session, :coach_id => coach1.id, :language_identifier => 'FRA', :session_start_time => session_start_time + 1.hour)
    #FactoryGirl.create(:confirmed_session, :coach_id => coach2.id, :language_identifier => 'FRA', :session_start_time => session_start_time)
    #emails = CoachSession.find_coaches_between(session_start_time,session_start_time+1.hour,'FRA').collect(&:rs_email).uniq
    #assert_equal 2, emails.size
  #end

end
