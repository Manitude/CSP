class MsErrorMessage < ActiveRecord::Migration
  def self.up
    create_table :ms_error_messages, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.string   :language_identifier
      t.text     :message
      t.datetime :start_of_week

      t.timestamps
    end

  end

  def self.down
    drop table :ms_error_messages
  end
end
