class ChangeMsDraftDataSchema < ActiveRecord::Migration
  def self.up
    execute %Q[DELETE FROM ms_draft_data]
    remove_column :ms_draft_data, :external_village_id
    add_column :ms_draft_data, :last_changed_by, :integer
  end

  def self.down
    remove_column :ms_draft_data, :last_changed_by
    execute %Q[DELETE FROM ms_draft_data]
    add_column :ms_draft_data, :external_village_id, :string
  end
end
