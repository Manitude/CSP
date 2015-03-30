class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.string :guid
      t.string :title
      t.string :description
      t.string :cefr_level
      t.integer :language
      t.boolean :selected
      t.boolean :removed , :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :topics
  end
end
