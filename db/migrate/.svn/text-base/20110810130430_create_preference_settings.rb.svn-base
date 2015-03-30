class CreatePreferenceSettings < ActiveRecord::Migration
  def self.up
    create_table :preference_settings do |t|
      t.integer :substitution_alerts_email
      t.string :substitution_alerts_email_type
      t.string :substitution_alerts_email_sending_schedule
      t.integer :substitution_alerts_sms
      t.string :substitution_alerts_sms_sending_schedule
      t.integer :no_of_substitution_alerts_to_display
      t.integer :substitution_alerts_display_time
      t.integer :notifications_email
      t.string :notifications_email_type
      t.string :notifications_email_sending_schedule
      t.integer :notifications_sms
      t.string :notifications_sms_sending_schedule
      t.integer :calendar_notices_email
      t.string :calendar_notices_email_type
      t.string :calendar_notices_email_sending_schedule
      t.integer :calendar_notices_sms
      t.string :calendar_notices_sms_sending_schedule
      t.integer :session_alerts_display_time
      t.string :start_page
      t.integer :account_id
      t.string :default_language_for_master_scheduler
      t.integer :no_of_home_announcements
      t.integer :no_of_home_events
      t.integer :no_of_home_notifications
      t.integer :no_of_learner_dashboard_records
      t.integer :no_of_notifications_to_display
      t.integer :notifications_display_time
      t.integer :no_of_calendar_notices_to_display
      t.integer :calendar_notices_display_time

      t.timestamps
    end
  end

  def self.down
    drop_table :preference_settings
  end
end
