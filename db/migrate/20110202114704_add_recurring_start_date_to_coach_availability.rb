class AddRecurringStartDateToCoachAvailability < ActiveRecord::Migration
  def self.up
    add_column :coach_availabilities, :recurring_start_date, :datetime
  end

  def self.down
    remove_column :coach_availabilities, :recurring_start_date
  end
end
