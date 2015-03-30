class AddActionAndUpdatedExtendableEndsAtToRightsExtensionLog < ActiveRecord::Migration
  def self.up
    add_column :rights_extension_logs, :action, :string
    add_column :rights_extension_logs, :updated_extendable_ends_at, :datetime
  end

  def self.down
    remove_column :rights_extension_logs, :action
    remove_column :rights_extension_logs, :updated_extendable_ends_at
  end
end
