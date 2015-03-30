class CreateBoxLinks < ActiveRecord::Migration
  def self.up
    create_table :box_links do |t|
      t.string :title
      t.string :url

      t.timestamps
    end
  end

  def self.down
    drop_table :box_links
  end
end
