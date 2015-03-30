class AddDailyCapToPreferenceSettings < ActiveRecord::Migration
  def self.up
    add_column :preference_settings, :daily_cap, :integer
    add_column :preference_settings, :mails_sent, :integer , :default => 0
  end

  def self.down
    remove_column :preference_settings, :daily_cap
    remove_column :preference_settings, :mails_sent
  end
end
