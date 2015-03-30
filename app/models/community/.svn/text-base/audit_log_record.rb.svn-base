# == Schema Information
#
# Table name: audit_log_records
#
#  id             :integer(4)      not null, primary key
#  loggable_type  :string(255)     
#  loggable_id    :integer(4)      
#  attribute_name :string(255)     
#  action         :string(255)     
#  previous_value :text(65535)     
#  new_value      :text(65535)     
#  timestamp      :datetime        
#  changed_by     :string(255)     
#  created_at     :datetime        
#  ip_address     :string(255)     
#

module Community
  class AuditLogRecord < Base
    set_table_name 'audit_log_records'
  end
end
