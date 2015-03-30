# == Schema Information
#
# Table name: user_villages
#
#  id           :integer(4)      not null, primary key
#  user_mail_id :string(255)     
#  village_id   :string(255)     
#  created_at   :datetime        
#  updated_at   :datetime        
#

class UserVillage < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
  belongs_to :user, :class_name => "Community::User"
  belongs_to :village, :class_name => "Community::Village"
end
