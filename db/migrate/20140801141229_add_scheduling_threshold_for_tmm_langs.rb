class AddSchedulingThresholdForTmmLangs < ActiveRecord::Migration
  def self.up
  	TMMPhoneLanguage.all.each do |tmm|
  		LanguageSchedulingThreshold.create!({:language_id => tmm.id})
  	end

  	TMMLiveLanguage.all.each do |tmm|
  		LanguageSchedulingThreshold.create!({:language_id => tmm.id})
  	end
  end

  def self.down
  	tmm_ids = TMMLiveLanguage.all.map{|lang| lang.id} + TMMPhoneLanguage.all.map{|lang| lang.id}
  	LanguageSchedulingThreshold.where("language_id in (?)", tmm_ids).destroy_all
  end
end
