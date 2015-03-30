class CreateBackgroundTasks < ActiveRecord::Migration
  def self.up
    create_table :background_tasks do |t|
      t.integer  :referer_id
      t.string   :state
      t.string   :error
      t.string   :background_type
      t.datetime :job_start_time
      t.datetime :job_end_time
      t.string   :triggered_by
      t.boolean  :locked, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :background_tasks
  end
end