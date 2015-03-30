class AlterColumnLastPushedWeek < ActiveRecord::Migration
  def self.up
    change_column :languages, :last_pushed_week, :datetime , :default => "#{Time.now.to_s(:db)}"
   Language.connection.update("UPDATE languages SET last_pushed_week = CURRENT_TIMESTAMP WHERE last_pushed_week IS NULL;")
  end

  def self.down
    Language.connection.update("UPDATE languages SET last_pushed_week = NULL;")
    change_column :languages, :last_pushed_week, :date
  end
end
