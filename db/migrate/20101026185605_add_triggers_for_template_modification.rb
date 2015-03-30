class AddTriggersForTemplateModification < ActiveRecord::Migration
  def self.up
    e1 = TriggerEvent.create(:name => 'TEMPLATE_CHANGED', :description => 'Coach changes a template without violating policy.')

    n1 = Notification.create(:trigger_event_id => e1.id, :message => 'has requested change to template.', :target_type => 'CoachAvailabilityTemplate')

    n1.message_dynamics.create(:msg_index => 0, :name => 'Coach Name', :rel_obj_type => 'coach', :rel_obj_attr => 'name')
    n1.message_dynamics.create(:msg_index => 33, :name => 'Template Name', :rel_obj_type => nil, :rel_obj_attr => 'label')

    n1.recipients.create(:name => 'Coach Manager', :rel_recipient_obj => 'coach.manager')
  end

  def self.down
    TriggerEvent.find_by_name('TEMPLATE_CHANGED').destroy
  end
end
