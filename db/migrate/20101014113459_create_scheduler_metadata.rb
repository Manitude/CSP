class CreateSchedulerMetadata < ActiveRecord::Migration
  def self.up
    create_table :scheduler_metadata do |t|
      t.boolean :locked
      t.string :lang_identifier
      t.integer :total_sessions, :default => 0
      t.integer :completed_sessions, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :scheduler_metadata
  end
end