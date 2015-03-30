class AddReasonToSubstitutions < ActiveRecord::Migration
  def self.up
  	add_column :substitutions, :reason, :text
  end

  def self.down
  	remove_column :substitutions, :reason
  end
end
