class AddMobileCountryCodeAndAimIdToAccountTable < ActiveRecord::Migration
  def self.up
    add_column :accounts, :mobile_country_code, :string
    add_column :accounts, :aim_id, :string
  end

  def self.down
    remove_column :accounts, :mobile_country_code
    remove_column :accounts, :aim_id
  end
end
