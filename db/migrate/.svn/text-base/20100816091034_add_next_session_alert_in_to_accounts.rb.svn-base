class AddNextSessionAlertInToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :next_session_alert_in, :integer, :limit => 3
  end

  def self.down
    remove_column :accounts, :next_session_alert_in
  end
end
