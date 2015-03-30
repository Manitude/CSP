require 'test_helper'

class Notification_test < ActiveSupport::TestCase
  
  def test_trigger
    NotificationMessageDynamic.delete_all
    NotificationRecipient.delete_all
    SystemNotification.delete_all
    Account.delete_all
    notif = FactoryGirl.create(:notification, :trigger_event_id => 1, :message => 'A new template for has been submitted for review.', :target_type => 'CoachAvailabilityTemplate')

    #checks if the Exception is raised when an invalid target type is passed or not
    assert_raise(RuntimeError){notif.trigger!('test')}

    #checks if a system notification is created or not. It will return not nil if a system notification is created successfully and exception is not thrown
    coach = FactoryGirl.create(:coach)
    FactoryGirl.create(:account)
    template = FactoryGirl.create(:coach_availability_template, :coach_id => coach.id, :effective_start_date => (Time.now + 5.day).to_date, :label => "test")
    FactoryGirl.create(:notification_recipient, :notification_id => notif.id, :name => 'Coach Manager', :rel_recipient_obj => 'all_managers')
    FactoryGirl.create(:notification_message_dynamic, :notification_id => notif.id, :name => 'Coach Name', :msg_index => 19, :rel_obj_attr => 'name', :rel_obj_type => 'coach')
    FactoryGirl.create(:notification_message_dynamic, :notification_id => notif.id, :name => 'Template Name', :msg_index => 15, :rel_obj_attr => 'label')
    assert_not_nil(notif.trigger!(template))
    assert_equal CoachManager.all.size, SystemNotification.all.size
  end
end
