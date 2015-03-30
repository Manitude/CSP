class CreateCmPreferences < ActiveRecord::Migration
  def self.up
    create_table :cm_preferences do |t|
      t.integer :account_id
      t.integer :min_time_to_alert_for_session_with_no_coach, :default => 2
      t.boolean :sms_alert_enabled, :default => false
      t.boolean :email_alert_enabled, :default => false
      t.string  :email_preference
      t.boolean :page_alert_enabled, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :cm_preferences
  end
end
