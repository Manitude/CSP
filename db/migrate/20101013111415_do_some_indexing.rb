class DoSomeIndexing < ActiveRecord::Migration
  def self.up
    add_index :coach_availability_templates, :coach_id
    add_index :coach_availabilities, :coach_availability_template_id
  end

  def self.down
    remove_index :coach_availabilities, :coach_availability_template_id
    remove_index :coach_availability_templates, :coach_id
  end
end
