module ReflexReport
  class ReflexSessionDetails

    attr_accessor :coach_id, :coach_name, :hours_count, :substitution, :grabbed, :requested, :approved, :denied, :hours_in_player, :paused, :per_paused, :avg_session, :incomplete, :complete, :total_time_off

    def initialize(coach_id,coach_name, hours_count = 0, substitution =0, grabbed = 0, requested =0, approved = 0, denied = 0, hours_in_player = 0, paused = 0, per_paused = 0, avg_session = 0, incomplete = 0, complete = 0, total_time_off = 0)
        @coach_id = coach_id
        @coach_name = coach_name
        @hours_count = hours_count
        @substitution = substitution
        @grabbed = grabbed
        @requested = requested
        @approved = approved
        @denied = denied
        @hours_in_player = hours_in_player
        @paused = paused
        @per_paused = per_paused
        @avg_session = avg_session
        @incomplete = incomplete
        @complete = complete
        @total_time_off = total_time_off
    end

    def hours_in_player_reflex(reflex_session_details)
      (reflex_session_details.total.to_f/60).round(2)
    end

    def percentage_paused_reflex(reflex_session_details)
      reflex_session_details.total.zero? ? "N/A" : ((self.paused.to_f/reflex_session_details.total)*100).to_f.round(2).to_s 
    end

    def percentage_incomplete_reflex(reflex_session_details)
      (reflex_session_details.complete_sessions.to_i+reflex_session_details.incomplete_sessions.to_i).zero? ? "N/A" : (((reflex_session_details.incomplete_sessions.to_f)/(reflex_session_details.complete_sessions.to_i+reflex_session_details.incomplete_sessions.to_i))*100).round(2)
    end

    def average_session_reflex(reflex_session_details)
      self.complete.zero? ? "N/A" : (reflex_session_details.teaching_complete.to_f/self.complete).round(2) 
    end

    def average_duration
      self.approved.to_i.zero? ? "N/A" : ((self.total_time_off.to_f/self.approved)/(24*60*60)).round(2).to_s + " days"
    end
  end
  class ReflexSessionDetailsAllAmerican

    attr_accessor :coach_id, :coach_name, :scheduled_totale, :scheduled_reflex, :scheduled_total, :taught_reflex, :mins_paused, :per_paused, :avg_session, :per_incomplete, :no_show_totale, :cancelled, :feedback, :requested_totale, :requested_reflex, :requested_total, :grabbed_totale, :grabbed_reflex, :grabbed_total, :in_player, :requested, :approved, :denied, :total_time_off, :complete, :incomplete_feedbacks, :complete_feedbacks, :taught_total, :taught_totale, :in_player_totals

    def initialize(coach_id, coach_name, scheduled_totale = 0, scheduled_reflex = 0, scheduled_total = 0, taught_reflex = 0, mins_paused = 0, per_paused = 0, avg_session = 0, per_incomplete = 0, no_show_totale = 0, cancelled = 0, feedback = 0, requested_totale = 0, requested_reflex = 0, requested_total = 0, grabbed_totale = 0, grabbed_reflex = 0, grabbed_total = 0, in_player = "N/A", requested = 0, approved = 0, denied = 0, total_time_off = 0, complete = 0, incomplete_feedbacks = 0, complete_feedbacks = 0, taught_total = 0, taught_totale = 0)
        @coach_id = coach_id
        @coach_name = coach_name
        @scheduled_totale = scheduled_totale
        @scheduled_reflex = scheduled_reflex
        @scheduled_total = scheduled_total
        @taught_reflex = taught_reflex
        @mins_paused = mins_paused
        @per_paused = per_paused
        @avg_session = avg_session
        @per_incomplete = per_incomplete
        @no_show_totale = no_show_totale
        @cancelled = cancelled
        @feedback = feedback
        @requested_totale = requested_totale
        @requested_reflex = requested_reflex
        @requested_total = requested_total
        @grabbed_totale = grabbed_totale
        @grabbed_reflex = grabbed_reflex
        @grabbed_total = grabbed_total
        @in_player = in_player
        @requested = requested
        @approved = approved
        @denied = denied
        @total_time_off = total_time_off
        @complete = complete
        @incomplete_feedbacks = incomplete_feedbacks
        @complete_feedbacks = complete_feedbacks
        @taught_total = taught_total
        @taught_totale = taught_totale
        @in_player_totals = 0
        
    end
    
    def hours_in_player_reflex(reflex_session_details)
      (reflex_session_details.total.to_f/60).round(2)
    end

    def average_duration
      self.approved.to_i.zero? ? "N/A" : ((self.total_time_off.to_f/self.approved)/(24*60*60)).round(2).to_s + " days"
    end

    def taught_reflex_in_minutes_reflex(reflex_session_details)
      (reflex_session_details.teaching_complete.to_f/60)
    end

    def minutes_paused_reflex(reflex_session_details)
      (reflex_session_details.paused).to_f.round(2)
    end

    def percentage_paused_reflex(reflex_session_details)
      reflex_session_details.total.zero? ? "N/A" : ((self.mins_paused.to_f/reflex_session_details.total)*100).round(2).to_s 
    end

    def percentage_incomplete_reflex(reflex_session_details)
     (reflex_session_details.complete_sessions.to_i+reflex_session_details.incomplete_sessions.to_i).zero? ? "N/A" : (((reflex_session_details.incomplete_sessions.to_f)/(reflex_session_details.complete_sessions.to_i+reflex_session_details.incomplete_sessions.to_i))*100).to_f.round(2)
    end

    def average_session_reflex(reflex_session_details)
      self.complete.zero? ? "N/A" : (reflex_session_details.teaching_complete.to_f/self.complete).round(2)
    end
  end

end