class AddRowToGlobalSettingToCustomizeTimeLimitForSessionCreation < ActiveRecord::Migration
  def self.up
  	execute("insert into global_settings (attribute_name,attribute_value,description)values('allow_session_creation_before', 20, 'Allowed time in minutes before which a session can be created');")
  end

  def self.down
    execute("DELETE FROM global_settings WHERE attribute_name = 'allow_session_creation_before';")
  end
end
