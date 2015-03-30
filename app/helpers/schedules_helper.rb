module SchedulesHelper

  def slot_details_title(session_start_time)
    "SHIFT DETAIL -- #{session_start_time.strftime('%a %m/%d/%y %I:%M %p')}"
  end

end
