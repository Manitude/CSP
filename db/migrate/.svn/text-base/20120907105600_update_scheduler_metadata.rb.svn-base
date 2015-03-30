class UpdateSchedulerMetadata < ActiveRecord::Migration
  def self.up
    add_column :scheduler_metadata, :start_of_week, :datetime
    remove_column :scheduler_metadata, :master_scheduler_bulk_data_id
  end

  def self.down
    remove_column :scheduler_metadata, :start_of_week
    add_column :scheduler_metadata, :master_scheduler_bulk_data_id, :integer
  end
end
