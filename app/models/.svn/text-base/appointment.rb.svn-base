class Appointment < CoachSession
    
  belongs_to :coach_recurring_schedule
  belongs_to :appointment_type

  def is_one_hour?
   	false
  end

  def self.create_one_off(params)
    options = {
        :coach_id               => params[:teacher_id],
        :session_start_time     => params[:start_time],
        :session_end_time       => params[:start_time].to_time + 30.minutes,
        :language_identifier    => params[:lang_identifier],
        :session_status 				=> COACH_SESSION_STATUS["Created in Eschool"],
        :recurring_schedule_id  => params[:recurring_schedule_id],
        :appointment_type_id    => params[:appointment_type_id],
        :reassigned             => params[:reassigned]
    }
    appointment = self.create(options)
    appointment.create_session_details(:details => params[:details]) if !params[:details].blank?
    if appointment.errors.blank?
      appointment
    end
  end
end