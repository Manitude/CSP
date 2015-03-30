# == Schema Information
#
# Table name: shown_substitutions
#
#  id         :integer(4)      not null, primary key
#  coach_id   :integer(4)      
#  created_at :datetime        
#  updated_at :datetime        
#

#Table Name: shown_substitutions
#id         :integer(11)
#coach_id   :integer(11)
#created_at :datetime
#updated_at :datetime

class ShownSubstitutions < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
  belongs_to :coach

  attr_accessor :updated_at
  validates_presence_of :coach_id
  laziness_lookup_attribute :coach_id

  def last_alert_closed_time
    read_attribute(:updated_at)
  end
end
