class UpdateNotificationRecipientChangeToAllManagers < ActiveRecord::Migration
  def self.up
    NotificationRecipient.find_all_by_rel_recipient_obj('coach.manager').each do |notification_recipient|
        notification_recipient.update_attribute(:rel_recipient_obj, 'coach.all_managers')
    end
  end

  def self.down
    NotificationRecipient.find_all_by_rel_recipient_obj('coach.all_managers').each do |notification_recipient|
      notification_recipient.update_attribute(:rel_recipient_obj, 'coach.manager') if notification_recipient
    end
  end
end
