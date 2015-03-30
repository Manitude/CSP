# == Schema Information
#
# Table name: announcements
#
#  id            :integer(4)      not null, primary key
#  body          :text(65535)
#  subject       :string(255)
#  expires_on    :date
#  language_id   :integer(4)
#  region_id     :integer(4)
#  language_name :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

class Announcement < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger
  validates :subject, :body, :expires_on, :language_id, :region_id, :presence => true
  validates_format_of  :subject, :with => /^[a-z0-9A-Z_ (\&)-?\/,'%$"@#!~`@^{}\[\]*&]*?$/
  validate :expires_on_cannot_be_past
  before_validation :change_zone_of_expires_on
  belongs_to :language
  belongs_to :region
  scope :future, lambda { { :conditions => ['expires_on >= ?', TimeUtils.time_in_user_zone.beginning_of_day.utc], :order => 'expires_on ASC' } }

  def self.search(search)
    search_condition = "%" + search + "%"
    future.where(['subject LIKE ? OR body LIKE ? OR regions.name LIKE ? OR language_name LIKE ?', search_condition, search_condition, search_condition, search_condition]).includes(:region)
  end

  private

  def expires_on_cannot_be_past
    errors.add(:expires_on, "can't be in the past") if !expires_on.blank? and expires_on < Date.today
  end

  def change_zone_of_expires_on
    self.expires_on -= TimeUtils.offset(self.expires_on) if self.expires_on
  end

end
