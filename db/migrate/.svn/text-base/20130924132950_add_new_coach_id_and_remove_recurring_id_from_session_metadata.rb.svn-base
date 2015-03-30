class AddNewCoachIdAndRemoveRecurringIdFromSessionMetadata < ActiveRecord::Migration
  def self.up
  	remove_column :session_metadata, :recurring_id
  	add_column :session_metadata, :new_coach_id, :integer
  end

  def self.down
  	remove_column :session_metadata, :new_coach_id
  	add_column :session_metadata, :recurring_id, :integer
  end
end
