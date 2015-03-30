require File.expand_path('../reflex_session_details', __FILE__)
require File.expand_path('../reflex_activity_utils', __FILE__)

class CoachActivityParser
  include ReflexActivityUtils

  def initialize(coach, start_time, end_time)
    @coach = coach
    @start_time = start_time
    @end_time = end_time
  end

  def parse(events)
    polling = {}
    teaching_complete = {}
    teaching_incomplete = {}
    paused = {}
    waiting = {}
    last_event = nil
    previous_event = nil
    complete_sessions = 0
    incomplete_sessions = 0

    events.each do |event|
      
      unless previous_event
        if event.event == 'coach_initialized'
          previous_event = event
        end
        next
      end
      current_time_diff = event.timestamp - previous_event.timestamp
      if current_time_diff > 2 * 1.hour.to_i
        if event.event == 'coach_initialized'
          previous_event = event
        else
          previous_event = nil
        end
        next
      end
      if event.timestamp < @start_time
        previous_event = event
        next
      elsif event.timestamp < @end_time
        if event.event == 'coach_end_session_complete'
          complete_sessions += 1
        elsif event.event == 'coach_end_session_incomplete'
          incomplete_sessions += 1
        end
      end
      if previous_event.timestamp > @end_time
        break
      end
      if previous_event.timestamp < @start_time
        current_time_diff = (event.timestamp - @start_time) * 1000
      end
      if event.timestamp > @end_time
        current_time_diff = (@end_time - previous_event.timestamp) * 1000
      end
      if event.event == previous_event.event
        next
      end
      unless ACCEPTABLE_FOLLOWERS[previous_event.event.to_sym].include? event.event
         Rails.logger.info "#{event.event}, #{previous_event.event}, 'unacceptable'"
        next
      end

      if previous_event.event == 'coach_initialized'
        polling[previous_event.timestamp] = current_time_diff * 1000
      elsif previous_event.event == 'coach_match_accepted' && event.event == 'coach_end_session_incomplete'
        teaching_incomplete[previous_event.timestamp] = current_time_diff * 1000
      elsif previous_event.event == 'coach_match_accepted' && event.event == 'coach_end_session_complete'
        teaching_complete[previous_event.timestamp] = current_time_diff * 1000
      elsif previous_event.event == 'coach_match_accepted'
        waiting[previous_event.timestamp] = current_time_diff * 1000
      elsif previous_event.event == 'coach_ready' && event.event == 'coach_end_session_complete'
        teaching_complete[previous_event.timestamp] = current_time_diff * 1000
      elsif previous_event.event == 'coach_ready' && event.event == 'coach_end_session_incomplete'
        teaching_incomplete[previous_event.timestamp] = current_time_diff * 1000
      elsif previous_event.event == 'coach_ready'
        teaching_incomplete[previous_event.timestamp] = current_time_diff * 1000
      elsif previous_event.event == 'student_not_show_up'
        teaching_incomplete[previous_event.timestamp] = current_time_diff * 1000
      elsif previous_event.event == 'coach_end_session_complete'
        waiting[previous_event.timestamp] = current_time_diff * 1000
      elsif previous_event.event == 'coach_end_session_incomplete'
        waiting[previous_event.timestamp] = current_time_diff * 1000
      elsif previous_event.event == 'coach_paused'
        if(current_time_diff >=15.minutes)
          current_time_diff = 15.minutes
        end
        paused[previous_event.timestamp] = current_time_diff * 1000
      elsif previous_event.event == 'coach_resumed'
        polling[previous_event.timestamp] = current_time_diff * 1000
      else
        raise 'unknown type ' + event.event
      end
      previous_event = event

      if previous_event
        last_event = previous_event.event
      end
    end
    ReflexSessionDetails.new(@coach, polling, teaching_complete, teaching_incomplete, paused, waiting, last_event, complete_sessions, incomplete_sessions)
  end

end