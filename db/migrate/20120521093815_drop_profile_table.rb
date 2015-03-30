class DropProfileTable < ActiveRecord::Migration
  def self.up
  	drop_table :profile_photos
  end

  def self.down
  	create_table :profile_photos do |t|
      t.binary  :image_file_data, :size => 10_000_000, :null => false
      t.integer :coach_id,        :null => false
    end
    execute "ALTER TABLE `profile_photos` MODIFY `image_file_data` MEDIUMBLOB"
    add_index :profile_photos, [:coach_id], :unique => true
  end
end
