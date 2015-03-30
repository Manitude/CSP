class AddCancellationReasonToSessionMetadata < ActiveRecord::Migration
  def self.up
    add_column :session_metadata, :cancellation_reason, :string
  end

  def self.down
    remove_column :session_metadata, :cancellation_reason
  end
end
