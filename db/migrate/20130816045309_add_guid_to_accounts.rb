class AddGuidToAccounts < ActiveRecord::Migration
  def self.up
  	add_column :accounts, :coach_guid, :string, :unique => true
  end

  def self.down
  	remove_column :accounts, :coach_guid
  end
end
