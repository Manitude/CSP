# == Schema Information
#
# Table name: notification_recipients
#
#  id                :integer(4)      not null, primary key
#  notification_id   :integer(4)      
#  name              :string(255)     
#  rel_recipient_obj :string(255)     
#

class NotificationRecipient < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
  belongs_to :notification
end
