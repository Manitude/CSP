class RemoveTimezoneFromAccount < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :time_zone
    remove_column :accounts, :solo_qualified
  end

  def self.down
    add_column :accounts, :solo_qualified, :boolean, :default => false
    add_column :accounts, :time_zone, :string, :default => 'Eastern Time (US & Canada)'
  end
end
