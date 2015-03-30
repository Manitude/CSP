class AddTimeoffRequestEmailToPreferenceSetting < ActiveRecord::Migration
  def self.up
    add_column :preference_settings, :timeoff_request_email, :integer
    add_column :preference_settings, :timeoff_request_email_type, :string
  end

  def self.down
    remove_column :preference_settings, :timeoff_request_email
    remove_column :preference_settings, :timeoff_request_email_type
  end
end
