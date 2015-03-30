class RemoveParatureChatUrlFromAccounts < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :parature_chat_url
  end

  def self.down
    add_column :accounts, :parature_chat_url, :string, :default => "http://totale.rosettastone.com/support?task=chat"
  end
end
