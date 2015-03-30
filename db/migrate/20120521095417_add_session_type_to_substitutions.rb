class AddSessionTypeToSubstitutions < ActiveRecord::Migration
  def self.up
    add_column :substitutions, :session_type, :string, :default => 'normal'
  end

  def self.down
    remove_column :substitutions, :session_type
  end
end
