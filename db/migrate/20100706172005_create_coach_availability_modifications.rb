class CreateCoachAvailabilityModifications < ActiveRecord::Migration
  def self.up
    drop_table :coach_availability_exceptions

    create_table :coach_availability_modifications, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  :coach_id
      t.datetime :start_date
      t.datetime :end_date
      t.integer  :availability_status, :limit => 1
      t.text     :comments
      t.boolean  :approved

      t.timestamps
    end

    add_index :coach_availability_modifications, :coach_id
    add_index :coach_availability_modifications, :approved
  end

  def self.down
    drop_table :coach_availability_modifications
    # no need to create 'coach_availability_exceptions'. It's not used anywhere
  end
end
