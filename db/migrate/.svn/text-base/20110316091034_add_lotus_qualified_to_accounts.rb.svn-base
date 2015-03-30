class AddLotusQualifiedToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :lotus_qualified, :boolean, :default => true
  end

  def self.down
    remove_column :accounts, :lotus_qualified
  end
end
