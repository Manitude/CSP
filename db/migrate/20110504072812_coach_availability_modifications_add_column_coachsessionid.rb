class CoachAvailabilityModificationsAddColumnCoachsessionid < ActiveRecord::Migration
  def self.up
    add_column :coach_availability_modifications,:coach_session_id, :integer, :limit => 3
  end

  def self.down
    remove_column :coach_availability_modifications, :coach_session_id
  end
end
