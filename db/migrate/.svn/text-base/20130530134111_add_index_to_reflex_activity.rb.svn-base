class AddIndexToReflexActivity < ActiveRecord::Migration
  def self.up
  	execute("set session old_alter_table=1")
  	execute("ALTER IGNORE TABLE reflex_activities ADD UNIQUE KEY adding_composite_unique_index(timestamp,coach_id,event)")
  	execute("set session old_alter_table=0")
  end

  def self.down
  	remove_index :reflex_activities, :name => "adding_composite_unique_index"
  end
end
