class ExcludedCoachesSession < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
  belongs_to :excluded_coach, :class_name => 'Coach', :foreign_key => 'coach_id'
  belongs_to :extra_session , :class_name => 'ExtraSession', :foreign_key => 'coach_session_id'
end
