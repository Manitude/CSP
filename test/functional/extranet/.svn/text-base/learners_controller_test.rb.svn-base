require File.dirname(__FILE__) + '/../../test_helper'

class Extranet::LearnersControllerTest < ActionController::TestCase

  def setup
    account = FactoryGirl.create(:account, :user_name => "jamie")
    user = User.new("coach_manager")
    user.groups = [AdGroup.coach_manager]
    user.time_zone = 'America/New_York'
    user.account_id = account.id
    session[:user] = user
  end

  test "search with all blank" do
    post :search_result, {:fname => "", :lname => "", :email => "",:phone_number=>""}
    assert_equal "Please provide a query to search.", flash[:error]
  end

  test "phone_number_validation_for(-)"  do
    post :search_result, {:phone_number=>"123$"}
    assert_equal "Invalid Phone Number. Note: Letters, Spaces and special characters are not allowed.", flash[:error]
  end

  test "game_history_link_present_for_coach_manager" do
    assert_check_for_user(AdGroup.coach_manager)
  end

  test "render_without_layout_for_combined_page" do
    learner = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '1111111111')
    stub_learner
    get :show , {:id => learner.id , :controller=> "extranet/learners", :is_combined_page => "true"}
    assert_no_tag 'img', :attributes => {:title => 'Rosetta Stone'}
    assert_no_tag 'img', :attributes => {:id => 'inst_container'}
  end

  test "game_history_link_present_for_coach" do
    assert_check_for_user(AdGroup.coach)
  end

  test "game_history_link_present_for_support_lead" do
    assert_check_for_user(AdGroup.support_lead)
  end

  test "game_history_link_present_for_support_concierge" do
    assert_check_for_user(AdGroup.support_concierge_user)
  end

  test "game_history_link_present_for_support_harrisonburg" do
    assert_check_for_user(AdGroup.support_harrisonburg_user)
  end
  
  test "game_history_link_and_other_moderation_details_present_for_community_moderator" do
    login_as_custom_user(AdGroup.community_moderator,'dranjit')
    learner = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '1111111111')
    stub_learner
    get :show , {:id => learner.id , :controller=> "extranet/learners"}
    assert_select "span", "View Game History"
    assert_select "span", "View Chat History"
    assert_select "span", "View World Interactions"
    assert_select "span", "View Invitation History"
  end

  test "game_history_link_present_for_led_user" do
    assert_check_for_user(AdGroup.led_user)
  end

  test "phone_number_validation_for_space"  do
    post :search_result, {:phone_number=>"123 "}
    assert_equal "Invalid Phone Number. Note: Letters, Spaces and special characters are not allowed.", flash[:error]
  end

  test "phone_number_validation_for_()"  do
    post :search_result, {:phone_number=>"123()"}
    assert_equal "Invalid Phone Number. Note: Letters, Spaces and special characters are not allowed.", flash[:error]
  end

  test "phone_number_validation_for_a-zA-Z"  do
    post :search_result, {:phone_number=>"abcABC"}
    assert_equal "Invalid Phone Number. Note: Letters, Spaces and special characters are not allowed.", flash[:error]
  end

  test "default search dropdown option" do
    post :search_result, {:fname => "", :lname => "", :email => "totale",:phone_number=>"", :village => "all" , :language => "all"}
    assert_select 'select[id="search_by_which_id"]' do
      assert_select 'option[value="activation_id"]' ,  :count => 1
      assert_select 'option[value="license_guid"][selected="selected"]',  :count => 1
    end
    assert_select 'select option[selected="selected"]'
  end

  test "post a query and check result" do
    learner = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '1111111111')
    if learner
      post :search_result, {:fname => learner.first_name, :village => "all" , :language => "all"}
      assert_response :success
      assert_select 'div#no-records', 0
    end
  end

  test "post a wrong query and check result" do
    learner = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '1111111111')
    if learner
      fname=learner.first_name+learner.first_name.reverse # Hope no will ever have such a strange name
      post :search_result, {:fname => fname, :village => "all" , :language => "all"}
      assert_response :success
      assert_select 'div#no-records'
    end
  end
  test "search based on guid and check result" do
    learner = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '1111111111')
    if learner
      post :search_result, {:search_id => learner[:guid], :search_by_which_id => "license_guid"}
      assert_response :success
      assert_select 'div#no-records', 0
    end
  end

  test "search based on activation id and check result: no result" do
    learner = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '1111111111')
    RosettaStone::ActiveLicensing::ProductRight.any_instance.stubs(:find_by_activation_id).returns([])
    if learner
      post :search_result, {:search_id => learner[:guid], :search_by_which_id => "activation_id"}
      assert_response :success
      assert_select 'div#no-records', "No Matches Found"
    end
  end

  test "search based on activation id and check result: one result" do
    learner = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '1111111111')
    RosettaStone::ActiveLicensing::ProductRight.any_instance.stubs(:find_by_activation_id).returns([{"license"=>{"identifier"=>"beta910@rs.com", "guid"=> learner.guid}}])
    if learner
      get :index
      @controller = Extranet::LearnersController.new
      post :search_result, {:search_id => "22NF56-WLKGD-HBD5C-6DH7Y-55ZCFX4", :search_by_which_id => "activation_id"}
      assert_response :success

      assert_select 'div#no-records', 0
      assert_select 'table#search_data' do
        assert_select 'tr' do
          assert_select 'td', "#{learner.first_name} #{learner.last_name}"
          assert_select 'td', "#{learner.email}"
          assert_select 'td', "#{learner.guid}"
          assert_select 'td', "#{learner.mobile_number}"
        end
      end
    end
  end

  test "check presence of studio info in learner profile for community learner" do
    Learner.any_instance.stubs(:can_show_studio_info?).returns(true)
    Community::User.find_by_guid("af2190de-fed0-4e93-81ae-b7aebebf8bef").try(:destroy)
    source_user = FactoryGirl.create(:community_user, :village_id => nil,:guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef")
    learner = assert_check_for_reflex_learner_profile("Community::User", source_user)
    assert_check_for_totale_learner_profile("Community::User", source_user)
  end

  test "check presence of studio info in learner profile for viper learner" do
    Learner.any_instance.stubs(:can_show_studio_info?).returns(true)
    source_user = FactoryGirl.create(:viper_user, :guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef")  
    learner = assert_check_for_reflex_learner_profile("RsManager::User", source_user)
    assert_check_for_totale_learner_profile("Community::User", source_user)
  end

  test "check learner profile fields for comunity" do
    Community::User.find_by_guid("af2190de-fed0-4e93-81ae-b7aebebf8bef").try(:destroy)
    source_user = FactoryGirl.create(:community_user, :village_id => nil, :guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef")
    learner = assert_check_for_reflex_learner_profile("Community::User", source_user)
    assert_select "span[class=formw]", :text => source_user.preferred_name, :count => 1
    assert_select "span[class=formw]", :text => source_user.time_zone, :count => 1
    assert_select "span[class=formw]", :text => source_user.city, :count => 1
    assert_select "span[class=formw]", :text => source_user.gender, :count => 1
    assert_select "span[class=formw]", :text => "#{source_user.state_province},#{source_user.city}", :count => 1
    assert_equal("Community", learner.type)

    learner = assert_check_for_totale_learner_profile("Community::User", source_user)
    assert_select "span[class=formw]", :text => source_user.preferred_name, :count => 1
    assert_select "span[class=formw]", :text => source_user.time_zone, :count => 1
    assert_select "span[class=formw]", :text => source_user.city, :count => 1
    assert_select "span[class=formw]", :text => source_user.gender, :count => 1
    assert_select "span[class=formw]", :text => "#{source_user.state_province},#{source_user.city}", :count => 1
    assert_equal("Community", learner.type)
    
  end

  test "check learner profile fields for viper" do
    source_user = FactoryGirl.create(:viper_user)
    learner = assert_check_for_reflex_learner_profile("RsManager::User", source_user)
    assert_equal("Viper", learner.type)
    assert_nil(learner.preferred_name)
    assert_nil(learner.time_zone)
    assert_nil(learner.city)
    assert_nil(learner.gender)
    assert_nil(learner.state_province)
    learner = assert_check_for_totale_learner_profile("Community::User", source_user)
    assert_equal("Community", learner.type)
    assert_nil(learner.preferred_name)
    assert_nil(learner.time_zone)
    assert_nil(learner.city)
    assert_nil(learner.gender)
    assert_nil(learner.state_province)
  end


  def test_check_learner_details_method
    Community::User.find_by_guid("af2190de-fed0-4e93-81ae-b7aebebf8bef").try(:destroy)
    source_user = FactoryGirl.create(:community_user, :village_id => nil, :guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef")
    stub_learner(source_user)
    learner = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => source_user.guid)
    RosettaStone::ActiveLicensing::License.any_instance.stubs(:details).returns({"created_at"=>"Wed Nov 30 19:54:29 +0530 2011".to_datetime, "guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "usable"=>true, "demo"=>false, "creation_account_identifier"=>"OSUBs", "creation_account_guid"=>"048f539c-7d13-102d-9b5a-f03c5d1f8336", "identifier"=>"csp@content.range", "test"=>true, "active"=>true})
    RosettaStone::ActiveLicensing::License.any_instance.stubs(:product_rights).returns([{"product_family"=>"application", "created_at"=> "Wed Nov 30 19:54:58 +0530 2011".to_datetime, "guid"=>"a456e046-4714-4247-a1a9-e58fa7d7b9bf", "unextended_ends_at"=>"Wed Apr 11 19:15:03 +0530 2012".to_datetime, "starts_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "license"=>{"guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "identifier"=>"csp@content.range"}, "usable"=>true, "product_identifier"=>"ESP", "activation_id"=>nil, "ends_at"=>"Wed Apr 11 19:15:03 +0530 2012".to_datetime, "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"4", "created_at"=>"1314835200", "guid"=>"f9865fdf-309c-4ec2-938c-3cdcf50d6ed3", "updated_at"=>"1314835200", "activation_id"=>nil, "min_unit"=>"1"}, {"max_unit"=>"8", "created_at"=>"1317427200", "guid"=>"27ad98e9-813e-4379-b882-e270b57df8fe", "updated_at"=>"1317427200", "activation_id"=>nil, "min_unit"=>"5"}, {"max_unit"=>"12", "created_at"=>"1322663808", "guid"=>"fae27ec0-e375-4aeb-a91e-3f89f907dad8", "updated_at"=>"1322663808", "activation_id"=>nil, "min_unit"=>"1"}]}, {"product_family"=>"eschool", "created_at"=>"Wed Nov 30 19:55:13 +0530 2011".to_datetime, "guid"=>"b4ecbdf2-8d4d-48f1-9b4d-b57fa2f91f4d", "unextended_ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "starts_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "license"=>{"guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "identifier"=>"csp@content.range"}, "usable"=>true, "product_identifier"=>"ESP", "activation_id"=>nil, "ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"4", "created_at"=>"1314835200", "guid"=>"43425c0b-cbff-43c8-bf14-d6c07f0693f8", "updated_at"=>"1314835200", "activation_id"=>nil, "min_unit"=>"1"}, {"max_unit"=>"8", "created_at"=>"1317427200", "guid"=>"e6a95d93-f8b1-4d93-b2e2-0ba3b660e74e", "updated_at"=>"1317427200", "activation_id"=>nil, "min_unit"=>"5"}, {"max_unit"=>"12", "created_at"=>"1322663822", "guid"=>"43d13237-6c5d-4589-b806-f8bdf97057e8", "updated_at"=>"1322663822", "activation_id"=>nil, "min_unit"=>"1"}]}, {"product_family"=>"premium_community", "created_at"=>"Wed Nov 30 19:55:24 +0530 2011".to_datetime, "guid"=>"11e2d905-3224-4428-94f1-4f10e5b57ea2", "unextended_ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "starts_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "license"=>{"guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "identifier"=>"csp@content.range"}, "usable"=>true, "product_identifier"=>"ESP", "activation_id"=>nil, "ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"4", "created_at"=>"1314835200", "guid"=>"9964fb81-13b3-4e6f-858d-3a9c958d28f1", "updated_at"=>"1314835200", "activation_id"=>nil, "min_unit"=>"1"}, {"max_unit"=>"8", "created_at"=>"1317427200", "guid"=>"79e72631-6c92-4b06-b147-9e7cec9873aa", "updated_at"=>"1317427200", "activation_id"=>nil, "min_unit"=>"5"}, {"max_unit"=>"12", "created_at"=>"1322663851", "guid"=>"9a0e8db2-441c-435e-9806-bc46d2c259fa", "updated_at"=>"1322663851", "activation_id"=>nil, "min_unit"=>"1"}]}])
    RosettaStone::ActiveLicensing::CreationAccount.any_instance.stubs(:details).returns({"access_ends_at"=>nil, "created_at"=>"Tue May 22 13:53:34 +0530 2007".to_datetime, "guid"=>"048f539c-7d13-102d-9b5a-f03c5d1f8336", "maximum_active_licenses"=>nil, "master_license_guid"=>nil, "demo"=>false, "type"=>"online_subscription", "configuration_ends_at"=>"Thu Jan 01 05:30:00 +0530 2037".to_datetime, "identifier"=>"OSUBs", "test"=>false, "maximum_product_rights_per_license"=>nil})
    get :learner_details, {:license_guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef"}
    assert_response :success
    assert_equal "Consumer", assigns(:learner_type)
    assert_true @response.body.include?("OSub")
  end  
  
  def test_learner_studio_history_without_sessions
    learner = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '1111111111')
    if learner
      @controller= Extranet::LearnersController.new
      options = {:guid => learner.guid}
      Eschool::Learner.stubs(:studio_history).returns learner_studio_history_without_sessions(options)
      get :learner_studio_history , {:view_access => false, :id => learner.id}
      assert_equal [], learner.studio_history.eschool_sessions
    end
  end

  def test_learner_studio_history_with_one_session_no_feedback
    datetime = "2011-11-01 10:00:00".to_time.utc
    lang = FactoryGirl.create(:language, :identifier => 'LANG')
    account = login_as_coach
    coach = Coach.find_by_id(account.id)
    FactoryGirl.create(:qualification, :language => lang, :coach_id => coach.id, :max_unit => 10)
    create_one_off_session(coach, datetime.in_time_zone("Eastern Time (US & Canada)"), lang)
    learner = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '1111111111')
    if learner
      @controller= Extranet::LearnersController.new
      options = {:guid => learner.guid,:coach => coach,:language_code => lang.identifier,:datetime => datetime}
      Eschool::Learner.stubs(:studio_history).returns learner_studio_history_with_one_session_no_feedback(options)
      get :learner_studio_history , {:view_access => false, :id => learner.id}
      assert_equal learner.studio_history.eschool_sessions.size,  1
      learner.studio_history.eschool_sessions.each do |eschool_session|
        assert_equal eschool_session.coach , coach.full_name
        assert_equal eschool_session.coach_id , coach.id.to_s
        assert_equal eschool_session.start_time.to_time.utc , datetime
        assert_equal eschool_session.first_seen_at.to_time.utc , datetime + 2.minutes
        assert_equal eschool_session.last_seen_at.to_time.utc , datetime + 50.minutes
        assert_equal eschool_session.feedbacks , []
      end
    end
  end

  def test_learner_studio_history_with_one_session_and_feedback
    account = login_as_coach
    coach = Coach.find_by_id(account.id)
    datetime = "2011-11-01 10:00:00".to_time.utc
    lang = FactoryGirl.create(:language, :identifier => 'LANG')
    FactoryGirl.create(:qualification, :language => lang, :coach_id => coach.id, :max_unit => 10)
    create_one_off_session(coach, datetime.in_time_zone("Eastern Time (US & Canada)"), lang)
    learner = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '1111111111')
    @controller= Extranet::LearnersController.new
    options = {:guid => learner.guid,:coach => coach,:language_code => lang.identifier,:datetime => datetime}
    Eschool::Learner.stubs(:studio_history).returns learner_studio_history_with_one_session_and_feedback(options)
    get :learner_studio_history , {:view_access => false, :id => learner.id}
    assert_equal learner.studio_history.eschool_sessions.size,  1
    learner.studio_history.eschool_sessions.each do |eschool_session|
      assert_equal eschool_session.coach , coach.full_name
      assert_equal eschool_session.coach_id , coach.id.to_s
      assert_equal eschool_session.start_time.to_time.utc , datetime
      assert_equal eschool_session.first_seen_at.to_time.utc , datetime + 2.minutes
      assert_equal eschool_session.last_seen_at.to_time.utc , datetime + 50.minutes
      assert_equal eschool_session.feedbacks.size , 6
    end
  end

  def test_search_learner_and_check_if_view_license_link_is_seen
    support_user_groups = [AdGroup.support_lead, AdGroup.support_user, AdGroup.support_concierge_user, AdGroup.support_harrisonburg_user]
    learner = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '1111111111')
    support_user_groups.each do |ad_group|
      login_as_custom_user(ad_group, 6.random_letters)
      learner=Learner.first
      if learner
        post :search_result, {:fname => learner.first_name, :village => "all" , :language => "all"}
        assert_select 'div#no-records', 0
        assert_select 'a', :text => "View Learner", :count => 1
      end
    end
  end

  def test_course_info_detail
    account = login_as_coach
    learner = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '1111111111')
    params = {"lang"=>"ARA", "level"=>"1", "learner"=>learner.id, "ARA"=>"1"}
    course_tracking_info = {"progressed_languages"=>{"language"=>[{"levels"=>{"level"=>"1"}, "code"=>"ARA"}]}, "guid"=>"5c4e0320-a6e0-4899-9856-1e9cb1d0ce0a", "last_access_time"=>"2011-05-31 06:21:23", "high_water_mark"=>{"level" => 1, "unit" => 2, "lesson" => 2}, "language"=>"ARA", "last_access_time_in_seconds"=>"1306822883", "last_completed"=>{}}
    Learner.any_instance.stubs(:baffler_course_tracking_info).returns(course_tracking_info)
    path_scores = {"path_scores"=>{"path_score"=>{"complete"=>"false", "path_type"=>"general", "lesson"=>"1", "unit"=>"1", "updated_at"=>"1282343560"}}, "guid"=>"5c4e0320-a6e0-4899-9856-1e9cb1d0ce0a", "language"=>"ARA", "level"=>"1"}
    Coach.any_instance.stubs(:can_read_high_water_mark?).returns(false)
    Learner.any_instance.stubs(:baffler_path_scores_for_language_and_level).returns(path_scores)
    get :course_info_detail, params
    assert_response :success
    assert_select 'div[id="profile"]'
    assert_select 'p', 'Course - ' + Language['ARA'].display_name
    assert_select 'span', 'Progress per language per level'
  end

  def test_game_history_page
    account = login_as_coach
    learner = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '1111111111')
    params = {"id"=>learner.id}
    resp = {"game_history"=>{
              "participation"=>[
                {
                  "gameplay_ended_at"=>"0",
                  "created_at"=>"1394691978",
                  "gameplay_start_at"=>"1394692153",
                  "game_modality"=>"solo",
                  "game_name"=>"prospero",
                  "game_version"=>"2.8.0-165321",
                  "invitation_uid"=>"456464654654564"
                }, 
                
                {
                  "gameplay_ended_at"=>"1282362412",
                  "created_at"=>"1282362378",
                  "gameplay_start_at"=>"1282362406",
                  "game_modality"=>"solo",
                  "game_name"=>"memory",
                  "game_version"=>"1.8.0-98026",
                  "invitation_uid"=>"8526_1282362376144"
                },
                {
                  "gameplay_ended_at"=>"0",
                  "created_at"=>"1282362259",
                  "gameplay_start_at"=>"0",
                  "game_modality"=>"duo",
                  "game_name"=>"memory",
                  "game_version"=>"1.8.0-98026",
                  "invitation_uid"=>"8526_1282362256606"
                }
              ]
            },
            "pagination"=>{
              "total_pages"=>"1",
              "current_page"=>"1"
            },
            "user"=>{"guid"=>"5c4e0320-a6e0-4899-9856-1e9cb1d0ce0a"}}
    Learner.any_instance.stubs(:user_game_history).returns(resp)
    get :game_history, params
    assert_response :success
    assert_select 'span', 'View Game history of ' + "#{learner.first_name.capitalize} #{learner.last_name.capitalize}"
    assert_select 'tr', :count => 5
  end

  private

  def stub_learner(user = nil)
    Eschool::Student.stubs(:get_completed_reflex_sessions_count_for_learner).returns(0)
    Learner.any_instance.stubs(:baffler_time_spent_on_languages).returns([])
    Learner.any_instance.stubs(:totale_languages_along_with_expired_lisences).returns([])
    Learner.any_instance.stubs(:user_session_log).returns([])
    user = FactoryGirl.build(:community_user, :guid => '1111111111', :village_id => 123) if user.nil?
    Learner.any_instance.stubs(:user_source).returns(user)
    Learner.any_instance.stubs(:languages).returns(["KLE","ARA"])
  end

  def assert_check_for_user(user_type)
    stub_learner
    login_as_custom_user(user_type,'dranjit')
    learner = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '1111111111')
    get :show , {:id => learner.id , :controller=> "extranet/learners"}
    assert_select "span", "View Game History"
    assert_no_tag 'span', :attributes => {:title => 'View Chat History'}
    assert_no_tag 'span', :attributes => {:title => 'View World Interactions'}
    assert_no_tag 'span', :attributes => {:title => 'View Invitation History'}
  end

  def assert_check_for_reflex_learner_profile(source_type, source_user = nil)
    stub_learner(source_user)
    learner = FactoryGirl.create(:learner, :user_source_type => source_type, :guid => source_user.guid)
    learner.learner_product_rights[0].update_attribute(:language_identifier, 'KLE')
    get :show,  {:id => learner.id, :view_access => false}
    assert_response :success
    assert_select "div#general_info"
    assert_select "span[class=label_learner]", :text => "Name", :count => 1
    assert_select "span[class=label_learner]", :text => "Display Name", :count => 1
    assert_select "span[class=label_learner]", :text => "Email", :count => 1
    assert_select "span[class=label_learner]", :text => "Location", :count => 1
    assert_select "span[class=label_learner]", :text => "Country", :count => 1
    assert_select "span[class=label_learner]", :text => "City", :count => 1
    assert_select "span[class=label_learner]", :text => "Birth date", :count => 1
    assert_select "span[class=label_learner]", :text => "Age", :count => 1
    assert_select "span[class=label_learner]", :text => "Gender", :count => 1
    assert_select "span[class=label_learner]", :text => "GUID", :count => 1
    assert_select "span[class=label_learner]", :text => "Account Type", :count => 1
    assert_select "span[class=label_learner]", :text => "Time Zone", :count => 1
    assert_select "span[class=label_learner]", :text => "Activated", :count => 1
    assert_select "div#logged_in_info"
    assert_select "div#reflex_info"
    assert_select "span[class=label]", :text => "Total time in Daily Training Sessions", :count => 1
    assert_select "span[class=label]", :text => "Daily Training Sessions started", :count => 1
    assert_select "span[class=label]", :text => "Daily Training Sessions completed", :count => 1
    assert_select "span[class=label]", :text => "Skills Sessions completed", :count => 1
    assert_select "span[class=label]", :text => "Rehearsals Completed", :count => 1
    assert_select "span[class=label]", :text => "Dojo sessions completed", :count => 1
    learner
  end

  def assert_check_for_totale_learner_profile(source_type, source_user = nil)
    stub_learner(source_user)
    learner = FactoryGirl.create(:learner, :user_source_type => source_type, :guid => source_user.guid)
    learner.learner_product_rights[0].update_attribute(:language_identifier, 'ARA')
    get :show,  {:id => learner.id, :view_access => false}
    assert_response :success
    assert_select "div#general_info"
    assert_select "span[class=label_learner]", :text => "Name", :count => 1
    assert_select "span[class=label_learner]", :text => "Display Name", :count => 1
    assert_select "span[class=label_learner]", :text => "Email", :count => 1
    assert_select "span[class=label_learner]", :text => "Location", :count => 1
    assert_select "span[class=label_learner]", :text => "Country", :count => 1
    assert_select "span[class=label_learner]", :text => "City", :count => 1
    assert_select "span[class=label_learner]", :text => "Birth date", :count => 1
    assert_select "span[class=label_learner]", :text => "Age", :count => 1
    assert_select "span[class=label_learner]", :text => "Gender", :count => 1
    assert_select "span[class=label_learner]", :text => "GUID", :count => 1
    assert_select "span[class=label_learner]", :text => "Account Type", :count => 1
    assert_select "span[class=label_learner]", :text => "Time Zone", :count => 1
    assert_select "span[class=label_learner]", :text => "Activated", :count => 1
    assert_select "div#logged_in_info"
    assert_select "div#studio_info", 1
    learner
  end
end