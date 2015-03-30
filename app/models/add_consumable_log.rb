class AddConsumableLog < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
  validates_presence_of :reason

  def self.find_added_consumables(pooler_guids)
    result = find(:all, :conditions => ["pooler_guid in (?)", pooler_guids], :order => "created_at DESC")
    result.each {|session| session[:added_by] = Account.find(session[:support_user_id]).full_name }
  end

  def self.find_logs_between(type, start_date, end_date, limit_to_500 = false)
  	query = "select a.created_at ,b.full_name ,a.case_number ,a.consumable_type, a.number_of_sessions , a.reason , a.license_guid from add_consumable_logs a, accounts b where a.support_user_id = b.id and action = 'Add' and a.created_at >= ? and a.created_at <= ? and consumable_type in (?) order by a.created_at desc" 
  	query += " limit 500" if limit_to_500
  	find_by_sql([query,start_date,end_date,type])
  end	

end
