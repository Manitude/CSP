# == Schema Information
#
# Table name: language_configurations
#
#  id                 :integer(4)      not null, primary key
#  language_id        :integer(4)      
#  session_start_time :integer(1)      
#  created_by         :integer(4)      
#  created_at         :datetime        
#

class LanguageConfiguration < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
  belongs_to :language

  validates_presence_of :session_start_time, :created_by, :language

  def self.options
    SESSION_START_TIME_MAPPING.invert.sort
  end

end
