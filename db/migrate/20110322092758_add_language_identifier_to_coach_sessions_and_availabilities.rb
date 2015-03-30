class AddLanguageIdentifierToCoachSessionsAndAvailabilities < ActiveRecord::Migration
  def self.up
    add_column :coach_sessions, :language_identifier, :string
    add_column :coach_availabilities, :recurring_language_identifier, :string
  end

  def self.down
    remove_column :coach_sessions, :language_identifier
    remove_column :coach_availabilities, :recurring_language_identifier
  end
end
