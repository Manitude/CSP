class MakeAuditLogTableUnicodeFriendly < ActiveRecord::Migration
  def self.up
  	execute "Delete from audit_log_records where created_at < '#{(Time.now - 1.month).to_s(:db)}'"
  	execute "ALTER TABLE audit_log_records CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci"
  end

  def self.down
  end
end
