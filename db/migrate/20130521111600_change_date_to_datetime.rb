class ChangeDateToDatetime < ActiveRecord::Migration
  def self.up
  	execute("ALTER TABLE events MODIFY COLUMN event_start_date DATETIME")
    execute("ALTER TABLE events MODIFY COLUMN event_end_date DATETIME")
    execute("UPDATE events SET event_start_date = ADDTIME(event_start_date, '05:00:00.00'), event_end_date = ADDTIME(event_end_date, '05:00:00.00')")
    execute("ALTER TABLE announcements MODIFY COLUMN expires_on DATETIME")
    execute("UPDATE announcements SET expires_on = ADDTIME(expires_on, '05:00:00.00')")
  end

  def self.down
    execute("ALTER TABLE events MODIFY COLUMN event_start_date DATE")
    execute("ALTER TABLE events MODIFY COLUMN event_end_date DATE")
    execute("ALTER TABLE announcements MODIFY COLUMN expires_on DATE")
  end
end
