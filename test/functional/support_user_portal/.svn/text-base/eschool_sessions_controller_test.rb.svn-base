require File.expand_path('../../../test_helper', __FILE__)
require 'support_user_portal/eschool_sessions_controller'
require 'application_controller'

class SupportUserPortal::EschoolSessionsControllerTest < ActionController::TestCase

  def test_show method

    @controller = SupportUserPortal::EschoolSessionsController.new
    login_as_custom_user(AdGroup.support_lead, 'test21')
    session_xml = <<EOF
    <eschool_sessions >
      <eschool_session>
        <eschool_session_id>88</eschool_session_id>
        <language>ESP</language>
        <level>1</level>
        <unit>1</unit>
        <teacher>dutchfellow</teacher>
        <teacher_id>12</teacher_id>
        <start_time time_zone="UTC">2025-06-13 12:00:00</start_time>
        <duration_in_seconds>3600</duration_in_seconds>
        <number_of_seats>4</number_of_seats>
        <learners_signed_up>1</learners_signed_up>
        <students_attended>0</students_attended>
        <wildcard>true</wildcard>
        <wildcard_units>1,2,3,4,5,6,7,8,9,10,11,12</wildcard_units>
        <wildcard_locked>false</wildcard_locked>
        <teacher_confirmed>true</teacher_confirmed>
        <external_village_id>8</external_village_id>
      </eschool_session>
   </eschool_sessions>
