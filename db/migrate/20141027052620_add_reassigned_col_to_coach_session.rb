class AddReassignedColToCoachSession < ActiveRecord::Migration
  def self.up
  	add_column :coach_sessions, :reassigned, :boolean
  	add_column :session_metadata, :coach_reassigned, :boolean
  end

  def self.down
  	remove_column :coach_sessions, :reassigned
  	remove_column :session_metadata, :coach_reassigned
  end
end
