class CreateStaffingFileInfos < ActiveRecord::Migration
  def self.up
    create_table :staffing_file_infos do |t|
      t.datetime :start_of_the_week, :null => false
      t.string   :file_name, :null => false
      t.integer  :manager_id, :null => false
      t.string   :status
      t.integer  :records_created, :default => 0
      t.string   :messages 
      t.binary   :file, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :staffing_file_infos
  end
end
