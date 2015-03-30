class CreateCoachContacts < ActiveRecord::Migration
  def self.up
    create_table :coach_contacts do |t|
      t.integer :coach_id
      t.string :coach_manager
      t.string :support_user

      t.timestamps
    end

    Coach.all.each do |coach|
      coach.create_coach_contact(:coach_manager => coach.manager.full_name) if coach.manager
    end

  end

  def self.down
    drop_table :coach_contacts
  end
end
