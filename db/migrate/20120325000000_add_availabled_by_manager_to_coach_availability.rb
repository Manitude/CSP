class AddAvailabledByManagerToCoachAvailability < ActiveRecord::Migration
  # US368
  # When a CM tries to create a recurring session on an unavailable slot, set this flag
  # and put the id of coach_recurring_schedules in the recurring_id
  def self.up
    add_column :coach_availabilities, :availabled_by_manager, :boolean, :default => false
    add_column :coach_availabilities, :recurring_id, :integer, :default => nil
  end

  def self.down
    remove_column :coach_availabilities, :availabled_by_manager
    remove_column :coach_availabilities, :recurring_id
  end
end
