class RemoveNonOeLanguages < ActiveRecord::Migration
  def self.up
    execute "DELETE FROM languages WHERE identifier IN ('CYM', 'DAN', 'IND', 'KIS', 'LAT', 'PAS', 'THA')"
  end

  def self.down
    ['DAN', 'IND', 'KIS', 'LAT', 'PAS', 'THA'].each do |lang_identifier|
      execute "INSERT INTO languages (identifier, created_at) VALUES ('#{lang_identifier}', NOW());"
    end
  end
end
