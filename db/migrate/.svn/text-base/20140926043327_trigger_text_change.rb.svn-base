class TriggerTextChange < ActiveRecord::Migration
  def self.up
        trigger_event = TriggerEvent['DECLINE_TIME_OFF']
        notif = trigger_event.notification
        notif.update_attribute(:message, 'Your requested time off from to has been denied.')
        notif.message_dynamics.each do |msg_dyn|
                msg_dyn.update_attribute(:msg_index, 29) if msg_dyn.rel_obj_attr == "start_date"
                msg_dyn.update_attribute(:msg_index, 32) if msg_dyn.rel_obj_attr == "end_date"
        end
  end

  def self.down
  end
end

