class CreateResources < ActiveRecord::Migration
  def self.up
    create_table :resources do |t|
      t.string  :title
      t.text    :description
      t.integer :size
      t.string  :content_type
      t.string  :filename
      t.column :db_file_id, :integer
      t.timestamps
    end

   create_table :db_files do |t|
    t.column :data, :binary
   end

  end

  def self.down
    drop_table :resources
    drop_table :db_files
  end
end
