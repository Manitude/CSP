require File.expand_path('../../test_helper', __FILE__)
require 'sms'
require 'mocha/parameter_matchers'

class AccountTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  fixtures :accounts, :languages, :qualifications, :preference_settings, :trigger_events

  def test_validates_presence_of
    coach = accounts(:jramanathan)
    coach.preferred_name = "ram"
    assert_presence_required(coach, :user_name)
  end

  def test_should_raise_exception_when_phone_number_is_invalid
    ::Sms.expects(:ok_to_send_messages?).returns(true)
    HoptoadNotifier.expects(:notify).with(instance_of Exception) do |args|
      args.message == "SMS has not been sent to the user Jamie with the mobile number 343 because Invalid mobile or country code for Jamie"
    end
    account = create_user_and_assign({'mobile_phone' => '343'})
    account.send_sms('hello')
  end

  def test_should_raise_exception_and_logged_with_mobile_number_when_api_throws_exception
    ::Sms.expects(:ok_to_send_messages?).returns(true)
    ::Sms.stubs(:send_message).raises(Exception.new("Number Not Reachabe"))
    HoptoadNotifier.expects(:notify).with(instance_of Exception) do |args|
      args.message == 'SMS has not been sent to the user Jamie with the mobile number 1873838493 because Number Not Reachabe'
    end
    coach = create_user_and_assign({'mobile_phone' => '1873838493', 'mobile_country_code' => '91'})
    coach.send_sms('hello')
  end

  def test_should_send_sms
    account = create_user_and_assign({'mobile_phone' => '1873838493', 'mobile_country_code' => '91'})
    ::Sms.expects(:ok_to_send_messages?).returns(true)
    ::Sms.expects(:send_message).with(account, '', false)
    HoptoadNotifier.expects(:notify).never
    account.send_sms('')
  end

  def test_get_preference_with_preference
    account = Account.first
    account.type = 'Coach'
    PreferenceSetting.delete_all
    preference = PreferenceSetting.create({:account_id => account.id})
    assert_equal account.get_preference.id, preference.id
  end

  def test_get_preference_without_preference
    account = Account.first
    account.type = 'Coach'
    PreferenceSetting.delete_all
    assert_nil account.preference_setting
    assert_not_nil account.get_preference
    assert_not_nil account.get_preference.id
  end

  def test_should_not_send_sms
    ::Sms.expects(:ok_to_send_messages?).returns(false)
    logger.expects(:info).with('SMS delivery disabled by configuration.  See application configurations')
    account = create_user_and_assign()
    account.send_sms('hello')
  end

  def test_validity_of_blank_mobile_country_code
    account = create_user_and_assign({'mobile_country_code' => ''})
    assert_false account.send(:valid_mobile_country_code?) #number is blank    
  end

  def test_validity_of_only_zeroes_mobile_country_code
    account = create_user_and_assign({'mobile_country_code' => '000'})
    assert_false account.send(:valid_mobile_country_code?)
  end

  def test_validity_of_lengthy_mobile_country_code
    account = create_user_and_assign({'mobile_country_code'=> '901230'})
    assert_false account.send(:valid_mobile_country_code?)
  end

  def test_validity_of_non_numeral_mobile_country_code
    account = create_user_and_assign({'mobile_country_code'=> '9a1'})
    assert_false account.send(:valid_mobile_country_code?)
  end

  def test_validity_of_valid_mobile_country_code
    account = create_user_and_assign({'mobile_country_code'=> '91'})
    assert_true account.send(:valid_mobile_country_code?)
  end

  def test_validity_of_blank_mobile_phone
    account = create_user_and_assign({'mobile_phone' => ''})
    assert_false account.send(:valid_mobile_phone?)
  end

=begin
  def test_valid_user_name
    account = Account.new(:user_name => 'Jamie',:full_name => "Jamieone", :type => 'Coach' , :time_zone => 'Eastern Time (US & Canada)', :primary_phone => "1234567890", :rs_email => "jamie123@rs.com", :primary_country_code => "123")
    assert_true account.save
  end


  def test_user_name_with_white_spaces
    account = Account.new(:user_name => 'Jamie Guy',:full_name => "Jamieone", :type => 'Coach' , :time_zone => 'Eastern Time (US & Canada)', :primary_phone => "1234567890", :rs_email => "jamie123@rs.com", :primary_country_code => "123")
    assert_false account.save
  end

   def test_user_name_with_special_characters
    account = Account.new(:user_name => 'Jamie #@%uy',:full_name => "Jamieone", :type => 'Coach' , :time_zone => 'Eastern Time (US & Canada)', :primary_phone => "1234567890", :rs_email => "jamie123@rs.com", :primary_country_code => "123")
    assert_false account.save
  end

   def test_user_name_with_numbers
    account = Account.new(:user_name => 'Jamie1234',:full_name => "Jamieone", :type => 'Coach' , :time_zone => 'Eastern Time (US & Canada)', :primary_phone => "1234567890", :rs_email => "jamie123@rs.com", :primary_country_code => "123")
    assert_true account.save
  end
