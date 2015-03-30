class AddSupportProfileFields < ActiveRecord::Migration
  def self.up
    add_column :accounts, :parature_chat_url, :string, :default => "http://totale.rosettastone.com/support?task=chat"
    add_column :accounts, :country, :string
    add_column :accounts, :native_language, :string
    add_column :accounts, :other_languages, :string
    add_column :accounts, :address, :string
  end

  def self.down
    remove_column :accounts, :parature_chat_url
    remove_column :accounts, :country
    remove_column :accounts, :native_language
    remove_column :accounts, :other_languages
    remove_column :accounts, :address
  end
end
