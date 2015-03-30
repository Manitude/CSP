# == Schema Information
#
# Table name: trigger_events
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)     
#  description :text(65535)     
#

class TriggerEvent < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
  has_one :notification, :dependent => :destroy

  laziness_lookup_attribute :name

  delegate :target_type, :trigger!, :to => :notification, :prefix => true, :allow_nil => true

end
