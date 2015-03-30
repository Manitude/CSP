class AuditLogWhoChangedIt < ActiveRecord::Migration
  def self.up
    add_column :audit_log_records, :changed_by, :string
  end

  def self.down
    remove_column :audit_log_records, :changed_by
  end
end
