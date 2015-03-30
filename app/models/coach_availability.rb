# == Schema Information
#
# Table name: coach_availabilities
#
#  id                             :integer(4)      not null, primary key
#  coach_availability_template_id :integer(4)      not null
#  day_index                      :integer(1)      not null
#  start_time                     :time            not null
#  end_time                       :time            not null
#  created_at                     :datetime
#  updated_at                     :datetime
#  availabled_by_manager          :boolean(1)
#  recurring_id                   :integer(4)
#


class CoachAvailability < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
  belongs_to  :coach_availability_template

  scope :search_day_and_start_time, lambda { |day_index, time| {:conditions => ["day_index = ? AND start_time = ?", day_index, time], :limit => 1} }

  def self.for_day_and_start_time(day_index, time)
    search_day_and_start_time(day_index, time).first
  end

  def self.coaches_with_availabilities(templates,day_index,time)
    sql = <<-END
          select coach_id from coach_availability_templates cat, coach_availabilities ca
          where cat.id in (?) and ca.coach_availability_template_id = cat.id and ca.day_index = ? and ca.start_time = ?;
    END
    find_by_sql([sql,templates,day_index,time])
  end

  def self.for_coach_and_datetime(coach_id, datetime)
    template = CoachAvailabilityTemplate.where(["coach_id = ? and status = ? and deleted = ? and effective_start_date <= ?", coach_id, TEMPLATE_STATUS.index('Approved'), false, TimeUtils.time_in_user_zone(datetime).end_of_day]).order('effective_start_date').last
    for_datetime_and_template(datetime, template)
  end

  def self.for_datetime_and_template(datetime, template)
    return nil if template.nil?
    template.filter_avail_for_slot(datetime)
  end

  # Do not delete this method.
  # The content of the method is available in coach_recurring_schedule class. This is backed by test cases too.
  def self.availability_for_week(start_time, end_time, coach)
    sql = %Q(
      select ca.id, ca.day_index, ca.start_time, ca.end_time from coach_availability_templates cat
      INNER JOIN coach_availabilities ca
      ON cat.id = ca.coach_availability_template_id
      INNER JOIN (select max(ca1.id) id from coach_availabilities ca1
        INNER JOIN coach_availability_templates cat1 on ca1.coach_availability_template_id = cat1.id
        WHERE cat1.deleted = 0 AND cat1.status = 1 AND cat1.coach_id = ? AND
        ((cat1.effective_start_date BETWEEN ? AND ?) OR cat1.effective_start_date <= ?)
        GROUP BY day_index) tmp_table
      on tmp_table.id = ca.id
      )
    find_by_sql([sql, coach.id, start_time.to_date, end_time.to_date, start_time.to_date])
  end
end
