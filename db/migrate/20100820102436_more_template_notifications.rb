class MoreTemplateNotifications < ActiveRecord::Migration
  def self.up
    e1 = TriggerEvent.create(:name => 'COACH_ACCEPT_TEMPLATE_CHANGES', :description => 'When a Coach accepts a template that a CM has suggested changes to, the CM should be notified of the acceptance')
    e2 = TriggerEvent.create(:name => 'COACH_REJECT_TEMPLATE_CHANGES', :description => 'When a Coach declines a template that a CM has suggested changes to, the CM should be notified of the declined template')
    e3 = TriggerEvent.create(:name => 'APPROVE_TEMPLATE_WITH_MODIFICATIONS', :description => 'When a CM approves a template with modifications')

    n1 = Notification.create(:trigger_event_id => e1.id, :message => 'The template beginning has been accepted by ', :target_type => 'CoachAvailabilityTemplate')
    n2 = Notification.create(:trigger_event_id => e2.id, :message => 'The template beginning has been rejected by ', :target_type => 'CoachAvailabilityTemplate')
    n3 = Notification.create(:trigger_event_id => e3.id, :message => 'Your template beginning has been approved with changes', :target_type => 'CoachAvailabilityTemplate')

    n1.message_dynamics.create(:msg_index => 13, :name => 'Template Name', :rel_obj_type => nil, :rel_obj_attr => 'label')
    n1.message_dynamics.create(:msg_index => 23, :name => 'Date', :rel_obj_type => nil, :rel_obj_attr => 'effective_start_date')
    n1.message_dynamics.create(:msg_index => 44, :name => 'Coach Name', :rel_obj_type => 'coach', :rel_obj_attr => 'name')
    n2.message_dynamics.create(:msg_index => 13, :name => 'Template Name', :rel_obj_type => nil, :rel_obj_attr => 'label')
    n2.message_dynamics.create(:msg_index => 23, :name => 'Date', :rel_obj_type => nil, :rel_obj_attr => 'effective_start_date')
    n2.message_dynamics.create(:msg_index => 44, :name => 'Coach Name', :rel_obj_type => 'coach', :rel_obj_attr => 'name')
    n3.message_dynamics.create(:msg_index => 14, :name => 'Template Name', :rel_obj_type => nil, :rel_obj_attr => 'label')
    n3.message_dynamics.create(:msg_index => 24, :name => 'Date', :rel_obj_type => nil, :rel_obj_attr => 'effective_start_date')

    n1.recipients.create(:name => 'Coach Manager', :rel_recipient_obj => 'coach.manager')
    n2.recipients.create(:name => 'Coach Manager', :rel_recipient_obj => 'coach.manager')
    n3.recipients.create(:name => 'Coach', :rel_recipient_obj => 'coach')
  end

  def self.down
    TriggerEvent.find_by_name('COACH_ACCEPT_TEMPLATE_CHANGES').destroy
    TriggerEvent.find_by_name('COACH_REJECT_TEMPLATE_CHANGES').destroy
    TriggerEvent.find_by_name('APPROVE_TEMPLATE_WITH_MODIFICATIONS').destroy
  end
end
