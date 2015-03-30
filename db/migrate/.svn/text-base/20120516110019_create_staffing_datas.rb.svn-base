class CreateStaffingDatas < ActiveRecord::Migration
  def self.up
    create_table :staffing_datas do |t|
      t.datetime :slot_time, :unique => true
      t.integer  :number_of_coaches, :default => 0
      t.integer  :staffing_file_info_id

      t.timestamps
    end
  end

  def self.down
    drop_table :staffing_datas
  end
end
