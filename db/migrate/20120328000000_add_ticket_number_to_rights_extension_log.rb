class AddTicketNumberToRightsExtensionLog < ActiveRecord::Migration
  def self.up
    add_column :rights_extension_logs, :ticket_number, :string
  end

  def self.down
    remove_column :rights_extension_logs, :ticket_number
  end
end
