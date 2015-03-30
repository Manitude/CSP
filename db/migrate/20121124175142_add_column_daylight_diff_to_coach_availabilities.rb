class AddColumnDaylightDiffToCoachAvailabilities < ActiveRecord::Migration
  def self.up
    add_column :coach_availabilities,:daylight_diff, :integer
  end

  def self.down
    remove_column :coach_availabilities,:daylight_diff
  end
end
