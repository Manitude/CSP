class AddRawNotifications < ActiveRecord::Migration
  def self.up
    add_column :system_notifications, :raw_message, :string
  end

  def self.down
    remove_column :system_notifications, :raw_message
  end
end