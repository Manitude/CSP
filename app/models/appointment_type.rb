class AppointmentType < ActiveRecord::Base
  attr_accessible :title, :active

  has_many :coach_recurring_schedules
  has_many :appointments

  validates :title , :presence => true, :uniqueness => { :case_sensitive => false }

  scope :active, lambda { {:conditions => ["active = 1"]} }
  
 end
