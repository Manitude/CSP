class CreateSessionMetadata < ActiveRecord::Migration
  def self.up
    create_table :session_metadata do |t|
      t.integer :coach_session_id , :null => false
      t.boolean :teacher_confirmed, :default => true
      t.integer :lessons
      t.boolean :recurring , :default => false
  end
  end

  def self.down
    drop_table :session_metadata
  end
end
