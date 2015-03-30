class AddMichelinLanguageAndSchedulingThreshold < ActiveRecord::Migration
  def self.up
	lang = TMMMichelinLanguage.create!({:identifier => 'TMM-MCH-L', :duration => 60})
  	LanguageSchedulingThreshold.create!({:language_id => lang.id})
  end

  def self.down
  	tmm_ids = TMMMichelinLanguage.all.map{|lang| lang.id} 
  	LanguageSchedulingThreshold.where("language_id in (?)", tmm_ids).destroy_all
	Language.where("type = 'TMMMichelinLanguage'").destroy_all
  end
end
