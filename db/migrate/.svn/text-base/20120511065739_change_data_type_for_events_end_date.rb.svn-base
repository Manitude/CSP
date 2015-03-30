class ChangeDataTypeForEventsEndDate < ActiveRecord::Migration
  def self.up
    change_table :events do |t|
      t.change :event_end_date, :date
    end
  end

  def self.down
    change_table :events do |t|
      t.change :event_end_date, :datetime
    end
  end
end
