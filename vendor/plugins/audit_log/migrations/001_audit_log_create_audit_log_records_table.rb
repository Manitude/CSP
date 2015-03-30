# This file installed by audit_log plugin. Please refrain from editing this migration, rather
# make changes in a new migration. Do not rename this file.
class AuditLogCreateAuditLogRecordsTable < ActiveRecord::Migration

  def self.up
    create_table :audit_log_records do |t|
      t.column :loggable_type,  :string
      t.column :loggable_id,    :integer
      t.column :attribute_name, :string
      t.column :action,         :string
      t.column :previous_value, :text
      t.column :new_value,      :text
      t.column :timestamp,      :datetime
      t.column :created_at,     :datetime
    end
  end

  def self.down
    drop_table :audit_log_records
  end
end