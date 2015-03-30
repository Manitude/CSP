class AddExternalVillageId < ActiveRecord::Migration
  def self.up
    add_column :coach_sessions, :external_village_id, :integer
    add_column :ms_draft_data, :external_village_id, :string
    add_column :coach_availabilities, :external_village_id, :integer
  end

  def self.down
    remove_column :coach_sessions, :external_village_id
    remove_column :ms_draft_data, :external_village_id
    remove_column :coach_availabilities, :external_village_id
  end
end
