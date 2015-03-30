class CoachAndManagerChanges < ActiveRecord::Migration
  def self.up
    rename_column :coaches, :manager_id, :is_manager
    change_column :coaches, :is_manager, :boolean

    create_table :coaches_managers, :id => false, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer :coach_id
      t.integer :manager_id
    end
  end

  def self.down
    rename_column :coaches, :is_manager, :manager_id
    change_column :coaches, :manager_id, :integer

    drop_table :coaches_managers
  end
end
