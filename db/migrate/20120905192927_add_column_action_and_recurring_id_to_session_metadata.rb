class AddColumnActionAndRecurringIdToSessionMetadata < ActiveRecord::Migration
  def self.up
  	add_column :session_metadata, :recurring_id, :integer
  	add_column :session_metadata, :action, :string
  end

  def self.down
  	remove_column :session_metadata, :recurring_id
  	remove_column :session_metadata, :action
  end
end
