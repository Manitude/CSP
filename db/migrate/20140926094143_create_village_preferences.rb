class CreateVillagePreferences < ActiveRecord::Migration
  def self.up
    create_table :village_preferences do |t|
      t.integer :village_id
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :village_preferences
  end
end