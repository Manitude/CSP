require File.expand_path('../../test_helper', __FILE__)

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test_helper'

class AnnouncementTest < ActiveSupport::TestCase
  
  def test_search
    FactoryGirl.create(:announcement)
    assert_equal 0, Announcement.search('search').size
    assert_equal 1, Announcement.search('test').size
  end

  def test_expires_on_cannot_be_past
    an = FactoryGirl.create(:announcement)
    #check using valid_data record for Expires_on
    assert_true an.errors.blank?
    #check using invalid_data record for Expires_on
    an.update_attributes(:expires_on => Time.now.utc - 2.days)
    assert_false an.errors.blank?
  end
end
