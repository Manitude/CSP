class CreateMasterSchedulerDraft < ActiveRecord::Migration
  def self.up
    create_table :ms_draft_data do |t|
      t.binary    :data, :limit => 1.megabytes
      t.datetime  :start_of_week
      t.string    :lang_identifier

      t.timestamps
    end
  end

  def self.down
    drop_table    :ms_draft_data
  end
end
