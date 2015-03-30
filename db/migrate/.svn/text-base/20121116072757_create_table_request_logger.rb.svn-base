class CreateTableRequestLogger < ActiveRecord::Migration
  def self.up
    create_table :request_logger do |t|
      t.string :user_name, :null => false
      t.string :url, :null => false
      t.datetime :time_zone, :null => false
      t.string :method, :null => false
      t.datetime :request_time, :null => false
      t.string :user_agent, :null => false
      t.string :ip_address, :null => false
    end
  end

  def self.down
    drop_table :request_logger
  end
end
