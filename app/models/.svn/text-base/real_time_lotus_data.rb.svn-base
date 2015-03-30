# == Schema Information
#
# Table name: real_time_lotus_datas
#
#  id                        :integer(4)      not null, primary key
#  learners_in_dts_kle       :string(255)     
#  learners_in_dts_jle       :string(255)     
#  learners_waiting_kle      :string(255)     
#  learners_waiting_jle      :string(255)     
#  average_waiting_time_kle  :string(255)     
#  average_waiting_time_jle  :string(255)     
#  coaches_actually_teaching :string(255)     
#  waiting_coaches           :string(255)     
#  scheduled_coaches         :string(255)     
#  created_at                :datetime        
#  updated_at                :datetime        
#

class RealTimeLotusData < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
end
