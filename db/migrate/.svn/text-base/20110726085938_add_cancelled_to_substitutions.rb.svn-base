class AddCancelledToSubstitutions < ActiveRecord::Migration
  def self.up
    add_column :substitutions, :cancelled, :boolean, :default => false
  end

  def self.down
    remove_column :substitutions, :cancelled
  end
end
