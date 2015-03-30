require File.expand_path('../../test_helper', __FILE__)

class CoachSessionTest < ActiveSupport::TestCase
  
  def test_cancel_and_stop_recurrence_with_recurrence_false
    coach = create_coach_with_qualifications('rajkumar', ['ARA'])
    coach_session   = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :session_start_time => Time.now.utc.beginning_of_hour+4.hour, :language_identifier => "ARA", :eschool_session_id => 343)
    Eschool::Session.stubs(:find_by_id).returns(eschool_sesson_without_learner)
    Eschool::Session.stubs(:cancel).returns true
    assert_equal(false,coach_session.cancelled)
    coach_session.cancel_and_stop_recurrence(false)
    Delayed::Worker.new.work_off
    coach_session = CoachSession.find coach_session.id
    assert_equal(true,coach_session.cancelled)
  end
 
  def test_cancel_and_stop_recurrence_with_recurrence_true
    Eschool::Session.stubs(:find_by_id).returns(eschool_sesson_without_learner)
    Eschool::Session.stubs(:cancel).returns true
    Account.delete_all
    coach = create_coach_with_qualifications('rajkumar', ['ESP'])
    session_time = Time.now.in_time_zone('Eastern Time (US & Canada)').beginning_of_hour + 2.hour
    coach_session   = FactoryGirl.create(:coach_session, :coach_id=> coach.id, :session_start_time => session_time.utc, :eschool_session_id=> 343, :language_identifier=> 'ESP')
    recurring_session_1 = FactoryGirl.create(:coach_session, :coach_id=> coach.id, :session_start_time => (session_time + 1.weeks).utc, :eschool_session_id=> 343, :language_identifier=> 'ESP')
    recurring_session_2 = FactoryGirl.create(:coach_session, :coach_id=> coach.id, :session_start_time => (session_time + 2.weeks).utc, :eschool_session_id=> 343, :language_identifier=> 'ESP')
    assert_equal(false,coach_session.cancelled)
    assert_equal(false,recurring_session_1.cancelled)
    assert_equal(false,recurring_session_2.cancelled)
    recurring_schedule = CoachRecurringSchedule.create(:day_index => coach_session.session_start_time.utc.strftime('%w'),:recurring_start_date => coach_session.session_start_time.utc,:start_time => coach_session.session_start_time.utc.strftime("%H:%M:%S"),:language_id => coach_session.language.id,:coach_id => coach_session.coach.id)
    assert_nil recurring_schedule.recurring_end_date, ""
    coach_session.update_attribute(:recurring_schedule_id, recurring_schedule.id)
    recurring_session_2.update_attribute(:recurring_schedule_id, recurring_schedule.id)
    recurring_session_1.update_attribute(:recurring_schedule_id, recurring_schedule.id)
    coach_session.language.update_attributes(:last_pushed_week => coach_session.session_start_time.beginning_of_week+14.days)
    coach_session.cancel_and_stop_recurrence(true)
    Delayed::Worker.new.work_off
    coach_session = CoachSession.find coach_session.id
    assert_equal(true,CoachSession.find(coach_session.id).cancelled)
    assert_not_nil CoachRecurringSchedule.find(recurring_schedule.id).recurring_end_date, ""
    assert_equal(true,CoachSession.find(recurring_session_1.id).cancelled)
    assert_equal(true,CoachSession.find(recurring_session_2.id).cancelled)
  end

  def test_enable_substitute_for_a_session
    coach = create_coach_with_qualifications('rajkumar', ['ARA'])
    coach_session = FactoryGirl.create(:confirmed_session, :session_start_time => (Time.now.beginning_of_hour + 5.hour).utc, :language_identifier => 'ARA', :coach_id => coach.id)
    eschool_session = eschool_session_with_learner
    CoachSession.any_instance.stubs(:eschool_session).returns(eschool_session)
    Eschool::Session.stubs(:substitute).returns(eschool_session)
    coach_session.enable_substitute!
    assert_nil coach_session.coach_id
  end

  def test_excluded_coaches
    Account.delete_all
    coach1 = create_coach_with_qualifications('rajkumar', ['ESP'])
    coach2 = create_coach_with_qualifications('rajkumar', ['ESP'])
    extra_session1 =  FactoryGirl.create(:extra_session, :session_start_time=> (Time.now.beginning_of_hour + 5.hour).utc,:eschool_session_id=> nil,:cancelled=> 0,:language_identifier=> 'ESP', :type=> 'ExtraSession')
    FactoryGirl.create(:excluded_coaches_session, :coach_id => coach1.id, :coach_session_id => extra_session1.id)
    FactoryGirl.create(:excluded_coaches_session, :coach_id => coach2.id, :coach_session_id => extra_session1.id)
    excluded_coaches = extra_session1.excluded_coaches_sessions
    assert_equal excluded_coaches.size,2
  end

  def test_request_for_a_substitute_and_check_flow
    Account.delete_all
    coach = create_coach_with_qualifications('rajkumar', ['ARA'])
    eschool_session = eschool_sesson_without_learner
    session = FactoryGirl.create(:confirmed_session, :eschool_session_id=> eschool_session.eschool_session_id.to_i, :language_identifier => 'ARA', :coach_id => coach.id)
    ConfirmedSession.any_instance.expects(:reflex).never
    ConfirmedSession.any_instance.stubs(:eschool_session).returns(eschool_session)
    Eschool::Session.stubs(:substitute).returns(true)
    Eschool::Session.stubs(:cancel).returns(true)
    session.cancel_or_subsitute!
    assert_true session.cancelled
  end

  def test_request_for_a_substitute_for_session_with_learner_and_check_for_sub_record
    Account.delete_all
    coach = create_coach_with_qualifications('rajkumar', ['ARA'])
    session = FactoryGirl.create(:confirmed_session, :language_identifier => 'ARA', :coach_id => coach.id)
    ConfirmedSession.any_instance.expects(:reflex).never
    eschool_session = eschool_session_with_learner
    ConfirmedSession.any_instance.stubs(:eschool_session).returns(eschool_session)
    Eschool::Session.stubs(:substitute).returns(nil)
    session.cancel_or_subsitute!
    sub= Substitution.find_by_coach_session_id(session.id)
    assert_not_nil sub
  end

  def test_check_the_count_of_sessions_in_next_hours
    CoachSession.delete_all    
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
    t1 = Time.now.beginning_of_hour.utc + 2.hour
    FactoryGirl.create(:confirmed_session, :coach_id=> coach.id, :language_identifier => 'KLE', :session_start_time => t1)
    FactoryGirl.create(:confirmed_session, :coach_id=> coach.id, :language_identifier => 'KLE', :session_start_time => t1+1.hour)
    FactoryGirl.create(:confirmed_session, :coach_id=> coach.id, :language_identifier => 'KLE', :session_start_time => t1+2.hour)
    FactoryGirl.create(:confirmed_session, :coach_id=> coach.id, :language_identifier => 'KLE', :session_start_time => t1+3.hour, :cancelled => 1)
    next_hour_coach_count = CoachSession.find_coaches_between(t1, t1+1.hours, 'KLE')
    assert_equal 1, next_hour_coach_count.length
  end

  def test_check_the_count_of_sessions_in_current_and_running_hour
    CoachSession.delete_all    
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
    t1 = Time.now.beginning_of_hour.utc + 2.hour
    FactoryGirl.create(:confirmed_session, :coach_id=> coach.id, :language_identifier => 'KLE', :session_start_time => t1)
    FactoryGirl.create(:confirmed_session, :coach_id=> coach.id, :language_identifier => 'KLE', :session_start_time => t1+1.hour)
    FactoryGirl.create(:confirmed_session, :coach_id=> coach.id, :language_identifier => 'KLE', :session_start_time => t1+3.hour, :cancelled => 1)
    next_hour_coach_count = CoachSession.find_coaches_between(t1, t1+1.hours, 'KLE')
    assert_equal 1, next_hour_coach_count.length

  end

  def test_check_the_count_of_aria_sessions_in_next_hours
    CoachSession.delete_all    
    coach = create_coach_with_qualifications('rajkumar', ['AUS'])
    coach2 = create_coach_with_qualifications('rajkumarTwo', ['AUK'])
    t1 = Time.now.beginning_of_hour.utc + 2.hour
    FactoryGirl.create(:confirmed_session, :coach_id=> coach.id, :language_identifier => 'AUS', :session_start_time => t1)
    FactoryGirl.create(:confirmed_session, :coach_id=> coach2.id, :language_identifier => 'AUK', :session_start_time => t1)
    FactoryGirl.create(:confirmed_session, :coach_id=> coach.id, :language_identifier => 'AUS', :session_start_time => t1+1.hour)
    FactoryGirl.create(:confirmed_session, :coach_id=> coach.id, :language_identifier => 'AUS', :session_start_time => t1+2.hour)
    FactoryGirl.create(:confirmed_session, :coach_id=> coach.id, :language_identifier => 'AUS', :session_start_time => t1+3.hour, :cancelled => 1)
    next_hour_coach_count_all_aria = CoachSession.find_aria_coaches_between(t1, t1+1.hours, 'all')
    next_hour_coach_count_AUK = CoachSession.find_aria_coaches_between(t1, t1+1.hours, 'AUK')
    next_hour_coach_count_AUS = CoachSession.find_aria_coaches_between(t1, t1+1.hours, 'AUS')
    assert_equal 2, next_hour_coach_count_all_aria.length
    assert_equal 1, next_hour_coach_count_AUK.length
    assert_equal 1, next_hour_coach_count_AUS.length
  end

  
  def test_send_email_to_coaches_without_preference_setting
    ActionMailer::Base.deliveries  = []
    options = { :method_call        => "send_email_to_coaches_and_coach_managers",
      :preference_type    => "substitution_alerts_email",
      :preference_setting => false}
    assert_send_sms_email_to_coaches(options)
  end

  def test_send_email_to_coaches_with_preference_setting_true_and_email_type_as_personal_and_daily_cap_null
    ActionMailer::Base.deliveries  = []
    options = { :method_call        => "send_email_to_coaches_and_coach_managers",
      :preference_type    => "substitution_alerts_email",
      :preference_setting => true,
      :pref_value         => 1}
    assert_send_sms_email_to_coaches(options)
    assert_true !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries[0]
    assert_equal ["personal@email.com"], email.to

  end

  def test_request_substitute_non_reflex_without_learners
    session = initial_setup_for_request_substitute('ARA', 0 ,12345)
    udt = session.request_substitute
    assert_equal session.coach_id, udt.coach_id
    assert_true session.cancelled
    assert_not_nil session.coach
    assert_equal 4, udt.unavailability_type
    assertion_for_sub_request(session, udt)
  end

  def test_request_substitute_non_reflex_with_learners
    session = initial_setup_for_request_substitute('ARA', 1, 12345)
    udt = session.request_substitute
    assert_false session.cancelled
    assert_nil session.coach
    assert_equal 1, udt.unavailability_type
    assertion_for_sub_request(session, udt)
  end

  def test_request_substitute_for_reflex_session
    session = initial_setup_for_request_substitute('KLE')
    udt = session.request_substitute(false)
    assert_false session.cancelled
    assert_nil session.coach
    assert_equal 1, udt.unavailability_type
    assertion_for_sub_request(session, udt, false)
  end

  def assertion_for_sub_request(session, udt, is_manager = true)
    assert_equal session.session_start_time, udt.start_date
    assert_equal 'Auto Approved - Coach requested Substitute', udt.comments
    assert_equal session.id, udt.coach_session_id
    unless session.cancelled
      unless is_manager
        te1 = TriggerEvent.find_by_name('SUBSTITUTE_REQUESTED')
        sn1 = SystemNotification.find_all_by_notification_id(te1.notification.id)
        assert_equal CoachManager.all.size, sn1.size
      else
        te1 = TriggerEvent.find_by_name('SUBSTITUTE_REQUESTED_FOR_COACH')
        sn1 = SystemNotification.find_all_by_notification_id(te1.notification.id)
        assert_equal session.language.coaches.size, sn1.size
      end
    end
  end
  
  def initial_setup_for_request_substitute(lang_identifier, learners = 0, es_id = nil)
    Account.delete_all
    Notification.delete_all
    NotificationRecipient.delete_all
    NotificationMessageDynamic.delete_all
    notif1 = FactoryGirl.create(:notification, :trigger_event_id => 21, :message => 'Your manager has requested a substitute on your behalf for your session starting .', :target_type => 'UnavailableDespiteTemplate')
    notif2 = FactoryGirl.create(:notification, :trigger_event_id => 17, :message => 'has requested a substitute for session starting .', :target_type => 'UnavailableDespiteTemplate')
    notif1.recipients << FactoryGirl.create(:notification_recipient, :notification_id => notif1.id, :name => 'Coach', :rel_recipient_obj => 'coach')
    notif2.recipients << FactoryGirl.create(:notification_recipient, :notification_id => notif2.id, :name => 'Coach Manager', :rel_recipient_obj => 'all_managers')
    FactoryGirl.create(:notification_message_dynamic, :notification_id => notif1.id, :name => 'Session Start Time', :msg_index => 81, :rel_obj_attr => 'start_date')
    FactoryGirl.create(:notification_message_dynamic, :notification_id => notif2.id, :name => 'Coach Name', :msg_index => 0, :rel_obj_type => 'coach', :rel_obj_attr => 'name')
    FactoryGirl.create(:notification_message_dynamic, :notification_id => notif2.id, :name => 'Session Start Time', :msg_index => 48, :rel_obj_attr => 'start_date')
    coach = create_coach_with_qualifications('subrequestedcoach', [lang_identifier])
    FactoryGirl.create(:account)
    datetime = (Time.now.beginning_of_hour + 1.day).utc
    ConfirmedSession.any_instance.stubs(:learners_signed_up).returns(learners)
    ConfirmedSession.any_instance.stubs(:send_email_to_coaches_and_coach_managers).returns(nil)
    Eschool::Session.stubs(:substitute).returns(true)
    Eschool::Session.stubs(:cancel).returns(true)
    FactoryGirl.create(:confirmed_session, :eschool_session_id => es_id,:session_start_time => datetime, :session_end_time => (datetime + 30.minutes), :language_identifier => lang_identifier, :coach_id => coach.id)
  end

  def test_send_email_to_coaches_with_preference_setting_true_and_email_type_as_rosetta_and_daily_cap_null
    ActionMailer::Base.deliveries  = []
    options = { :method_call        => "send_email_to_coaches_and_coach_managers",
      :preference_type    => "substitution_alerts_email",
      :preference_setting => true,
      :pref_value         => 1,
      :email_type         => COMMON_EMAIL_TYPES["Rosetta"]}
    assert_send_sms_email_to_coaches(options)
    assert_true !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries[0]
    assert_equal ["rs@email.com"], email.to

  end


  def test_send_email_to_coaches_with_preference_setting_true_and_daily_cap_with_zero
    ActionMailer::Base.deliveries  = []
    options = { :method_call        => "send_email_to_coaches_and_coach_managers",
      :preference_type    => "substitution_alerts_email",
      :preference_setting => true,
      :pref_value         => 1,
      :email_type         => COMMON_EMAIL_TYPES["Rosetta"],
      :daily_cap_aval     => true,
      :daily_cap_value    => 0}
    assert_send_sms_email_to_coaches(options)
  end

  def test_send_email_to_coaches_with_preference_setting_true_and_daily_cap_with_not_zero
    ActionMailer::Base.deliveries  = []
    options = { :method_call        => "send_email_to_coaches_and_coach_managers",
      :preference_type    => "substitution_alerts_email",
      :preference_setting => true,
      :pref_value         => 1,
      :email_type         => COMMON_EMAIL_TYPES["Rosetta"],
      :daily_cap_aval     => true}
    assert_send_sms_email_to_coaches(options)
    assert_true !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries[0]
    assert_equal ["rs@email.com"], email.to

  end

  def test_send_email_to_coaches_with_preference_setting_true_and_daily_cap_with_not_zero_and_mails_sent_with_less_value
    ActionMailer::Base.deliveries  = []
    options = { :method_call        => "send_email_to_coaches_and_coach_managers",
      :preference_type    => "substitution_alerts_email",
      :preference_setting => true,
      :pref_value         => 1,
      :email_type         => COMMON_EMAIL_TYPES["Rosetta"],
      :daily_cap_aval     => true}
    assert_send_sms_email_to_coaches(options)
    assert_true !ActionMailer::Base.deliveries.empty?

    email = ActionMailer::Base.deliveries[0]
    assert_equal ["rs@email.com"], email.to

  end

  def test_send_email_to_coaches_with_preference_setting_true_and_daily_cap_with_not_zero_and_mails_sent_with_greater_value
    ActionMailer::Base.deliveries  = []
    options = { :method_call        => "send_email_to_coaches_and_coach_managers",
      :preference_type    => "substitution_alerts_email",
      :preference_setting => true,
      :pref_value         => 1,
      :email_type         => COMMON_EMAIL_TYPES["Rosetta"],
      :daily_cap_aval     => true,
      :mails_sent_value   => 8}
    assert_send_sms_email_to_coaches(options)
  end

  def test_send_email_to_coaches_with_preference_setting_false
    ActionMailer::Base.deliveries  = []
    options = { :method_call        => "send_email_to_coaches_and_coach_managers",
      :preference_type    => "substitution_alerts_email",
      :preference_setting => true}
    assert_send_sms_email_to_coaches(options)
  end


  def test_send_email_to_coach_manager_without_preference_setting
    ActionMailer::Base.deliveries   = []
    options = { :preference_setting => false,
      :pref_value         => 0,
      :email_type         => COMMON_EMAIL_TYPES["Rosetta"],
      :daily_cap_aval     => false}
    assert_send_email_to_managers(options)
  end

  def test_send_email_to_coach_manager_with_preference_setting_email_true
    ActionMailer::Base.deliveries   = []
    options = { :preference_setting => true,
      :pref_value         => 1,
      :email_type         => COMMON_EMAIL_TYPES["Rosetta"],
      :daily_cap_aval     => true}
    assert_send_email_to_managers(options)
    assert_email_delivery_hash_for_coach_managers
  end

  def test_send_email_to_coach_manager_with_preference_setting_email_false
    ActionMailer::Base.deliveries   = []
    options = { :preference_setting => true,
      :pref_value         => 0,
      :email_type         => COMMON_EMAIL_TYPES["Rosetta"],
      :daily_cap_aval     => false}
    assert_send_email_to_managers(options)
  end

  def test_send_email_to_coach_manager_with_preference_setting_true_and_daily_cap_with_zero
    ActionMailer::Base.deliveries  = []
    options = {:preference_setting => true,
      :pref_value         => 1,
      :email_type         => COMMON_EMAIL_TYPES["Rosetta"],
      :daily_cap_aval     => true,
      :daily_cap_value    => 0}
    assert_send_email_to_managers(options)
  end

  def test_send_email_to_coach_manager_with_preference_setting_true_and_daily_cap_with_not_zero
    ActionMailer::Base.deliveries  = []
    options = {:preference_setting => true,
      :pref_value         => 1,
      :email_type         => COMMON_EMAIL_TYPES["Rosetta"],
      :daily_cap_aval     => true}

    assert_send_email_to_managers(options)
    assert_email_delivery_hash_for_coach_managers

  end

  def test_send_email_to_coach_manager_with_preference_setting_true_and_daily_cap_with_not_zero_and_mails_sent_with_less_value
    ActionMailer::Base.deliveries  = []
    options = { :preference_setting => true,
      :pref_value         => 1,
      :email_type         => COMMON_EMAIL_TYPES["Rosetta"],
      :daily_cap_aval     => true}

    assert_send_email_to_managers(options)
    assert_email_delivery_hash_for_coach_managers
  end

  def test_send_email_to_coach_manager_with_preference_setting_true_and_daily_cap_with_not_zero_and_mails_sent_with_greater_value
    ActionMailer::Base.deliveries  = []
    options = {:preference_setting => true,
      :pref_value         => 1,
      :email_type         => COMMON_EMAIL_TYPES["Rosetta"],
      :daily_cap_aval     => true,
      :mails_sent_value    => 8}
    assert_send_email_to_managers(options)
  end

  def test_enable_substitute_for_a_session_with_a_coach_whose_record_not_found #test for a safety fix to handle if any accounts-record was deleted mannualy.
    coach = create_coach_with_qualifications('rajkumar', ['ARA'])
    coach_session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :session_start_time => Time.now.utc.beginning_of_hour+2.hour, :language_identifier => "ARA")
    eschool_session = eschool_session_with_learner
    CoachSession.any_instance.stubs(:eschool_session).returns(eschool_session)
    # There will be no coach with id = (Account.maximum("id") + 1). So, here we test this out-of-edge case.
    qualification = Qualification.create(:coach_id => (Account.maximum("id") + 1), :language_id => Language.find_by_identifier(coach_session.language_identifier).id)
    qualification.save(:validate => false)
    Eschool::Session.stubs(:substitute).returns(eschool_session)
    coach_session.enable_substitute!
    assert_nil coach_session.coach_id
  end

  # def test_bulk_cancel_coach_sessions
  #   coach = create_coach_with_qualifications('rajkumar', ['ARA'])
  #   cs1 = FactoryGirl.create(:local_session, :coach_id => coach.id, :eschool_session_id => 111, :session_start_time => Time.now.utc.beginning_of_hour+2.hour, :language_identifier => "ARA")
  #   cs2 = FactoryGirl.create(:local_session, :coach_id => coach.id, :eschool_session_id => 222, :session_start_time => Time.now.utc.beginning_of_hour+3.hour, :language_identifier => "ARA")
  #   Eschool::Session.stubs(:bulk_cancel).returns([cs1,cs2])
  #   eschool_session_ids = [cs1,cs2].collect(&:eschool_session_id)
  #   CoachSession.bulk_cancel_sessions(eschool_session_ids, 'UTC')
  #   cs1.reload
  #   cs2.reload
  #   assert_true cs1.cancelled
  #   assert_true cs2.cancelled
  # end

  # def test_bulk_cancel_coach_less_sessions
  #   coach = create_coach_with_qualifications('rajkumar', ['ARA'])
  #   Eschool::Session.stubs(:substitute).returns true
  #   LocalSession.any_instance.stubs(:learners_signed_up).returns 1
  #   cs1 = FactoryGirl.create(:local_session, :coach_id => coach.id, :eschool_session_id => 111, :session_start_time => Time.now.utc.beginning_of_hour+2.hour, :language_identifier => "ARA")
  #   cs2 = FactoryGirl.create(:local_session, :coach_id => coach.id, :eschool_session_id => 222, :session_start_time => Time.now.utc.beginning_of_hour+3.hour, :language_identifier => "ARA")
  #   cs1.request_substitute
  #   cs2.request_substitute
  #   sub1 = cs1.substitution
  #   sub2 = cs2.substitution
  #   Eschool::Session.stubs(:bulk_cancel).returns([cs1,cs2])
  #   eschool_session_ids = [cs1,cs2].collect(&:eschool_session_id)
  #   assert_false sub1.cancelled
  #   assert_false sub2.cancelled
  #   LocalSession.any_instance.stubs(:email_cancelled_session_details)
  #   CoachSession.bulk_cancel_sessions(eschool_session_ids, 'UTC')
  #   [cs1, cs2, sub1, sub2].each do |record|
  #     record.reload
  #     assert_true record.cancelled
  #   end
  # end

  def test_cancel_and_email
    ActionMailer::Base.deliveries  = []
    coach = create_coach_with_qualifications('coach1', ['ENG'])
    cs1 = FactoryGirl.create(:local_session, :coach_id => coach.id, :eschool_session_id => 111, :session_start_time => Time.now.utc.beginning_of_hour+2.hour, :language_identifier => "ENG")
    Eschool::Session.stubs(:find_by_id).returns(eschool_session_with_learner)
    Thread.current[:account] = FactoryGirl.create(:account, :full_name => "CoachManager21")
    cs1.cancel_and_email
    assert_true cs1.cancelled
    assert_email_delivery_for_cancelled_session
  end

  def test_cancel_and_email_with_sub_requested_session
    ActionMailer::Base.deliveries  = []
    coach = create_coach_with_qualifications('coach1', ['ENG'])
    cs1 = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :eschool_session_id => 111, :session_start_time => Time.now.utc.beginning_of_hour+2.hour, :language_identifier => "ENG")
    Eschool::Session.stubs(:find_by_id).returns(eschool_session_with_learner)
    Eschool::Session.stubs(:substitute).returns(true)
    Thread.current[:account] = FactoryGirl.create(:account, :full_name => "CoachManager21")
    cs1.request_substitute
    cs1.cancel_and_email
    assert_true cs1.cancelled
    assert_email_delivery_for_cancelled_session
  end

  def assert_email_delivery_for_cancelled_session
    assert_true !ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries[0]
    assert_equal ["rsstudioteam-supervisors-l@rosettastone.com"], email.to
  end

  def test_count_actual_scheduled_reflex_session_count
    coach1 = create_coach_with_qualifications('rajkumarone', ['KLE'])
    coach2 = create_coach_with_qualifications('rajkumartwo', ['KLE'])
    coach3 = create_coach_with_qualifications('rajkumarthree', ['KLE'])
    FactoryGirl.create(:confirmed_session, :language_identifier => 'KLE', :eschool_session_id => 251, :session_start_time => '2025-05-20 10:00:00'.to_time, :coach_id => coach3.id)
    FactoryGirl.create(:confirmed_session, :type => 'ConfirmedSession',:language_identifier => 'KLE', :eschool_session_id => 252, :session_start_time => '2025-05-20 10:00:00'.to_time, :coach_id => coach1.id)
    FactoryGirl.create(:extra_session, :language_identifier => 'KLE', :eschool_session_id => 253, :session_start_time => '2025-05-20 10:00:00'.to_time)
    FactoryGirl.create(:confirmed_session,:type => 'ConfirmedSession', :language_identifier => 'KLE', :cancelled => 1, :eschool_session_id => 254, :session_start_time => '2025-05-20 10:00:00'.to_time, :coach_id => coach2.id)

    scheduled_session_count = ConfirmedSession.get_reflex_session_count_for_a_slot('2025-05-20 10:00:00'.to_time)
    assert_equal 2, scheduled_session_count
  end

  def test_audit_logging_for_coach_session_creation
    CustomAuditLogger.set_changed_by!("test21")
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
    coach_session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :session_start_time => Time.now.utc.beginning_of_hour+2.hour, :language_identifier => "KLE")
    audit_record = AuditLogRecord.last

    assert_equal coach_session.id, audit_record.loggable_id
    assert_equal "CoachSession", audit_record.loggable_type
    assert_equal "create", audit_record.action
    assert_equal "test21", audit_record.changed_by
  end

  def test_audit_logging_for_coach_session_edit
    CustomAuditLogger.set_changed_by!("test21")
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
    coach_session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :session_start_time => Time.now.utc.beginning_of_hour+2.hour, :language_identifier => "KLE")
    coach_session.update_attribute('coach_id', 124)
    audit_record = AuditLogRecord.last

    assert_equal coach_session.id, audit_record.loggable_id
    assert_equal "CoachSession", audit_record.loggable_type
    assert_equal "update", audit_record.action
    assert_equal "test21", audit_record.changed_by
  end

  def test_audit_logging_for_coach_session_deletion
    CustomAuditLogger.set_changed_by!("test21")
    coach = create_coach_with_qualifications('rajkumar', ['KLE'])
    coach_session = FactoryGirl.create(:confirmed_session, :coach_id => coach.id, :session_start_time => Time.now.utc.beginning_of_hour+2.hour, :language_identifier => "KLE")
    coach_session.destroy
    audit_record = AuditLogRecord.last

    assert_equal coach_session.id, audit_record.loggable_id
    assert_equal "CoachSession", audit_record.loggable_type
    assert_equal "destroy", audit_record.action
    assert_equal "test21", audit_record.changed_by
  end

  def test_label_for_google_calendar
    time_pointer = Time.now.beginning_of_hour.utc
    coach = create_coach_with_qualifications('vkn', ['ESP', 'ARA', 'KLE'])
    external_village_id_with_no_village = 0
    Eschool::Session.stubs(:find_by_id).returns(eschool_sesson_without_learner)
    Eschool::Session.any_instance.stubs(:external_village_id).returns(external_village_id_with_no_village)

    session1 = FactoryGirl.create(:coach_session, :coach_id=> coach.id, :session_start_time => time_pointer + 2.hour, :eschool_session_id=> 1343, :language_identifier=> 'ESP')
    assert_equal "Spanish (Latin America) Max L3-U12-LE2", session1.label_for_google_calendar

    session2 = FactoryGirl.create(:local_session, :coach_id=> coach.id, :session_start_time => time_pointer + 3.hour, :eschool_session_id=> 1344, :language_identifier=> 'ESP')
    assert_equal "Spanish (Latin America) Max L3-U12-LE2", session2.label_for_google_calendar

    session3 = FactoryGirl.create(:coach_session, :coach_id=> coach.id, :session_start_time => time_pointer + 4.hour, :eschool_session_id=> 1345, :language_identifier=> 'KLE')
    assert_equal "Advanced English", session3.label_for_google_calendar
  end

  private

  def assert_send_sms_email_to_coaches(options)
    default_options = {
      :pref_value       => 0,
      :email_type       => COMMON_EMAIL_TYPES["Personal"],
      :daily_cap_aval   => false,
      :daily_cap_value  => 5,
      :mails_sent_value => 3
    }
    
    options.reverse_merge!(default_options)
    Qualification.delete_all
    PreferenceSetting.delete_all
    Account.delete_all # Added this line to avoid sending mail to Coach Mangers

    coach = create_a_coach
    coach.update_attributes(
      :mobile_phone        => "1234568790",
      :mobile_country_code => "91",
      :rs_email            => "rs@email.com",
      :personal_email      => "personal@email.com"
    )
    if options[:preference_setting]
      params_for_pref = {
        options[:preference_type]                   => options[:pref_value],
        :substitution_alerts_email_type             => options[:email_type],
        :account_id                                 => coach.id,
        :substitution_alerts_email_sending_schedule => COMMON_SCHEDULE_TYPES["Immediately"]
      }
      params_for_pref.merge!({
        :daily_cap => options[:daily_cap_value],
        :mails_sent => options[:mails_sent_value]
      }) if options[:daily_cap_aval]

      PreferenceSetting.create(params_for_pref)
      assert_equal 1, PreferenceSetting.count
    end

    coach.qualifications.create(:max_unit => "12", :language_id => Language["ESP"].id)

    date      = "2022-01-04 00:00:00".to_time # (Sending as UTC Time)
    lang      = Language["ESP"]
    session   = create_recurring_session(coach,date,lang)
    sub_data  = Substitution.create(:coach_id => coach.id, :grabbed => false, :coach_session_id => session.id)
    session.send(options[:method_call])

    if options[:daily_cap_aval] && options[:method_call] == "send_email_to_coaches_and_coach_managers" &&
        options[:daily_cap_value] != 0 && options[:daily_cap_value] > options[:mails_sent_value]
      assert_updating_mail_sent( (options[:mails_sent_value] + 1), coach)
    end

  end  

  def assert_send_email_to_managers(options)
    default_options = {:pref_value       => 0,
      :email_type       => COMMON_EMAIL_TYPES["Personal"],
      :daily_cap_aval   => false,
      :daily_cap_value  => 5,
      :mails_sent_value => 3}
    options.reverse_merge!(default_options)
    Qualification.delete_all
    PreferenceSetting.delete_all
    Account.delete_all
    
    selected_cms = ["vramanan", "skumar", "ajayakodi"]
   FactoryGirl.create(:account,:user_name => 'vramanan',:rs_email => 'vramanan@rosettastone.com');
   FactoryGirl.create(:account,:user_name => 'skumar',:rs_email => 'skumar@rosettastone.com');
   FactoryGirl.create(:account,:user_name => 'ajayakodi',:rs_email => 'ajayakodi@rosettastone.com');
    
    CoachManager.all.each do |cm|
      selected_cms.each do |sel_cm|
        if cm.user_name == sel_cm
          if options[:preference_setting]            
            params_for_pref = {:substitution_alerts_email => options[:pref_value],
              :substitution_alerts_email_type             => options[:email_type],
              :account_id                                 => cm.id,
              :substitution_alerts_email_sending_schedule => COMMON_SCHEDULE_TYPES["Immediately"]}
            params_for_pref.merge!({:daily_cap => options[:daily_cap_value], :mails_sent => options[:mails_sent_value]}) if options[:daily_cap_aval]
            PreferenceSetting.create(params_for_pref)
          end
        end
      end
    end
    assert_equal 3, PreferenceSetting.count if options[:preference_setting]

    coach = create_a_coach
    coach.update_attributes(:mobile_phone        => "1234568790",
      :mobile_country_code => "91",
      :rs_email            => "rs@email.com",
      :personal_email      => "personal@email.com")
    coach.save!

    if options[:preference_setting]
      params_for_pref = {:substitution_alerts_email                  => options[:pref_value],
        :substitution_alerts_email_type             => options[:email_type],
        :account_id                                 => coach.id,
        :substitution_alerts_email_sending_schedule => COMMON_SCHEDULE_TYPES["Immediately"]}
      params_for_pref.merge!({:daily_cap => options[:daily_cap_value], :mails_sent => options[:mails_sent_value]}) if options[:daily_cap_aval]
      PreferenceSetting.create(params_for_pref)
      assert_equal 4, PreferenceSetting.count
    end

    coach.qualifications.create(:max_unit => "12", :language_id => Language["ESP"].id)

    date  = "2022-01-04 00:00:00".to_time # (Sending as UTC Time)
    lang  = Language["ESP"]
    session = create_recurring_session(coach,date,lang)
    Substitution.create(
      :coach_id         => coach.id,
      :grabbed          => false,
      :coach_session_id => session.id)
    session.send_email_to_coaches_and_coach_managers
  end


  def assert_email_delivery_hash_for_coach_managers
    
    assert_true !ActionMailer::Base.deliveries.empty?

    email_1 = ActionMailer::Base.deliveries[0]
    assert_equal ["rs@email.com"], email_1.to
    
  end

  def assert_updating_mail_sent(expected_count, coach)
    assert_equal expected_count, coach.get_preference.mails_sent
  end
end