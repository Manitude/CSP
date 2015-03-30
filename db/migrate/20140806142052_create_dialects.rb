class CreateDialects < ActiveRecord::Migration
  def self.up
    create_table :dialects do |t|
    	t.string 	:name
    	t.integer	:language_id

      t.timestamps
    end

    add_column :qualifications, :dialect_id, :integer

    ['TMM-ENG-P','TMM-ENG-L'].each do |lang|
    	Dialect.create!({:name => 'US', :language_id => Language[lang].id})
    	Dialect.create!({:name => 'UK', :language_id => Language[lang].id})
    end
  end

  def self.down
  	remove_column :qualifications, :dialect_id
    drop_table :dialects
  end
end
