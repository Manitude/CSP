class UpdateCoachAvailabiltyTemplatesAddColumnDeleted < ActiveRecord::Migration
  def self.up
    add_column :coach_availability_templates, :deleted, :boolean, :default=>false
  end

  def self.down
    remove_column :coach_availability_templates, :deleted
  end
end
