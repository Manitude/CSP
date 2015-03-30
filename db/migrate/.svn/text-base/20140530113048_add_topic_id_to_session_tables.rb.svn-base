class AddTopicIdToSessionTables < ActiveRecord::Migration
  def self.up
    add_column :session_metadata, :topic_id, :integer, :default => nil
    add_column :coach_sessions, :topic_id, :integer, :default => nil
    add_column :coach_recurring_schedules, :topic_id, :integer, :default => nil
  end

  def self.down
  	remove_column :session_metadata, :topic_id
  	remove_column :coach_sessions, :topic_id
  	remove_column :coach_recurring_schedules, :topic_id
  end
end
