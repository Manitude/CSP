class ModifyCoachAvailabilityValues < ActiveRecord::Migration
  def self.up
    CoachAvailability.connection.update("UPDATE coach_availabilities SET start_time = ADDTIME(start_time, '04:00:00'), end_time = ADDTIME(end_time, '04:00:00');")
    CoachAvailability.connection.update("UPDATE coach_availabilities SET start_time = ADDTIME(start_time, '-24:00:00'), day_index = day_index + 1 WHERE start_time >= '24:00:00';")
    CoachAvailability.connection.update("UPDATE coach_availabilities SET end_time = ADDTIME(end_time, '-24:00:00') WHERE end_time >= '24:00:00';")
    CoachAvailability.connection.update("UPDATE coach_availabilities SET day_index = 0 WHERE day_index = 7;")
  end

  def self.down
    CoachAvailability.connection.update("UPDATE coach_availabilities SET start_time = ADDTIME(start_time, '-04:00:00'), end_time = ADDTIME(end_time, '-04:00:00');")
    CoachAvailability.connection.update("UPDATE coach_availabilities SET start_time = ADDTIME(start_time, '24:00:00'), day_index = day_index - 1 WHERE start_time <= '00:00:00';")
    CoachAvailability.connection.update("UPDATE coach_availabilities SET end_time = ADDTIME(end_time, '24:00:00') WHERE end_time <= '00:00:00';")
    CoachAvailability.connection.update("UPDATE coach_availabilities SET day_index = 6 WHERE day_index = -1;")
  end
end
