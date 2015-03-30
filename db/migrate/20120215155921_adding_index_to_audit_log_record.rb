class AddingIndexToAuditLogRecord < ActiveRecord::Migration
  def self.up
    add_index :audit_log_records, :loggable_id
    add_index :audit_log_records, :loggable_type
    add_index :audit_log_records, :action
    add_index :audit_log_records, :timestamp
  end

  def self.down
    remove_index :audit_log_records, :loggable_id
    remove_index :audit_log_records, :loggable_type
    remove_index :audit_log_records, :action
    remove_index :audit_log_records, :timestamp
  end
end
