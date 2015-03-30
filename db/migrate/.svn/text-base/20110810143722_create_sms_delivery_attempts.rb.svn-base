class CreateSmsDeliveryAttempts < ActiveRecord::Migration
  def self.up
    create_table :sms_delivery_attempts, :force => true, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
     t.belongs_to :account
     t.string :mobile_number, :null => false
     t.string :message_body
     t.string :api_response_successful, :null => false, :default => false
     t.string :clickatell_msgid
     t.string :clickatell_error_code
     t.string :clickatell_error_message
     t.string :celltrust_msgid
     t.string :celltrust_error_code
     t.string :celltrust_error_message
     t.timestamps
    end
    #add_foreign_key_constraint(:sms_delivery_attempts, :account_id, :accounts, :id)
    #add_index :sms_delivery_attempts, :mobile_number
  end

  def self.down
    drop_table :sms_delivery_attempts
  end
end
