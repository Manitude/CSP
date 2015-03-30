class AddConsumableLogs < ActiveRecord::Migration
  def self.up
    create_table :add_consumable_logs do |t|
      t.integer :support_user_id, :null => false
      t.string :license_guid, :null => false
      t.string :reason, :null => false
      t.string :consumable_guid, :null => false
      t.string :case_number, :null => false
      t.string :consumable_type
      t.string :pooler_guid
      t.string :pooler_type

      t.timestamps
    end
  end

  def self.down
    drop_table :add_consumable_logs
  end
end
