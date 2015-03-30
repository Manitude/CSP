class CreateSubstitutions < ActiveRecord::Migration
  def self.up
    create_table :substitutions, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  :coach_id
      t.integer  :grabber_coach_id
      t.boolean  :grabbed
      t.integer  :lang_id
      t.integer  :eschool_session_id
      t.datetime :substitution_date

      t.timestamps
    end

    add_index :substitutions, :coach_id
    add_index :substitutions, :eschool_session_id
  end

  def self.down
    drop_table :substitutions
  end
end