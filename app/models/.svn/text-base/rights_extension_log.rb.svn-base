# == Schema Information
#
# Table name: rights_extension_logs
#
#  id                         :integer(4)      not null, primary key
#  support_user_id            :integer(4)      
#  license_guid               :string(255)     
#  reason                     :string(255)     
#  extendable_guid            :string(255)     
#  created_at                 :datetime        
#  updated_at                 :datetime        
#  learner_id                 :integer(4)      
#  duration                   :string(255)     
#  extendable_created_at      :datetime        
#  extendable_ends_at         :datetime        
#  action                     :string(255)     
#  updated_extendable_ends_at :datetime        
#  ticket_number              :string(255)     
#

class RightsExtensionLog < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
  validates_presence_of :reason

  def self.find_extensions_between (start_date,end_date,limit_to_500 = false)
      sql = <<-END
        select rel.* , CONCAT_WS(' ',l.first_name,l.last_name) as CustomerName,l.email,su.full_name as SupportUserName
        from rights_extension_logs rel , learners l, accounts su
        where (rel.action = 'ADD_TIME' or rel.action = 'REMOVE_RIGHTS') and l.id= rel.learner_id and su.id = rel.support_user_id
        and date(rel.created_at) >= '#{start_date.to_date.to_s(:db)}' and date(rel.created_at) <= '#{end_date.to_date.to_s(:db)}' and duration != '20y' and extendable_ends_at < DATE_ADD(NOW(), INTERVAL 10 YEAR)
        END
    if !limit_to_500
      sql << "group by ticket_number order by created_at desc;"
    elsif limit_to_500 == true
      sql << "group by ticket_number order by created_at desc limit 500;"
    end
    find_by_sql(sql)
  end

end
