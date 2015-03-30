class AddNotNullabilityToAccountsType < ActiveRecord::Migration
  def self.up
  	Account.delete_all("type is null")
  	change_table :accounts do |t|
  		t.change :type, :string, :null => false
  	end
  end

  def self.down
  	change_table :accounts do |t|
  		t.change :type, :string, :null => true
  	end
  end
end
