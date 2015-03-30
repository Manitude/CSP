class AddColumnCoachShowedUpAndSecondsPriorToSessionToCoachSessions < ActiveRecord::Migration
  def self.up
    add_column :coach_sessions, :coach_showed_up, :boolean, :default => false
    add_column :coach_sessions, :seconds_prior_to_session, :integer
  end

  def self.down
    remove_column :coach_sessions, :coach_showed_up
    remove_column :coach_sessions, :seconds_prior_to_session
  end
end
