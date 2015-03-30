class AddTriggersForSubstituteRequestedForCoach < ActiveRecord::Migration
  def self.up
    e1 = TriggerEvent.create(:name => 'SUBSTITUTE_REQUESTED_FOR_COACH', :description => 'Coach Manager requests a substitute for a session on behalf of coach.')
    n1 = Notification.create(:trigger_event_id => e1.id, :message => 'Your manager has requested a substitute on your behalf for your session starting .', :target_type => 'UnavailableDespiteTemplate')
    n1.message_dynamics.create(:msg_index => 81, :name => 'Session Start Time', :rel_obj_type => nil, :rel_obj_attr => 'start_date')
    n1.recipients.create(:name => 'Coach', :rel_recipient_obj => 'coach')
  end

  def self.down
    TriggerEvent.find_by_name('SUBSTITUTE_REQUESTED_FOR_COACH').destroy
  end
end
