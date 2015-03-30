class ExcludedCoachesSessions < ActiveRecord::Migration
  def self.up
    create_table :excluded_coaches_sessions do |t|
      t.integer :coach_session_id, :null => false
      t.integer :coach_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :excluded_coaches_sessions
  end
end
