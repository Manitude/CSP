class CreateTriggerEventsAndNotificationsForSubstitutions < ActiveRecord::Migration
  def self.up
    e1 = TriggerEvent.create(:name => 'SUBSTITUTION_GRABBED', :description => 'A substitute Coach grabs an available session.')

    n1 = Notification.create(:trigger_event_id => e1.id, :message => ' session on has been grabbed by .', :target_type => 'Substitution')

    n1.message_dynamics.create(:msg_index => 0, :name => 'Language identifier', :rel_obj_type => 'language', :rel_obj_attr => 'identifier')
    n1.message_dynamics.create(:msg_index => 12, :name => 'datetime', :rel_obj_type => nil, :rel_obj_attr => 'substitution_date')
    n1.message_dynamics.create(:msg_index => 32, :name => 'Coach Name', :rel_obj_type => 'grabber_coach', :rel_obj_attr => 'name')

    n1.recipients.create(:name => 'Coach Manager', :rel_recipient_obj => 'coach.manager')
  end

  def self.down
    TriggerEvent.find_by_name('SUBSTITUTION_GRABBED').destroy
  end
end
