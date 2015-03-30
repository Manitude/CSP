class AddSessionEndTimeToCoachSessions < ActiveRecord::Migration
  def self.up
    add_column :coach_sessions, :session_end_time, :datetime
    execute "update coach_sessions set session_end_time = DATE_ADD(session_start_time, INTERVAL 1 hour)"
  end

  def self.down
    remove_column :coach_sessions, :session_end_time
  end
end
