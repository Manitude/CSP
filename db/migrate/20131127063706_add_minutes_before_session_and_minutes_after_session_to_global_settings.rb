class AddMinutesBeforeSessionAndMinutesAfterSessionToGlobalSettings < ActiveRecord::Migration
  def self.up
  	execute("INSERT INTO global_settings (attribute_name,attribute_value,description) VALUES('minutes_before_session_for_sending_email_alert', 5, 'Minutes before sessions are scheduled to start, check and see if coaches are present. For each coach not present, send an email to the coach and all Coach Supervisors');")
  	execute("INSERT INTO global_settings (attribute_name,attribute_value,description) VALUES('allow_session_creation_after', 29, 'Allowed time in minutes after session start time that a session can be created');")
  end

  def self.down
    execute("DELETE FROM global_settings WHERE attribute_name = 'allow_session_creation_after';")
    execute("DELETE FROM global_settings WHERE attribute_name = 'minutes_before_session_for_sending_email_alert';")
  end
end
