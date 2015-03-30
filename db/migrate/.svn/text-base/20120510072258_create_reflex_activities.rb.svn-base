class CreateReflexActivities < ActiveRecord::Migration
  def self.up
    create_table :reflex_activities do |t|
      t.integer :coach_id, :null => false
      t.datetime :timestamp, :null => false
      t.string :event, :null => false
      t.timestamps
    end

    add_index :reflex_activities, :coach_id
    add_index :reflex_activities, :timestamp

  end

  def self.down
    drop_table :reflex_activities
  end
end