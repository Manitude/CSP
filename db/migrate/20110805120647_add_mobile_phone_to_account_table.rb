class AddMobilePhoneToAccountTable < ActiveRecord::Migration
  def self.up
    add_column :accounts, :mobile_phone, :string
    add_index  :accounts, :mobile_phone
  end

  def self.down
    remove_index  :accounts, :mobile_phone
    remove_column :accounts, :mobile_phone
  end
end
