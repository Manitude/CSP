class CreateCoachSession < ActiveRecord::Migration
  def self.up
    create_table :coach_sessions, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.string   :coach_user_name
      t.integer  :eschool_session_id
      t.datetime :session_start_time

      t.timestamps
    end

    add_index     :coach_sessions, :coach_user_name
    rename_column :substitutions,  :eschool_session_id, :coach_session_id
  end

  def self.down
    rename_column :substitutions,  :coach_session_id, :eschool_session_id
    drop_table    :coach_sessions
  end
end
