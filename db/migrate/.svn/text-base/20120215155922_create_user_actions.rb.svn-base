class CreateUserActions < ActiveRecord::Migration
  def self.up
    create_table :user_actions do |t|
      t.string :user_name
      t.string :user_role
      t.text :action
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :user_actions
  end
end
