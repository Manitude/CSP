class AddIndexToCoachIdInCoachSessions < ActiveRecord::Migration
  def self.up
    add_index     :coach_sessions, :coach_id
  end

  def self.down
    remove_index     :coach_sessions, :coach_id
  end
end
