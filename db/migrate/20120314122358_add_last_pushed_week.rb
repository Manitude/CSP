class AddLastPushedWeek < ActiveRecord::Migration
  def self.up
    add_column :languages, :last_pushed_week, :date
  end

  def self.down
    remove_column :languages, :last_pushed_week
  end
end