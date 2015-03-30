class CreateManagementTeamMembers < ActiveRecord::Migration
  def self.up
    create_table :management_team_members do |t|
		t.string :name, :limit => 255
		t.string :title, :limit => 255
		t.string :phone_cell, :limit => 255
		t.string :phone_desk, :limit => 255
		t.string :email, :limit => 255
		t.string :image_file_name, :limit => 255
		t.string :image_content_type, :limit => 255
		t.integer :image_file_size
		t.boolean :hide, :default => false
		t.integer :position
		t.text :bio

      	t.timestamps
    end
  	execute 'ALTER TABLE management_team_members ADD COLUMN image_file LONGBLOB'
  end

  def self.down
    drop_table :management_team_members
  end
end
