class MakeSchedulesRecurring < ActiveRecord::Migration
  def self.up
    CoachAvailability.find_all_by_status(AVAILABILITY_STATUSES.index('Available')).each do |availability|
      availability.update_attribute(:status, AVAILABILITY_STATUSES.index('Scheduled'))
    end
  end

  def self.down
    # I'm afraid even this migration cannot be undone :)
  end
end
