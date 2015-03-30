class DropLocosDatas < ActiveRecord::Migration
  def self.up
     drop_table :locos_datas
  end

  def self.down
    create_table :locos_datas do |t|
      t.integer  :dts_learners_count
      t.datetime :last_call_to_locos
    end
  end
end
