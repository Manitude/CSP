# == Schema Information
#
# Table name: unavailable_despite_templates
#
#  id                  :integer(4)      not null, primary key
#  coach_id            :integer(4)
#  start_date          :datetime
#  end_date            :datetime
#  unavailability_type :integer(1)      default(0)
#  comments            :text(65535)
#  approval_status     :integer(1)      default(0)
#  coach_session_id    :integer(4)
#  created_at          :datetime
#  updated_at          :datetime
#
class UnavailableDespiteTemplate < ActiveRecord::Base

  audit_logged :audit_logger_class => CustomAuditLogger
  has_ancestry

  belongs_to :coach
  belongs_to :coach_session

  scope :approved, :conditions => ["approval_status = 1"]
  scope :not_denied, where('approval_status != ?', 3).where('unavailability_type != ?', 3)
  scope :between, lambda { |start_date, end_date| where('unavailable_despite_templates.start_date <= ? and unavailable_despite_templates.end_date >= ?', start_date, end_date) }

  validate :validate_attributes_data

  def violates_policy?
    start_date > Time.now && time_left_from_now < TIME_LIMIT_FOR_AVAILABILITY_MODIFICATION
  end

  def time_left_from_now
    start_date - Time.now
  end

  def status
    approval_status
  end

  private

  def validate_attributes_data
    errors.add(:base, "Please enter a valid coach id.") if coach.blank?
    errors.add(:base, "Please enter a valid comments.") if comments.blank?
    if start_date.blank?
      errors.add(:base, "Please enter a start date.")
    else
      self.end_date = start_date + coach.duration_in_seconds if coach && end_date.blank?
      start_date_limit = TimeUtils.current_slot(coach.has_one_hour?)
      errors.add(:base, "Start date of time off cannot be a date in the past.") if start_date < start_date_limit
      errors.add(:base, "End Date must be after Start Date.") if end_date <= start_date
    end
  end

end
