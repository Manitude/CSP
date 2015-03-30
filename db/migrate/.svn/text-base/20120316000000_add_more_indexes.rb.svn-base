class AddMoreIndexes < ActiveRecord::Migration
  def self.up
    add_index :substitutions, :grabber_coach_id
    add_index :coach_sessions, [:coach_user_name, :language_identifier]
  end

  def self.down
    remove_index :substitutions, :grabber_coach_id
    remove_index :coach_sessions, [:coach_user_name, :language_identifier]
  end
end
