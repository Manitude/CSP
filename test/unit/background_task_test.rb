
$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test_helper'

class BackgroundTaskTest < ActiveSupport::TestCase
  def test_append_message
    bt = BackgroundTask.create(:message => nil )
    assert_nil bt.message
    bt.append_message 'Hello. '
    assert_equal 'Hello. ', bt.message
    bt.append_message 'World'
    assert_equal 'Hello. World', bt.message
  end
end

