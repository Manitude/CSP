class SessionMetadata < ActiveRecord::Base
  set_table_name 'session_metadata'
  belongs_to :coach_session
  
end
