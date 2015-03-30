class CreateRightsExtensionLogs < ActiveRecord::Migration
  def self.up
    create_table :rights_extension_logs do |t|
      t.integer :support_user_id
      t.string :license_guid
      t.string :reason
      t.string :extension_guid

      t.timestamps
    end
  end

  def self.down
    drop_table :rights_extension_logs
  end
end
