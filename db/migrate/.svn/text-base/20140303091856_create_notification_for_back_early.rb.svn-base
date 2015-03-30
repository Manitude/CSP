class CreateNotificationForBackEarly < ActiveRecord::Migration
  def self.up
  	trigger = TriggerEvent.create(:name => "TIME_OFF_REMOVED", :description => "Coach is back early from his/her requested time off.")
  	Notification.create(:trigger_event_id => trigger.id, :message => "is back early from time off - .", :target_type => "UnavailableDespiteTemplate")
  	NotificationMessageDynamic.create(:notification_id => trigger.id, :msg_index => 0, :name => "Coach Name", :rel_obj_type => "coach", :rel_obj_attr => "name")
  	NotificationMessageDynamic.create(:notification_id => trigger.id, :msg_index => 28, :name => "Start Date", :rel_obj_attr => "start_date")
  	NotificationMessageDynamic.create(:notification_id => trigger.id, :msg_index => 30, :name => "End Date", :rel_obj_attr => "end_date")
  	NotificationRecipient.create(:notification_id => trigger.id, :name => "Coach Manager", :rel_recipient_obj => "all_managers")
  end

  def self.down
  	trigger = TriggerEvent.find_by_name('TIME_OFF_REMOVED')
  	Notification.delete_all(:trigger_event_id => trigger.id)
   	NotificationRecipient.delete_all(:notification_id => trigger.id)
  	NotificationMessageDynamic.delete_all(:notification_id => trigger.id)
  	TriggerEvent.delete_all(:name => "TIME_OFF_REMOVED")
  end
end