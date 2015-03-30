class CreateMsBulkData < ActiveRecord::Migration
  def self.up
    create_table :master_scheduler_bulk_data do |t|
      t.string :language_identifier
      t.date :start_of_the_week
      t.binary :bulk_data, :limit => 4.megabytes
      t.timestamps
    end
  end

  def self.down
    drop_table :master_scheduler_bulk_data
  end
end
