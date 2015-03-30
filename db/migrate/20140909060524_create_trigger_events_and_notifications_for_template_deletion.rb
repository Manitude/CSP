class CreateTriggerEventsAndNotificationsForTemplateDeletion < ActiveRecord::Migration
  def self.up
    e1 = TriggerEvent.create(:name => 'CM_DELETED_TEMPLATE', :description => "Triggers when a coach manager deletes coach's template ")
    n1 = Notification.create(:trigger_event_id => e1.id, :message => "Your manager has deleted the template   .", :target_type => 'CoachAvailabilityTemplate')
    n1.message_dynamics.create(:msg_index => 38, :name => '',  :rel_obj_attr => 'label')
    n1.recipients.create(:name => 'Coach', :rel_recipient_obj => 'coach')
  end

  def self.down
    TriggerEvent.find_by_name('CM_DELETED_TEMPLATE').destroy
  end
end