module StaffingHelper

  def options_for_available_weeks(selected = nil)
    options = [['Select Schedule Week', '-1']]
    available_weeks = StaffingFileInfo.get_all_available_weeks
    options += available_weeks.map {|row| [get_week_range(row.start_of_the_week), row.id.to_s] }
    options = options_for_select(options, selected)
  end

  def get_week_range(start_of_the_week)
    start_of_the_week.strftime("%m/%d/%Y" ) + " - " + (start_of_the_week + 6.days).strftime("%m/%d/%Y" )
  end
  
end
