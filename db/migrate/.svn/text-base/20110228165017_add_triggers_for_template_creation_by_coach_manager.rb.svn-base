class AddTriggersForTemplateCreationByCoachManager < ActiveRecord::Migration
  def self.up
    #  create trigger for Coach when Coach Manager creates a new template for him/her.
    e1 = TriggerEvent.create(:name => 'CM_CREATED_NEW_TEMPLATE', :description => 'Coach Manager creates a new template for the coach.')
    n1 = Notification.create(:trigger_event_id => e1.id, :message => 'Your manager has created a new template  for you.', :target_type => 'CoachAvailabilityTemplate')
    n1.message_dynamics.create(:msg_index => 40, :name => 'Template Name', :rel_obj_type => nil, :rel_obj_attr => 'label')
    n1.recipients.create(:name => 'Coach', :rel_recipient_obj => 'coach')

  end

  def self.down
    TriggerEvent.find_by_name('CM_CREATED_NEW_TEMPLATE').destroy
  end
end
