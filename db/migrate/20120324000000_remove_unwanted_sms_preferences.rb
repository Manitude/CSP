class RemoveUnwantedSmsPreferences < ActiveRecord::Migration
  def self.up
    execute("create table preference_settings_backup_20111219_2012 LIKE preference_settings;")
    execute("INSERT INTO preference_settings_backup_20111219_2012 SELECT * FROM preference_settings;")
    remove_column :preference_settings, :substitution_alerts_sms_sending_schedule, :notifications_sms, :notifications_sms_sending_schedule, :calendar_notices_sms, :calendar_notices_sms_sending_schedule
    execute("create table cm_preferences_backup_20111219_2012 LIKE cm_preferences;")
    execute("INSERT INTO cm_preferences_backup_20111219_2012 SELECT * FROM cm_preferences;")
    remove_column :cm_preferences, :sms_alert_enabled
  end

  def self.down
    drop_table :cm_preferences
    rename_table :cm_preferences_backup_20111219_2012, :cm_preferences
    drop_table :preference_settings
    rename_table :preference_settings_backup_20111219_2012, :preference_settings
  end
end
