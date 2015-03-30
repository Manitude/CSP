class AddColumnCoachIdAndSessionsStatusToCoachSessions< ActiveRecord::Migration
  def self.up
    add_column :coach_sessions, :coach_id, :integer
    add_column :coach_sessions, :sessions_status, :integer, :default => 1
    execute("UPDATE coach_sessions SET coach_id = (SELECT id FROM accounts WHERE BINARY user_name = coach_sessions.coach_user_name);")
  end

  def self.down
    # Here there is no point to update coach_id column. Since we are removing the coach_id itself.
    remove_column :coach_sessions, :coach_id
    remove_column :coach_sessions, :sessions_status
  end
end
