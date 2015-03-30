class AddTriggersForCuttingShortTimeOff < ActiveRecord::Migration
  def self.up
    #  create trigger for Coach returning from Time off early
    e1 = TriggerEvent.create(:name => 'TIME_OFF_CUT_SHORT', :description => 'Coach has reduced his/her requested time off.')
    n1 = Notification.create(:trigger_event_id => e1.id, :message => 'has reduced his/her requested time off. The new time off is from to .', :target_type => 'CoachAvailabilityModification')
    n1.message_dynamics.create(:msg_index => 0, :name => 'Coach Name', :rel_obj_type => 'coach', :rel_obj_attr => 'name')
    n1.message_dynamics.create(:msg_index => 65, :name => 'Start Date', :rel_obj_type => nil, :rel_obj_attr => 'start_date')
    n1.message_dynamics.create(:msg_index => 68, :name => 'End Date', :rel_obj_type => nil, :rel_obj_attr => 'end_date')
    n1.recipients.create(:name => 'Coach Manager', :rel_recipient_obj => 'coach.manager')

  end

  def self.down
    TriggerEvent.find_by_name('TIME_OFF_CUT_SHORT').destroy
  end
end
