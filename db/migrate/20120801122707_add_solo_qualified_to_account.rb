class AddSoloQualifiedToAccount < ActiveRecord::Migration
  def self.up
  	add_column :accounts, :solo_qualified, :boolean
  end

  def self.down
  	remove_column :accounts, :solo_qualified
  end
end
