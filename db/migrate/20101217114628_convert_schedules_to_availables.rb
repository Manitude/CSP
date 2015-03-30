# Deletes all current available slots.
# then, changes all schedule slots to available.
# Previously, the coach could enter his availability as "Scheduled", "Available" or "Unavailable"
# Now, the approach is simpler.
# Coach can enter his availability either as "Available" or "Unavailable".

# *Coming_Soon*: The total absence of the state "Scheduled"
# A migration that'll change all "Schedules" to "Available" in coach_availability_modifications table
# But that happens after the release on 01/05

class ConvertSchedulesToAvailables < ActiveRecord::Migration
  def self.up
    # Part I - Delete all available slots
    CoachAvailability.find_all_by_status(AVAILABILITY_STATUSES.index('Available')).each {|availability| availability.destroy}
    #
    # Part - II - Change all Schedule slots to Available
    CoachAvailability.find_all_by_status(AVAILABILITY_STATUSES.index('Scheduled')).each do |availability|
      availability.update_attribute(:status, AVAILABILITY_STATUSES.index('Available'))
    end
  end

  def self.down
    # I'm afraid this migration cannot be undone :)
  end
end