=end

  def test_send_time_off_notifications_mail_no_preference
    account = create_user_and_assign({'rs_email' => 'abc@rs.com', 'personal_email' => 'abc@gmail.com'})
    account.type = 'Coach'
    GeneralMailer.expects(:deliver_notifications_email).never
  end

  def test_send_calendar_notifications_mail_no_preference
    account = create_user_and_assign({'rs_email' => 'abc@rs.com', 'personal_email' => 'abc@gmail.com'})
    account.type = 'Coach'
    GeneralMailer.expects(:deliver_calendar_notifications_email).never
    event = FactoryGirl.create(:event)
    GeneralMailer.calendar_notifications_email(event, account.personal_email).deliver
  end

  def test_send_calendar_notifications_mail_with_rs_preferred_mail
    account = create_user_and_assign({'rs_email' => 'abc@rs.com', 'personal_email' => 'abc@gmail.com'})
    account.type = 'Coach'
    account.get_preference.calendar_notices_email = 1
    account.get_preference.calendar_notices_email_sending_schedule = 'IMMEDIATELY'
    account.get_preference.calendar_notices_email_type = 'RS'
    event = FactoryGirl.create(:event)
    mail = GeneralMailer.calendar_notifications_email(event, account.rs_email).deliver
    assert_equal ["abc@rs.com"], mail.to
  end

  def test_send_calendar_notifications_mail_with_personal_preferred_mail
    account = create_user_and_assign({'rs_email' => 'abc@rs.com', 'personal_email' => 'abc@gmail.com'})
    account.type = 'Coach'
    account.get_preference.calendar_notices_email = 1
    account.get_preference.calendar_notices_email_sending_schedule = 'IMMEDIATELY'
    account.get_preference.calendar_notices_email_type = 'PER'
    event = FactoryGirl.create(:event)
    mail = GeneralMailer.calendar_notifications_email(event, account.personal_email).deliver
    assert_equal ["abc@gmail.com"], mail.to
  end
  
  def test_validity_of_only_zeroes_mobile_phone
    account = create_user_and_assign({'mobile_phone' => '0000000000'})
    assert_false account.send(:valid_mobile_phone?)
  end

  def test_validity_of_small_mobile_phone
    account = create_user_and_assign({'mobile_phone' => '654'})
    assert_false account.send(:valid_mobile_phone?)
  end

  def test_validity_of_non_numeral_mobile_phone
    account = create_user_and_assign({'mobile_phone' => '654)a'})
    assert_false account.send(:valid_mobile_phone?)
  end

  def test_validity_of_valid_mobile_phone
    account = create_user_and_assign({'mobile_phone' => '6048733219'})
    assert_true account.send(:valid_mobile_phone?)
  end

