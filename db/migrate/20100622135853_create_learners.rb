class CreateLearners < ActiveRecord::Migration
  def self.up
    create_table :learners do |t|
      t.string :first_name, :limit => 255
      t.string :last_name, :limit => 255
      t.string :email, :limit => 255
      t.string :mobile_number, :limit => 255
      t.string :mobile_number_at_activation, :limit => 255
      t.string :preferred_name, :limit =>255
      t.string :state_province, :limit => 255
      t.string :city, :limit => 255
      t.string :guid, :limit => 255
      t.string :username, :limit => 255
      t.integer :user_source_id, :limit => 11
      t.string :user_source_type, :limit => 255
      t.boolean :totale, :default => false
      t.boolean :rworld, :default => false
      t.boolean :osub, :default => false
      t.boolean :osub_active, :default => false
      t.boolean :totale_active, :default => false
      t.boolean :enterprise_license_active, :default => false
      t.boolean :parature_customer, :default => false
      t.text :previous_license_identifiers

      t.timestamps
    end
  end

  def self.down
    drop_table :learners
  end
end
