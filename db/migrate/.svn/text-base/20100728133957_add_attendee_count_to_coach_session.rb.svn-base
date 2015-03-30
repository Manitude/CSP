class AddAttendeeCountToCoachSession < ActiveRecord::Migration
  def self.up
    add_column :coach_sessions, :attendee_count, :integer, :limit => 2
  end

  def self.down
    remove_column :coach_sessions, :attendee_count
  end
end
