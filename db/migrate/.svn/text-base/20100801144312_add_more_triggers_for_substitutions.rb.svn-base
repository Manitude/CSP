class AddMoreTriggersForSubstitutions < ActiveRecord::Migration
  def self.up
    e1 = TriggerEvent.create(:name => 'SESSION_CANCELLED', :description => 'Coach Manager cancels a session because no substitute could be found.')
    e2 = TriggerEvent.create(:name => 'MANUALLY_REASSIGNED', :description => 'Coach Manager manually reassigns an available session to a substitute.')

    n1 = Notification.create(:trigger_event_id => e1.id, :message => 'Your Studio Session on has been canceled.', :target_type => 'Substitution')
    n2 = Notification.create(:trigger_event_id => e2.id, :message => 'session on has been reassigned to you.', :target_type => 'Substitution')

    n1.message_dynamics.create(:msg_index => 5, :name => 'Language identifier', :rel_obj_type => 'language', :rel_obj_attr => 'identifier')
    n1.message_dynamics.create(:msg_index => 23, :name => 'datetime', :rel_obj_type => nil, :rel_obj_attr => 'substitution_date')
    n2.message_dynamics.create(:msg_index => 0, :name => 'Language identifier', :rel_obj_type => 'language', :rel_obj_attr => 'identifier')
    n2.message_dynamics.create(:msg_index => 11, :name => 'datetime', :rel_obj_type => nil, :rel_obj_attr => 'substitution_date')

    n1.recipients.create(:name => 'Coach', :rel_recipient_obj => 'coach')
    n2.recipients.create(:name => 'Coach', :rel_recipient_obj => 'grabber_coach')
  end

  def self.down
    TriggerEvent.find_by_name('SESSION_CANCELLED').destroy
    TriggerEvent.find_by_name('MANUALLY_REASSIGNED').destroy
  end
end