class IncreaseSessionDataSize < ActiveRecord::Migration
  def self.up
    change_column :sessions, :data, :mediumtext
  end

  def self.down
    change_column :sessions, :data, :text
  end
end
