class CreateProductLanguageLogs < ActiveRecord::Migration
  def self.up
    create_table :product_language_logs do |t|
      t.integer :support_user_id
      t.string :license_guid
      t.string :product_rights_guid
      t.string :previous_language
      t.string :changed_language
      t.text :reason

      t.timestamps
    end
  end

  def self.down
    drop_table :product_language_logs
  end
end
