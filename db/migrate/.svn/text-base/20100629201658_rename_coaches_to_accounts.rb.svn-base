class RenameCoachesToAccounts < ActiveRecord::Migration
  def self.up
    execute("ALTER TABLE coaches RENAME TO accounts")

    add_column :accounts, :type, :string
    add_index :accounts, :type
  end

  def self.down
    remove_index :accounts, :type
    remove_column :accounts, :type

    execute("ALTER TABLE accounts RENAME TO coaches")
  end
end
