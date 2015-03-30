class StaffingFileInfo < ActiveRecord::Base
  has_many :staffing_datas
  belongs_to :coach_manager, :class_name => 'Account', :foreign_key => 'manager_id'

  scope :find_success_file_for_a_week, lambda { |start_of_the_week| {:conditions => ["status = ? and start_of_the_week = ? ", "Success", start_of_the_week]}}

  def self.get_all_available_weeks
    find(:all, :select => 'id, start_of_the_week', 
      :conditions => ["status = ? AND start_of_the_week >= ?", "Success", (Time.now - 4.weeks).beginning_of_week - 1.day],
      :order => 'start_of_the_week')
  end
end