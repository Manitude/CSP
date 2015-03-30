class AddLanguageStartTimeToCoachAvailabilityTemplates < ActiveRecord::Migration
  def self.up
    add_column :coach_availability_templates, :language_start_time, :integer, :limit => 1,:default => 1
  end

  def self.down
    remove_column :coach_availability_templates, :language_start_time
  end
end
