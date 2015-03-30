# == Schema Information
#
# Table name: user_languages
#
#  id                  :integer(4)      not null, primary key
#  user_mail_id        :string(255)     
#  language_identifier :string(255)     
#  created_at          :datetime        
#  updated_at          :datetime        
#

class UserLanguage < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
  belongs_to :user, :class_name => "Community::User"
  belongs_to :village, :class_name => "Community::Language"
end
