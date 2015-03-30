class AddExtendableInfoToRightsExtensionLog < ActiveRecord::Migration
  def self.up
    add_column :rights_extension_logs, :duration, :string
    add_column :rights_extension_logs, :extendable_created_at, :datetime
    add_column :rights_extension_logs, :extendable_ends_at, :datetime
  end

  def self.down
    remove_column :rights_extension_logs, :extendable_ends_at
    remove_column :rights_extension_logs, :extendable_created_at
    remove_column :rights_extension_logs, :duration
  end
end
