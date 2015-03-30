class AddRevisionIdToTopics < ActiveRecord::Migration
  def self.up
  	add_column :topics, :revision_id, :string, :default => "NA"
  end

  def self.down
  	remove_column :topics, :revision_id
  end
end
