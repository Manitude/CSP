class AddMessageToBackgroundTasks < ActiveRecord::Migration
  def self.up
    add_column :background_tasks, :message, :text
  end

  def self.down
    remove_column :background_tasks, :message
  end
end
