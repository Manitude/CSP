class AddColumnIslotusAndAddLanguageKle < ActiveRecord::Migration
  def self.up
    add_column :languages, :is_lotus, :boolean , :default =>false
    insert(%Q[insert into languages (identifier,is_lotus, created_at) values ('KLE',true, NOW())])
  end


  def self.down
    execute %Q[delete from languages where identifier = 'KLE']
    remove_column :languages, :is_lotus
  end
end