EOF
    session = parse_session_xml_to_object_license(session_xml)
    SupportLead.any_instance.stubs(:time_zone).returns('Eastern Time (US & Canada)')
    ExternalHandler::HandleSession.stubs(:find_upcoming_sessions_for_language_and_levels).returns(session)
    Community::User.delete_all
    community_user = FactoryGirl.create(:community_user, :guid => '1111111-2222222-3333333')
    get :show, :guid => community_user.guid, :content_range_array=>["", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true"], :lang_identifier=>"DEU", :license_identifier=>"viper1-totale/sublicenses/OLLC::02cca68c-95c7-4590-88a9-be30a49a1a38", :product_right_ends_at=>"2013-02-01 07:41 SST"
    assert_template "support_user_portal/eschool_sessions/show_eschool_sessions.html.erb"
  end


  def test_available_sessions_table_structure
    @controller = SupportUserPortal::EschoolSessionsController.new
    user = login_as_custom_user(AdGroup.support_lead, 'test21')
    session_xml = default_session_xml
    session = parse_session_xml_to_object_license(session_xml)
    Community::User.delete_all
    community_user = FactoryGirl.create(:community_user, :village_id => nil, :guid => '111111-222222-333333', :time_zone => 'Eastern Time (US & Canada)')
    SupportLead.any_instance.stubs(:time_zone).returns('Eastern Time (US & Canada)')
    ExternalHandler::HandleSession.stubs(:find_upcoming_sessions_for_language_and_levels).returns(session)
    get :show, :guid => community_user.guid, :content_range_array=>["", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true"], :lang_identifier=>"DEU", :license_identifier=>"viper1-totale/sublicenses/OLLC::02cca68c-95c7-4590-88a9-be30a49a1a38", :product_right_ends_at=>"2013-02-01 07:41 SST"
    assert_select 'table[id="sessions_table"]', :count => 1 do
      assert_select 'thead', :count => 1 do
        assert_select 'tr', :count => 1 do
          assert_select 'th', :count => 8 do
            assert_select 'th', "Date & Time (#{Time.now.in_time_zone(user.time_zone).strftime("%Z")})"
            assert_select 'th', "Learner Date & Time (#{Time.now.in_time_zone('Eastern Time (US & Canada)').strftime("%Z")})"
            assert_select 'th[class="unsortable"]', "Level"
            assert_select 'th[class="unsortable"]', "Unit"
            assert_select 'th', "Lesson"
            assert_select 'th', "Wildcard?"
            assert_select 'th', "Coach"
            assert_select 'th[class="unsortable"]', "Learners/Seats"
          end
        end
      end
    end
    assert_select "span[id='language_name']", "Language: German"
    assert_select "span[id='village_name']", "Village:  None"
  end

  def test_available_sessions_with_zero_records
    @controller = SupportUserPortal::EschoolSessionsController.new
    login_as_custom_user(AdGroup.support_lead, 'test21')
    session = parse_session_xml_to_object_license("<eschool_sessions ></eschool_sessions >")
    SupportLead.any_instance.stubs(:time_zone).returns('Eastern Time (US & Canada)')
    ExternalHandler::HandleSession.stubs(:find_upcoming_sessions_for_language_and_levels).returns(session)
    get :show, :content_range_array=>["", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true"], :lang_identifier=>"DEU", :guid => "111111-222222",:license_identifier=>"viper1-totale/sublicenses/OLLC::02cca68c-95c7-4590-88a9-be30a49a1a38", :product_right_ends_at=>"2013-02-01 07:41 SST"
    assert_select "p", "There are no Sessions occurring now."
    assert_select "span[id='language_name']", "Language: German"
    assert_select "span[id='village_name']", "Village:  None"
  end

  def test_available_sessions_for_village_name_language_name_and_title
    @controller = SupportUserPortal::EschoolSessionsController.new
    login_as_custom_user(AdGroup.support_lead, 'test21')
    session_xml = default_session_xml
    session = parse_session_xml_to_object_license(session_xml)
    SupportLead.any_instance.stubs(:time_zone).returns('Eastern Time (US & Canada)')
    ExternalHandler::HandleSession.stubs(:find_upcoming_sessions_for_language_and_levels).returns(session)
    user = create_community_user_and_stub_village
    get :show, :content_range_array=>["", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true"], :lang_identifier=>"DEU", :guid => user.guid, :license_identifier=>"viper1-totale/sublicenses/OLLC::02cca68c-95c7-4590-88a9-be30a49a1a38", :product_right_ends_at=>"2013-02-01 07:41 SST"
    assert_select "span[id='language_name']", "Language: German"
    assert_select "span[id='village_name']", "Village:  Japanese Kids"
  end

  def test_available_sessions_with_a_record
    community_user = create_community_user_and_stub_village
    @controller = SupportUserPortal::EschoolSessionsController.new
    user = login_as_custom_user(AdGroup.support_lead, 'test21')
    session_xml = default_session_xml
    session = parse_session_xml_to_object_license(session_xml)
    SupportLead.any_instance.stubs(:time_zone).returns('Eastern Time (US & Canada)')
    ExternalHandler::HandleSession.stubs(:find_upcoming_sessions_for_language_and_levels).returns(session)
    get :show, :content_range_array=>["", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true"], :lang_identifier=>"DEU", :guid => community_user.guid, :license_identifier=>"viper1-totale/sublicenses/OLLC::02cca68c-95c7-4590-88a9-be30a49a1a38", :product_right_ends_at=>"2013-02-01 07:41 SST"
    assert_select 'table[id="sessions_table"]', :count => 1 do
      assert_select 'thead', :count => 1 do
        assert_select 'tr', :count => 1 do
          assert_select 'th', :count => 8 do
            assert_select 'th', "Date & Time (#{Time.now.in_time_zone(user.time_zone).strftime("%Z")})"
            assert_select 'th', "Learner Date & Time (#{Time.now.in_time_zone('Pacific Time (US & Canada)').strftime("%Z")})"
            assert_select 'th[class="unsortable"]', "Level"
            assert_select 'th[class="unsortable"]', "Unit"
            assert_select 'th', "Lesson"
            assert_select 'th', "Wildcard?"
            assert_select 'th', "Coach"
            assert_select 'th[class="unsortable"]', "Learners/Seats"
          end
        end
      end
      assert_select 'tbody', :count => 1 do
        assert_select 'tr', :count => 1 do
          assert_select 'td', :count => 8 do
            assert_select 'td', "06/13/25 08:00 AM"
            assert_select 'td', "06/13/25 05:00 AM"
            assert_select 'td', "1"
            assert_select 'td', "1"
            assert_select 'td', "2"
            assert_select 'td', "Max L3, U4, LE4"
            assert_select 'td', "dutchfellow"
          end
        end
      end
    end
    assert_select "span[id='language_name']", "Language: German"
    assert_select "span[id='village_name']", "Village:  Japanese Kids"
  end

  def test_available_sessions_csv_with_a_record
    community_user = create_community_user_and_stub_village
    @controller = SupportUserPortal::EschoolSessionsController.new
    user = login_as_custom_user(AdGroup.support_lead, 'test21')
    session_xml = default_session_xml
    session = parse_session_xml_to_object_license(session_xml)
    SupportLead.any_instance.stubs(:time_zone).returns('Eastern Time (US & Canada)')
    ExternalHandler::HandleSession.stubs(:find_upcoming_sessions_for_language_and_levels_without_pagination).returns(session)
    get :export_sessions_to_csv, :content_range_array=>["", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true", "true"], :lang_identifier=>"DEU", :guid => community_user.guid, :license_identifier=>"viper1-totale/sublicenses/OLLC::02cca68c-95c7-4590-88a9-be30a49a1a38", :product_right_ends_at=>"2013-02-01 07:41 SST"
    response_array = CSV.parse(@response.body)
    assert_equal "Date & Time (#{Time.now.in_time_zone(user.time_zone).strftime("%Z")})", response_array[0][0]
    assert_equal "Learner Date & Time (#{Time.now.in_time_zone('Pacific Time (US & Canada)').strftime("%Z")})", response_array[0][1]
    assert_equal "Level", response_array[0][2]
    assert_equal "Unit", response_array[0][3]
    assert_equal "Lesson", response_array[0][4]
    assert_equal "Wildcard?", response_array[0][5]
    assert_equal "Coach", response_array[0][6]
    assert_equal "Learners/Seats", response_array[0][7]
    assert_equal "06/13/25 08:00 AM", response_array[1][0]
    assert_equal "06/13/25 05:00 AM", response_array[1][1]
    assert_equal "1", response_array[1][2]
    assert_equal "1", response_array[1][3]
    assert_equal "2", response_array[1][4]
    assert_equal "Max L3, U4, LE4", response_array[1][5]
    assert_equal "dutchfellow", response_array[1][6]
    assert_equal "0/4", response_array[1][7]
  end

  def ignore_test_show_attendances
    login_as_custom_user(AdGroup.support_lead, 'test21')
    learner = FactoryGirl.create(:learner, :guid => '123456789', :email => 'aa@aa.aa')
    session_xml = default_session_xml
    session = parse_session_xml_to_object_license(session_xml)
    SupportLead.any_instance.stubs(:time_zone).returns('Eastern Time (US & Canada)')
    result_set = Eschool::Session.new(:attendances => [], :learner_list => [{:name => "user_name", :student_id => 2134, :email=>learner.email, }])
    ExternalHandler::HandleSession.stubs(:find_registered_and_unregistered_learners_for_session).returns(result_set)
    get :show_attendances, {:guid => learner.guid, :license_identifier => 'aa@aa.aa', :session_id => session.id, :lang_identifer => 'ESP', :class_id => 12345, :wildcard_units => '1,2,3'}
    assert_response :success
  end

  def test_add_student_to_session
    login_as_custom_user(AdGroup.support_lead, 'test21')
    sess = FactoryGirl.create(:coach_session, :id => 123456, :eschool_session_id => 8493 , :type => 'ConfirmedSession', :coach_id => 318)
    account = FactoryGirl.create(:account, :id => 318, :user_name => "jamie", :type => "Coach")
    result = Eschool::Session.new(:status => "OK" , :message => "Learner Added Successfully.")
    ExternalHandler::HandleSession.stubs(:add_student_to_session).returns(result)
    ExternalHandler::HandleSession.stubs(:find_session).returns(eschool_sesson_without_learner)
    post :add_student, {:session_id => 8493 }
    assert_response :success

    result = Eschool::Session.new(:status => "ERROR" , :message => "Learner Not Added Successfully.")
    ExternalHandler::HandleSession.stubs(:add_student_to_session).returns(result)
    post :add_student
    assert_response :error
  end

  def test_remove_student_from_session
    login_as_custom_user(AdGroup.support_lead, 'test21')
    result = Eschool::Session.new(:body => {:status => "OK" , :message => "Learner Removed Successfully."})
    ExternalHandler::HandleSession.stubs(:remove_student_from_session).returns(result)
    XmlSimple.any_instance.stubs(:xml_in).returns({"message"=>["Session was successfully removed from student's schedule."], "status"=>["OK"]})
    post :remove_student
    assert_response :success

    result = Eschool::Session.new(:body => {:status => "ERROR" , :message => "Learner Not Removed Successfully."})
    ExternalHandler::HandleSession.stubs(:remove_student_from_session).returns(result)
    XmlSimple.any_instance.stubs(:xml_in).returns({"message"=>["Session was not successfully removed from student's schedule."], "status"=>["ERROR"]})
    post :remove_student
    assert_response :error
  end

  def default_session_xml(options = {})
    session_xml = <<EOF
    <eschool_sessions >
      <eschool_session>
        <eschool_session_id>#{options[:session_id]? options[:session_id]: 88}</eschool_session_id>
        <language>#{options[:language]? options[:language]: "ESP"}</language>
        <level>#{options[:level]? options[:level]: 1}</level>
        <unit>#{options[:unit]? options[:unit]: 1}</unit>
        <lesson>#{options[:lesson]? options[:lesson]: 2}</lesson>
        <teacher>#{options[:teacher]? options[:teacher]: "dutchfellow"}</teacher>
        <teacher_id>#{options[:teacher_id]? options[:teacher_id]: 12}</teacher_id>
        <start_time time_zone="UTC">#{options[:start_time]? options[:start_time]: "2025-06-13 12:00:00"}</start_time>
        <duration_in_seconds>#{options[:duration_in_seconds]? options[:duration_in_seconds]: 3600}</duration_in_seconds>
        <number_of_seats>#{options[:number_of_seats]? options[:number_of_seats]: 4}</number_of_seats>
        <learners_signed_up>#{options[:learners_signed_up]? options[:learners_signed_up]: 1}</learners_signed_up>
        <students_attended>#{options[:students_attended]? options[:students_attended]: 0}</students_attended>
        <wildcard>#{options[:wildcard]? options[:wildcard]: true}</wildcard>
        <wildcard_units>#{options[:wildcard_units]? options[:wildcard_units]: "1,2,3,4,5,6,7,8,9,10,11,12"}</wildcard_units>
        <wildcard_locked>#{options[:wildcard_locked]? options[:wildcard_locked]: false}</wildcard_locked>
        <teacher_confirmed>#{options[:teacher_confirmed]? options[:teacher_confirmed]: true}</teacher_confirmed>
        <external_village_id>#{options[:external_village_id]? options[:external_village_id]: 8}</external_village_id>
      </eschool_session>
   </eschool_sessions>
EOF
    return session_xml
  end

  def parse_session_xml_to_object_license(xml)
    doc = XML::Parser.string(xml).parse
    eschool_session_obj = nil
    eschool_sessions_array = []
    doc.find("//eschool_sessions").each do |eschool_session_one|
      eschool_session_one.find('//eschool_session').each do |eschool_session|
        eschool_session_obj =  Eschool::Session.new(
          :session_id => eschool_session.find('eschool_session_id')[0].content,
          :language =>  eschool_session.find('language')[0].content,
          :level => eschool_session.find('level')[0].content,
          :unit => eschool_session.find('unit')[0].content,
          :teacher => eschool_session.find('teacher')[0].content,
          :teacher_id => eschool_session.find('teacher_id')[0].content,
          :eschool_class_id => nil,
          :start_time => eschool_session.find('start_time')[0].content,
          :duration_in_seconds => eschool_session.find('duration_in_seconds')[0].content,
          :level_unit => 'Level ' + eschool_session.find('level')[0].content + ' unit ' + eschool_session.find('unit')[0].content+ ' lesson ' + eschool_session.find('lesson')[0].content,
          :number_of_seats => eschool_session.find('number_of_seats')[0].content,
          :learners_signed_up => eschool_session.find('learners_signed_up')[0].content,
          :students_attended => eschool_session.find('students_attended')[0].content,
          :wildcard => eschool_session.find('wildcard')[0].content,
          :attendance_record => 20 ,
          :wildcard_units => eschool_session.find('wildcard_units')[0].content,
          :filled_seats => "0/4",
          :wildcard_locked => eschool_session.find('wildcard_locked')[0].content,
          :teacher_confirmed => eschool_session.find('teacher_confirmed')[0].content,
          :village_name => '' ,
          :external_village_id => eschool_session.find('external_village_id')[0].content)
        eschool_sessions_array << eschool_session_obj
      end

    end

    #     Eschool::Session.any_instance.stubs(:eschool_sessions).returns(eschool_sessions_array)
    final_obj = Eschool::Session.new(:eschool_sessions => [] )
    final_obj.eschool_sessions = eschool_sessions_array
    final_obj

  end

  def create_community_user_and_stub_village
    Community::Village.stubs(:display_name).returns("Japanese Kids")
    Community::User.any_instance.stubs(:village_id => 10)
    Community::User.find_by_guid('44444-222222-333333') || FactoryGirl.create(:community_user, :village_id => nil, :guid => '44444-222222-333333', :time_zone => 'Pacific Time (US & Canada)')
  end

end
