class CreateRealTimeLotusDatas < ActiveRecord::Migration
  def self.up
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

  def self.down
    drop_table :real_time_lotus_datas
  end
end
