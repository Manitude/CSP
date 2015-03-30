class UpdateNotificationMessageDynamics < ActiveRecord::Migration
  def self.up
    NotificationMessageDynamic.find_all_by_notification_id_and_msg_index(TriggerEvent.find_by_name("SUBSTITUTION_GRABBED").id, 0).first.update_attribute(:rel_obj_attr, "display_name")
    NotificationMessageDynamic.find_all_by_notification_id_and_msg_index(TriggerEvent.find_by_name("SESSION_CANCELLED").id, 5).first.update_attribute(:rel_obj_attr, "display_name")
    NotificationMessageDynamic.find_all_by_notification_id_and_msg_index(TriggerEvent.find_by_name("MANUALLY_REASSIGNED").id, 0).first.update_attribute(:rel_obj_attr, "display_name")
  end

  def self.down
    NotificationMessageDynamic.find_all_by_notification_id_and_msg_index(TriggerEvent.find_by_name("SUBSTITUTION_GRABBED").id, 0).first.update_attribute(:rel_obj_attr, "identifier") if NotificationMessageDynamic.find_all_by_notification_id_and_msg_index(TriggerEvent.find_by_name("SUBSTITUTION_GRABBED").id, 0)
    NotificationMessageDynamic.find_all_by_notification_id_and_msg_index(TriggerEvent.find_by_name("SESSION_CANCELLED").id, 5).first.update_attribute(:rel_obj_attr, "identifier") if NotificationMessageDynamic.find_all_by_notification_id_and_msg_index(TriggerEvent.find_by_name("SESSION_CANCELLED").id, 5)
    NotificationMessageDynamic.find_all_by_notification_id_and_msg_index(TriggerEvent.find_by_name("MANUALLY_REASSIGNED").id, 0).first.update_attribute(:rel_obj_attr, "identifier") if NotificationMessageDynamic.find_all_by_notification_id_and_msg_index(TriggerEvent.find_by_name("MANUALLY_REASSIGNED").id, 0)
  end
end
