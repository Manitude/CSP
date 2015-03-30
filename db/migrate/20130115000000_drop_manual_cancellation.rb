class DropManualCancellation < ActiveRecord::Migration

  def self.up
    drop_table :manual_cancellations
  end

  def self.down
    create_table :manual_cancellations do |t|
      t.integer  :coach_session_id
      
      t.timestamps
    end
  end

end
