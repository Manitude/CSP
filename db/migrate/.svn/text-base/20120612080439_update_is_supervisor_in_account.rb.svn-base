class UpdateIsSupervisorInAccount < ActiveRecord::Migration
  def self.up
  	Account.update_all("is_supervisor = 0", "is_supervisor is null")
  	change_column :accounts, :is_supervisor, :boolean, :default => false
  end

  def self.down
  	change_column :accounts, :is_supervisor, :boolean, :default => nil
  end
end
