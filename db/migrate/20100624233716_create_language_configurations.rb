class CreateLanguageConfigurations < ActiveRecord::Migration
  def self.up
    create_table :language_configurations, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  :language_id
      t.integer  :session_start_time, :limit => 1
      t.integer  :created_by
      t.datetime :created_at
    end

    add_index :language_configurations, :language_id
  end

  def self.down
    drop_table :language_configurations
  end
end
