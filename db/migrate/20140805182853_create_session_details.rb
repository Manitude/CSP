class CreateSessionDetails < ActiveRecord::Migration
  def self.up
    create_table :session_details do |t|
    	t.integer :coach_session_id
    	t.text :details

      t.timestamps
    end
  end

  def self.down
    drop_table :session_details
  end
end
