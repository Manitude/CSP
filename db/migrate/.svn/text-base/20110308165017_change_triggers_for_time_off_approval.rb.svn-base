class ChangeTriggersForTimeOffApproval < ActiveRecord::Migration
  def self.up
    # 'ACCEPT_TIME_OFF'
    e1 = TriggerEvent.find(:first, :conditions => {:name => "ACCEPT_TIME_OFF"})
    n1 = Notification.find_by_trigger_event_id(e1.id)
    start_date_dynamic = NotificationMessageDynamic.find(:first, :conditions => {:notification_id => n1.id, :rel_obj_attr => "start_date"})
    start_date_dynamic.update_attributes(:msg_index => 29, :name => "Start Date")
    end_date_dynamic = NotificationMessageDynamic.find(:first, :conditions => {:notification_id => n1.id, :rel_obj_attr => "end_date"})
    end_date_dynamic.update_attributes(:msg_index => 32, :name => 'End Date')

  end

  def self.down
    # 'ACCEPT_TIME_OFF'
    e1 = TriggerEvent.find(:first, :conditions => {:name => "ACCEPT_TIME_OFF"})
    n1 = Notification.find_by_trigger_event_id(e1.id)
    start_date_dynamic = NotificationMessageDynamic.find(:first, :conditions => {:notification_id => n1.id, :rel_obj_attr => "start_date"})
    start_date_dynamic.update_attributes(:msg_index => 20, :name => "Start Date")
    end_date_dynamic = NotificationMessageDynamic.find(:first, :conditions => {:notification_id => n1.id, :rel_obj_attr => "end_date"})
    end_date_dynamic.update_attributes(:msg_index => 23, :name => 'End Date')
  end
end
