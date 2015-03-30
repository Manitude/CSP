class AddColumnsToManagementTeamMembers < ActiveRecord::Migration
  def self.up
  	add_column :management_team_members, :on_duty, :boolean, :default => false
    add_column :management_team_members, :available_start, :time
    add_column :management_team_members, :available_end, :time 
  end

  def self.down
  	remove_column :management_team_members, :on_duty 
    remove_column :management_team_members, :available_start
    remove_column :management_team_members, :available_end
  end
end
