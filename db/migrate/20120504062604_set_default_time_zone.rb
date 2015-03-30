class SetDefaultTimeZone < ActiveRecord::Migration
  def self.up
    change_column_default(:accounts, :time_zone, 'Eastern Time (US & Canada)')
    Account.update_all("time_zone = 'Eastern Time (US & Canada)'", "time_zone IS NULL")
  end

  def self.down
    change_column_default(:accounts, :time_zone, nil)
  end
end