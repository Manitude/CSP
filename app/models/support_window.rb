# == Schema Information
#
# Table name: support_windows
#
#  id          :integer(4)      not null, primary key
#  window_type :string(255)
#  start_time  :time
#  end_time    :time
#  start_wday  :integer(1)
#  end_wday    :integer(1)
#

class SupportWindow < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
  validates_presence_of :type, :start_time, :end_time

  def self.create_or_update(type, start_time, end_time, start_wday, end_wday)
    obj = self.find_by_window_type(type)
    if obj
      obj.update_attributes(:start_time => start_time, :end_time => end_time, :start_wday => start_wday, :end_wday => end_wday)
    else
      obj = self.create(:window_type => type, :start_time => start_time, :end_time => end_time, :start_wday => start_wday, :end_wday => end_wday)
    end
  end

  def self.session_in_maintenance_time?(datetime)
    adobe_maintenance = SupportWindow.find_by_window_type("AdobeMaintenance")
    return false if adobe_maintenance.nil?
    begin_of_week = datetime.beginning_of_week
    start_date = begin_of_week + adobe_maintenance.start_wday.days + adobe_maintenance.start_time.hour.hours
    end_date = begin_of_week + adobe_maintenance.end_wday.days + adobe_maintenance.end_time.hour.hours
    end_date += 7.days if end_date < start_date
    datetime >= start_date && datetime <= end_date
  end

  def self.falls_outside_tech_support_window?(hour)
    tech_support = SupportWindow.find_by_window_type("TechSupport")
    tech_support.nil? ? false : hour < tech_support.start_time.hour || hour >= tech_support.end_time.hour
  end

end
