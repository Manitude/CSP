class ChangeColumnNameAndAddDefaultToCoachSessions< ActiveRecord::Migration
  def self.up
    rename_column :coach_sessions, :sessions_status, :session_status
  end

  def self.down
    rename_column :coach_sessions, :session_status, :sessions_status
  end
end

