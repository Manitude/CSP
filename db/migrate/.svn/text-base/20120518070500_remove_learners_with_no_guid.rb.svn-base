class RemoveLearnersWithNoGuid < ActiveRecord::Migration
  def self.up
    execute("delete from learners where guid like '' or guid is null or user_source_type like 'Ollc::%';")
  end

  def self.down    
  end
end
