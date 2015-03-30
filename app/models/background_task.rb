# == Schema Information
#
# Table name: background_tasks
#
#  id              :integer(4)      not null, primary key
#  referer_id      :integer(4)      
#  state           :string(255)     
#  error           :string(255)     
#  background_type :string(255)     
#  job_start_time  :datetime        
#  job_end_time    :datetime        
#  triggered_by    :string(255)     
#  locked          :boolean(1)      
#  created_at      :datetime        
#  updated_at      :datetime        
#  message         :text(65535)     
#

class BackgroundTask < ActiveRecord::Base
  def append_message(text_to_add)
    msg = self.message
    if msg
      msg += text_to_add
    else
      msg = text_to_add
    end
    self.update_attribute(:message, msg)
  end

  alias :another_create :create
  
  def create    
    another_create
  end
end

