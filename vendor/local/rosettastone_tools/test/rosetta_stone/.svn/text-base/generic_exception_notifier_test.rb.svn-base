# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))
require 'rosetta_stone/generic_exception_notifier'

class RosettaStone::GenericExceptionNotifierTest < Test::Unit::TestCase

  # ExceptionNotifier is a prerequisite for RosettaStone::GenericExceptionNotifier. Don't reference RosettaStone::GenericExceptionNotifier with ExceptionNotifier in an app.
  # Also, don't test RosettaStone::GenericExceptionNotifier if ExceptionNotifier isn't in the app. it won't work. :)
  if defined?(ExceptionNotifier) && RosettaStone::GenericExceptionNotifier.superclass == ExceptionNotifier

    def setup
      sending_test_emails!
      @orig_subject_truncate_length_value = RosettaStone::GenericExceptionNotifier.subject_truncate_length
    end

    def teardown
      RosettaStone::GenericExceptionNotifier.subject_truncate_length = @orig_subject_truncate_length_value
    end

    def test_exception_email_is_delivered
      assert_no_emails
      RosettaStone::GenericExceptionNotifier.deliver_exception_notification(RosettaStone::GenericExceptionNotifier.test_exception)
      assert_one_email
    end

    def test_generate_exception_notification_calls_deliver
      assert_no_emails
      RosettaStone::GenericExceptionNotifier.generate_exception_notification('custom error text')
      assert_one_email
      assert_match('custom error text', @emails.first.body)
    end

    def test_subject_truncation_when_disabled
      RosettaStone::GenericExceptionNotifier.subject_truncate_length = nil
      RosettaStone::GenericExceptionNotifier.generate_exception_notification('m' * 500)
      assert_one_email
      assert_match('m' * 500, @emails.first.subject)
      assert_no_match(%r{\.\.\.}, @emails.first.subject)
    end

    def test_subject_truncation_when_configured
      RosettaStone::GenericExceptionNotifier.subject_truncate_length = 100
      RosettaStone::GenericExceptionNotifier.generate_exception_notification('m' * 500)
      assert_one_email
      assert_match(%r{\.\.\.}, @emails.first.subject)
      assert_equal(103, @emails.first.subject.length) # ellipses added to the end
    end

  elsif defined?(HoptoadNotifier)

    def test_exception_notification_is_sent_to_hoptoad
      exception = mock('exception')
      HoptoadNotifier.expects(:notify).with(exception, {})
      RosettaStone::GenericExceptionNotifier.deliver_exception_notification(exception)
    end

    def test_exception_notification_is_sent_to_hoptoad_with_options
      exception = mock('exception')
      HoptoadNotifier.expects(:notify).with(exception, {:an_option => true})
      RosettaStone::GenericExceptionNotifier.deliver_exception_notification(exception, {:an_option => true})
    end

    def test_generate_exception_notification_with_hoptoad
      HoptoadNotifier.expects(:notify)
      RosettaStone::GenericExceptionNotifier.generate_exception_notification('monkey')
    end

  elsif defined?(Airbrake)

    def test_exception_notification_is_sent_to_airbrake
      exception = mock('exception')
      Airbrake.expects(:notify).with(exception, {})
      RosettaStone::GenericExceptionNotifier.deliver_exception_notification(exception)
    end

    def test_exception_notification_is_sent_to_airbrake_with_options
      exception = mock('exception')
      Airbrake.expects(:notify).with(exception, {:an_option => true})
      RosettaStone::GenericExceptionNotifier.deliver_exception_notification(exception, {:an_option => true})
    end

    def test_generate_exception_notification_with_airbrake
      Airbrake.expects(:notify)
      RosettaStone::GenericExceptionNotifier.generate_exception_notification('monkey')
    end

  else

    def test_deliver_exception_notification_when_no_notifiers_are_present
      logger.expects(:error).once
      RosettaStone::GenericExceptionNotifier.deliver_exception_notification(RuntimeError.new)
    end

    def test_generate_exception_notification_when_no_notifiers_are_present
      logger.expects(:error).once
      RosettaStone::GenericExceptionNotifier.generate_exception_notification('message')
    end

  end

end
