class FixColumnName < ActiveRecord::Migration
  def self.up
  	rename_column :coach_contacts, :support_user, :supervisor
  end

  def self.down
  end
end
