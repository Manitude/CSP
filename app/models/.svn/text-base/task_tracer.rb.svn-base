# == Schema Information
#
# Table name: task_tracer
#
#  id                  :integer(4)      not null, primary key
#  task_name           :string(255)     
#  is_running_now      :boolean(1)      
#  last_successful_run :datetime        
#  created_at          :datetime        
#  updated_at          :datetime        
#

class TaskTracer < ActiveRecord::Base
  
  audit_logged :audit_logger_class => CustomAuditLogger 
  set_table_name 'task_tracer'
  
end
