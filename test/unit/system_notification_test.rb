require File.dirname(__FILE__) + '/../test_helper'

class SystemNotificationTest < ActiveSupport::TestCase
  
  def test_message
    coach = FactoryGirl.create(:coach)
    template = FactoryGirl.create(:coach_availability_template, :coach_id => coach.id, :effective_start_date => (Time.now + 5.day).to_date, :label => "test")
    notif = FactoryGirl.create(:notification, :trigger_event_id => 1, :message => 'A new template for has been submitted for review.', :target_type => 'CoachAvailabilityTemplate')
    FactoryGirl.create(:notification_recipient, :notification_id => notif.id, :name => 'Coach Manager', :rel_recipient_obj => 'all_managers')
    FactoryGirl.create(:notification_message_dynamic, :notification_id => notif.id, :name => 'Coach Name', :msg_index => 19, :rel_obj_attr => 'name', :rel_obj_type => 'coach')
    FactoryGirl.create(:notification_message_dynamic, :notification_id => notif.id, :name => 'Template Name', :msg_index => 15, :rel_obj_attr => 'label')

    #not for email
    sn = FactoryGirl.create(:system_notification, :notification_id => notif.id, :recipient_id => coach.id, :recipient_type => 'Account', :target_id => template.id)
    assert_equal("A new template <a href = '/availability/#{coach.id}/#{template.id}'>#{template.label}</a> for <a href = '/view-coach-profiles?coach_id=#{coach.id}'>#{coach.name}</a> has been submitted for review.", sn.message)

    #for email
    sn = SystemNotification.find_by_id(sn.id)
    assert_equal("A new template <a href = 'http://coachportal.rosettastone.com/availability/#{coach.id}/#{template.id}'>#{template.label}</a> for <a href = 'http://coachportal.rosettastone.com/view-coach-profiles?coach_id=#{coach.id}'>#{coach.name}</a> has been submitted for review.", sn.message(true))

    #when raw message is present
    sn = FactoryGirl.create(:system_notification, :notification_id => notif.id, :recipient_id => coach.id, :recipient_type => 'Account', :target_id => template.id, :raw_message => "Coach Avalibility Modification")
    assert_equal("Coach Avalibility Modification", sn.message)

    #test require_cta_links? for non time off
    assert_false sn.require_cta_links?
  end

  def test_require_cta_links_for_time_off
    coach = create_coach_with_qualifications
    manager = FactoryGirl.create(:account)
    timeoff = FactoryGirl.create(:unavailable_despite_template, :coach_id => coach.id)
    notif = FactoryGirl.create(:notification, :trigger_event_id => 5, :message => 'has violated policy by requesting time off from to .', :target_type => 'UnavailableDespiteTemplate')
    FactoryGirl.create(:notification_recipient, :notification_id => notif.id, :name => 'Coach Manager', :rel_recipient_obj => 'all_managers')
    
    #time off not approved yet
    sn = FactoryGirl.create(:system_notification, :notification_id => notif.id, :recipient_id => manager.id, :recipient_type => 'Account', :target_id => timeoff.id)
    assert_true sn.require_cta_links?

    #time off already approved
    timeoff.update_attribute('approval_status', 1)
    sn = SystemNotification.find_by_id(sn.id)
    assert_false sn.require_cta_links?
  end

end
