# == Schema Information
#
# Table name: temp_data
#
#  id         :integer(4)      not null, primary key
#  data       :binary(16777215 
#  done       :boolean(1)      
#  created_at :datetime        
#  updated_at :datetime        
#

#This table is used as a temporary store to pass data from background thread to the View
class TempData < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
  set_table_name 'temp_data'
end
