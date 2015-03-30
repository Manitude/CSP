class CreateLocosDatas < ActiveRecord::Migration
  def self.up
    create_table :locos_datas do |t|
      t.integer  :dts_learners_count
      t.datetime :last_call_to_locos
    end
  end

  def self.down
    drop_table :locos_datas
  end
end
