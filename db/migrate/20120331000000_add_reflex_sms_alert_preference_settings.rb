class AddReflexSmsAlertPreferenceSettings < ActiveRecord::Migration
  def self.up
    add_column :cm_preferences, :receive_reflex_sms_alert, :boolean, :default => false
  end

  def self.down
    remove_column :cm_preferences, :receive_reflex_sms_alert
  end
end
