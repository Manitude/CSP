# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::RakeTaskExtTest < Test::Unit::TestCase
  def setup
    @log_file_match =
      if defined?(Airbrake)
        nil # FIXME: exception notification doesn't seem to log itself on Rails 3/Airbrake
      elsif defined?(ExceptionNotifier)
        'Sent mail to '
      elsif defined?(Hoptoad)
        "Hoptoad notification suppressed for this configuration"
      else
        'RuntimeError: Exception that should be thrown to hoptoad'
      end
  end

  def test_adding_exception_notify_to_rake_task_works
    with_clean_log_file do
      assert_match "Exception that should be thrown to hoptoad!", get_rake_output('test:exception_notification_enabled')
    end
    assert_true log_file_entries.split($/).any?{|entry| entry.match(@log_file_match)} if @log_file_match
  end

  def test_not_having_exception_notify_means_exception_does_not_get_notified
    with_clean_log_file do
      assert_match "Exception that should just be thrown to the screen (not to hoptoad)", get_rake_output('test:exception_notification_disabled')
    end
    assert_true log_file_entries.split($/).none?{|entry| entry.match(@log_file_match)} if @log_file_match
  end

  private

  def get_rake_output(task)
    `cd "#{Rails.root}" && ./rake --silent #{task} RAILS_ENV=test 2>&1| fgrep -v "Using rake"`.strip
  end
end
