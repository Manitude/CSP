class AddNoOfSeatsToCoachRecurringSchedules < ActiveRecord::Migration
  def self.up
    add_column :coach_recurring_schedules, :number_of_seats, :integer, :default => 4
    execute("UPDATE coach_recurring_schedules SET number_of_seats = 4")
  end

  def self.down
    remove_column :coach_recurring_schedules, :number_of_seats
  end
end
