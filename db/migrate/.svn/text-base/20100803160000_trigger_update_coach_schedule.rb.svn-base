class TriggerUpdateCoachSchedule < ActiveRecord::Migration
  def self.up
    e1 = TriggerEvent.create(:name => 'UPDATE_COACH_SCHEDULE', :description => 'Coach Manager manually changes the schedule of a coach in Master Scheduler')
    n1 = Notification.create(:trigger_event_id => e1.id, :message => 'Your availability on has been changed by your manager.', :target_type => 'CoachAvailabilityModification')
    n1.message_dynamics.create(:msg_index => 21, :name => 'datetime', :rel_obj_type => nil, :rel_obj_attr => 'start_date')
    n1.recipients.create(:name => 'Coach', :rel_recipient_obj => 'coach')
  end

  def self.down
    TriggerEvent.find_by_name('UPDATE_COACH_SCHEDULE').destroy
  end
end