class RangedChunkAgents < ActiveRecord::Migration
  def self.up
    create_table :ranged_chunk_agents, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.string :agent_class, :unique => true, :null => false
      t.boolean :enabled
      t.integer :chunk_size 
      t.integer :chunks
      t.integer :interval
      t.integer :cursor
      t.timestamp :last_processed_timestamp
      t.timestamp :created_at, :null => false
      t.timestamp :updated_at, :null => false
    end
    #add_index :ranged_chunk_agents, :timestamp
  end

  def self.down
    drop_table :ranged_chunk_agents
  end
end
