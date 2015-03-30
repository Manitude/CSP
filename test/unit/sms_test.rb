require 'test_helper'

class SmsTest < ActiveSupport::TestCase

  def setup
    Sms.instance.clickatell_disconnect!
    sms_vendor_enabled('celltrust', true)
    sms_vendor_enabled('clickatell', true)
    @user = create_coach_with_qualifications("smsdeliverycoach",[])
  end

  def test_tries_clickatell_first_for_international_numbers
    calls_send_message('clickatell', true)
    calls_send_message('celltrust', false)
    setup_user_with_international_number
    assert Sms.send_message(@user, 'asdf')
  end

  def test_tries_celltrust_first_for_domestic_numbers
    calls_send_message('clickatell', false)
    calls_send_message('celltrust', true)
    setup_user_with_domestic_number
    assert Sms.send_message(@user, 'asdf')
  end

  def test_tries_celltrust_for_international_number_only_if_clickatell_is_disabled
    setup_user_with_international_number
    calls_send_message('clickatell', false)
    calls_send_message('celltrust', true)
    sms_vendor_enabled('clickatell', false)
    assert Sms.send_message(@user, 'asdf')
  end

  def test_tries_clickatell_for_domestic_number_only_if_celltrust_is_disabled
    setup_user_with_domestic_number
    calls_send_message('clickatell', true)
    calls_send_message('celltrust', false)
    sms_vendor_enabled('celltrust', false)
    assert Sms.send_message(@user, 'asdf')
  end

  def test_doesnt_send_any_messages_if_both_are_disabled
    setup_user_with_domestic_number
    calls_send_message('clickatell', false)
    calls_send_message('celltrust', false)
    sms_vendor_enabled('celltrust', false)
    sms_vendor_enabled('clickatell', false)
    assert_false Sms.send_message(@user, 'asdf')
  end

  def test_tries_celltrust_as_backup_if_clickatell_fails
    setup_user_with_international_number
    Sms.any_instance.expects(:send_clickatell_message).returns(false)
    Sms.any_instance.expects(:send_celltrust_message).returns(true)
    assert Sms.send_message(@user, 'asdf')
  end

  def test_tries_clickatell_as_backup_if_celltrust_fails
    setup_user_with_domestic_number
    Sms.any_instance.expects(:send_clickatell_message).returns(true)
    Sms.any_instance.expects(:send_celltrust_message).returns(false)
    assert Sms.send_message(@user, 'asdf')
  end

  def test_sanitize_removes_leading_zeros
    assert_equal('15402713221', Sms.sanitize_number('15402713221'))
    assert_equal('15402713221', Sms.sanitize_number('015402713221'))
    assert_equal('15402713221', Sms.sanitize_number('0015402713221'))
    assert_equal('15402713221', Sms.sanitize_number('000015402713221'))
  end

  def test_sanitize_removes_non_numeric_characters
    assert_equal('15402713221', Sms.sanitize_number('+0(015)402-71.3221'))
    assert_equal('444027132210', Sms.sanitize_number('+044 40.271.32210 '))
  end

  def test_celltrust_bad_xml_generates_exception_and_falls_back_to_clickatell
    Sms.any_instance.expects(:clickatell_make_api_request).returns('1234')
    SmsDeliveryAttempt.destroy_all
    setup_user_with_domestic_number
    Net::HTTP.any_instance.expects(:post).returns(['response', 'nonxml'])
    RosettaStone::GenericExceptionNotifier.expects(:deliver_exception_notification)
    assert_nothing_raised do
      Sms.send_message(@user, 'asdf')
    end
    assert_equal 2, SmsDeliveryAttempt.all.size
    assert_match /File does not exist: nonxml/, SmsDeliveryAttempt.first.celltrust_error_message
    assert_equal "0", SmsDeliveryAttempt.first.api_response_successful
    assert_equal '1234', SmsDeliveryAttempt.last.clickatell_msgid
  end

  def test_celltrust_unexpected_xml
    Sms.any_instance.expects(:clickatell_make_api_request).returns('1234')
    SmsDeliveryAttempt.destroy_all
    setup_user_with_domestic_number
    Net::HTTP.any_instance.expects(:post).returns(['response', '<unexpected_xml/>'])
    RosettaStone::GenericExceptionNotifier.expects(:deliver_exception_notification)
    assert_nothing_raised do
      Sms.send_message(@user, 'asdf')
    end
    assert_equal 2, SmsDeliveryAttempt.all.size
    assert_match /unknown xml body/, SmsDeliveryAttempt.first.celltrust_error_message
    assert_equal "0", SmsDeliveryAttempt.first.api_response_successful
    assert_equal '1234', SmsDeliveryAttempt.last.clickatell_msgid
  end

  def test_celltrust_error_xml
    Sms.any_instance.expects(:clickatell_make_api_request).returns('1234')
    SmsDeliveryAttempt.destroy_all
    setup_user_with_domestic_number
    Net::HTTP.any_instance.expects(:post).returns(['response', "<?xml version=\"1.0\" ?><TxTNotifyResponse><Error><ErrorCode>206</ErrorCode><ErrorString>Password is not valid</ErrorString></Error></TxTNotifyResponse>\r\n"])
    assert_nothing_raised do
      Sms.send_message(@user, 'asdf')
    end
    assert_equal 2, SmsDeliveryAttempt.all.size
    assert_equal "Password is not valid", SmsDeliveryAttempt.first.celltrust_error_message
    assert_equal "206", SmsDeliveryAttempt.first.celltrust_error_code
    assert_equal "0", SmsDeliveryAttempt.first.api_response_successful
    assert_equal '1234', SmsDeliveryAttempt.last.clickatell_msgid
  end

  def test_celltrust_success_xml
    Sms.any_instance.expects(:clickatell_make_api_request).never
    SmsDeliveryAttempt.destroy_all
    setup_user_with_domestic_number
    Net::HTTP.any_instance.expects(:post).returns(['response', "<?xml version=\"1.0\" ?><TxTNotifyResponse><MsgResponseList><MsgResponse type=\"SMS\"><Status>ACCEPTED</Status><MessageId>1234</MessageId></MsgResponse></MsgResponseList></TxTNotifyResponse>\r\n"])
    assert_nothing_raised do
      Sms.send_message(@user, 'asdf')
    end
    assert_equal 1, SmsDeliveryAttempt.all.size
    assert_equal nil, SmsDeliveryAttempt.first.celltrust_error_message
    assert_equal nil, SmsDeliveryAttempt.first.celltrust_error_code
    assert_equal '1234', SmsDeliveryAttempt.first.celltrust_msgid
    assert SmsDeliveryAttempt.first.api_response_successful
  end

  def test_clickatell_errors_are_reported_but_send_message_does_not_raise_on_api_error
    coach = FactoryGirl.create(:coach, :mobile_phone => '5555550001', :mobile_country_code => '1')
    App.stubs(:enable_celltrust).returns(false)
    logger.expects(:error)
    api = mock
    Clickatell::API.expects(:authenticate).returns(api)
    RosettaStone::GenericExceptionNotifier.expects(:deliver_exception_notification)
    api.expects(:send_message).raises(Clickatell::API::Error.new('002', 'bay'))
    assert_nothing_raised do
      assert_false(Sms.send_message(coach, 'bar'))
    end
  end

  def test_respond_to_includes_instance_methods
    assert_false(Sms.respond_to?(:bugaboo))
    assert_true(Sms.api_methods.any?)
    Sms.api_methods.each do |api_method|
      assert_true(Sms.respond_to?(api_method))
    end
  end

  def test_clickatell_simulating_timed_out_session_reconnects
    App.stubs(:enable_celltrust).returns(false)
    clickatell_connection = Clickatell::API.new
    RosettaStone::GenericExceptionNotifier.expects(:deliver_exception_notification).never
    clickatell_connection.expects(:account_balance).twice.raises(Clickatell::API::Error.new('001', 'blah')).then.returns(5678)
    Clickatell::API.expects(:authenticate).twice.returns(clickatell_connection)
    assert_equal(5678, Sms.clickatell_account_balance)
  end

  def test_clickatell_simulating_authentication_error
    App.stubs(:enable_celltrust).returns(false)
    clickatell_connection = Clickatell::API.new
    RosettaStone::GenericExceptionNotifier.expects(:deliver_exception_notification)
    clickatell_connection.expects(:account_balance).twice.raises(Clickatell::API::Error.new('001', 'blah'))
    Clickatell::API.expects(:authenticate).twice.returns(clickatell_connection)
    assert_raises(Clickatell::API::Error) do
      Sms.clickatell_account_balance
    end
  end

  def test_clickatell_simulating_another_type_of_error
    App.stubs(:enable_celltrust).returns(false)
    RosettaStone::GenericExceptionNotifier.expects(:deliver_exception_notification)
    clickatell_connection = Clickatell::API.new
    clickatell_connection.expects(:account_balance).once.raises(Clickatell::API::Error.new('002', 'blah'))
    Clickatell::API.expects(:authenticate).once.returns(clickatell_connection)
    assert_raises(Clickatell::API::Error) do
      Sms.clickatell_account_balance
    end
  end

  def test_clickatell_ping
    response = mock do |r|
      r.expects(:is_a?).returns(true).at_least_once # easiest way to mock that it's a Net::HTTPOK
    end
    api = mock
    Clickatell::API.expects(:authenticate).returns(api)
    api.expects(:ping_with_current_session_id).returns(response)
    assert_nothing_raised do
      assert(value = Sms.clickatell_ping)
      assert(value.is_a?(Integer))
    end
  end

  def test_clickatell_ping_with_api_failure
    RosettaStone::GenericExceptionNotifier.expects(:deliver_exception_notification)
    api = mock
    Clickatell::API.expects(:authenticate).returns(api)
    api.expects(:ping_with_current_session_id).raises(Clickatell::API::Error.new('002', 'foo'))
    assert_raises(Sms::PingError) do
      Sms.clickatell_ping
    end
  end

  def test_clickatell_ping_with_http_failure
    api = mock
    Clickatell::API.expects(:authenticate).returns(api)
    api.expects(:ping_with_current_session_id).returns(OpenStruct.new) # something other than Net::HTTPOK
    assert_raises(Sms::PingError) do
      Sms.clickatell_ping
    end
  end

  def test_clickatell_has_route_coverage_true_response
    response_body = "OK: This prefix is currently supported. Messages sent to this prefix will be routed. Charge: 1\n"
    response = mock do |r|
      r.expects(:body).returns(response_body)
      r.expects(:is_a?).returns(true).at_least_once # easiest way to mock that it's a Net::HTTPOK
    end
    api = mock
    Clickatell::API.expects(:authenticate).returns(api)
    api.expects(:route_coverage).returns(response)
    assert_nothing_raised do
      assert_true(Sms.clickatell_has_route_coverage?('12345'))
    end
  end

  def test_clickatell_has_route_coverage_false_response
    response_body = "ERR: This prefix is not currently supported. Messages sent to this prefix will fail. Please contact support for assistance.\n"
    response = mock do |r|
      r.expects(:body).returns(response_body)
      r.expects(:is_a?).returns(true).at_least_once # easiest way to mock that it's a Net::HTTPOK
    end
    api = mock
    Clickatell::API.expects(:authenticate).returns(api)
    api.expects(:route_coverage).returns(response)
    assert_nothing_raised do
      assert_false(Sms.clickatell_has_route_coverage?('12345'))
    end
  end

  def test_clickatell_has_route_coverage_http_error_response
    response = mock do |r|
      r.expects(:body).returns('')
      r.expects(:is_a?).returns(false).at_least_once # easiest way to mock that it's a Net::HTTPOK
    end
    api = mock
    Clickatell::API.expects(:authenticate).returns(api)
    api.expects(:route_coverage).returns(response)
    assert_raises(Sms::UncategorizedException) do
      Sms.clickatell_has_route_coverage?('12345')
    end
  end

private

  def setup_user_with_international_number
    @user.update_attribute(:mobile_country_code, '2')
    assert @user.has_international_mobile_number?
  end

  def setup_user_with_domestic_number
    @user.update_attribute(:mobile_country_code, '1')
    assert !@user.has_international_mobile_number?
  end
  
end

