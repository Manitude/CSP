class RemoveTimeOffDeniedNotification < ActiveRecord::Migration
  def self.up
    TriggerEvent.find_by_name('DENY_TIME_OFF').destroy
  end

  def self.down
    e1 = TriggerEvent.create(:name => 'DENY_TIME_OFF', :description => 'Coach Manager denies a request for time off.')
    n1 = Notification.create(:trigger_event_id => e1.id, :message => 'Your requested time off for the session starting at has been denied.', :target_type => 'CoachAvailabilityModification')
    n1.message_dynamics.create(:msg_index => 52, :name => 'date', :rel_obj_type => nil, :rel_obj_attr => 'start_date')
    n1.recipients.create(:name => 'Coach', :rel_recipient_obj => 'coach')
  end
end
