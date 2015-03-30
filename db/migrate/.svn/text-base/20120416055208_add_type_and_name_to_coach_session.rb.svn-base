class AddTypeAndNameToCoachSession < ActiveRecord::Migration
  def self.up
    add_column :coach_sessions, :type, :string
    add_column :coach_sessions, :name, :string
  end

  def self.down
    remove_column :coach_sessions, :name
    remove_column :coach_sessions, :type
  end
end
