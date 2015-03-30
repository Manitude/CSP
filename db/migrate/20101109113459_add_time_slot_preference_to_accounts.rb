class AddTimeSlotPreferenceToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :time_slot_preference, :string
  end

  def self.down
    remove_column :accounts, :time_slot_preference
  end
end