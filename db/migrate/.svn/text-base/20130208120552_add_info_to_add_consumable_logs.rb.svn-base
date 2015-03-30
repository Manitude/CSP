class AddInfoToAddConsumableLogs < ActiveRecord::Migration
  def self.up
    add_column :add_consumable_logs, :action, :string
    add_column :add_consumable_logs, :number_of_sessions, :integer
    remove_column :add_consumable_logs, :consumable_guid
    execute "UPDATE add_consumable_logs SET action = 'Add',number_of_sessions = '1'"
  end

  def self.down
    remove_column :add_consumable_logs, :number_of_sessions
    remove_column :add_consumable_logs, :action
    add_column :add_consumable_logs, :consumable_guid, :integer, :null => false
  end
end
