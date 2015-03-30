class AddSingleNumberUnitNumberOfSeatsAndAttendanceCountToCoachSessions < ActiveRecord::Migration
 def self.up
    add_column :coach_sessions, :single_number_unit, :integer
    add_column :coach_sessions, :number_of_seats, :integer
    add_column :coach_sessions, :attendance_count, :integer
  end

  def self.down
    remove_column :coach_sessions, :single_number_unit
    remove_column :coach_sessions, :number_of_seats
    remove_column :coach_sessions, :attendance_count
  end
end
