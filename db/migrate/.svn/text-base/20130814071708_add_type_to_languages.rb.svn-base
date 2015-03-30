class AddTypeToLanguages < ActiveRecord::Migration
  
  def self.up
  	add_column :languages, :type, :string, :null => false, :default => 'TotaleLanguage'
  	Language.update_all({:type => 'ReflexLanguage'}, {:is_lotus => true})
  	remove_column :languages, :is_lotus
    AriaLanguage.create([{:identifier => 'AUS'}, {:identifier => 'AUK'}])
  end

  def self.down
    AriaLanguage.delete_all
  	add_column :languages, :is_lotus, :boolean, :null => false, :default => false
    ReflexLanguage.update_all :is_lotus => true
  	remove_column :languages, :type
  end

end