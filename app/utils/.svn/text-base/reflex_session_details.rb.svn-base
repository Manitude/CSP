
class ReflexSessionDetails

  attr_reader :coach_id, :polling, :waiting, :paused, :teaching_complete, :teaching_incomplete, :total, :last_event, :complete_sessions, :incomplete_sessions

  def initialize(coach_id, polling_dict = {}, teaching_complete_dict = {}, teaching_incomplete_dict = {}, paused_dict = {}, waiting_dict = {}, last_event = nil, complete_sessions = 0, incomplete_sessions = 0)
    @coach_id = coach_id
    @polling = seconds_to_minutes(sum(polling_dict.values))
    @waiting = seconds_to_minutes(sum(waiting_dict.values))
    @paused = seconds_to_minutes(sum(paused_dict.values))
    @teaching_complete = seconds_to_minutes(sum(teaching_complete_dict.values))
    @teaching_incomplete = seconds_to_minutes(sum(teaching_incomplete_dict.values))
    @total = sum([@polling ||= 0 , @waiting ||= 0, @paused ||= 0, @teaching_complete ||= 0, @teaching_incomplete ||= 0])
    @last_event = last_event
    @complete_sessions = complete_sessions
    @incomplete_sessions = incomplete_sessions
  end

  def sum(values)
    return 0 if values.empty?
    values.inject {|sum, value| sum += value}
  end

  def seconds_to_minutes(value)
    value/60000.0
  end
end
