class CreateUserLanguages < ActiveRecord::Migration
  def self.up
    create_table :user_languages do |t|
      t.string :user_mail_id
      t.string :language_identifier
      t.timestamps
    end
  end

  def self.down
    drop_table :user_languages
  end
end
