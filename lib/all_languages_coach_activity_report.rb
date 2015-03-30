require File.expand_path('../../app/utils/coach_activity_report_utils', __FILE__)
require 'csv'

class AllLanguagesCoachActivityReport < Struct.new(:current_user_id, :start_time, :end_time, :region, :time, :timeframe)
  
  def perform
    coach_manager = CoachManager.find_by_id(current_user_id)
    all_coaches = []
    report_location = '/tmp/coach_activity_report_for_all_languages.csv'
    car_report = File.new(report_location, 'w')

    CSV::Writer.generate(car_report , ',') do |title|
      title << ['Language', 'Coach Name', 'Scheduled Past', 'Scheduled Future', 'Taught', 'No Show', 'Cancelled',
        'Incomplete Feedback', 'Complete Feedback', 'Requested Subs', 'Grabbed Subs', '% of taught',
        'Time offs Requested', 'Time offs Approved', 'Time offs Denied', 'Total Duration', 'In player (min)prior to session']
      coach_manager.languages.select { |lang| lang.is_totale?}.each do |lang|
        language_identifier = [lang.identifier]
        name = lang.display_name
        data_hash = CoachActivityReportUtils.fetch_report_for_languages(language_identifier, region, start_time, end_time)
        coaches = sort_based_on_full_name(data_hash)
        if lang.identifier == 'KLE'
          make_some_field_na_for_kle(coaches)
        end
        all_coaches += coaches
        coaches.each do |r|
          title << [name, r[:full_name],r[:scheduled_past],r[:scheduled_future],r[:taught_count],r[:no_show],r[:cancelled_count],
            r[:incomplete_feedbacks],r[:complete_feedbacks],
            r[:subs_requested],r[:subs_grabbed], r[:pc_taught],
            r[:time_offs_requested],r[:time_offs_approved],r[:time_offs_denied],r[:total_time_off],
            r[:in_player_time]
          ]
        end
      end
      totals  = calculate_totals_and_averages(all_coaches)
      title << ["", "Total for All Languages",totals[:scheduled_past],totals[:scheduled_future], totals[:taught],totals[:no_show],totals[:cancelled],
        totals[:incomplete_feedback],totals[:complete_feedback],
        totals[:subs_requested],totals[:subs_grabbed], totals[:pc_taught],
        totals[:requested_time_offs],totals[:approved_time_offs],totals[:denied_time_offs],totals[:total_time_off],
        totals[:in_player_time]
      ]
    end
    car_report.close
    GeneralMailer.send_all_languages_coach_activity_reports(coach_manager, report_location, time, start_time, end_time, timeframe).deliver
  end

  def calculate_totals_and_averages(coaches)
    totals = {:scheduled_past => 0, :scheduled_future => 0, :taught => 0, :no_show => 0, :cancelled => 0,
      :incomplete_feedback => 0, :complete_feedback => 0,
      :subs_requested => 0, :subs_grabbed => 0, :pc_taught => 0,
      :requested_time_offs => 0, :approved_time_offs => 0, :denied_time_offs => 0, :total_time_off => 0,
      :in_player_totals => 0
    }
    ids = []
    coaches.each do |coach|
      totals[:scheduled_past]       += coach[:scheduled_past].to_i
      totals[:scheduled_future]     += coach[:scheduled_future].to_i
      totals[:taught]               += coach[:taught_count].to_i
      totals[:no_show]              += coach[:no_show].to_i
      totals[:cancelled]            += coach[:cancelled_count].to_i

      totals[:incomplete_feedback]  += coach[:incomplete_feedbacks].to_i
      totals[:complete_feedback]    += coach[:complete_feedbacks].to_i

      totals[:subs_requested]       += coach[:subs_requested].to_i
      totals[:subs_grabbed]         += coach[:subs_grabbed].to_i

      unless ids.include?(coach[:id])
        totals[:requested_time_offs]  += coach[:time_offs_requested].to_i
        totals[:approved_time_offs]   += coach[:time_offs_approved].to_i
        totals[:denied_time_offs]     += coach[:time_offs_denied].to_i
        totals[:total_time_off]       += coach[:total_time_off].to_f
        ids << coach[:id]
      end
      totals[:in_player_totals]     += coach[:in_player_totals].to_i
    end

    totals[:pc_taught]      = totals[:taught].zero? ? "N/A" : (totals[:subs_grabbed].to_f/totals[:taught]).round(4) * 100
    totals[:in_player_time] = totals[:taught].zero? ? "N/A" : (totals[:in_player_totals].to_f/totals[:taught]).round(2)
    total_time_off_int = totals[:total_time_off].to_i
    totals[:total_time_off] = (totals[:total_time_off]  ==  total_time_off_int) ?  total_time_off_int :  totals[:total_time_off].round(2)
    totals[:total_time_off] = "#{totals[:total_time_off]} day(s)" if totals[:total_time_off] > 0
    totals
  end

  def sort_based_on_full_name(hash)
    data = []
    details_array = hash.sort_by {|id, details_hash| details_hash[:full_name]}
    details_array.each do |detail|
      temp_hash = {}
      temp_hash[:id] = detail[0]
      data  << temp_hash.merge(detail[1])
    end
    data
  end

  def make_some_field_na_for_kle(coaches)
    coaches.each do |coach|
      coach[:cancelled_count] = "N/A"
      coach[:incomplete_feedbacks] = "N/A"
      coach[:complete_feedbacks] = "N/A"
      coach[:in_player_time] = "N/A"
    end
  end

end
