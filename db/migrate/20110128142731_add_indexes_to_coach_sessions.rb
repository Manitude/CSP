class AddIndexesToCoachSessions < ActiveRecord::Migration
  def self.up
    add_index :coach_sessions, :eschool_session_id, :name => "idx_coach_sessions_eschool_session_id"
    add_index :coach_sessions, :session_start_time, :name => "idx_coach_sessions_start_time"
  end

  def self.down
    remove_index :coach_sessions, :name => "idx_coach_sessions_start_time"
    remove_index :coach_sessions, :name => "idx_coach_sessions_eschool_session_id"
  end
end
