# == Schema Information
#
# Table name: notifications
#
#  id               :integer(4)      not null, primary key
#  trigger_event_id :integer(4)      
#  message          :text(65535)     
#  target_type      :string(255)     
#

class Notification < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
  has_many   :recipients, :class_name => 'NotificationRecipient', :dependent => :destroy
  has_many   :message_dynamics, :class_name => 'NotificationMessageDynamic', :order => 'msg_index', :dependent => :destroy, :include => [:notification]
  has_many   :system_notifications, :dependent => :destroy
  belongs_to :trigger_event

  def trigger!(target_obj = nil)
    raise_if_param_invalid(target_obj)
    self.recipients.each do |recipient|
      create_system_notification(recipient, target_obj)
    end
  end

  def create_system_notification(recipient, target_obj)
    actual_recipient = recipient.rel_recipient_obj == "all_managers" ? CoachManager.all : target_obj.send(recipient.rel_recipient_obj).to_a
    actual_recipient.each do |each_recipient|
      each_recipient.system_notifications.create(:notification => self, :target_id    => target_obj.id)
    end
  end

  private

  def raise_if_param_invalid(target_obj)
    valid_param = self.target_type == target_obj.class.to_s
    raise "Invalid Object param. Expecting object of type: #{self.target_type}" unless valid_param
  end
end
