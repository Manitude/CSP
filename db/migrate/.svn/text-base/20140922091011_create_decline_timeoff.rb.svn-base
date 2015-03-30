class CreateDeclineTimeoff < ActiveRecord::Migration
  def self.up
    trigger_event = TriggerEvent.create(:name => 'DECLINE_TIME_OFF', :description => 'Coach Manager declines a request for time off.')
    notification = Notification.create(:trigger_event_id => trigger_event.id, :message => 'Your requested time off from <b>  </b> to <b>  </b> has been denied.', :target_type => 'UnavailableDespiteTemplate')
    notification.message_dynamics.create(:msg_index => 33, :name => 'Start Date',  :rel_obj_attr => 'start_date')
    notification.message_dynamics.create(:msg_index => 46, :name => 'End Date',  :rel_obj_attr => 'end_date')
    notification.recipients.create(:name => 'Coach', :rel_recipient_obj => 'coach')
  end

  def self.down
    TriggerEvent.find_by_name('DECLINE_TIME_OFF').destroy
  end
end
