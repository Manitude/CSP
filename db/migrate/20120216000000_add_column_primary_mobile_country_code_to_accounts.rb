class AddColumnPrimaryMobileCountryCodeToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :primary_country_code, :string
  end

  def self.down
    remove_column :accounts, :primary_country_code
  end
end
