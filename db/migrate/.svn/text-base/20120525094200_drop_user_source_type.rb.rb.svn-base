class DropUserSourceType < ActiveRecord::Migration
  def self.up
    remove_index    :learners, :name => "idx_learners_user_source"
    remove_column   :learners, :user_source_id
  end

  def self.down
    add_column      :learners, :user_source_id, :integer
    add_index       :learners, [:user_source_id, :user_source_type], :unique => true, :name => "idx_learners_user_source"
  end
end
