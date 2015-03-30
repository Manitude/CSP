class MakeMgmtTableUnicodeFriendly < ActiveRecord::Migration
  def self.up
  	execute "ALTER TABLE management_team_members CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci"
  end

  def self.down
  end
end
