class TypeForCoachSessionMandatory < ActiveRecord::Migration
  def self.up
    change_column :coach_sessions, :type, :string, :null => false, :default => 'LocalSession'
  end

  def self.down
    change_column :coach_sessions, :type, :string, :null => true, :default => nil
  end
end
