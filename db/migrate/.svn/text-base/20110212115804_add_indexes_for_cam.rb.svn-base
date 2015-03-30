class AddIndexesForCam < ActiveRecord::Migration
  def self.up
    add_index :coach_availability_modifications, :start_date, :name => "idx_coach_availability_modifications_start_date"
    add_index :coach_availability_modifications, :end_date, :name => "idx_coach_availability_modifications_end_date"
    execute "alter table temp_data change data data mediumblob"
  end

  def self.down
    execute "alter table temp_data change data data blob"
    remove_index :coach_availability_modifications, :name => "idx_coach_availability_modifications_end_date"
    remove_index :coach_availability_modifications, :name => "idx_coach_availability_modifications_start_date"
  end
end
