class UpdateTypeForCoachSession < ActiveRecord::Migration
  def self.up
    CoachSession.update_all("type = 'ConfirmedSession'", "type is NULL")
  end

  def self.down
    CoachSession.update_all("type = NULL", "type = 'ConfirmedSession'")
  end
end
