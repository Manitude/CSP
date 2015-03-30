class UpdateNotificationRecipientsAllManagers < ActiveRecord::Migration
  def self.up
      NotificationRecipient.find_by_id_and_rel_recipient_obj(5,'coach.manager').update_attribute(:rel_recipient_obj, 'coach.all_managers')
      NotificationRecipient.find_by_id_and_rel_recipient_obj(6,'coach.manager').update_attribute(:rel_recipient_obj, 'coach.all_managers')
      NotificationRecipient.find_by_id_and_rel_recipient_obj(18,'coach.manager').update_attribute(:rel_recipient_obj, 'coach.all_managers')
  end

  def self.down
      NotificationRecipient.find_by_id_and_rel_recipient_obj(5,'coach.all_managers').update_attribute(:rel_recipient_obj, 'coach.manager') if NotificationRecipient.find_by_id_and_rel_recipient_obj(5,'coach.all_managers')
      NotificationRecipient.find_by_id_and_rel_recipient_obj(6,'coach.all_managers').update_attribute(:rel_recipient_obj, 'coach.manager') if NotificationRecipient.find_by_id_and_rel_recipient_obj(6,'coach.all_managers')
      NotificationRecipient.find_by_id_and_rel_recipient_obj(18,'coach.all_managers').update_attribute(:rel_recipient_obj, 'coach.manager') if NotificationRecipient.find_by_id_and_rel_recipient_obj(18,'coach.all_managers')
  end
end
