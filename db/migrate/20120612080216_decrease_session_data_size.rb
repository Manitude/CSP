class DecreaseSessionDataSize < ActiveRecord::Migration
  def self.up
  	change_column :sessions, :data, :text
  end

  def self.down
  	change_column :sessions, :data, :mediumtext
  end
end
