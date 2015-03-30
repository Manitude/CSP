class CreateSupportWindows < ActiveRecord::Migration
  def self.up
    create_table  :support_windows, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.string    :window_type #Either AdobeMaintenance or TechSupport
      t.time      :start_time
      t.time      :end_time
      t.integer   :start_wday,  :limit => 1
      t.integer   :end_wday,    :limit => 1
    end

  end

  def self.down
    drop_table :support_windows
  end
end
