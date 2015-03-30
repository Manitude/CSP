require 'csv'
class ReportController < ApplicationController
  
  def authenticate
    access_denied unless manager_logged_in?
  end

  def index
    self.page_title = 'Coach Activity Report'
  end

  def get_qualified_coaches_for_language
    if params[:lang_identifier] == "all"
      active_coaches = []
      current_user.languages.select { |lang| lang.is_totale?}.each do |lang|
        active_coaches += lang.coaches
      end
      display_name   = "All Languages"
    else
      language = Language[params[:lang_identifier]]
      active_coaches = language.coaches
      display_name   = language.display_name
    end
    render :text => "<b>#{active_coaches.uniq.size}</b> active coaches are qualified to teach <b>#{display_name}</b>"
  end

  
  def get_report_ui
    if params[:lang_identifier] == "all"
      @all_language_report = true
      range = get_time_range(params[:timeframe], params[:start_date], params[:end_date])
      time = TimeUtils.format_time(Time.now, "%m/%d/%Y %I:%M%p %Z")
      Delayed::Job.enqueue(AllLanguagesCoachActivityReport.new(current_user.id, range[:from], range[:to], params[:region], time, params[:timeframe]), 0)    
    else
      get_report(params)
    end
    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          page.replace_html 'coach_report_data', :partial => 'report_table.html.erb'
        end
      } if request.xhr?
    end
  end

  def export_car_to_csv
    params[:timeframe] = params[:timeframe_hidden]
    params[:region] = params[:region_hidden]
    params[:lang_identifier] = params[:lang_identifier_hidden]
    params[:start_date] = params[:start_date_hidden]
    params[:end_date] = params[:end_date_hidden]
    get_report(params)

    report_location = '/tmp/coach_activity_report_report.csv'

    car_report = File.new(report_location, 'w')
    CSV::Writer.generate(car_report , ',') do |title|
      title << ['Coach Name','Scheduled Past','Scheduled Future','Taught', 'Solo','No Show', 'Canceled',
        'Incomplete Feedback', 'Complete Feedback',
        'Requested Subs','Grabbed Subs','% of taught',
        'Time offs Requested','Time offs Approved','Time offs Denied', 'Time Off - Total Duration',
        'In player (min)prior to session']
      @coaches.each do |r|
        title << [ r[:full_name],r[:scheduled_past],r[:scheduled_future],r[:taught_count], r[:scheduled_past_solo], r[:no_show],r[:cancelled_count],
          r[:incomplete_feedbacks],r[:complete_feedbacks],
          r[:subs_requested],r[:subs_grabbed], r[:pc_taught],
          r[:time_offs_requested],r[:time_offs_approved],r[:time_offs_denied],r[:total_time_off],
          r[:in_player_time]
        ]
      end
      title << [ "Language Total",@totals[:scheduled_past],@totals[:scheduled_future], @totals[:taught], @totals[:scheduled_past_solo], @totals[:no_show],@totals[:cancelled],
        @totals[:incomplete_feedback],@totals[:complete_feedback],
        @totals[:subs_requested],@totals[:subs_grabbed], @totals[:pc_taught],
        @totals[:requested_time_offs],@totals[:approved_time_offs],@totals[:denied_time_offs],@totals[:total_time_off],
        @totals[:in_player_time]
      ]
    end
    car_report.close
    send_file(report_location, :type => "text/csv", :charset => "utf-8")
  end

  def about_report_data
    render :partial => 'about_report_data'
  end

  private

  def get_report(params)
    # Part 0 - Preparation
    data_hash = {}
    range = get_time_range(params[:timeframe], params[:start_date], params[:end_date])
    lang_array = [params[:lang_identifier]]
    data_hash = CoachActivityReportUtils.fetch_report_for_languages(lang_array, params[:region], range[:from], range[:to])
    @coaches = sort_based_on_full_name(data_hash)
    @totals  = calculate_totals_and_averages(@coaches)
    @coaches = mark_some_coach_fields_as_na_for_future_sessions(@coaches)
    @totals  = mark_some_total_fields_as_na_for_future_sessions(@totals)
    if params[:lang_identifier] == 'KLE'
      result = mark_some_fields_as_na_for_advanced_english(@coaches,@totals)
      @coaches = result[:coaches]
      @totals  = result[:totals]
    end
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

  def mark_some_coach_fields_as_na_for_future_sessions(coaches)
    coaches.each do |coach|
      if coach[:scheduled_past].zero?
        coach[:taught_count]         = "N/A" if coach[:taught_count] == 0
        coach[:scheduled_past_solo]  = "N/A" if coach[:scheduled_past_solo] == 0
        coach[:no_show]              = "N/A" unless  coach[:no_show] > 0
        coach[:incomplete_feedbacks] = "N/A"
        coach[:complete_feedbacks]   = "N/A"
        coach[:in_player_time]       = "N/A" if coach[:in_player_time] == 0
      end
     end
    coaches
  end

  def mark_some_total_fields_as_na_for_future_sessions(totals)
    totals[:in_player_time]         = "N/A" if ["KLE", "ALL_AMERICAN"].include?(params[:lang_identifier])
    if totals[:scheduled_past].zero?
      totals[:taught]               = "N/A" if totals[:taught] == 0
      totals[:scheduled_past_solo]  = "N/A" if totals[:scheduled_past_solo] == 0
      totals[:no_show]              = "N/A" unless totals[:no_show] > 0
      totals[:incomplete_feedback]  = "N/A"
      totals[:complete_feedback]    = "N/A"
      totals[:in_player_time]       = "N/A" if totals[:in_player_time] == 0
    end
    totals
  end

  def mark_some_fields_as_na_for_advanced_english(coaches,totals)
    coaches.each do |coach|
      coach[:in_player_time]    = "N/A" if ["KLE", "ALL_AMERICAN"].include?(params[:lang_identifier])
      coach[:scheduled_future]  = "N/A"
      coach[:cancelled_count]   = "N/A"
      coach[:no_show]       = "N/A"
    end
    totals[:no_show] = "N/A"
    totals[:scheduled_future]   = "N/A"
    totals[:cancelled]    = "N/A"
    {:coaches => coaches, :totals => totals}
  end
  
  def calculate_totals_and_averages(coaches)
    totals = {:scheduled_past => 0, :scheduled_future => 0, :taught => 0, :scheduled_past_solo => 0,  :no_show => 0, :cancelled => 0,
      :incomplete_feedback => 0, :complete_feedback => 0,
      :subs_requested => 0, :subs_grabbed => 0, :pc_taught => 0,
      :requested_time_offs => 0, :approved_time_offs => 0, :denied_time_offs => 0, :total_time_off => 0,
      :in_player_totals => 0
    }

    coaches.each do |coach|
      totals[:scheduled_past]       += coach[:scheduled_past].to_i
      totals[:scheduled_future]     += coach[:scheduled_future].to_i
      totals[:taught]               += coach[:taught_count].to_f
      totals[:scheduled_past_solo]  += coach[:scheduled_past_solo].to_f
      totals[:no_show]              += coach[:no_show].to_i
      totals[:cancelled]            += coach[:cancelled_count].to_i

      totals[:incomplete_feedback]  += coach[:incomplete_feedbacks].to_i
      totals[:complete_feedback]    += coach[:complete_feedbacks].to_i

      totals[:subs_requested]       += coach[:subs_requested].to_i
      totals[:subs_grabbed]         += coach[:subs_grabbed].to_i

      totals[:requested_time_offs]  += coach[:time_offs_requested].to_i
      totals[:approved_time_offs]   += coach[:time_offs_approved].to_i
      totals[:denied_time_offs]     += coach[:time_offs_denied].to_i
      totals[:total_time_off]       += coach[:total_time_off].to_f
      totals[:in_player_totals]     += coach[:in_player_totals].to_i
    end

    totals[:pc_taught]      = totals[:taught].zero? ? "N/A" : (totals[:subs_grabbed].to_f/totals[:taught]).round(4) * 100
    totals[:in_player_time] = totals[:taught].zero? ? "N/A" : (totals[:in_player_totals].to_f/totals[:taught]).round(2)
    total_time_off_int = totals[:total_time_off].to_i
    totals[:total_time_off] = (totals[:total_time_off]  ==  total_time_off_int) ?  total_time_off_int :  totals[:total_time_off].round(2)
    totals[:total_time_off] = "#{totals[:total_time_off]} day(s)" if totals[:total_time_off] > 0
    totals
  end


  def time_off_falls_in(udt_table_alias, from, to)
    "(#{udt_table_alias}.end_date >= '#{from}' AND #{udt_table_alias}.start_date <= '#{to}')"
  end

  def generate_report_for_all_langauges(params)
    report_location = '/tmp/coach_activity_report_for_all_languages.csv'
    car_report = File.new(report_location, 'w')
    CSV::Writer.generate(car_report , ',') do |title|
      title << ['Language','Coach Name','Scheduled Past','Scheduled Future','Taught','No Show', 'Canceled',
        'Incomplete Feedback', 'Complete Feedback',
        'Requested Subs','Grabbed Subs','% of taught',
        'Time offs Requested','Time offs Approved','Time offs Denied', 'Avg. Duration',
        'In player (min)prior to session']
      current_user.languages.select { |lang| lang.is_totale?}.each do |language|
        params[:lang_identifier] = language.identifier
        get_report(params)
        @coaches.each do |r|
          title << [ r[:full_name],r[:scheduled_past],r[:scheduled_future],r[:taught_count],r[:no_show],r[:cancelled_count],
            r[:incomplete_feedbacks],r[:complete_feedbacks],
            r[:subs_requested],r[:subs_grabbed], r[:pc_taught],
            r[:time_offs_requested],r[:time_offs_approved],r[:time_offs_denied],r[:avg_duration],
            r[:in_player_time]
          ]
      end
      end
      title << [ "Language Total",@totals[:scheduled_past],@totals[:scheduled_future], @totals[:taught],@totals[:no_show],@totals[:cancelled],
        @totals[:incomplete_feedback],@totals[:complete_feedback],
        @totals[:subs_requested],@totals[:subs_grabbed], @totals[:pc_taught],
        @totals[:requested_time_offs],@totals[:approved_time_offs],@totals[:denied_time_offs],@totals[:avg_duration],
        @totals[:in_player_time]
      ]
    end
    car_report.close
  end

end
