class AddCancellationReasonToCoachSession < ActiveRecord::Migration
  def self.up
    add_column :coach_sessions, :cancellation_reason, :string
  end

  def self.down
    remove_column :coach_sessions, :cancellation_reason
  end
end
