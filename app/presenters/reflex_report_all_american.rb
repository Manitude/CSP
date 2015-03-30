require File.dirname(__FILE__) + '/../utils/reflex_report/reflex_session_details'
require 'libxml'

class ReflexReportAllAmerican
  attr_accessor :subs_data_kle, :subs_data_eng, :coach_data, :time_off_data, :eve_data, :sessions_data, :response_feedback, :data_hash, :total_complete, :total_teaching_complete, :total_incomplete
  def initialize(coaches)
    @data_hash = []
    coaches.each do |coach|
      @data_hash << ReflexReport::ReflexSessionDetailsAllAmerican.new(coach[:coach_id], coach[:name].strip)
    end
  end
  def substitution_data_kle
    @subs_data_kle.each do |coach|
      @data_hash.each do |item|
        if (item.coach_id.to_i == coach.coach_id.to_i)
          item.requested_reflex = item.requested_reflex.zero? ? coach.requested.to_i : item.requested_reflex
          item.grabbed_reflex = item.grabbed_reflex.zero? ? coach.grabber.to_i : item.grabbed_reflex
          break
        end
      end
    end
  end
  def substitution_data_eng
    @subs_data_eng.each do |coach|
      @data_hash.each do |item|
        if (item.coach_id.to_i == coach.coach_id.to_i)
          item.requested_totale = item.requested_totale.zero? ? coach.requested.to_i : item.requested_totale
          item.grabbed_totale = item.grabbed_totale.zero? ? coach.grabber.to_i : item.grabbed_totale
          break
        end
      end
    end
  end
  def coach_data
    @coach_data.each do |coach|
      @data_hash.each do |item|
        if (item.coach_id.to_i == coach.coach_id.to_i)
          item.scheduled_reflex = item.scheduled_reflex.zero? ? coach.hours.to_i : item.scheduled_reflex
          break
        end
      end
    end
  end
  def time_off_data
    @time_off_data.each do |coach|
      @data_hash.each do |item|
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
      @data_hash.each do |item|
        if (item.coach_id.to_i == reflex_session_details.coach_id.to_i)
          item.taught_reflex = item.hours_in_player_reflex(reflex_session_details)
          item.mins_paused = item.minutes_paused_reflex(reflex_session_details)
          item.per_paused = item.percentage_paused_reflex(reflex_session_details)
          item.complete = reflex_session_details.complete_sessions
          item.per_incomplete = item.percentage_incomplete_reflex(reflex_session_details)
          item.avg_session = item.average_session_reflex(reflex_session_details)
          break
        end
      end
     
    end
  end
  def get_totals
    @total_complete = 0
    @total_teaching_complete = 0
    @total_incomplete = 0
    @eve_data.each do |reflex_session_details|
      @total_complete += reflex_session_details.complete_sessions.to_f
      @total_teaching_complete += reflex_session_details.teaching_complete.to_f
      @total_incomplete += reflex_session_details.incomplete_sessions.to_f
    end
    data = {"total_complete"=>@total_complete,"total_teaching_complete"=>@total_teaching_complete,"total_incomplete"=>@total_incomplete}  
  end  
  def sessions_data
    @sessions_data && @sessions_data.each do |coach|
      @data_hash.each do |item|
        if (item.coach_id.to_i == coach['coach_id'].to_i)
            item.scheduled_totale = coach['session_count'].to_i
            item.no_show_totale   = coach['past_uncancelled_sessions_with_coach_no_show'].to_i + coach['past_cancelled_sessions_with_coach_no_show_cancelled_after_it_started'].to_i
            item.in_player_totals = coach['seconds_prior_to_session'].to_i
            item.taught_totale    = coach['past_uncancelled_sessions_with_coach_shown_up'].to_i + coach['past_cancelled_sessions_with_coach_shown_up_cancelled_after_it_started'].to_i
            item.in_player        = item.taught_totale.zero? ? "N/A" : ((item.in_player_totals.to_f)/item.taught_totale.to_i).round(2)
          break
        end
      end
    end
  end
  
  def response_feedback
    if @response_feedback
      response_xml = @response_feedback.read_body
      source = LibXML::XML::Parser.string(response_xml)
      content = source.parse
      teachers = content.root.find("//teacher")
      teachers.each do |teacher|
        @data_hash.each do |item|
          if (item.coach_id.to_i == teacher.find_first('external_coach_id').content.to_i)
            item.incomplete_feedbacks = teacher.find_first('total_sessions').content.to_i - teacher.find_first('evaluated_sessions').content.to_i
            item.complete_feedbacks   = teacher.find_first('evaluated_sessions').content.to_i
          end
        end
      end
    end
  end
  
  def sum_of_totale_and_reflex
    @data_hash.each do |item|
      item.scheduled_total = item.scheduled_totale  + item.scheduled_reflex
      item.requested_total = item.requested_totale + item.requested_reflex
      item.grabbed_total  = item.grabbed_totale + item.grabbed_reflex
      item.taught_total = ((item.taught_totale*30 + item.taught_reflex*60).to_f/60).round(2)
    end
  end
  def populate(subs_data_kle, subs_data_eng, coach_data, time_off_data, eve_data, sessions_data, response_feedback)
    @subs_data_kle = subs_data_kle
    @subs_data_eng = subs_data_eng
    @coach_data = coach_data
    @time_off_data = time_off_data
    @eve_data = eve_data
    @sessions_data = sessions_data
    @response_feedback = response_feedback
    
  end
  def get_complete_all_american_english_report
    self.substitution_data_kle
    self.substitution_data_eng
    self.coach_data
    self.time_off_data
    self.eve_data
    self.sessions_data
    self.response_feedback
    self.sum_of_totale_and_reflex
  end
  
  def self.sort_based_on_full_name(coaches)
    coaches.sort_by {|details_hash| details_hash.coach_name}
  end
end
