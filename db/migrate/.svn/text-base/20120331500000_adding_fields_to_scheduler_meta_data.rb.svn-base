class AddingFieldsToSchedulerMetaData < ActiveRecord::Migration
  def self.up
    add_column :scheduler_metadata ,:total_sessions_to_be_created , :integer , :default => 0
    add_column :scheduler_metadata ,:successfully_created_sessions , :integer, :default => 0
    add_column :scheduler_metadata ,:error_sessions , :integer, :default => 0
  end

  def self.down
    remove_column :scheduler_metadata ,:total_sessions_to_be_created
    remove_column :scheduler_metadata ,:successfully_created_sessions
    remove_column :scheduler_metadata ,:error_sessions 
  end
end
