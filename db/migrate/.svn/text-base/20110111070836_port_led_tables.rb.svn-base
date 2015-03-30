class PortLedTables < ActiveRecord::Migration
  def self.up
    create_table :learner_support_statuses do |t|
      t.string :guid
      t.integer :session_id
      t.string :status

      t.timestamps
    end

    create_table :support_languages do |t|
      t.string :name
      t.string :language_code

      t.timestamps
    end

    execute "TRUNCATE TABLE support_languages"
    SupportLanguage.create(:name =>"NONE",:language_code => "none")
    SupportLanguage.create(:name =>"Chinese",:language_code => "zh-CN")
    SupportLanguage.create(:name =>"English",:language_code => "en-US")
    SupportLanguage.create(:name =>"French",:language_code => "fr-FR")
    SupportLanguage.create(:name =>"German",:language_code => "de-DE")
    SupportLanguage.create(:name =>"Italian",:language_code => "it-IT")
    SupportLanguage.create(:name =>"Japanese",:language_code => "ja-JP")
    SupportLanguage.create(:name =>"Korean",:language_code => "ko-KR")
    SupportLanguage.create(:name =>"Portuguese",:language_code => "pt-BR")
    SupportLanguage.create(:name =>"Russian",:language_code => "ru-RU")
    SupportLanguage.create(:name =>"Spanish",:language_code => "es-419")
  end

  def self.down
    drop_table :learner_support_statuses
    drop_table :support_languages
  end
end
