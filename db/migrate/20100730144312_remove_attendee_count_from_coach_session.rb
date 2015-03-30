class RemoveAttendeeCountFromCoachSession < ActiveRecord::Migration
  def self.up
    remove_column :coach_sessions, :attendee_count
  end

  def self.down
    add_column :coach_sessions, :attendee_count, :integer, :limit => 2
  end
end
