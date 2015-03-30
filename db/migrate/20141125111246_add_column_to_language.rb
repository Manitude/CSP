class AddColumnToLanguage < ActiveRecord::Migration
  def self.up
    add_column :languages, :connection_type, :string
    add_column :languages, :external_scheduler, :string

    Language.where(:type => 'TotaleLanguage').update_all(:external_scheduler => 'eschool')
    Language.where(:type => 'AriaLanguage').update_all(:connection_type => 'supersaas1', :external_scheduler => 'supersaas')
    Language.where(:type => 'TMMMichelinLanguage').update_all(:connection_type => 'supersaas1', :external_scheduler => 'supersaas')
    Language.where(:type => 'TMMPhoneLanguage').update_all(:connection_type => 'supersaas2', :external_scheduler => 'supersaas')
  end

  def self.down
    remove_column :languages, :connection_type
    remove_column :languages, :external_scheduler
  end
end
