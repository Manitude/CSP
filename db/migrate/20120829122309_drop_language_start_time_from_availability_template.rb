class DropLanguageStartTimeFromAvailabilityTemplate < ActiveRecord::Migration
  def self.up
    remove_column :coach_availability_templates, :language_start_time
  end

  def self.down
    add_column :coach_availability_templates, :language_start_time, :integer, :limit => 1, :default => 1
    add_index :coach_availability_templates, :language_start_time, :name => "idx_lng_st_time"
  end
end
