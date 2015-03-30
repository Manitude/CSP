class CreateTempData < ActiveRecord::Migration
  def self.up
    create_table :temp_data do |t|
      t.binary  :data, :limit => 1.megabytes
      t.boolean :done

      t.timestamps
    end
  end

  def self.down
    drop_table :temp_data
  end
end