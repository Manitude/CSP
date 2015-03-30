class AddLastChunkingTimeToRangedChunkAgents < ActiveRecord::Migration
  def self.up
    add_column :ranged_chunk_agents, :last_chunking_time, :integer
  end

  def self.down
    remove_column :ranged_chunk_agents, :last_chunking_time
  end
end
