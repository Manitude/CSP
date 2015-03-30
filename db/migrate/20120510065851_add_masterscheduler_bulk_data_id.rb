class AddMasterschedulerBulkDataId < ActiveRecord::Migration
  def self.up 
    add_column :scheduler_metadata ,:master_scheduler_bulk_data_id , :integer
  end

  def self.down
    remove_column :scheduler_metadata ,:master_scheduler_bulk_data_id
  end
end
