class AddDurationAndTmmLanguages < ActiveRecord::Migration
  def self.up
  	tmm_phone_langs = ["TMM-NED-P","TMM-ENG-P","TMM-FRA-P","TMM-DEU-P","TMM-ITA-P","TMM-ESP-P"]
  	tmm_live_langs = ["TMM-NED-L","TMM-ENG-L","TMM-FRA-L","TMM-DEU-L","TMM-ITA-L","TMM-ESP-L"]
  
  	add_column :languages, :duration, :integer, :default => 30
  	tmm_phone_langs.each do |tmm_phone_lang|
  		TMMPhoneLanguage.create!({:identifier => tmm_phone_lang})
  	end

  	tmm_live_langs.each do |tmm_live_lang|
  		TMMLiveLanguage.create!({:identifier => tmm_live_lang})
  	end

  	Language.update_all("duration = 60", "type = 'AriaLanguage'")
    Language.update_all("duration = 60", "type = 'TMMLiveLanguage'")

  end

  def self.down
  	Language.where("type in ('TMMPhoneLanguage','TMMLiveLanguage')").destroy_all
  	remove_column :languages, :duration
  end
end
