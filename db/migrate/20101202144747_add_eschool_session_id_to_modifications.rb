class AddEschoolSessionIdToModifications < ActiveRecord::Migration
#This migration is needed due to requirement where a  coach is allowed to take time-off for a single session without manager's approval.
#The manager can see that a session is without a coach and assign a substitute. In order to track the sessions which was abandoned We need this data in the modifications.
  def self.up
    add_column :coach_availability_modifications, :eschool_session_id, :integer
  end

  def self.down
    remove_column :coach_availability_modifications, :eschool_session_id
  end
end
