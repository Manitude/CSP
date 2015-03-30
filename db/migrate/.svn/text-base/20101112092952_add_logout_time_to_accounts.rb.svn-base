class AddLogoutTimeToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :last_logout, :datetime
  end

  def self.down
    remove_column :accounts, :last_logout
  end
end
