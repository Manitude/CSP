# == Schema Information
#
# Table name: learner_support_statuses
#
#  id         :integer(4)      not null, primary key
#  guid       :string(255)     
#  session_id :integer(4)      
#  status     :string(255)     
#  created_at :datetime        
#  updated_at :datetime        
#

class LearnerSupportStatus < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
  validates_uniqueness_of :guid, :scope => :session_id

  scope :for_session, lambda { |session| where(['session_id = ?', session]) }
  scope :for_learner_in_a_session, lambda { |session,guid| where(['session_id = ? and guid = ?', session,guid]).limit(1) }

  def self.update_status_for_learner_in_a_session(session_id,guid,status)
    learner_support_status = LearnerSupportStatus.for_learner_in_a_session(session_id,guid)[0]
    if learner_support_status
      learner_support_status.update_attribute(:status,status)
    else
      LearnerSupportStatus.create(:guid => guid, :session_id => session_id, :status => status)
    end
  end

  def self.clean
    learner_support_statuses = LearnerSupportStatus.where(["created_at < ?", 10.minutes.ago])
    if learner_support_statuses.size > 0
      LearnerSupportStatus.destroy(learner_support_statuses)
    end
  end

end
