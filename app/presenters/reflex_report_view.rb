# To change this template, choose Tools | Templates
# and open the template in the editor.
require File.dirname(__FILE__) + '/../utils/reflex_report/reflex_session_details'
class ReflexReportView
  attr_accessor :subs_data, :coach_data, :time_off_data, :eve_data, :data_hash, :total_complete, :total_teaching_complete, :total_incomplete
  def initialize(coaches)
    data = []
    coaches.each do |coach|
      data << ReflexReport::ReflexSessionDetails.new(coach.id,coach.full_name.strip)
    end
    @data_hash = data
  end
  def substitution_data
    @subs_data.each do |coach|
      @data_hash.map do |item|
        if (item.coach_id.to_i == coach.coach_id.to_i)
          item.substitution = item.substitution.zero? ? coach.requested.to_i : item.substitution
          item.grabbed = item.grabbed.zero? ? coach.grabber.to_i : item.grabbed
          break
        end
      end
    end
  end
  def coach_data
    @coach_data.each do |coach|
      @data_hash.map do |item|
        if (item.coach_id.to_i == coach.coach_id.to_i)
          item.hours_count = item.hours_count.zero? ? (coach.hours.to_f/2) : item.hours_count.to_f
          item.hours_count = item.hours_count.zero? ? 0 : item.hours_count 
          break
        end
      end
    end
  end
  def time_off_data
    @time_off_data.each do |coach|
      @data_hash.map do |item|
        if (item.coach_id.to_i == coach.coach_id.to_i)
           total_time_off=(coach.total_time_off.to_f)/(24*60*60)
          total_time_off_int=total_time_off.to_i
          item.total_time_off = ((total_time_off == total_time_off_int )? total_time_off_int : total_time_off.round(2) ) # shows the total time offs taken in days
          item.requested = coach.time_offs_requested.to_i
          item.denied = coach.time_offs_denied.to_i
          item.approved = coach.time_offs_approved.to_i
          break
        end
      end
    end
  end
  def eve_data
    @eve_data.each do |reflex_session_details|
      @data_hash.map do |item|
        if (item.coach_id.to_i == reflex_session_details.coach_id.to_i)
          item.hours_in_player = item.hours_in_player_reflex(reflex_session_details)
          item.paused = (reflex_session_details.paused).to_f.round(2)
          item.per_paused = item.percentage_paused_reflex(reflex_session_details)
          item.complete = reflex_session_details.complete_sessions
          item.incomplete = item.percentage_incomplete_reflex(reflex_session_details)
          item.avg_session = item.average_session_reflex(reflex_session_details)
          break
        end
      end
      @total_complete += reflex_session_details.complete_sessions.to_f
      @total_teaching_complete += reflex_session_details.teaching_complete.to_f
      @total_incomplete += reflex_session_details.incomplete_sessions.to_f
    end
  end
  def populate(subs_data, coach_data, time_off_data, eve_data)
    
    @subs_data = subs_data
    @coach_data = coach_data
    @time_off_data = time_off_data
    @eve_data = eve_data
    @total_complete = 0
    @total_teaching_complete = 0
    @total_incomplete = 0
  end
  def get_complete_advanced_english_report
    self.substitution_data
    self.coach_data
    self.time_off_data
    self.eve_data
    self.sort_based_on_full_name
  end
  def sort_based_on_full_name
    {"coaches"=>@data_hash.sort_by {|details_hash| details_hash.coach_name},"total_complete"=>@total_complete,"total_teaching_complete"=>@total_teaching_complete,"total_incomplete"=>@total_incomplete}
  end

end
