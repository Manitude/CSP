class RenameExtensionGuidColumnOnRightsExtensionLog < ActiveRecord::Migration
  def self.up
    rename_column :rights_extension_logs, :extension_guid, :extendable_guid
  end

  def self.down
    rename_column :rights_extension_logs, :extendable_guid, :extension_guid
  end
end
