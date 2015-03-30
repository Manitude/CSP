class AddTriggersForSubRequestedAndTimeOffChanges < ActiveRecord::Migration
  def self.up
    # Part I - create Substitution requested trigger
    e1 = TriggerEvent.create(:name => 'SUBSTITUTE_REQUESTED', :description => 'Coach requests a substitute for a session.')
    n1 = Notification.create(:trigger_event_id => e1.id, :message => 'has requested a substitute for session starting .', :target_type => 'CoachAvailabilityModification')
    n1.message_dynamics.create(:msg_index => 0, :name => 'Coach Name', :rel_obj_type => 'coach', :rel_obj_attr => 'name')
    n1.message_dynamics.create(:msg_index => 48, :name => 'Session Start Time', :rel_obj_type => nil, :rel_obj_attr => 'start_date')
    n1.recipients.create(:name => 'Coach Manager', :rel_recipient_obj => 'coach.manager')

    # Part II - Show the end time of the time off as well
    #
    # 'REQUEST_TIME_OFF'
    e2 = TriggerEvent.find(:first, :conditions => {:name => "REQUEST_TIME_OFF"})
    n2 = Notification.find_by_trigger_event_id(e2.id)
    n2.update_attribute(:message, "has requested time off from to .")
    start_date_dynamic = NotificationMessageDynamic.find(:first, :conditions => {:notification_id => n2.id, :rel_obj_attr => "start_date"})
    start_date_dynamic.update_attributes(:msg_index => 28, :name => "Start Date")
    n2.message_dynamics.create(:msg_index => 31, :name => 'End Date', :rel_obj_type => nil, :rel_obj_attr => 'end_date')

    # 'REQUEST_TIME_OFF_BY_VIOLATING_POLICY'
    e3 = TriggerEvent.find(:first, :conditions => {:name => "REQUEST_TIME_OFF_BY_VIOLATING_POLICY"})
    n3 = Notification.find_by_trigger_event_id(e3.id)
    n3.update_attribute(:message, "has violated policy by requesting time off from to .")
    start_date_dynamic = NotificationMessageDynamic.find(:first, :conditions => {:notification_id => n3.id, :rel_obj_attr => "start_date"})
    start_date_dynamic.update_attributes(:msg_index => 48, :name => "Start Date")
    n3.message_dynamics.create(:msg_index => 51, :name => 'End Date', :rel_obj_type => nil, :rel_obj_attr => 'end_date')

    # 'ACCEPT_TIME_OFF'
    e4 = TriggerEvent.find(:first, :conditions => {:name => "ACCEPT_TIME_OFF"})
    n4 = Notification.find_by_trigger_event_id(e4.id)
    n4.update_attribute(:message, "Your requested time off from to has been approved .")
    start_date_dynamic = NotificationMessageDynamic.find(:first, :conditions => {:notification_id => n4.id, :rel_obj_attr => "start_date"})
    start_date_dynamic.update_attributes(:msg_index => 20, :name => "Start Date")
    n4.message_dynamics.create(:msg_index => 23, :name => 'End Date', :rel_obj_type => nil, :rel_obj_attr => 'end_date')

    # 'DENY_TIME_OFF'
    e5 = TriggerEvent.find(:first, :conditions => {:name => "DENY_TIME_OFF"})
    n5 = Notification.find_by_trigger_event_id(e5.id)
    n5.update_attribute(:message, "Your requested time off from to has been denied .")
    start_date_dynamic = NotificationMessageDynamic.find(:first, :conditions => {:notification_id => n5.id, :rel_obj_attr => "start_date"})
    start_date_dynamic.update_attributes(:msg_index => 20, :name => "Start Date")
    n5.message_dynamics.create(:msg_index => 23, :name => 'End Date', :rel_obj_type => nil, :rel_obj_attr => 'end_date')

    # bug fix for a punctuation mistake
    t = TriggerEvent.find_by_name('TEMPLATE_CHANGED')
    t.notification.update_attributes(:message => 'has requested change to template .')
  end

  def self.down
    # Part II

    # DENY_TIME_OFF
    e5 = TriggerEvent.find(:first, :conditions => {:name => "DENY_TIME_OFF"})
    n5 = Notification.find_by_trigger_event_id(e5.id)
    n5.message_dynamics.find(:first, :conditions => {:rel_obj_attr => "end_date"}).destroy
    start_date_dynamic = NotificationMessageDynamic.find(:first, :conditions => {:notification_id => n5.id, :rel_obj_attr => "start_date"})
    start_date_dynamic.update_attributes(:msg_index => 52, :name => "Start Date")
    n5.update_attribute(:message, "Your requested time off for the session starting at has been denied.")

    # ACCEPT_TIME_OFF
    e4 = TriggerEvent.find(:first, :conditions => {:name => "ACCEPT_TIME_OFF"})
    n4 = Notification.find_by_trigger_event_id(e4.id)
    n4.message_dynamics.find(:first, :conditions => {:rel_obj_attr => "end_date"}).destroy
    start_date_dynamic = NotificationMessageDynamic.find(:first, :conditions => {:notification_id => n4.id, :rel_obj_attr => "start_date"})
    start_date_dynamic.update_attributes(:msg_index => 52, :name => "Start Date")
    n4.update_attribute(:message, "Your requested time off for the session starting at has been approved.")

    # REQUEST_TIME_OFF_BY_VIOLATING_POLICY
    e3 = TriggerEvent.find(:first, :conditions => {:name => "REQUEST_TIME_OFF_BY_VIOLATING_POLICY"})
    n3 = Notification.find_by_trigger_event_id(e3.id)
    n3.message_dynamics.find(:first, :conditions => {:rel_obj_attr => "end_date"}).destroy
    start_date_dynamic = NotificationMessageDynamic.find(:first, :conditions => {:notification_id => n3.id, :rel_obj_attr => "start_date"})
    start_date_dynamic.update_attributes(:msg_index => 51, :name => "Start Date")
    n3.update_attribute(:message, "has requested time off for the session starting at ,less than 2 weeks in advance.")

    # REQUEST_TIME_OFF
    e2 = TriggerEvent.find(:first, :conditions => {:name => "REQUEST_TIME_OFF"})
    n2 = Notification.find_by_trigger_event_id(e2.id)
    n2.message_dynamics.find(:first, :conditions => {:rel_obj_attr => "end_date"}).destroy
    start_date_dynamic = NotificationMessageDynamic.find(:first, :conditions => {:notification_id => n2.id, :rel_obj_attr => "start_date"})
    start_date_dynamic.update_attributes(:msg_index => 51, :name => "Start Date")
    n2.update_attribute(:message, "has requested time off for the session starting at ...")

    # Part I
    TriggerEvent.find_by_name('SUBSTITUTE_REQUESTED').destroy
  end
end
