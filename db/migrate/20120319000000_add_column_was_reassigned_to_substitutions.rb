class AddColumnWasReassignedToSubstitutions < ActiveRecord::Migration
  def self.up
    add_column :substitutions, :was_reassigned, :boolean, :default => false
  end

  def self.down
    remove_column :substitutions, :was_reassigned
  end
end
