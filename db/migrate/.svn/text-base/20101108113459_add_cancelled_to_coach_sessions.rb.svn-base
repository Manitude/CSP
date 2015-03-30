class AddCancelledToCoachSessions < ActiveRecord::Migration
  def self.up
    add_column :coach_sessions, :cancelled, :boolean, :default => false
  end

  def self.down
    remove_column :coach_sessions, :cancelled
  end
end