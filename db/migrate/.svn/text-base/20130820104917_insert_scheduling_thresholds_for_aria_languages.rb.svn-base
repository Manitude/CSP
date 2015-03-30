class InsertSchedulingThresholdsForAriaLanguages < ActiveRecord::Migration
  def self.up
  	['AUS', 'AUK'].each do |lang_identifier|
	  	LanguageSchedulingThreshold.create!(:language_id => Language[lang_identifier].id, :max_assignment => 50, :max_grab => 30, :hours_prior_to_sesssion_override => 1)
	  end
  end

  def self.down
  	LanguageSchedulingThreshold.where(:language_id => [Language['AUS'].id, Language['AUK'].id]).destroy_all
  end
end
