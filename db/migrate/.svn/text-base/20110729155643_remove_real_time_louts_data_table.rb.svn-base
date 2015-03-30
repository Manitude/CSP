class RemoveRealTimeLoutsDataTable < ActiveRecord::Migration
  def self.up
    drop_table :real_time_lotus_datas
  end

  def self.down
    create_table :real_time_lotus_datas do |t|
      t.string :learners_in_dts_kle, :limit => 255
      t.string :learners_in_dts_jle, :limit => 255
      t.string :learners_waiting_kle, :limit => 255
      t.string :learners_waiting_jle, :limit => 255
      t.string :average_waiting_time_kle, :limit => 255
      t.string :average_waiting_time_jle, :limit => 255
      t.string :coaches_actually_teaching, :limit => 255
      t.string :waiting_coaches, :limit => 255
      t.string :scheduled_coaches, :limit => 255

      t.timestamps
    end
  end
end
