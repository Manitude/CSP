class RefactoredSchema < ActiveRecord::Migration
  def self.up
    rename_table :coach_availability_modifications, :coach_availability_modifications_backup_20110530

    create_table :unavailable_despite_templates, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  :coach_id
      t.datetime :start_date
      t.datetime :end_date
      t.integer  :unavailability_type, :limit => 1, :default => 0 #Type of unavailability [ 0 - Time off , 1 - Substitute Requested, 2 - Substitute Triggered]
      t.text     :comments
      t.integer  :approval_status, :limit => 1, :default => 0 # 0 - Pending approval , 1 - approved, 2 - Rejected
      t.integer  :coach_session_id

      t.timestamps
    end
    add_index :unavailable_despite_templates, :coach_id, :name => "idx_unavailable_despite_template_coach_id"
    add_index :unavailable_despite_templates, :approval_status, :name => "idx_unavailable_despite_template_approval_status"
    add_index :unavailable_despite_templates, :start_date, :name => "idx_unavailable_despite_template_start_date"
    add_index :unavailable_despite_templates, :end_date, :name => "idx_unavailable_despite_template_end_date"

    create_table :coach_recurring_schedules, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  :coach_id, :null => false
      t.integer  :day_index,       :limit => 1,        :null => false
      t.time     :start_time,      :null => false
      t.datetime :recurring_start_date, :null => false
      t.datetime :recurring_end_date
      t.integer  :language_id, :null => false
      t.integer  :external_village_id

      t.timestamps
    end

    rename_table :coach_availabilities, :coach_availabilities_backup_20110530

    create_table :coach_availabilities, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.belongs_to  :coach_availability_template, :null => false
      t.integer     :day_index,       :limit => 1,        :null => false
      t.time        :start_time,      :null => false
      t.time        :end_time,        :null => false

      t.timestamps
    end
    add_index :coach_availabilities, :coach_availability_template_id,:name => "idx_coach_availabilities_coach_availability_template_id"

    execute("INSERT INTO coach_availabilities (id,coach_availability_template_id, day_index, start_time, end_time, created_at, updated_at)
             SELECT id,coach_availability_template_id, day_index, start_time, end_time, created_at, updated_at FROM coach_availabilities_backup_20110530 ca
              where ca.status != 2;")

    rename_column :coach_availability_templates,  :approval_status, :status # [0 - Draft, 1 - Auto_approved]

    add_column :substitutions, :grabbed_at, :datetime
    #remove_column :substitutions, :lang_id # We will remove this column in the next sprint.This is to avoid data loss if we decide to revert chunky monkey changes
    execute("UPDATE substitutions set grabbed_at = updated_at where grabbed = 1;")
    execute("UPDATE notifications set target_type = 'UnavailableDespiteTemplate' where target_type = 'CoachAvailabilityModification';")

    create_table :manual_cancellations, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  :coach_session_id

      t.timestamps
    end

  end

  def self.down
    drop_table :unavailable_despite_templates
    rename_table :coach_availability_modifications_backup_20110530, :coach_availability_modifications
    drop_table :coach_recurring_schedules
    drop_table :coach_availabilities
    rename_table :coach_availabilities_backup_20110530, :coach_availabilities
    rename_column :coach_availability_templates, :status,  :approval_status
    remove_column :substitutions, :grabbed_at
    #add_column :substitutions, :lang_id, :integer
    execute("UPDATE notifications set target_type = 'CoachAvailabilityModification' where target_type = 'UnavailableDespiteTemplate';")
    drop_table :manual_cancellations
  end
end
