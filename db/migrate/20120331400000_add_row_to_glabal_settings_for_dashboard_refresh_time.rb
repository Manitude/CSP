class AddRowToGlabalSettingsForDashboardRefreshTime < ActiveRecord::Migration
  def self.up
    execute("insert into global_settings (attribute_name,attribute_value,description)values('seconds_to_refresh_live_sessions_in_dashboard',30,'Frequency in which dashboard has to be refreshed on selection of live data');")
  end

  def self.down
    execute("DELETE FROM global_settings WHERE attribute_name = 'seconds_to_refresh_live_sessions_in_dashboard';")
  end
end
