# == Schema Information
#
# Table name: sms_delivery_attempts
#
#  id                       :integer(4)      not null, primary key
#  account_id               :integer(4)      
#  mobile_number            :string(255)     not null
#  message_body             :string(255)     
#  api_response_successful  :string(255)     default("0"), not null
#  clickatell_msgid         :string(255)     
#  clickatell_error_code    :string(255)     
#  clickatell_error_message :string(255)     
#  celltrust_msgid          :string(255)     
#  celltrust_error_code     :string(255)     
#  celltrust_error_message  :string(255)     
#  created_at               :datetime        
#  updated_at               :datetime        
#

class SmsDeliveryAttempt < ActiveRecord::Base
  belongs_to :account

  # HACK HACK HACK HACK
  class << self
    def create(attrs)
      attrs[:account] = attrs.delete(:coach) || attrs.delete(:coach_manager)
      record = new(attrs)
      record.save!
      record
    end
  end

end
