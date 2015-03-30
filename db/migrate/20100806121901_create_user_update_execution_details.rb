class CreateUserUpdateExecutionDetails < ActiveRecord::Migration
  def self.up
    create_table :user_update_execution_details do |t|
      t.string :user_update_identifier, :limit => 45
      t.integer :last_processed_id
      t.datetime :started_at
      t.datetime :finished_at
    end

    add_index :user_update_execution_details, :user_update_identifier

  end

  def self.down
    drop_table :user_update_execution_details
  end
end
