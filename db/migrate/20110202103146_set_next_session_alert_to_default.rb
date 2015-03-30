class SetNextSessionAlertToDefault < ActiveRecord::Migration
  def self.up
    Coach.all.each do |c|
      c.update_attributes(:next_session_alert_in => 20)
    end
  end

  def self.down
    #Irreversible - but the roof wont come down. Can be present any time.
  end
end
