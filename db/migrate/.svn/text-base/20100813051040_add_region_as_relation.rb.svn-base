class AddRegionAsRelation < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :region
    add_column :accounts, :region_id, :integer
  end

  def self.down
    remove_column :accounts, :region_id
    add_column :accounts, :region, :string
  end
end
