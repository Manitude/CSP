class AddIndexToLearnersForSourceType < ActiveRecord::Migration
  def self.up
    add_index(:learners, [:user_source_id, :user_source_type], :unique => true, :name => "idx_learners_user_source")
    add_index :learners, :guid, :name => "idx_learners_guid"
    add_index :learners, :username, :name => "idx_learners_username"
  end

  def self.down
    remove_index :learners, :name => "idx_learners_user_source"
    remove_index :learners, :name => "idx_learners_guid"
    remove_index :learners, :name => "idx_learners_username"
  end
end
