require File.dirname(__FILE__) + '/coach_activity_fetcher'

class CoachActivityReportUtils
  
  def self.fetch_report_for_languages(lang_array, region, from, to)
    data_hash = {}
    coach_list = Coach.coach_ids_of_that_language(lang_array,from,to,region)
    if !coach_list.blank?
      # Initialize the data hash
      coach_list.each do |coach|
        coach_id = coach.id.to_s
        data_hash[coach_id] = {
          :full_name => coach.full_name.strip, 
          :scheduled_future => 0, 
          :scheduled_past => 0, 
          :scheduled_past_solo => 0, 
          :taught_count => 0.0, 
          :no_show => 0, 
          :cancelled_count => 0,
          :subs_requested => 0, 
          :subs_grabbed => 0, 
          :pc_taught => 'N/A',
          :incomplete_feedbacks => 0, 
          :complete_feedbacks => 0,
          :time_offs_requested => 0, 
          :time_offs_denied => 0, 
          :time_offs_approved => 0, 
          :total_time_off => 0,
          :in_player_time => 0
        }
      end
      coach_ids = coach_list.collect(&:id)
      # Part 1 - Substitutions data fetch
      subs_data = Coach.substitution_grabbed(coach_ids, from, to,lang_array)
      subs_data.each do |coach|
        coach_id = coach.coach_id.to_s
        data_hash[coach_id][:subs_requested] = data_hash[coach_id][:subs_requested].zero? ? coach.requested.to_i : data_hash[coach_id][:subs_requested]
        data_hash[coach_id][:subs_grabbed]   = data_hash[coach_id][:subs_grabbed].zero? ? coach.grabber.to_i : data_hash[coach_id][:subs_grabbed]
      end

      
      # Part 2 - Sessions/Shift data fetch
      
      sessions_data = Eschool::CoachActivity.activity_report_for_coaches(coach_ids, from, to,lang_array[0])
      sessions_data && sessions_data.each do |coach|
        coach_id = coach['coach_id'].to_s
        data_hash[coach_id][:scheduled_future]        = coach['future_sessions'].to_i
        data_hash[coach_id][:scheduled_past]          = coach['past_uncancelled_sessions_with_coach_shown_up'].to_i + coach['past_cancelled_sessions_with_coach_shown_up_cancelled_after_it_started'].to_i
        data_hash[coach_id][:scheduled_past_solo]     = (coach['past_uncancelled_solo_sessions_with_coach_shown_up'].to_i + coach['past_cancelled_solo_sessions_with_coach_shown_up_cancelled_after_it_started'].to_i) * 0.5
        data_hash[coach_id][:taught_count]            = data_hash[coach_id][:scheduled_past] * 0.5
        data_hash[coach_id][:no_show]                 = coach['past_uncancelled_sessions_with_coach_no_show'].to_i + coach['past_cancelled_sessions_with_coach_no_show_cancelled_after_it_started'].to_i
        data_hash[coach_id][:in_player_totals]        = coach['seconds_prior_to_session'].to_i
        data_hash[coach_id][:cancelled_count]         = coach['future_cancelled_sessions'].to_i + coach['past_cancelled_sessions_cancelled_before_it_started'].to_i

        percent_taught = data_hash[coach_id][:taught_count].zero? ? "N/A" : (data_hash[coach_id][:subs_grabbed].to_f/data_hash[coach_id][:taught_count]).round(4) * 100
        data_hash[coach_id][:pc_taught]         = percent_taught
        in_player_time = data_hash[coach_id][:taught_count].zero? ? "N/A" : ((data_hash[coach_id][:in_player_totals].to_f)/data_hash[coach_id][:taught_count]).round(2)
        data_hash[coach_id][:in_player_time]    = in_player_time
       end
      
      # Part 3 - Time off data fetch

      time_off_data = Coach.time_off(coach_ids, from, to)
      time_off_data.each do |coach|
        coach_id = coach.coach_id.to_s

        total_time_off = (coach.total_time_off.to_f)/(24*60*60)
        total_time_off_int = total_time_off.to_i
        data_hash[coach_id][:total_time_off] = (total_time_off == total_time_off_int )? total_time_off_int : total_time_off.round(2)
        data_hash[coach_id][:total_time_off] = "#{data_hash[coach_id][:total_time_off]} day(s)" if data_hash[coach_id][:total_time_off] > 0

        data_hash[coach_id][:time_offs_requested] = coach.time_offs_requested.to_i
        data_hash[coach_id][:time_offs_denied]    = coach.time_offs_denied.to_i
        data_hash[coach_id][:time_offs_approved]  = coach.time_offs_approved.to_i

      end

      # Part 4 - In/Complete feedback data fetch (API)
      begin
        response = Eschool::Coach.get_session_feedback_per_teacher_counts(coach_list.collect(&:id), from, to)
        if response
          response_xml = REXML::Document.new response.read_body
          teachers = response_xml.elements.to_a( "//teacher")
          teachers.each do |teacher|
            external_coach_id = teacher.get_tag_value('external_coach_id').to_s
            data_hash[external_coach_id][:incomplete_feedbacks] = teacher.get_tag_value('total_sessions').to_i - teacher.get_tag_value('evaluated_sessions').to_i
            data_hash[external_coach_id][:complete_feedbacks]   = teacher.get_tag_value('evaluated_sessions').to_i
          end
        end
      rescue Exception => e
        notify_hoptoad(e)
      end
    end
    data_hash
  end
  
end
