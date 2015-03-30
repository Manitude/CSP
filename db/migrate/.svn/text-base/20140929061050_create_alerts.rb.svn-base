class CreateAlerts < ActiveRecord::Migration
  def self.up
    create_table :alerts do |t|

      t.text :description
      t.string :created_by
      t.boolean :active , :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :alerts
  end
end
