require 'faster_csv'
require File.expand_path('../../validator/staffing_csv_validator', __FILE__)
require File.expand_path('../../parser/staffing_csv_parser', __FILE__)

class StaffingController < ApplicationController
  include Validator::StaffingCsvValidator

  def authenticate
    access_denied unless manager_logged_in?
  end

  def view_report
    self.page_title = 'Staffing Model Reconciliation Report'
  end

  def get_report_data_for_a_week
    result = {};
    week_id = params[:week_id].to_i
    staffing_file_info = StaffingFileInfo.find(week_id)
    report_data = get_report(week_id)
    dates = report_data.collect{ |data| data[:staffing_data][:date_of_the_slot]}.uniq
    result[:report_data] = report_data;
    result[:dates] = dates;
    result[:no_of_slots] = (staffing_file_info.start_of_the_week >= AppUtils.wc_release_date) ? 48 : 24
    render :json => result.to_json, :status => 200
  end

  def export_staffing_report
    week_id = params[:week_id].to_i
    report_data = get_report(week_id)
    report_name = 'Staffing_Model_Report_'+report_data[0][:staffing_data][:slot_time].in_time_zone("Eastern Time (US & Canada)").strftime("%m_%d_%Y")+'.csv'

    csv_content = []
    report_data.each do |r|
      dr = r[:staffing_data]
      csv_content << [ dr[:timeslot_est], dr[:timeslot_kst], dr[:timeslot], dr[:number_of_coaches], dr[:actual_scheduled], dr[:delta], dr[:extra_sessions_scheduled], dr[:extra_sessions_grabbed] ]
    end
    csv_generator = CsvGenerator.new(
      ["#{report_data[0]['time_zone']} Date/Time",'KST Date/Time',"Time Slot (#{report_data[0]['time_zone']})",'Requests Projected','Actual Scheduled',
        'Delta', 'Extra Sessions Scheduled', 'Extra Sessions Grabbed'],
      csv_content
    )
    send_data(csv_generator.to_csv,:type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment", :filename => report_name)
  end

  def get_report(week_id)
    report_data = StaffingData.report_data_for_a_week(week_id)
    staffing_file_info = StaffingFileInfo.find(week_id)
    @end_of_week = (staffing_file_info.start_of_the_week + 1.week - 1.hour)
    report_data_hash = []
    report_data.collect do |slot_data|
      slot_data_hash = {:number_of_coaches => slot_data.number_of_coaches, :slot_time => slot_data.slot_time}
      populate_slot_date_and_time(slot_data_hash)
      populate_extra_sessions_details(slot_data_hash)
      populate_scheduled_sessions_details(slot_data_hash)
      populate_color_scheme(slot_data_hash)
      report_data_hash << { :staffing_data => slot_data_hash }
    end
    report_data_hash
  end

  def show_staffing_file_info
    self.page_title = "ReFLEX Staffing Model Import Management"
    @week_extremes = TimeUtils.week_extremes_for_user
    @staffing_file_info = StaffingFileInfo.paginate(:order => "created_at DESC", :per_page => 10, :page => params[:page] )
  end

  def import_staffing_data
    start_of_the_week = TimeUtils.time_in_user_zone(params["date"])
    staffing_file_info = StaffingFileInfo.create(:start_of_the_week => start_of_the_week,
      :file_name => params["staffing_data"]["file"].original_filename,
      :manager_id => current_user.id,
      :status => "Processing",
      :file => params["staffing_data"]["file"].read)
    Delayed::Job.enqueue(StaffingCsvParser.new(staffing_file_info.id, current_user.id))
    redirect_to show_staffing_file_info_url
  end

  def download_staffing_data_file
    staffing_file_info = StaffingFileInfo.find(params["id"])
    send_data(staffing_file_info.file, :type => 'text/csv', :filename => staffing_file_info.file_name)
  end

  def show_create_extra_session_popup_reflex_smr
    result = {};
    language = Language.find_by_identifier(params[:lang_identifier])
    @coaches = language.coaches
    @lang_id = language.id
    result[:coaches] = @coaches
    result[:lang_id] = @lang_id
    start_time = params[:start_time].gsub('-', '/')
    result[:est_start_time] = start_time
    result[:session_start_time] = time_in_popup_format_for_lotus(start_time)
    render :json => result.to_json, :status => 200
  end

  def create_extra_session_reflex_smr
    extra_session_params = {
      :start_time           => params[:start_time].to_time,
      :name                 => params[:name],
      :lang_identifier      => Language.find_by_id(params[:lang_id]).identifier
    }
    ExtraSession.create_one_off_reflex(extra_session_params, params[:excluded_coaches].split(','))
    render :text => "Extra Session created successfully.", :status => 200
  end


  private

  def populate_slot_date_and_time(slot_data)
    slot_data[:time_zone] = slot_data[:slot_time].in_time_zone("Eastern Time (US & Canada)").strftime("%Z")
    slot_data[:date_of_the_slot] = slot_data[:slot_time].in_time_zone("Eastern Time (US & Canada)").strftime("%a, %m/%d/%Y")
    slot_data[:timeslot_est] = (slot_data[:slot_time].in_time_zone("Eastern Time (US & Canada)")).strftime("%m/%d/%Y %I:%M %p")
    slot_data[:timeslot_kst] = (slot_data[:slot_time].in_time_zone("Seoul")).strftime("%m/%d/%Y %I:%M %p")
    slot_data[:timeslot] = (slot_data[:slot_time].in_time_zone("Eastern Time (US & Canada)")).strftime("%I:%M %p")
    slot_data[:utc_time] = slot_data[:slot_time].to_s(:db)
    daylight_switch_flag = ((slot_data[:slot_time].dst? and !@end_of_week.dst?) || (!slot_data[:slot_time].dst? and @end_of_week.dst?) and slot_data[:timeslot] == "02:00 AM")
slot_data[:enable_create_extra_session] = ((slot_data[:slot_time]+59.minutes).in_time_zone("Eastern Time (US & Canada)") >= Time.now.in_time_zone("Eastern Time (US & Canada)") and !daylight_switch_flag) ? " class=staffing-button " : " disabled=disabled class=staffing-button-disabled "
end

  def populate_extra_sessions_details(slot_data)
    slot_data[:extra_sessions_scheduled] = ExtraSession.get_total_extra_session_count_for_reflex_on_a_slot(slot_data[:slot_time])
    slot_data[:extra_sessions_grabbed] = ExtraSession.get_grabbed_extra_session_count_for_reflex_on_a_slot(slot_data[:slot_time])
  end

  def populate_scheduled_sessions_details(slot_data)
    slot_data[:actual_scheduled] = ConfirmedSession.get_reflex_session_count_for_a_slot(slot_data[:slot_time]) - slot_data[:extra_sessions_grabbed] + slot_data[:extra_sessions_scheduled]
    slot_data[:delta] = slot_data[:actual_scheduled] - slot_data[:number_of_coaches]
  end

  def populate_color_scheme(slot_data)
    case slot_data[:delta]
    when -3..-1
      slot_data[:row_color] = SCHEDULED_UNDER_PROJECTION['1-3']
    when -6..-4
      slot_data[:row_color] = SCHEDULED_UNDER_PROJECTION['4-6']
    when -1000..-7
      slot_data[:row_color] = SCHEDULED_UNDER_PROJECTION['7 or more']
    when 0
      slot_data[:row_color] = SCHEDULED_TO_PROJECTION['0']
    when 1..3
      slot_data[:row_color] = SCHEDULED_ABOVE_PROJECTION['1-3']
    when 4..6
      slot_data[:row_color] = SCHEDULED_ABOVE_PROJECTION['4-6']
    when 7..1000
      slot_data[:row_color] = SCHEDULED_ABOVE_PROJECTION['7 or more']
    end
  end


  def time_in_popup_format_for_lotus(time)
    time = time.to_time
    WEEKDAY_NAMES[time.in_time_zone("Eastern Time (US & Canada)").wday].slice(0,3).upcase + " " + (time.in_time_zone("Eastern Time (US & Canada)")).strftime("%m/%d/%y" ) + " " + (time.in_time_zone("Eastern Time (US & Canada)")).strftime("%I:%M%p")
  end
end
