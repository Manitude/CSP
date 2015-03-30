class AddColumnToCoachRecurringSchedule < ActiveRecord::Migration
  def self.up
    add_column :coach_recurring_schedules, :recurring_type, :string , :default => 'recurring_session'
    add_column :coach_recurring_schedules, :appointment_type_id, :integer
    add_column :coach_sessions, :appointment_type_id, :integer

    add_index :coach_recurring_schedules, :recurring_type
    add_index :coach_recurring_schedules, :appointment_type_id
    add_index :coach_sessions, :appointment_type_id
  end

  def self.down
    remove_index :coach_recurring_schedules, :recurring_type
    remove_index :coach_recurring_schedules, :appointment_type_id
    remove_index :coach_sessions, :appointment_type_id

    remove_column :coach_recurring_schedules, :recurring_type
    remove_column :coach_recurring_schedules, :appointment_type_id
    remove_column :coach_sessions, :appointment_type_id
  end
end
