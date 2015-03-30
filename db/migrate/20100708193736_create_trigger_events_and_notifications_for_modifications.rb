class CreateTriggerEventsAndNotificationsForModifications < ActiveRecord::Migration
  def self.up
    e1 = TriggerEvent.create(:name => 'REQUEST_TIME_OFF_BY_VIOLATING_POLICY', :description => 'Coach requests time off less than 2 weeks in advance.')
    e2 = TriggerEvent.create(:name => 'REQUEST_TIME_OFF', :description => 'Coach requests time off over 2 weeks in advance.')
    e3 = TriggerEvent.create(:name => 'ACCEPT_TIME_OFF', :description => 'Coach Manager accepts a request for time off.')
    e4 = TriggerEvent.create(:name => 'DENY_TIME_OFF', :description => 'Coach Manager denies a request for time off.')

    n1 = Notification.create(:trigger_event_id => e1.id, :message => 'has requested time off for the session starting at ,less than 2 weeks in advance.', :target_type => 'CoachAvailabilityModification')
    n2 = Notification.create(:trigger_event_id => e2.id, :message => 'has requested time off for the session starting at ', :target_type => 'CoachAvailabilityModification')
    n3 = Notification.create(:trigger_event_id => e3.id, :message => 'Your requested time off for the session starting at has been approved.', :target_type => 'CoachAvailabilityModification')
    n4 = Notification.create(:trigger_event_id => e4.id, :message => 'Your requested time off for the session starting at has been denied.', :target_type => 'CoachAvailabilityModification')

    n1.message_dynamics.create(:msg_index => 0, :name => 'Coach Name', :rel_obj_type => 'coach', :rel_obj_attr => 'name')
    n1.message_dynamics.create(:msg_index => 51, :name => 'date', :rel_obj_type => nil, :rel_obj_attr => 'start_date')
    n2.message_dynamics.create(:msg_index => 0, :name => 'Coach Name', :rel_obj_type => 'coach', :rel_obj_attr => 'name')
    n2.message_dynamics.create(:msg_index => 51, :name => 'date', :rel_obj_type => nil, :rel_obj_attr => 'start_date')
    n3.message_dynamics.create(:msg_index => 52, :name => 'date', :rel_obj_type => nil, :rel_obj_attr => 'start_date')
    n4.message_dynamics.create(:msg_index => 52, :name => 'date', :rel_obj_type => nil, :rel_obj_attr => 'start_date')

    n1.recipients.create(:name => 'Coach Manager', :rel_recipient_obj => 'coach.manager')
    n2.recipients.create(:name => 'Coach Manager', :rel_recipient_obj => 'coach.manager')
    n3.recipients.create(:name => 'Coach', :rel_recipient_obj => 'coach')
    n4.recipients.create(:name => 'Coach', :rel_recipient_obj => 'coach')
  end

  def self.down
    TriggerEvent.find_by_name('REQUEST_TIME_OFF_BY_VIOLATING_POLICY').destroy
    TriggerEvent.find_by_name('REQUEST_TIME_OFF').destroy
    TriggerEvent.find_by_name('ACCEPT_TIME_OFF').destroy
    TriggerEvent.find_by_name('DENY_TIME_OFF').destroy
  end
end
