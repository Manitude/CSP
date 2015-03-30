class QualificationChanges < ActiveRecord::Migration
  def self.up
    rename_column :qualifications, :max_level_id, :max_unit
  end

  def self.down
    rename_column :qualifications, :max_unit, :max_level_id
  end
end
