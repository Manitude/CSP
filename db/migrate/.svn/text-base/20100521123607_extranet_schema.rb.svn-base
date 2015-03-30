class ExtranetSchema < ActiveRecord::Migration
  def self.up
    create_table :events, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.text :event_description
      t.string :event_name
      t.date :event_start_date
      t.datetime :event_end_date
      t.belongs_to :language
      t.integer :region_id

      t.timestamps
    end
    add_index :events, :event_name
    add_index :events, :language_id
    add_index :events, :created_at

    create_table :announcements, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.text :body
      t.string :subject
      t.date :expires_on
      t.belongs_to :language
      t.integer :region_id
      t.string :language_name
      t.timestamps
    end
    add_index :announcements, :subject
    add_index :announcements, :expires_on
    add_index :announcements, :region_id
    add_index :announcements, :language_id
    add_index :announcements, :language_name
    add_index :announcements, :created_at

 end

  def self.down
    drop_table :events
    drop_table :announcements
  end
end
