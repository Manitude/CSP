# == Schema Information
#
# Table name: events
#
#  id                :integer(4)      not null, primary key
#  event_description :text(65535)
#  event_name        :string(255)
#  event_start_date  :date
#  event_end_date    :datetime
#  language_id       :integer(4)
#  region_id         :integer(4)
#  created_at        :datetime
#  updated_at        :datetime
#

class Event < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger
  validates :event_name, :event_description, :event_start_date, :event_end_date, :language_id, :region_id, :presence => true
  validates_format_of  :event_name, :with => /^[a-z0-9A-Z\-\ ]*?$/
  belongs_to :language
  belongs_to :region
  validate :event_cant_be_in_past
  validate :validate_start_date_earlier_than_end_date
  before_validation :change_zone_of_dates
  scope :future, lambda { { :conditions => ['event_end_date >= ?', TimeUtils.time_in_user_zone.beginning_of_day.utc], :order => 'event_start_date ASC' } }

  def event_cant_be_in_past
    errors.add(:event_start_date, "can't be in the past") if !event_start_date.blank? and event_start_date < Date.today
  end

  def validate_start_date_earlier_than_end_date
    errors.add(:event_start_date, 'must be earlier than end date') if !event_start_date.blank? and !event_end_date.blank? and event_end_date < event_start_date
  end

  def change_zone_of_dates
    self.event_start_date -= TimeUtils.offset(self.event_start_date) if self.event_start_date
    self.event_end_date -= TimeUtils.offset(self.event_end_date) if self.event_end_date
  end

end
