require File.dirname(__FILE__) + '/../test_helper'
require 'coach_portal_controller'
require 'sub_sequence'

class CoachPortalControllerTest < ActionController::TestCase
  fixtures :accounts, :qualifications, :languages, :coach_availability_templates, :unavailable_despite_templates, :coach_sessions, :language_configurations, :trigger_events, :notifications

  def setup
    Coach.any_instance.stubs(:valid?).returns true
  end
  #Whenever a logout action is performed, it should redirect to a login screen with a message
  def test_logout
    post :logout
    assert_response :redirect
    assert_equal "Logged out", flash[:notice]
  end

  #User should not be allowed to login, instead should be redirected to home page
  def test_login
    post :logout #Initially logout of the application and try to login
    get :index
    assert_response :redirect
  end

  def test_login_failed_due_to_ldap
    User.stubs(:authenticate).returns false #Simulate a failure authentication
    post :login, :coach => {:user_name => 'idonthaveldap', :password =>'bar'}
    assert_equal "Failed to authenticate idonthaveldap. Incorrect username/password combination.", flash[:error]
    assert_response :redirect
  end

  def test_login_failed_due_to_profile_incomplete
    user = login_as_custom_user(AdGroup.coach, 'test21')
    user.update_attribute('created_at', Time.now.utc)
    User.stubs(:authenticate).returns @request.session[:user] #user is present in LDAP
    post :login, :coach => {:user_name => 'coach', :password =>'P@$$w0rD'}
    assert_equal "Your coach manager or supervisor has not yet created a profile for you in the Customer Success Portal.<br/>Once your profile has been created you will be able to log in.", flash[:error]
    assert_response :redirect
  end

  def test_login_success_page
    user = login_as_custom_user(AdGroup.coach, 'test21')
    FactoryGirl.create(:preference_setting, :account_id => user.id, :start_page => 'HOME')
    User.stubs(:authenticate).returns @request.session[:user] #Simulate a success authentication
    Coach.any_instance.stubs(:qualifications).returns [Qualification.first]
    post :login, :coach => {:user_name => 'coach', :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    assert_redirected_to homes_url
  end

  def test_coach_showed_up
    coach = accounts(:ARA_scheduled_coach)
    login_as_custom_user(AdGroup.coach,coach.user_name)
    cs = coach_sessions(:session_starting_at_4_hours_from_now)
    assert_false cs.coach_showed_up
    CoachPortalController.any_instance.stubs(:load_next_session).returns(true)
    CoachSession.any_instance.stubs(:eschool_session_id_validations).returns(true)
    post :coach_showed_up, {:id => cs.id}
    cs = CoachSession.find cs.id
    assert_true cs.coach_showed_up
  end

  def test_view_profile_page_layout_for_coach
    Coach.any_instance.stubs(:qualifications).returns [Qualification.first]
    login_as_custom_user(AdGroup.coach, 'test21')
    get :view_profile
    assert_response :success
    assert_html_header_layout_tags
  end

  def test_view_profile_page_html_tags_for_coach
    Coach.any_instance.stubs(:qualifications).returns [Qualification.first]
    login_as_custom_user(AdGroup.coach, 'test21')
    get :view_profile
    assert_response :success
    assert_view_profile_html_field_tags
  end

  def test_edit_profile_page_layout_for_coach
    # Coach.any_instance.stubs(:qualifications).returns [Qualification.first]
    coach = login_as_custom_user(AdGroup.coach, 'testforeditprofile')
    aria_language     = Language['AUS'] || FactoryGirl.create(:aria_language, :identifier => 'AUS')
    reflex_language = Language['KLE']  || FactoryGirl.create(:reflex_language, :identifier => 'KLE')
    FactoryGirl.create(:qualification, :coach_id => coach.id, :language => aria_language, :max_unit => 1)
    FactoryGirl.create(:qualification, :coach_id => coach.id, :language => reflex_language, :max_unit => 1)
    get :edit_profile
    assert_response :success
    assert_select 'li.hide_units', :count => 2
    assert_select '.hide_units', :count => 2
    assert_select 'li.arabic_unit', :count => 1
    assert_select 'li.aeb_us_unit', :count => 1
    assert_select 'li.advanced_english_unit', :count => 1
    assert_html_header_layout_tags
  end

  def test_edit_profile_page_html_tags_for_coach
    Coach.any_instance.stubs(:qualifications).returns [Qualification.first]
    login_as_custom_user(AdGroup.coach, 'test21')
    get :edit_profile
    assert_response :success
    assert_edit_profile_html_field_tags
  end

  def test_start_page_for_coach_with_announcements_as_start_page_in_preference_settings
    user = login_as_custom_user(AdGroup.coach, 'test21')
    FactoryGirl.create(:preference_setting, :account_id => user.id, :start_page => COACH_START_PAGES["Announcements"])
    User.stubs(:authenticate).returns @request.session[:user] #Simulate a success authentication
    Coach.any_instance.stubs(:qualifications).returns [Qualification.first]
    post :login, :coach => {:user_name => 'coach', :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    assert_redirected_to self.send(START_PAGE_URLS[COACH_START_PAGES["Announcements"]])
  end

  def test_start_page_for_coach_with_events_as_start_page_in_preference_settings
    user = login_as_custom_user(AdGroup.coach, 'test21')
    FactoryGirl.create(:preference_setting, :account_id => user.id, :start_page => COACH_START_PAGES["Events"])
    User.stubs(:authenticate).returns @request.session[:user] #Simulate a success authentication
    Coach.any_instance.stubs(:qualifications).returns [Qualification.first]
    post :login, :coach => {:user_name => 'coach', :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    assert_redirected_to self.send(START_PAGE_URLS[COACH_START_PAGES["Events"]])
  end

  def test_start_page_for_coach_with_notifications_as_start_page_in_preference_settings
   user = login_as_custom_user(AdGroup.coach, 'test21')
    FactoryGirl.create(:preference_setting, :account_id => user.id, :start_page => COACH_START_PAGES["Notifications"])
    User.stubs(:authenticate).returns @request.session[:user] #Simulate a success authentication
    Coach.any_instance.stubs(:qualifications).returns [Qualification.first]
    post :login, :coach => {:user_name => 'coach', :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    assert_redirected_to self.send(START_PAGE_URLS[COACH_START_PAGES["Notifications"]])
  end

  def test_start_page_for_coach_with_substitutions_as_start_page_in_preference_settings
    user = login_as_custom_user(AdGroup.coach, 'test21')
    FactoryGirl.create(:preference_setting, :account_id => user.id, :start_page => COACH_START_PAGES["Substitutions"])
    User.stubs(:authenticate).returns @request.session[:user] #Simulate a success authentication
    Coach.any_instance.stubs(:qualifications).returns [Qualification.first]
    post :login, :coach => {:user_name => 'coach', :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    assert_redirected_to self.send(START_PAGE_URLS[COACH_START_PAGES["Substitutions"]])
  end

  def test_start_page_for_coach_with_my_schedule_as_start_page_in_preference_settings
    user = login_as_custom_user(AdGroup.coach, 'test21')
    FactoryGirl.create(:preference_setting, :account_id => user.id, :start_page => COACH_START_PAGES["My Schedule"])
    User.stubs(:authenticate).returns @request.session[:user] #Simulate a success authentication
    Coach.any_instance.stubs(:qualifications).returns [Qualification.first]
    post :login, :coach => {:user_name => 'coach', :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    assert_redirected_to self.send(START_PAGE_URLS[COACH_START_PAGES["My Schedule"]])
  end

  def test_start_page_for_coach_without_preference_settings
    stub_ldap_authentication_for_coach
    coach = create_a_coach
    assert_not_nil coach.get_preference
    User.stubs(:authenticate).returns @request.session[:user] #Simulate a success authentication
    post :login, :coach => {:user_name => coach.user_name, :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    assert_redirected_to my_schedule_url
  end

  def test_next_session_notification_countdown_for_coach_totale
    user = login_as_custom_user(AdGroup.coach, 'test21')
    User.stubs(:authenticate).returns @request.session[:user] #Simulate a success authentication
    Coach.any_instance.stubs(:qualifications).returns [Qualification.first]
    t = Time.now.min >= 30 ? Time.now.beginning_of_hour + 1.hour : Time.now.beginning_of_hour + 30.minutes
    sess = FactoryGirl.create(:confirmed_session, :coach_id=> user.id, :eschool_session_id => 1234, :language_identifier => 'ARA', :session_start_time => t)
    e_session = sample_eschool_session_object_for(sess)
    Time.stubs(:now).returns(sess.session_start_time - 5.minutes)
    post :login, :coach => {:user_name => 'coach', :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    get :get_next_session_details
    assert_select 'span[style="color:red"]'
    Eschool::Session.stubs(:find_by_id).returns(e_session)
    get :get_next_session_details
    assert_countdown_qtip
  end

  def test_next_session_notification_countdown_for_coach_reflex
    user = login_as_custom_user(AdGroup.coach, 'test21')
    User.stubs(:authenticate).returns @request.session[:user] #Simulate a success authentication
    Coach.any_instance.stubs(:qualifications).returns [Qualification.first]
    t = Time.now.min >= 30 ? Time.now.beginning_of_hour + 1.hour : Time.now.beginning_of_hour + 30.minutes
    FactoryGirl.create(:confirmed_session, :coach_id=> user.id, :eschool_session_id => 1234, :language_identifier => 'KLE', :session_start_time => t)
    Time.stubs(:now).returns(t - 5.minutes)
    post :login, :coach => {:user_name => 'coach', :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    get :get_next_session_details
    assert_countdown_qtip
  end

  def test_next_session_notification_countdown_for_coach_aria
    user = login_as_custom_user(AdGroup.coach, 'test21')
    User.stubs(:authenticate).returns @request.session[:user] #Simulate a success authentication
    Coach.any_instance.stubs(:qualifications).returns [Qualification.first]
    t = Time.now.beginning_of_hour + 1.hour
    ConfirmedSession.any_instance.stubs(:supersaas_learner).returns([])
    ConfirmedSession.any_instance.stubs(:supersaas_session).returns(nil)
    FactoryGirl.create(:confirmed_session, :coach_id=> user.id, :eschool_session_id => 1234, :language_identifier => 'AUS', :session_start_time => t)
    Time.stubs(:now).returns(t - 5.minutes)
    post :login, :coach => {:user_name => 'coach', :password =>'bar'}
    assert_equal "Signed in successfully", flash[:notice]
    get :get_next_session_details
    assert_select 'span[style="color:red"]'
    supersaas_sess = [{:booking_id=>11657961, :full_name=>user.full_name, :guid=>"ff3b8231-035f-453b-b32c-fe26b0e7a086", :email=>user.rs_email}]
    ConfirmedSession.any_instance.stubs(:supersaas_session).returns(supersaas_sess)
    get :get_next_session_details
    assert_countdown_qtip
  end

  def test_edit_profile_for_coach
    coach = create_coach_with_qualifications('Vishnu', ['ARA'])
    user = login_as_custom_user(AdGroup.coach, 'Vishnu')
    Callisto::Base.stubs(:create_or_update_coach_in_callisto).returns(true)
    response = Net::HTTPOK.new(true,200,"OK")
    Eschool::Coach.stubs(:create_or_update_teacher_profile_with_multiple_qualifications).returns(response)
    Eschool::Session.stubs(:update_wildcard_units_for_eschool_sessions).returns(response)
    response.stubs(:read_body).returns("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<response>\n  <status>OK</status>\n  <message>Successfully updated the profile in eSchool.</message>\n</response>\n")
    #random_name_suffix = rand(1000).to_s
    #random_qualification = 1 + (rand(Language['ARA'].max_unit) - 1)
    params = {"remove_profile_picture"=>"true", "coach"=>{"preferred_name"=>"Vishnu_ji", "country"=>"AF", "region_id"=>"4", "bio"=>"", "birth_date(3i)"=>"14", "address"=>"add", "birth_date(1i)"=>"1978", "birth_date(2i)"=>"10"}, "commit"=>"Save", "qualification"=>{"#{Language['ARA'].id}"=>5}}
    post :edit_profile, params
    user.reload
    assert_equal user.preferred_name, "Vishnu_ji"
    assert_equal user.qualifications.first.max_unit, 5
    assert_equal "Profile has been updated successfully.", flash[:notice]
    assert_redirected_to view_profile_url
  end

  def test_coach_notifications
    user = login_as_custom_user(AdGroup.coach, 'test21')
    User.stubs(:authenticate).returns @request.session[:user] #Simulate a success authentication
    Coach.any_instance.stubs(:qualifications).returns [Qualification.first]
    get :notifications
    assert_response :success
    assert_equal 'Notifications', assigns(:page_title)
  end

  def test_view_upcoming_classes
    user = login_as_custom_user(AdGroup.coach, 'test21')
    User.stubs(:authenticate).returns @request.session[:user] #Simulate a success authentication
    Coach.any_instance.stubs(:qualifications).returns [Qualification.first]
    t = Time.now.beginning_of_hour + 1.hour
    FactoryGirl.create(:confirmed_session, :coach_id=> user.id, :eschool_session_id => 1234, :language_identifier => 'ARA', :session_start_time => t)
    get :view_my_upcoming_classes
    assert_response :success
    assert_select 'div[id="upcoming_sessions"]'

  end

  def test_my_schedule
    user = login_as_custom_user(AdGroup.coach, 'test21')
    User.stubs(:authenticate).returns @request.session[:user] 
    get :calendar_week
    assert :redirected
  end

  private

  def sample_eschool_session_object_for(sess)
    session_data = {
      "eschool_session_id"=>sess.eschool_session_id,
      "external_session_id"=>"459595",
      "wildcard_units"=>"1",
      "cancelled"=>"false",
      "teacher_confirmed"=>"true",
      "learner_details"=>[],
      "level"=>"1",
      "wildcard_locked"=>"false", 
      "average_attendance"=>"0.0",
      "lesson"=>"4",
      "launch_session_url"=>"launchOnline('http://studio.rosettastone.com')",
      "language"=>sess.language_identifier,
      "number_of_seats"=>"4",
      "teacher_id"=>sess.coach_id,
      "learners_signed_up"=>"0",
      "teacher_arrived"=>"false",
      "students_attended"=>"0",
      "wildcard"=>"true",
      "start_time"=>sess.session_start_time,
      "unit"=>"1",
      "teacher"=>"Coach",
      "duration_in_seconds"=>"1800"
    }
    Eschool::Session.new(session_data)
  end

  def assert_countdown_qtip
    assert_select 'div[id="countdown-popup-content"]'
    assert_select 'span[id="title"]'
    assert_select 'div[class="session-details-half"]'
    assert_select 'div[id="launch_session"]'
  end
  
  def assert_html_header_layout_tags
    assert_select 'head'        , :count => 1
    assert_select 'head>link'   , :count => 18
    assert_select 'head>script' 
  end

  def assert_view_profile_html_field_tags
    assert_select 'div[id="content"]>div[id="content-header"]>div'
    assert_select 'h2', :text => "View Profile"

    assert_select 'span[class = "left-space"]>a[href="/edit-profile"]', :text => "Edit"
    assert_select 'div[class="justclear"]' #single line div

    assert_select 'div[id="profile"]' do
      assert_select 'p[class="header"][style="border-bottom: 2px solid gray;"]'

      assert_select 'div[id="general"]' do
        assert_select 'ul[class="col1"]' do
          assert_select 'li>label', "Full Name"
          assert_select 'span'    , "N/A"
          assert_select 'li>label', "External Coach ID"
          assert_select 'span'    , @request.session[:user].account.user_name
          assert_select 'li>label', "AD Name"
          assert_select 'span'    , "test21"
          assert_select 'li>label', "Preferred Name"
          assert_select 'span'    , "N/A"
          assert_select 'li>label', "Rosetta Email"
          assert_select 'span'    , "N/A"
          assert_select 'li>label', "Personal Email"
          assert_select 'span'    , "N/A"
          assert_select 'li>label', "Skype ID"
          assert_select 'span'    , "N/A"
          assert_select 'li>label', "Aim ID"
          assert_select 'span'    , "N/A"
          assert_select 'li>label', "Primary Phone"
          assert_select 'span'    , "N/A"
          assert_select 'li>label', "Secondary Phone"
          assert_select 'span'    , "N/A"
          assert_select 'li>label', "Mobile Phone"
          assert_select 'span'    , "N/A"
          assert_select 'li>label', "Address"
          assert_select 'span'    , "N/A"
          assert_select 'li>label',"Country"
          assert_select 'span'    , "N/A"
          assert_select 'li>label', "Region"
          assert_select 'span'    , "N/A"
        end

        assert_select 'ul[class="col2"]' do
          assert_select 'li>label'                           , "Active?"
          assert_select 'span'                               , "Yes"
          assert_select 'li>label'                           , "Role"
          assert_select 'span'                               , "Coach"
          assert_select 'li>label'                           , "Display Language"
          assert_select 'span'                               , "N/A"
          assert_select 'li>label'                           , "Language Qualification"
          assert_select 'span'                               , "N/A"
          assert_select 'li>label'                           , "Unit Qualification"
          assert_select 'span'                               , "N/A"
          assert_select 'li>label'                           , "Coach Manager"
          assert_select 'span'                               , "Yes"
          assert_select 'li>label'                           , "Supervisor"
          assert_select 'span'                               , "Yes"
          assert_select 'li>fieldset[class = "profile-fieldset"]>legend>span>div[class = "about_me"]', "About Me"
        end
      end

      assert_select 'div' do
        assert_select 'div[class = "left-space birthdate"]' do
          assert_select 'span[class = "bold-font"]' , "Birthdate"
          assert_select 'span[class = "left-space"]', "N/A"
        end
        assert_select 'div[class = "left-space top_bottom_space"]' #Single line div
      end
    end
  end


  def assert_edit_profile_html_field_tags
    assert_select 'div[id="content"]>div[id="content-header"]>div'
    assert_select 'h2', :text => "Edit Profile"

    assert_select 'span[class = "left-space"]>a[href="/view-profile"]', :text => "Return to My Profile"
    assert_select 'div[class="justclear"]' #single line div

    assert_select 'form[action="/edit-profile"][id="profile-form"][method="post"][name="profileform"]' do
      assert_select 'div[id="profile"]' do

        assert_select 'p[class="header"]'
        assert_select 'div[id="general"][class="pad-top-20 edit_profile"][style="float:left;"]'
        assert_select 'ul[class="col1"]' do
          assert_select 'li>label[for="coach_full_name"]', "Full Name*"
          assert_select  'li', :html => "<label for=\"coach_full_name\">Full Name*</label> test21"
          assert_select 'li>label[for="coach_user_name"]', "AD Name"
          assert_select  'li', :html => "<label for=\"coach_user_name\">AD Name</label> test21"
          assert_select 'li>label[for="coach_preferred_name"]', "Preferred Name"
          assert_select "input[id='coach_preferred_name'][name='coach[preferred_name]'][size='30'][type='text']"
          assert_select 'li>label[for="coach_lang_qualifications"]', "Language"
          assert_select  'li', :html => "<label for=\"coach_full_name\">Full Name*</label> test21"
          assert_select 'li>label[for="coach_unit_qualifications"]', "Unit Qualification"
          assert_select 'li>label[for="coach_address"]', "Address"
          assert_select "textarea[cols='45'][id='coach_address'][name='coach[address]'][rows='3']"

          assert_select 'li>label[for="coach_country"]', "Country*"
          assert_select "select[id='coach_country'][name='coach[country]']" do
            assert_select 'option', :count => 240
          end

          assert_select 'li>label[for="coach_region"]', "Region"
          assert_select "select[id='coach_region_id'][name='coach[region_id]']" do
            assert_select 'option', :count => 1
          end

          assert_select 'li>label[for="coach_other_languages"]', "Other Languages"
          assert_select 'input[id="olang-button"][name="olang-button"][type="button"][value="Show"][style="cursor:pointer;"][onclick="otherLangs();"]'
          assert_select 'br[style="clear:both"]'
          assert_select 'label'
          assert_select 'div[id="olang-div"]' do

            assert_select "input[name= 'olang[en-US]'][type= 'hidden'][value='0']"
            assert_select "input[id='olang_en-US'][name='olang[en-US]'][type='checkbox'][value='1']"
            assert_select 'label[for="language_English"]', "English"
            assert_select 'br[style="clear:both"]'

          end

          assert_select 'li>label[for="coach_bio"]', "About Me"
          assert_select "textarea[cols='45'][id='coach_bio'][name='coach[bio]'][rows='3']"
          assert_select 'li>label[for="coach_birth_date"]', "Birth Date*"
          assert_select "select[id='coach_birth_date_1i'][name='coach[birth_date(1i)]']" do
            assert_select 'option', :count => 61
          end

          assert_select "select[id='coach_birth_date_2i'][name='coach[birth_date(2i)]']" do
            assert_select 'option', :count => 12
          end

          assert_select "select[id='coach_birth_date_3i'][name='coach[birth_date(3i)]']" do
            assert_select 'option', :count => 31
          end

          assert_select "li>input[id='one_time_locale'][name='one_time_locale'][type='hidden'][value='en-US']"
          assert_select 'li>div[id="profile-save"]' do
            assert_select 'input[id="coach_submit"][name="commit"][type="submit"][value="Save"]'
          end

        end
      end
    end
  end

  def assert_coach_doesnt_have_preference_setting
    coach = Coach.find_by_user_name("coach")
    assert_not_nil coach.get_preference
    return coach
  end

end