def test_hoptoad_not_notified_for_clickatell_api_errors
    coach = create_user_and_assign({'mobile_phone' => '1873838493', 'mobile_country_code' => '91'})
    ::Sms.expects(:ok_to_send_messages?).returns(true)
    ::Sms.expects(:send_message).raises(Clickatell::API::Error.parse("ERR: 001, Cannot route the message"))
    HoptoadNotifier.expects(:notify).with(instance_of Exception).never
    logger.expects(:debug).with("API error caught and supressed")
    coach.send_sms('hello')
  end
  
  def test_displaying_events_of_all_languages
    coach = Coach.find_by_user_name("dutchfellow")
    event_options = {
      "event_description" =>  "Dutch coaches are requested to attend the meeting in Central park. ",
      "event_name" => "Dutch coaches meeting",
      "event_start_date" => "2910-09-14",
      "event_end_date" => "2910-09-14 04:00:00",
      "language_id" => "-1",
      "region_id" => "-1",
      "created_at" => "2010-08-27 15:19:40",
      "updated_at" => "2010-08-27 15:19:40"
    }
    Event.create(event_options)
    assert_equal("Dutch coaches meeting", coach.find_by_region_and_language("event")[0].event_name)
  end

  def test_system_notifications_in_last_hour
    account = accounts(:dranjit)
    sys_not = account.system_notifications.create(:raw_message => 'test msg', :id => '33', :notification_id => '1' , :recipient_id => account.id ,:recipient_type=> 'Account',:target_id => '1',:created_at => (Time.now - 30.minute))
    account.system_notifications.create(:raw_message => 'test msg', :id => '34', :notification_id => '1' , :recipient_id => account.id ,:recipient_type=> 'Account',:target_id => '1',:created_at => (Time.now - 2.day))
    notifications = account.system_notifications_in_last_hour
    assert_equal notifications.size , 1
    assert_equal notifications.first.id , sys_not.id
  end

  def test_system_notifications_in_last_day
    account = accounts(:dranjit)
    account.system_notifications.delete_all
    account.system_notifications.create(:raw_message => 'test msg', :id => '35', :notification_id => '1' , :recipient_id => account.id ,:recipient_type=> 'Account',:target_id => '1',:created_at => (Time.now - 30.day))
    sys_not1 = account.system_notifications.create(:raw_message => 'test msg', :id => '36', :notification_id => '1' , :recipient_id => account.id ,:recipient_type=> 'Account',:target_id => '1',:created_at => (Time.now - 2.hours))
    account.system_notifications.create(:raw_message => 'test msg', :id => '37', :notification_id => '1' , :recipient_id => account.id ,:recipient_type=> 'Account',:target_id => '1',:created_at => (Time.now - 5.day))
    sys_not2 = account.system_notifications.create(:raw_message => 'test msg', :id => '38', :notification_id => '1' , :recipient_id => account.id ,:recipient_type=> 'Account',:target_id => '1',:created_at => (Time.now - 8.hour))
    notifications = account.system_notifications_in_last_day
    assert_equal notifications.size , 2
    id_array =[]
    id_array << sys_not1.id
    id_array << sys_not2.id
    assert_equal notifications.collect(&:id) , id_array
  end

  def test_displaying_events_of_a_specific_language
    coach = Coach.find_by_user_name("dutchfellow")
    event_options = {
      "event_description" =>  "Dutch coaches are requested to attend the meeting in Central park. ",
      "event_name" => "Dutch coaches meeting",
      "event_start_date" => "2910-09-14",
      "event_end_date" => "2910-09-14 04:00:00",
      "language_id" => coach.languages.first.id,
      "region_id" => "-1",
      "created_at" => "2010-08-27 15:19:40",
      "updated_at" => "2010-08-27 15:19:40"
    }
    Event.create(event_options)
    assert_equal("Dutch coaches meeting", coach.find_by_region_and_language("event")[0].event_name)
  end

  def test_displaying_announcement_of_all_languages
    coach = Coach.find_by_user_name("dutchfellow")
    announcement_options = {
      "subject" =>  "An Announcement for Dutch Coaches",
      "body" =>  "All the dutch classes on every Monday are cancelled. ",
      "language_id" => coach.languages.first.id,
      "region_id" => "-1",
      "expires_on" => "2910-08-27 15:19:40",
    }
    Announcement.create(announcement_options)
    assert_equal("An Announcement for Dutch Coaches", coach.find_by_region_and_language("announcement")[0].subject)
  end

  def test_displaying_events_of_announcement_specific_language
    coach = Coach.find_by_user_name("dutchfellow")
    announcement_options = {
      "subject" =>  "An Announcement for Dutch Coaches",
      "body" =>  "All the dutch classes on every Monday are cancelled. ",
      "language_id" => "-1",
      "region_id" => "-1",
      "expires_on" => "2910-08-27 15:19:40",
    }
    Announcement.create(announcement_options)
    assert_equal("An Announcement for Dutch Coaches", coach.find_by_region_and_language("announcement")[0].subject)
  end

  def test_account_with_time_zone_returns_correct_time_zone
    account = accounts(:DutchCoach)
    assert_not_nil(account.time_zone)
    assert_not_nil(account.tzone)
    assert_equal(account.tzone,'Eastern Time (US & Canada)')
  end

  def test_account_without_time_zone_returns_est
    account = accounts(:support_lead_for_preference_settings)
    assert_equal("Eastern Time (US & Canada)", account.time_zone)
    assert_not_nil(account.tzone)
    assert_equal(account.tzone,'Eastern Time (US & Canada)')
  end

  def test_system_notifications_reassigned_or_grabbed
    coach = Coach.first
    assert_equal 0, coach.system_notifications_reassigned_or_grabbed(5).length
    coach.system_notifications.create({:raw_message => 'test msg', :notification_id => 9})
    assert_equal 1, coach.system_notifications_reassigned_or_grabbed(5).length
    coach.system_notifications.create({:raw_message => 'test msg', :notification_id => 9})
    assert_equal 2, coach.system_notifications_reassigned_or_grabbed(5).length
  end

  def test_time_off_denied_notification_for_coach
    coach = Coach.first
    assert_equal 0, coach.system_notifications_not_reassigned_or_grabbed.length
    coach.system_notifications.create({:raw_message => "Your requested time off from <b>March 03, 2011 00:00</b> to <b>March 03, 2011 23:00</b> has been denied."})
    assert_equal 1, coach.system_notifications_not_reassigned_or_grabbed.length
  end

  def test_system_notifications_not_reassigned_or_grabbed
    coach = Coach.first
    assert_equal coach.system_notifications_not_reassigned_or_grabbed.length, 0
    coach.system_notifications.create({:raw_message => 'test msg', :notification_id => 1})
    assert_equal coach.system_notifications_not_reassigned_or_grabbed.length, 1
    coach.system_notifications.create({:raw_message => 'test msg', :notification_id => 1})
    assert_equal coach.system_notifications_not_reassigned_or_grabbed.length, 2
  end

  def test_subscribed_to_coach_not_present_alert_named_scope
    accounts = Account.subscribed_to_coach_not_present_alert
    assert_equal 1, accounts.size, "Only one account should be subscribed to the coach_not_present_alert (with account id 12)"
  end

  def test_get_preferred_mail_id_for_substitution_alerts_with_personal_email
    account = create_user_and_assign({'rs_email' => 'abc@rs.com', 'personal_email' => 'abc@gmail.com'})
    account.type = 'Coach'
    account.get_preference.substitution_alerts_email = 1
    account.get_preference.substitution_alerts_email_type = 'PER'
    account.get_preference.substitution_alerts_email_sending_schedule = 'IMMEDIATELY'
    assert_equal 'abc@gmail.com', account.get_preferred_mail_id_by_type('substitution_alerts_email')
  end

  def test_get_preferred_mail_id_for_substitution_alerts_with_rs_email
    account = create_user_and_assign({'rs_email' => 'abc@rs.com', 'personal_email' => 'abc@gmail.com'})
    account.type = 'Coach'
    account.get_preference.substitution_alerts_email = 1
    account.get_preference.substitution_alerts_email_type = 'RS'
    account.get_preference.substitution_alerts_email_sending_schedule = 'IMMEDIATELY'
    assert_equal 'abc@rs.com', account.get_preferred_mail_id_by_type('substitution_alerts_email')
  end

  def test_get_preferred_mail_id_for_substitution_alerts_with_disabled_preference
    account = create_user_and_assign({'rs_email' => 'abc@rs.com', 'personal_email' => 'abc@gmail.com'})
    account.type = 'Coach'
    account.get_preference.substitution_alerts_email = 0
    account.get_preference.substitution_alerts_email_type = 'PER'
    account.get_preference.substitution_alerts_email_sending_schedule = 'IMMEDIATELY'
    assert_nil account.get_preferred_mail_id_by_type('substitution_alerts_email')
  end

  def test_get_preferred_mail_id_for_substitution_alerts_with_enabled_preference_but_not_immediately
    account = create_user_and_assign({'rs_email' => 'abc@rs.com', 'personal_email' => 'abc@gmail.com'})
    account.type = 'Coach'
    account.get_preference.substitution_alerts_email = 1
    account.get_preference.substitution_alerts_email_type = 'PER'
    account.get_preference.substitution_alerts_email_sending_schedule = 'HOURLY'
    assert_nil account.get_preferred_mail_id_by_type('substitution_alerts_email')
  end

  def test_get_preferred_mail_id_for_calendar_notices_with_personal_email
    account = create_user_and_assign({'rs_email' => 'abc@rs.com', 'personal_email' => 'abc@gmail.com'})
    account.type = 'Coach'
    account.get_preference.calendar_notices_email = 1
    account.get_preference.calendar_notices_email_type = 'PER'
    account.get_preference.calendar_notices_email_sending_schedule = 'IMMEDIATELY'
    assert_equal 'abc@gmail.com', account.get_preferred_mail_id_by_type('calendar_notices_email')
  end

  def test_get_preferred_mail_id_for_calendar_notices_with_rs_email
    account = create_user_and_assign({'rs_email' => 'abc@rs.com', 'personal_email' => 'abc@gmail.com'})
    account.type = 'Coach'
    account.get_preference.calendar_notices_email = 1
    account.get_preference.calendar_notices_email_type = 'RS'
    account.get_preference.calendar_notices_email_sending_schedule = 'IMMEDIATELY'
    assert_equal 'abc@rs.com', account.get_preferred_mail_id_by_type('calendar_notices_email')
  end

  def test_get_preferred_mail_id_for_calendar_notices_with_disabled_preference
    account = create_user_and_assign({'rs_email' => 'abc@rs.com', 'personal_email' => 'abc@gmail.com'})
    account.type = 'Coach'
    account.get_preference.calendar_notices_email = 0
    account.get_preference.calendar_notices_email_type = 'PER'
    account.get_preference.calendar_notices_email_sending_schedule = 'IMMEDIATELY'
    assert_nil account.get_preferred_mail_id_by_type('calendar_notices_email')
  end

  def test_get_preferred_mail_id_for_calendar_notices_with_enabled_preference_but_not_immediately
    account = create_user_and_assign({'rs_email' => 'abc@rs.com', 'personal_email' => 'abc@gmail.com'})
    account.type = 'Coach'
    account.get_preference.calendar_notices_email = 1
    account.get_preference.calendar_notices_email_type = 'PER'
    account.get_preference.calendar_notices_email_sending_schedule = 'HOURLY'
    assert_nil account.get_preferred_mail_id_by_type('calendar_notices_email')
  end

  def test_get_preferred_mail_id_for_notifications_with_personal_email
    account = create_user_and_assign({'rs_email' => 'abc@rs.com', 'personal_email' => 'abc@gmail.com'})
    account.type = 'Coach'
    account.get_preference.notifications_email = 1
    account.get_preference.notifications_email_type = 'PER'
    account.get_preference.notifications_email_sending_schedule = 'IMMEDIATELY'
    assert_equal 'abc@gmail.com', account.get_preferred_mail_id_by_type('notifications_email')
  end

  def test_get_preferred_mail_id_for_notifications_with_rs_email
    account = create_user_and_assign({'rs_email' => 'abc@rs.com', 'personal_email' => 'abc@gmail.com'})
    account.type = 'Coach'
    account.get_preference.notifications_email = 1
    account.get_preference.notifications_email_type = 'RS'
    account.get_preference.notifications_email_sending_schedule = 'IMMEDIATELY'
    assert_equal 'abc@rs.com', account.get_preferred_mail_id_by_type('notifications_email')
  end

  def test_get_preferred_mail_id_for_notifications_with_disabled_preference
    account = create_user_and_assign({'rs_email' => 'abc@rs.com', 'personal_email' => 'abc@gmail.com'})
    account.type = 'Coach'
    account.get_preference.notifications_email = 0
    account.get_preference.notifications_email_type = 'PER'
    account.get_preference.notifications_email_sending_schedule = 'IMMEDIATELY'
    assert_nil account.get_preferred_mail_id_by_type('notifications_email')
  end

  def test_get_preferred_mail_id_for_notifications_with_enabled_preference_but_not_immediately
    account = create_user_and_assign({'rs_email' => 'abc@rs.com', 'personal_email' => 'abc@gmail.com'})
    account.type = 'Coach'
    account.get_preference.notifications_email = 1
    account.get_preference.notifications_email_type = 'PER'
    account.get_preference.notifications_email_sending_schedule = 'HOURLY'
    assert_nil account.get_preferred_mail_id_by_type('notifications_email')
  end

  def test_email_recipients
    recipients = Account.email_recipients('calendar_notices_email')
    assert_equal 0, recipients.length

    coachA = create_coach_with_qualifications('recipientA', ['ARA'])
    coachB = create_coach_with_qualifications('recipientB', ['TUR'])
    coachC = create_coach_with_qualifications('recipientC', ['TUR'])
    [coachA, coachB, coachC].each do |coach|
      FactoryGirl.create(:preference_setting, :account_id =>  coach.id, :calendar_notices_email_type => 1, :calendar_notices_email_sending_schedule => 'IMMEDIATELY', :daily_cap => 499 )
    end
    recipients = Account.email_recipients('calendar_notices_email')
    assert_equal 3, recipients.length

    recipients = Account.email_recipients('calendar_notices_email', Language.find_by_identifier('TUR').id)
    assert_equal 2, recipients.length

    recipients = Account.email_recipients('calendar_notices_email', "ARA")
    assert_equal 1, recipients.length
  end
  
  private

  def assert_account_updation(options)
    Account.delete_all
    account = FactoryGirl.create(:account)
    assert_true(account.update_attribute(:is_supervisor, options[:is_supervisor]))
    assert_equal(options[:expected], account.is_supervisor)
  end

  def create_user_and_assign(options = {})
    default_options = {:user_name => 'Jamie'}
    options.each do |key, value|
      default_options.merge!({key.to_sym => value}) if Account.new.respond_to?(key) and value
    end
    Account.new(default_options)
  end

end
