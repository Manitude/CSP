class UpdateAccountsAddColumnForSubstitutions < ActiveRecord::Migration
  def self.up
    add_column :accounts, :next_substitution_alert_in, :decimal, :default => 24.00
  end

  def self.down
    remove_column :accounts, :next_substitution_alert_in
  end
end
