class AddSubstituteRequestedToCoachAvailabilityModifications < ActiveRecord::Migration
  def self.up
    add_column :coach_availability_modifications, :substitute_requested, :boolean, :default => false
  end

  def self.down
    remove_column :coach_availability_modifications, :substitute_requested
  end
end