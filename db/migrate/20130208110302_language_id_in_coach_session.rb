class LanguageIdInCoachSession < ActiveRecord::Migration
  def self.up
  	add_column :coach_sessions, :language_id, :integer, :null => false
  	execute "UPDATE coach_sessions cs INNER JOIN languages l ON cs.language_identifier = l.identifier SET cs.language_id = l.id"
  end

  def self.down
  	remove_column :coach_sessions, :language_id
  end
end
