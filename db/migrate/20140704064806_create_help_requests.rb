class CreateHelpRequests < ActiveRecord::Migration
  def self.up
    create_table :help_requests do |t|
      t.string :role
      t.string :user_id
      t.integer :external_session_id

      t.timestamps
    end
  end

  def self.down
    drop_table :help_requests
  end
end
