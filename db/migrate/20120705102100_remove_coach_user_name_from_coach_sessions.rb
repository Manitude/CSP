class RemoveCoachUserNameFromCoachSessions < ActiveRecord::Migration
  def self.up
    remove_column :coach_sessions, :coach_user_name
  end

  def self.down
    add_column :coach_sessions, :coach_user_name, :string
  end
end
