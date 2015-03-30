class CreateCronAndRakeTaskTracer < ActiveRecord::Migration
  def self.up
    create_table :task_tracer do |t|
      t.string   :task_name
      t.boolean  :is_running_now, :default => false
      t.datetime :last_successful_run
      t.timestamps
    end
  end

  def self.down
    drop_table :task_tracer
  end
end
