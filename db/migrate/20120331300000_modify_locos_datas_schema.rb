class ModifyLocosDatasSchema < ActiveRecord::Migration
  def self.up
    add_column    :locos_datas, :api_type, :string
    add_column    :locos_datas, :data, :text, :limit => 4.megabytes
    remove_column :locos_datas, :dts_learners_count
    change_column_default :locos_datas, :last_call_to_locos, "2010-01-01 00:00:00"
    # Just making sure that the default is < Time.now + 30.seconds
  end

  def self.down
    add_column    :locos_datas, :dts_learners_count, :integer
    remove_column :locos_datas, :data
    remove_column :locos_datas, :api_type
    change_column_default :locos_datas, :last_call_to_locos, "2010-01-01 00:00:00"
  end
end
