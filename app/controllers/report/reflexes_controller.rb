require File.dirname(__FILE__) + '/../../utils/coach_activity_fetcher'
require File.dirname(__FILE__) + '/../../presenters/reflex_report_view'
require File.dirname(__FILE__) + '/../../presenters/reflex_report_all_american'
require File.expand_path('../../../utils/task_splitter', __FILE__)
require 'faster_csv'

class Report::ReflexesController < ApplicationController

  before_filter :set_page_title

  def set_page_title
     self.page_title = "Advanced English"
  end
  
  def authenticate
    access_denied unless manager_logged_in?
  end

  def show
    render '_reflex_report', :locals => {:reflexurl_value => 'reflex/generate'}
  end
  
  def generate
    @total = Hash.new { |hash, key| hash[key] = 0 }
    data = get_reflex_report_data
    @coaches = data["coaches"]
    @total[:complete] = data["total_complete"]
    @total[:teaching_complete] = data["total_teaching_complete"]
    @total[:incomplete] = data["total_incomplete"]
    @total = calculate_totals_for_reflex_report(@coaches)
    render :layout => false
  end

  def show_eng
    self.page_title = "All American English"
    render '_reflex_report', :locals => {:reflexurl_value => 'generate_eng'}
  end

  def generate_eng
    @coaches = get_all_american_report_data
    @totals = calculate_totals_for_all_american_report(@coaches)
    render :layout => false
  end

  def export_reflex_report_to_csv
    params[:region] = params[:region_hidden]
    params[:start_date] = params[:start_date_hidden]
    params[:end_date] = params[:end_date_hidden]
    @total = Hash.new { |hash, key| hash[key] = 0 }
    data = get_reflex_report_data
    @coaches = data["coaches"]
    @total[:complete] = data["total_complete"]
    @total[:teaching_complete] = data["total_teaching_complete"]
    @total[:incomplete] = data["total_incomplete"]
    @total = calculate_totals_for_reflex_report(@coaches)
    report_name = "ReFLEX_Report_#{params[:start_date].to_time.strftime("%m%d%Y")}_to_#{params[:end_date].to_time.strftime("%m%d%Y")}.csv"

    csv_content = []
    @coaches.each do |r|
      csv_content << [ r.coach_name,r.hours_count,r.hours_in_player,r.paused,r.per_paused,r.avg_session,
        r.incomplete,r.complete,
        r.substitution,r.grabbed, r.requested.to_s+'/'+r.approved.to_s, r.denied, r.total_time_off ]
    end
    csv_content << [ "Language Total",@total[:hours_count],@total[:hours_in_player],@total[:paused],@total[:per_paused],@total[:avg_session],
      @total[:incomplete],@total[:complete],@total[:substitution],@total[:grabbed], @total[:requested].to_s+'/'+@total[:approved].to_s,
      @total[:denied],@total[:total_time_off]
    ]
    csv_generator = CsvGenerator.new(
      ['Coach Name','Hours Scheduled','Hours in Player','Mins Paused','% Paused', 'Avg Session (Mins)',
      '% Incomplete', 'Completed sessions',
      'Substitutions - Requested','Substitutions - Grabbed','Time Off - Requested/Approved',
      'Time Off - Denied','Time Off - Total Duration'], csv_content
    )
    send_data(csv_generator.to_csv,:type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment", :filename => report_name)
  end

  def export_all_american_report_to_csv
    params[:region] = params[:region_hidden]
    params[:start_date] = params[:start_date_hidden]
    params[:end_date] = params[:end_date_hidden]

    @coaches = get_all_american_report_data
    @totals = calculate_totals_for_all_american_report(@coaches)
    report_name = "All_American_Report_#{params[:start_date].to_time.strftime("%m%d%Y")}_to_#{params[:end_date].to_time.strftime("%m%d%Y")}.csv"

    csv_content = []
    @coaches.each do |r|
      csv_content << [ r.coach_name, r.scheduled_totale, r.scheduled_reflex, r.scheduled_total,r.taught_reflex,r.mins_paused,
        r.per_paused,r.avg_session,r.per_incomplete,r.no_show_totale,r.cancelled,r.incomplete_feedbacks.to_s+'/'+r.complete_feedbacks.to_s,
        r.complete,r.taught_total, r.requested_totale, r.requested_reflex, r.requested_total, r.grabbed_totale, r.grabbed_reflex,
        r.grabbed_total, r.in_player, r.requested.to_s+'/'+r.approved.to_s, r.denied, r.total_time_off ]
    end
    csv_content << [ "Language Total", @totals[:scheduled_totale], @totals[:scheduled_reflex], @totals[:scheduled_total],@totals[:taught_reflex],@totals[:mins_paused],
        @totals[:per_paused],@totals[:avg_session],@totals[:per_incomplete],@totals[:no_show_totale],@totals[:cancelled],@totals[:incomplete_feedbacks].to_s+'/'+@totals[:complete_feedbacks].to_s,
        @totals[:complete],@totals[:taught_total], @totals[:requested_totale], @totals[:requested_reflex], @totals[:requested_total], @totals[:grabbed_totale], @totals[:grabbed_reflex],
        @totals[:grabbed_total], (@totals[:in_player] == 0 ? "N/A" : @totals[:in_player]), @totals[:requested].to_s+'/'+@totals[:approved].to_s, @totals[:denied], @totals[:total_time_off] ]
    csv_generator = CsvGenerator.new(
      ['Coach Name','Scheduled TOTALe','Scheduled ReFLEX','Scheduled Total','Taught ReFLEX', 'Mins Paused',
      '% Paused', 'Avg Session (Mins)','% Incomplete','No Show TOTALe','Canceled TOTALe','Feedback','Completed sessions (Reflex)',
      'Total Taught','Substitutions - Requested TOTALe','Substitutions - Requested ReFLEX','Substitutions - Requested Total',
      'Substitutions - Grabbed TOTALe','Substitutions - Grabbed ReFLEX','Substitutions - Grabbed Total',
      'In Player (min) prior to session (TOTALe)','Time Off - Requested / Approved','Time Off - Denied','Time Off - Total Duration'], csv_content
    )
    send_data(csv_generator.to_csv,:type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment", :filename => report_name)
  end

  private

  def get_reflex_report_data
    lang_identifiers    = ProductLanguages.reflex_language_codes
    from_date           = TimeUtils.time_in_user_zone(params[:start_date]).utc
    to_date             = TimeUtils.time_in_user_zone(params[:end_date]).utc
    start_date_db       = from_date.to_s(:db)
    end_date_db         = to_date.to_s(:db)
    reflex_coaches      = Coach.coach_ids_of_that_language(lang_identifiers,start_date_db,end_date_db,params[:region])
    reflex_report_view  = ReflexReportView.new(reflex_coaches)
    coach_ids           = reflex_coaches.collect(&:id)
    subs_data           = Coach.substitution_grabbed(coach_ids,start_date_db,end_date_db, lang_identifiers)
    coach_data          = CoachSession.no_of_hours_coach_scheduled(coach_ids,lang_identifiers,from_date,to_date)
    time_off_data       = Coach.time_off(coach_ids, start_date_db, end_date_db)
    eve_data            = CoachActivityFetcher.new(coach_ids,from_date, to_date).coach_session_details
    reflex_report_view.populate(subs_data, coach_data, time_off_data,eve_data)
    reflex_report_view.get_complete_advanced_english_report()
  end

  def get_all_american_report_data
    lang_identifiers = ["ENG","KLE"]
    from_date = TimeUtils.time_in_user_zone(params[:start_date]).utc
    to_date = TimeUtils.time_in_user_zone(params[:end_date]).utc
    start_date_db = from_date.to_s(:db)
    end_date_db = to_date.to_s(:db)
    reflex_coaches = Coach.coach_ids_of_that_language(lang_identifiers,start_date_db,end_date_db,params[:region])
    coach_info = reflex_coaches.collect {|coach_obj| {:coach_id => coach_obj.id, :name => coach_obj.full_name}}
    lang_array = ['ENG']
    coaches = []
    @total = Hash.new { |hash, key| hash[key] = 0 }
    unless reflex_coaches.empty?
      proc_task = Proc.new { |coach_info, params|
        reflex_report_all_american_view = ReflexReportAllAmerican.new(coach_info)
        coaches = coach_info.map { |hash| hash[:coach_id]}  
        time_off_data = Coach.time_off(coaches, start_date_db, end_date_db)
        coach_data = CoachSession.no_of_hours_coach_scheduled(coaches, "KLE", from_date, to_date)
        subs_data_kle = Coach.substitution_grabbed(coaches, start_date_db, end_date_db, 'KLE')
        subs_data_eng = Coach.substitution_grabbed(coaches, start_date_db, end_date_db, lang_array[0])
        eve_data = CoachActivityFetcher.new(coaches, from_date, to_date).coach_session_details
        sessions_data = Eschool::CoachActivity.activity_report_for_coaches(coaches, start_date_db, end_date_db, lang_array)
        response_feedback  = Eschool::Coach.get_session_feedback_per_teacher_counts(coaches, start_date_db, end_date_db)
        reflex_report_all_american_view.populate(subs_data_kle, subs_data_eng, coach_data, time_off_data, eve_data, sessions_data, response_feedback)
        data = reflex_report_all_american_view.get_totals
        @total[:complete] += data["total_complete"]
        @total[:teaching_complete] += data["total_teaching_complete"]
        @total[:incomplete] += data["total_incomplete"]
        reflex_report_all_american_view.get_complete_all_american_english_report
      }

      split_count = ((to_date - from_date) / 1.month) > 1 ? 10 : 30
      splitter  = TaskSplitter.new(proc_task, coach_info, {:split_count => split_count, :start_date => from_date.to_s(:db), :to_date => to_date.to_s(:db), :lang_array => lang_array})
      coaches = splitter.perform
    end
    coaches = ReflexReportAllAmerican.sort_based_on_full_name(coaches)
  end

  def calculate_totals_for_reflex_report(coaches)
    totals = {:hours_count =>0, :hours_in_player=>0, :paused=>0, :per_paused=>0, :avg_session=>0, :incomplete=>0, :complete=>0, 
      :substitution=>0, :grabbed=>0, :requested=>0, :approved=>0, :denied=>0, :total_time_off=>0 }
    coaches.each do |coach|
      totals[:hours_count] += coach.hours_count.to_f
      totals[:hours_in_player] += coach.hours_in_player.to_f
      totals[:paused] += coach.paused.to_f
      totals[:avg_session] += coach.avg_session.to_f
      totals[:incomplete] += coach.incomplete.to_f
      totals[:substitution] += coach.substitution.to_i
      totals[:grabbed] += coach.grabbed.to_i
      totals[:requested] += coach.requested.to_i
      totals[:approved] += coach.approved.to_i
      totals[:denied] += coach.denied.to_i
      totals[:total_time_off] += coach.total_time_off.to_f
    end
    totals[:per_paused] = totals[:hours_in_player].zero? ? totals[:hours_in_player] :((totals[:paused]*100)/(totals[:hours_in_player]*60)).to_f.round(2)
    totals[:avg_session] = @total[:complete].zero? ? @total[:complete] : (@total[:teaching_complete]/@total[:complete]).to_f.round(2) 
    totals[:incomplete] = (@total[:complete]+@total[:incomplete]).zero? ? 0 : (((@total[:incomplete])/(@total[:complete]+@total[:incomplete]))*100).to_f.round(2)
    totals[:hours_in_player] = totals[:hours_in_player].to_f.round(2)
    totals
  end

  def calculate_totals_for_all_american_report(coaches)
    totals = {:scheduled_totale =>0, :scheduled_reflex=>0, :scheduled_total=>0, :taught_reflex=>0, :mins_paused=>0, :per_paused=>0, :avg_session=>0, 
      :per_incomplete=>0, :no_show_totale=>0, :cancelled=>0, :incomplete_feedbacks=>0, :complete_feedbacks=>0, :complete=>0, :taught_total=>0, 
      :requested_reflex=>0, :requested_totale=>0, :requested_total=>0, :grabbed_totale=>0, :grabbed_reflex=>0, :grabbed_total=>0, :in_player=>0,
      :requested=>0, :approved=>0, :denied=>0, :total_time_off=>0 }
     coaches.each do |coach|
      totals[:scheduled_totale] += coach.scheduled_totale.to_i
      totals[:scheduled_reflex] += coach.scheduled_reflex.to_i
      totals[:scheduled_total] += coach.scheduled_total.to_i
      totals[:taught_reflex] += coach.taught_reflex.to_f
      totals[:mins_paused] += coach.mins_paused.to_f
      totals[:no_show_totale] += coach.no_show_totale.to_i
      totals[:cancelled] += coach.cancelled.to_i
      totals[:incomplete_feedbacks] += coach.incomplete_feedbacks.to_i
      totals[:complete_feedbacks] += coach.complete_feedbacks.to_i
      totals[:complete] += coach.complete.to_i
      totals[:taught_total] += coach.taught_total.to_f
      totals[:requested_reflex] += coach.requested_reflex.to_i
      totals[:requested_totale] += coach.requested_totale.to_i
      totals[:requested_total] += coach.requested_total.to_i
      totals[:grabbed_totale] += coach.grabbed_totale.to_i
      totals[:grabbed_reflex] += coach.grabbed_reflex.to_i
      totals[:grabbed_total] += coach.grabbed_total.to_i
      totals[:in_player] += (coach.in_player == "N/A" ? 0 : coach.in_player).to_f
      totals[:requested] += coach.requested.to_i
      totals[:approved] += coach.approved.to_i
      totals[:denied] += coach.denied.to_i
      totals[:total_time_off] += coach.total_time_off.to_f
    end
    totals[:taught_reflex] = totals[:taught_reflex].to_f.round(2)
    totals[:per_paused] = totals[:taught_reflex].zero? ? totals[:taught_reflex] :((totals[:mins_paused]*100)/(totals[:taught_reflex]*60)).to_f.round(2)
    totals[:avg_session] = @total[:complete].zero? ? @total[:complete] : (@total[:teaching_complete]/@total[:complete]).to_f.round(2) 
    totals[:per_incomplete] = (@total[:complete]+@total[:incomplete]).zero? ? 0 : ((@total[:incomplete]*100)/(@total[:complete]+@total[:incomplete])).to_f.round(2)
    totals
  end
end

