class UpdateNotificationRecepientsTable < ActiveRecord::Migration
  def self.up
    notification_recipient_records = NotificationRecipient.find_all_by_name("Coach Manager")
    notification_recipient_records.each do |record|
      record.update_attribute(:rel_recipient_obj, "all_managers")
    end
  end

  def self.down
    notification_recipient_records = NotificationRecipient.find_all_by_name("Coach Manager")
    notification_recipient_records.each do |record|
      record.update_attribute(:rel_recipient_obj, "coach.all_managers")
    end
  end
end
