# == Schema Information
#
# Table name: user_update_execution_details
#
#  id                     :integer(4)      not null, primary key
#  user_update_identifier :string(45)      
#  last_processed_id      :integer(4)      
#  started_at             :datetime        
#  finished_at            :datetime        
#

class UserUpdateExecutionDetail < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
  class << self
    def record_time(identifier)
      user_update_detail = create(:user_update_identifier => identifier, :started_at => Time.now)
      begin
        yield if block_given?
        user_update_detail.update_attribute(:finished_at, Time.now)
      rescue => e
        puts e.message
        user_update_detail.destroy
        HoptoadNotifier.notify(e)
      end
    end

    def last_execution_time(identifier, rescue_time = 1.hour.ago)
      last_execution_for(identifier).started_at rescue rescue_time
    end

    def last_updated_time(identifier)
      last_execution_detail = where("user_update_identifier = ? and finished_at IS NOT NULL", identifier).last
      last_execution_detail.started_at if last_execution_detail
    end

    def last_processed_id(identifier)
      last_execution_for(identifier).last_processed_id rescue 0
    end

    def last_execution_for(identifier)
      where(:user_update_identifier => identifier).order("id DESC").first
    end

  end
end
