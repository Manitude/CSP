require File.expand_path('../../../test_helper', __FILE__)
require 'extranet/homes_controller'
require 'scheduler_metadata'

class Extranet::HomesControllerTest < ActionController::TestCase

  def setup
    login_as_coach_manager
  end

  def test_side_navigation_for_admin
    login_as_custom_user(AdGroup.admin, 'test21')
    get :admin_dashboard
    assert_select 'div[id="main-navigation"]', :count => 1 do
      assert_select 'div[id="left-nav"]', :count => 1 do
        assert_select 'ul', :count => 1 do
          assert_select 'li', :count => 5 do
            assert_select 'a[href="/support_user_portal/view-profile"]', 'My Profile', :count => 1
            assert_select 'a[href="/homes/admin_dashboard"]', 'Admin Dashboard', :count => 1
            assert_select 'a[href="/scheduling_thresholds"]', 'Scheduling Thresholds', :count => 1
            assert_select 'a[href="/application_configuration"]', 'Application Configuration', :count => 1
            assert_select 'a[href="/application-status"]', 'Application Status', :count => 1
          end
        end
      end
    end
  end

  def test_enter_admin_dashboard_as_cm_and_check_for_records
    SchedulerMetadata.destroy_all
    get :admin_dashboard
    assert_equal 0, assigns(:master_scheduler_sessions_data).size
    FactoryGirl.create(:scheduler_metadata, :lang_identifier => "ARA", :locked => true)
    FactoryGirl.create(:scheduler_metadata, :lang_identifier => "ARA", :locked => true)
    assert_equal 2, assigns(:master_scheduler_sessions_data).size
  end

  def test_enter_admin_dashboard_as_admin_and_check_for_records
    login_as_custom_user(AdGroup.admin, 'test21')
    get :admin_dashboard
    assert_select 'div[class="admin_dashboard_item"]', :count => 7
  end
  
  def test_denial_of_data_for_coach
    coach = create_coach_with_qualifications('rajkumar', ['ARA', 'ENG'])
    login_as_custom_user(AdGroup.coach, coach.user_name)
    get :admin_dashboard
    assert_response :redirect
    assert_equal "Sorry, you are not authorized to view the requested page. Please contact the IT Help Desk.", flash[:error]
  end
  
  def test_release_lock_and_check_if_record_exists
    sm_data = FactoryGirl.create(:scheduler_metadata, :lang_identifier => "ARA")
    get :release_lock, :session_record_id => sm_data.id
    assert_raise(ActiveRecord::RecordNotFound) {SchedulerMetadata.find(sm_data.id) }
  end

  def test_release_lock_should_not_throw_error_when_record_does_not_exist
    #SchedulerMetadata.expects(:find).with(instance_of String).raises(ActiveRecord::RecordNotFound)
    get :release_lock, :session_record_id => 101
    assert_template 'lock_released', :succeeded => false, :message => "The lock has been released already"
  end

  def test_release_lock_should_not_throw_error_when_bulk_data_record_does_not_exist
    sm_data = FactoryGirl.create(:scheduler_metadata, :lang_identifier => "ARA")
    get :release_lock, :session_record_id => sm_data.id
    assert_template 'lock_released', :succeeded => true, :message => "The lock has been released already"
  end

  def test_audit_log_home_page
    get :audit_logs
    assert_response :success
    assert_nil assigns(:audit_log_records)
  end

  def test_audit_log_with_no_record_id
    post :audit_logs, {:table_name => "Region"}
    assert_response :success
    assert_equal 0, assigns(:audit_log_records).size
  end

  def test_global_setting_set_sms_alert
    FactoryGirl.create(:global_setting, :attribute_name => "minutes_before_session_for_sending_email_alert", :description => "Minutes before sessions are scheduled to start, check and see if coaches are present. For each coach not present, send an email to the coach and all Coach Supervisors", :attribute_value => "5")
    post :set_global_settings, {"minutes_before_session_for_triggering_sms_alert" => 20 }
    assert_equal assigns(:errors), nil
    assert_redirected_to :action => "admin_dashboard"
  end

  def test_audit_log_create
    post :audit_logs, {:table_name => "Region"}
    assert_response :success
    assert_equal 0, assigns(:audit_log_records).size

    dummy_region = Region.create(:name => "Test Region")

    post :audit_logs, {:table_name => "Region"}
    assert_response :success
    assert_equal 1, assigns(:audit_log_records).size
    audit_log_record = assigns(:audit_log_records).first
    assert_equal "Region", audit_log_record.loggable_type
    assert_equal dummy_region.id, audit_log_record.loggable_id
    assert_equal "create", audit_log_record.action
    assert_nil audit_log_record.new_value
    assert_nil audit_log_record.previous_value

  end

  def test_audit_log_update
    post :audit_logs, {:table_name => "Region"}
    assert_response :success
    assert_equal 0, assigns(:audit_log_records).size

    dummy_region = Region.create(:name => "Old Region")
    post :audit_logs, {:table_name => "Region"}
    assert_response :success
    assert_equal 1, assigns(:audit_log_records).size

    dummy_region.update_attribute(:name, "New Region")

    post :audit_logs, {:table_name => "Region", :record_action =>"update", :record_id => dummy_region.id}
    assert_response :success
    assert_equal 1, assigns(:audit_log_records).size
    audit_log_record = assigns(:audit_log_records).last

    assert_equal "update", audit_log_record.action
    assert_equal "name", audit_log_record.attribute_name
    assert_equal dummy_region.id, audit_log_record.loggable_id
    assert_equal "Region", audit_log_record.loggable_type
    assert_equal "New Region", audit_log_record.new_value
    assert_equal "Old Region", audit_log_record.previous_value
  end

  def test_audit_log_destroy
    post :audit_logs, {:table_name => "Region"}
    assert_response :success
    assert_equal 0, assigns(:audit_log_records).size

    dummy_region = Region.create(:name => "Old Region")

    post :audit_logs, {:table_name => "Region"}
    assert_response :success
    assert_equal 1, assigns(:audit_log_records).size

    dummy_region.destroy

    post :audit_logs, {:table_name => "Region"}
    assert_response :success
    assert_equal 2, assigns(:audit_log_records).size
    audit_log_record = assigns(:audit_log_records).last

    assert_equal "destroy", audit_log_record.action
    assert_equal dummy_region.id, audit_log_record.loggable_id
    assert_equal "Region", audit_log_record.loggable_type
    assert_nil audit_log_record.new_value
    assert_nil audit_log_record.previous_value
  end

  def test_global_setting_with_invalid_values_and_check_for_error_message
    FactoryGirl.create(:global_setting, :attribute_name => "minutes_before_session_for_sending_email_alert", :description => "Minutes before sessions are scheduled to start, check and see if coaches are present. For each coach not present, send an email to the coach and all Coach Supervisors", :attribute_value => "5")
    post :set_global_settings, {"average_learner_wait_time_threshold" => -10 }
    assert_true assigns(:errors).include?('»Average Learner wait time should be a positive Integer.')
    assert_redirected_to home_admin_dashboard_url(:errors => assigns(:errors))
  end

  def create_substituion_and_do(action = 'none')
    time = 1.hour
    language="KLE"
    CoachSession.any_instance.stubs(:send_email_to_coaches_and_coach_managers).returns nil # Since this method is called as a separate thread, this method has to be stubbed
    sample_coach = create_coach_with_qualifications("ssitoke",[])
    coach_session_in_x_hr = CoachSession.create!(:coach_id => sample_coach.id, :session_start_time => Time.now + time, :language_identifier => language, :eschool_session_id => SubSequence.next)
    sub_record = nil
    sub_record  = sample_coach.substitutions.create!(:grabber_coach_id => nil, :was_reassigned=>1, :cancelled=>0, :coach_session_id => coach_session_in_x_hr.id) if action == 'reassign'
    sub_record  = sample_coach.substitutions.create!(:grabber_coach_id => nil, :grabbed=>1, :cancelled=>0, :coach_session_id => coach_session_in_x_hr.id) if action == 'grab'
    sub_record  = sample_coach.substitutions.create!(:grabber_coach_id => nil, :cancelled=>0, :coach_session_id => coach_session_in_x_hr.id) if action == 'none'
    sub_record
  end

  def test_homes_index
    get :index
    assert_equal "", assigns(:page_title)
    assert_select 'h2','Substitutions'
    assert_select 'h2','Notifications'
    assert_select 'h2','Announcements'
  end

  def test_audit_log_filters
    post :audit_logs, {:table_name => "Region"}
    assert_response :success
    assert_equal 0, assigns(:audit_log_records).size

    dummy_region = Region.create(:name => "Old Region")
    post :audit_logs, {:table_name => "Region", :record_action =>"create", :record_id => dummy_region.id}
    assert_response :success
    audit_log_record = assigns(:audit_log_records).last
    assert_equal 1, assigns(:audit_log_records).size
    assert_equal "create", audit_log_record.action
    dummy_region.update_attribute(:name, "New Region")

    post :audit_logs, {:table_name => "Region", :record_action =>"update", :record_id => dummy_region.id}
    assert_response :success
    assert_equal 1, assigns(:audit_log_records).size
    audit_log_record = assigns(:audit_log_records).last
    assert_equal "update", audit_log_record.action
    assert_equal "New Region", audit_log_record.new_value
    assert_equal "Old Region", audit_log_record.previous_value

    post :audit_logs, {:table_name => "Region"}
    assert_response :success
    assert_equal 2, assigns(:audit_log_records).size
  end
  
  def test_log_filters_time
    dummy_region = Region.create(:name => "Old Region")
    today = Time.now.utc
    #custom - past period
    post :audit_logs, {:table_name => "Region", :duration => 'Custom', :start_date => (today-3.days).beginning_of_day.to_s(:db), :end_date => (today-3.days).end_of_day.to_s(:db)}
    assert_response :success
    assert_equal 0, assigns(:audit_log_records).size
    #custom - today
    post :audit_logs, {:table_name => "Region", :duration => 'Custom', :start_date => today.beginning_of_day.to_s(:db), :end_date => today.end_of_day.to_s(:db)}
    assert_response :success
    assert_equal 1, assigns(:audit_log_records).size

    #today filter
    post :audit_logs, {:table_name => "Region", :duration => 'Today', :start_date => Time.now.utc.beginning_of_day.to_s(:db), :end_date => Time.now.utc.end_of_day.to_s(:db)}
    assert_response :success
    assert_equal 1, assigns(:audit_log_records).size
    
    #yesterday case
    Time.stubs(:now).returns(today + 1.day)
    post :audit_logs, {:table_name => "Region", :duration => 'Yesterday', :start_date => today.beginning_of_day.to_s(:db), :end_date => today.end_of_day.to_s(:db)}
    assert_response :success
    assert_equal 1, assigns(:audit_log_records).size
    #last week
    Time.stubs(:now).returns(today + 7.day)
    post :audit_logs, {:table_name => "Region", :duration => 'Last week', :start_date => today.beginning_of_day.to_s(:db), :end_date => today.end_of_day.to_s(:db)}
    assert_response :success
    assert_equal 1, assigns(:audit_log_records).size

    #last month
    Time.stubs(:now).returns(today.months_ago(-1))
    post :audit_logs, {:table_name => "Region", :duration => 'Last month', :start_date => today.beginning_of_day.to_s(:db), :end_date => today.end_of_day.to_s(:db)}
    assert_response :success
    assert_equal 1, assigns(:audit_log_records).size

    #non matching filter case
    Time.stubs(:now).returns(today.months_ago(1))
    post :audit_logs, {:table_name => "Region", :duration => 'Today', :start_date => today.beginning_of_day.to_s(:db), :end_date => today.end_of_day.to_s(:db)}
    assert_response :success
    assert_equal 0, assigns(:audit_log_records).size
  end

  def test_track_users
    UserAction.create({:user_name => "SomeUser", :user_role => 'CoachManager', :action => "Pushed all session to Eschool"})
    get :track_users, {:user_role => 'CoachManager', :user_name => 'SomeUser'}
    assert_response :success
    assert_select 'h2','Track Users' 
    assert_select 'table[id="filter-table"]'
    assert_select 'table[id="audit_log_table"]'
  end
end