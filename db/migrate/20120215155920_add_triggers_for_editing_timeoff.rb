class AddTriggersForEditingTimeoff < ActiveRecord::Migration
  def self.up
    #  create trigger for Coach editing timeoff
    e1 = TriggerEvent.create(:name => 'TIME_OFF_EDITED', :description => 'Coach has edited his/her requested time off.')
    n1 = Notification.create(:trigger_event_id => e1.id, :message => 'has edited his/her requested time off. The new time off is from to .', :target_type => 'UnavailableDespiteTemplate')
    n1.message_dynamics.create(:msg_index => 0, :name => 'Coach Name', :rel_obj_type => 'coach', :rel_obj_attr => 'name')
    n1.message_dynamics.create(:msg_index => 64, :name => 'Start Date', :rel_obj_type => nil, :rel_obj_attr => 'start_date')
    n1.message_dynamics.create(:msg_index => 67, :name => 'End Date', :rel_obj_type => nil, :rel_obj_attr => 'end_date')
    n1.recipients.create(:name => 'Coach Manager', :rel_recipient_obj => 'coach.all_managers')

  end

  def self.down
    TriggerEvent.find_by_name('TIME_OFF_EDITED').destroy
  end
end

