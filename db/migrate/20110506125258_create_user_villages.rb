class CreateUserVillages < ActiveRecord::Migration
  def self.up
    create_table :user_villages do |t|
      t.string :user_mail_id
      t.string :village_id
      t.timestamps
    end
  end

  def self.down
    drop_table :user_villages
  end
end
