class RemoveTimeSlotPreferenceToAccounts < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :time_slot_preference
  end

  def self.down
    add_column :accounts, :time_slot_preference, :string
  end
end