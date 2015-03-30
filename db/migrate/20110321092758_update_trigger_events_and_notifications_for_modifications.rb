class UpdateTriggerEventsAndNotificationsForModifications < ActiveRecord::Migration
  def self.up
    NotificationRecipient.find_by_id_and_rel_recipient_obj(17,'coach.manager').update_attribute(:rel_recipient_obj, 'coach.all_managers')
  end

  def self.down
    NotificationRecipient.find_by_id_and_rel_recipient_obj(17,'coach.all_managers').update_attribute(:rel_recipient_obj, 'coach.manager') if NotificationRecipient.find_by_id_and_rel_recipient_obj(17,'coach.all_managers')
  end
end
