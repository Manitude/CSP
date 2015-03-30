require 'csv'
require 'will_paginate/array' 
require File.dirname(__FILE__) + '/../../utils/learner/advanced_search'
require File.dirname(__FILE__) + '/../../utils/learner/learner_mapper'
require File.dirname(__FILE__) + '/../../utils/learner/primary_search'
require File.dirname(__FILE__) + '/../../utils/learner/learner_search_factory'

class Extranet::LearnersController < ApplicationController

  before_filter :get_learners, :only => [:show, :learner_details, :course_info_detail, :rworld_social_app_info, :audit_logs, :game_history, :user_interaction, :user_invite_history, :chat_history, :selected_learner_chat_history, :detailed_chat_history, :logged_in_history, :learner_studio_history]

  def index
    self.page_title = ""
  end

  def show
    if params[:view_access]
      self.page_title = "View Access Log"
      @view_access_flag = true
    else
      self.page_title = ""
      @page_title_new = "Learner Profile - " + @learner.name
      @view_access_flag = false
    end
    @date = TimeUtils.time_in_user_zone.to_date
    languages = @learner.languages
    languages << @learner.simbio_language_identifier if !@learner.simbio_language_identifier.blank?
    user_session_log = @learner.user_session_log
    @days_logged_in = user_session_log.collect{|d| TimeUtils.format_time(d.session_start_time, "%Y-%m-%d")}
    @last_logged_in = TimeUtils.format_time((user_session_log.last).session_start_time, "%A %b %d, %Y %H:%M:%S") unless user_session_log.empty?
    @baffler_time_spent_on_languages = @learner.baffler_time_spent_on_languages
    baffler_social_app_languages = @learner.baffler_social_app_languages || []
    @baffler_social_app_languages = @learner.reflex_languages.blank? ? baffler_social_app_languages : (languages & baffler_social_app_languages)
    language = @baffler_social_app_languages.first unless @baffler_social_app_languages.blank?
    @baffler_details = @learner.baffler_details(language)
    @connections_count = @learner.acquaintances_count
    @coach = current_user
    @baffler_course_tracking_info = @learner.baffler_course_tracking_info(params[:lang])
    @lang = params[:lang]
    @level = params[:level] 
    if !@baffler_course_tracking_info.nil?
      @lang ||= @baffler_course_tracking_info["language"]
      progressed_languages = [@baffler_course_tracking_info["progressed_languages"].try(:[],"language")].compact.flatten
      @level||= progressed_languages.empty? ? nil : (levels = progressed_languages.detect{|s| s["code"] == @lang }.try(:[],"levels")).nil? ? nil : levels.values.flatten.first.to_i
    end
      @baffler_path_scores = @learner.baffler_path_scores_for_language_and_level(@lang, @level)
    begin
      result = @learner.get_product_details
    rescue Exception => e
      result = {}
    end
    @language_display_name = result[:language_display_name]
    @projected_through = result[:projected_through]
    render :layout => false if params[:is_combined_page] == "true"
  end

  def learner_details
    @learner_type = @learner.learner_type
    @language_display_name = {}
    begin
      license_details = ls_api.license.details(:guid => params[:license_guid])
      creation_account = ls_api.creation_account.details(:creation_account_guid => license_details["creation_account_guid"])
      @family = (creation_account["type"] == "date_range") ? "" : "("+get_formatted_type(creation_account["type"])+")"
      result = @learner.get_product_details
      @language_display_name = result[:language_display_name]
    rescue Exception => e
      @error = "License Information is not available for the given identifier/GUID."
    end
    render :partial => 'learner_details'
  end

  def my_calendar
    @date = TimeUtils.time_in_user_zone(params[:date]).to_date
    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          page.replace_html 'calendar', :partial => 'shared/extranet/my_calendar', :locals=>{:days_logged_in => (params[:days] || [])}
        end
      } if request.xhr?
    end
  end

  def learner_search_info
     render :partial => 'extranet/learners/learner_search_info'
  end

  def search_result
    self.page_title = ""
    if params[:fname].blank? && params[:lname].blank? && params[:email].blank? && params[:phone_number].blank? && params[:search_id].blank? && params[:username].blank?
      error = "Please provide a query to search."
    else
      response = LearnerSearchFactory.create(params).search
      response[:error] ? error = response[:error] : learners = response[:result]
    end
    
    if error
      flash[:error] = error
      redirect_to learners_path
    else
      @learners_data = learners_data_from_learners(learners)
      @learners_data = @learners_data && @learners_data.paginate(:per_page => 10, :page =>params[:page])
      render :action => :index
    end
  end

  def course_info_detail
    @baffler_course_tracking_info = @learner.baffler_course_tracking_info(params[:lang])
    if @baffler_course_tracking_info.nil?
      @baffler_path_scores = @learner.baffler_path_scores_for_language_and_level(params[:lang],params[:level])
    else
      @lang = params[:lang] || @baffler_course_tracking_info["language"]
      progressed_languages = [@baffler_course_tracking_info["progressed_languages"].try(:[],"language")].compact.flatten
      @level = params[:level] || progressed_languages.empty? ? nil : (levels = progressed_languages.detect{|s| s["code"] == @lang }.try(:[],"levels")).nil? ? nil : levels.values.flatten.first.to_i
      @baffler_path_scores = @learner.baffler_path_scores_for_language_and_level(@lang, @level)
    end
  end

  def rworld_social_app_info
    baffler_details = @learner.baffler_details(params[:language])
    render :partial => "rworld_lang_info", :locals => { :baffler_details => baffler_details }
  end

  def audit_logs
    render :template  => "extranet/learners/community_learner_audit_log_history", :locals => {:audit_logs => @learner.community_learner_audit_logs}
  end

  def game_history
    page = params[:page] ? params[:page] : 1
    user_game_history = @learner.user_game_history(page)
    guids = {}
    if user_game_history
      [user_game_history["game_history"]["participation"]].flatten.each do |participant|
        if participant && participant["partner_guid"]
          if participant["partner_guid"].is_a? Array
            participant["partner_guid"].each do |p_guid|
              guids[p_guid] = false if p_guid
            end
          else
            guids[participant["partner_guid"]] = false if participant["partner_guid"]
          end
        end
      end
      CommunityApi::Util.email_for_guids(guids)
      @guids = guids
    end
    render :template  => "extranet/learners/user_game_history", :locals => { :user_game_history => user_game_history }
  end

  def user_interaction
    page = params[:page] ? params[:page] : 1
    user_interactions = @learner.user_interactions(page)
    render :template  => "extranet/learners/user_interactions", :locals => { :user_interactions => user_interactions }
  end

  def user_invite_history
    page = params[:page] ? params[:page] : 1
    user_invite_history = @learner.user_invite_history(page)
    guids = {}
    if user_invite_history && user_invite_history["invitation"]
      [user_invite_history["invitation"]].flatten.each do |participant|
        if participant && participant["partner_guid"]
          if participant["partner_guid"].is_a? Array
            participant["partner_guid"].each do |p_guid|
              guids[p_guid] = false if p_guid
            end
          else
            guids[participant["partner_guid"]] = false if participant["partner_guid"]
          end
        end
      end
      CommunityApi::Util.email_for_guids(guids)
      @guids = guids
    end
    render :template  => "extranet/learners/user_invite_history", :locals => { :user_invite_history => user_invite_history }
  end

  def chat_history
    page = params[:page] ? params[:page] : 1
    chat_history = @learner.chat_history(page)
    guids = {}
    if chat_history && chat_history["conversation"]
      [chat_history["conversation"]].flatten.each do |conv_history|
        [conv_history["messages"]["message"]].flatten.each {|message| guids[message["sender"]] = false if message["sender"]}
      end
      CommunityApi::Util.email_for_guids(guids)
      [chat_history["conversation"]].flatten.each do |conv_history|
        [conv_history["messages"]["message"]].flatten.each do |message|
          message["email"] = guids[message["sender"]] ? guids[message["sender"]] : '[email not found]'
        end
      end
    end
    render :template  => "extranet/learners/chat_history", :locals => { :chat_history => chat_history }
  end

  def selected_learner_chat_history
    self.page_title = "Chat History"
    timeframe_range = params[:timeframe_range].blank? ? 'Today' : params[:timeframe_range]

    range = get_time_range(timeframe_range, params[:start_date], params[:end_date])
    start_date = URI.escape(range[:from].to_time.strftime("%Y-%m-%d %H:%M:%S"))
    end_date = URI.escape(range[:to].to_time.strftime("%Y-%m-%d %H:%M:%S"))
    chat_history = @learner.selected_learner_chat_history(params[:page], params[:number_of_records], start_date , end_date, params[:conversation_type])
    conversations = chat_history["conversations"]["conversation"] if chat_history and chat_history["conversations"] 
    chat_data = []
    if conversations && conversations.is_a?(Array)
      conversations = conversations.sort_by{|conversation| conversation["id"].to_i}
      conversations.each do |conversation|
        messages = [conversation["messages"]["message"]]
        messages = messages.flatten
        # messages = messages.index_by{|m| m["message-time"]}.values && messages.index_by{|m| m["message"]}.values
        # messages = messages.sort_by{|message| message["message-time"].to_time.to_i}
        messages.reverse.each do |message|
          chat_data << generate_chat_data(message, conversation)
        end
      end
    elsif conversations && conversations.is_a?(Hash)
      messages = [conversations["messages"]["message"]]
      messages = messages.flatten
      # messages = messages.index_by{|m| m["message-time"]}.values && messages.index_by{|m| m["message"]}.values
      # messages = messages.sort_by{|message| message["message-time"].to_time.to_i}
      messages.reverse.each do |message|
        chat_data << generate_chat_data(message, conversations)
      end
    end
    total_pages = (chat_history && chat_history["pagination"]) ? chat_history["pagination"]["total-pages"].to_i : nil
    current_page = (chat_history && chat_history["pagination"]) ? chat_history["pagination"]["current-page"].to_i : nil
    render  :locals => { :chat_data => chat_data, :total_pages => total_pages, :current_page => current_page}
  end

  def generate_chat_data(message, conversation)
    {
      :date_time         => TimeUtils.format_time(message["message-time"].to_time, "%m/%d/%Y %I:%M:%S %p"),
      :message           => message["message"],
      :conversation_type => (conversation["type"] == "JabberConversation") ? "Private Conversation" : conversation["type"].titlecase,
      :message_id        => message["message-id"],
    }
  end

  def get_time_range(timeframe, custom_from, custom_to)
    range = {:from => '', :to => ''}
    now = TimeUtils.time_in_user_zone
    today_start = now.beginning_of_day.utc
    case timeframe
      when 'Custom'
        range[:from] = TimeUtils.time_in_user_zone(custom_from).utc.to_s(:db)
        range[:to]   = TimeUtils.time_in_user_zone(custom_to).utc.to_s(:db)
        range[:to_date] = TimeUtils.time_in_user_zone(custom_to)
      when 'Last month'
        range[:from] = (today_start - 30.days).to_s(:db)
        range[:to]   = (today_start).to_s(:db)
        range[:to_date] = ((today_start) - 1.day).to_s
      when 'Last week'
        range[:from] = (today_start - 7.days).to_s(:db)
        range[:to]   = (today_start).to_s(:db)
        range[:to_date] = ((today_start) - 1.day).to_s
      when 'Yesterday'
        range[:from] = (today_start - 1.day).to_s(:db)
        range[:to]   = (today_start).to_s(:db)
        range[:to_date] = ((today_start) - 1.day).to_s
      when 'Today'
        range[:from] = (today_start).to_s(:db)
        range[:to]   = (today_start + 1.day).to_s(:db)
        range[:to_date] = (today_start).to_s
    end
    range
  end

  def detailed_chat_history
    start_date = params["start_date"]
    end_date = params["end_date"]
    if params["conversation_type"] == "PublicConversation"
      if params["message_date_time"]
        start_date = URI.escape((TimeUtils.time_in_user_zone(params["message_date_time"]).utc - 5.minutes).strftime("%Y-%m-%d %H:%M:%S"))
        end_date = URI.escape((TimeUtils.time_in_user_zone(params["message_date_time"]).utc + 5.minutes).strftime("%Y-%m-%d %H:%M:%S"))
        params["start_date"] = URI.decode(start_date)
        params["end_date"] = URI.decode(end_date)
      else
        start_date = URI.escape((TimeUtils.time_in_user_zone(params["start_date"]).utc).strftime("%Y-%m-%d %H:%M:%S"))
        end_date = URI.escape((TimeUtils.time_in_user_zone(params["end_date"]).utc).strftime("%Y-%m-%d %H:%M:%S"))
        params["start_date"] = URI.decode(start_date)
        params["end_date"] = URI.decode(end_date)
      end
    end
    chat_history = @learner.detailed_chat_history(params[:page], params[:number_of_records], start_date, end_date, params[:message_id])
    conversation = chat_history["conversations"]["conversation"] if chat_history && chat_history["conversations"]
    chat_data = []
    if conversation
      title = (conversation["type"] == "JabberConversation") ? "Private Conversation" : conversation["type"].titlecase
      self.page_title = "Full Details of #{title} Chat"
      messages = conversation["messages"]["message"] 
      # messages = messages.index_by{|m| m["message-time"]}.values && messages.index_by{|m| m["message"]}.values
      # messages = messages.sort_by{|message| message["message-time"].to_time.to_i}
      messages.each do |message|
        learner = Learner.find_by_guid(message["sender"])# || Coach.find_by_rs_email(message["sender"])
        selected_learner_or_message = learner ? ((@learner.id == learner.id) ? "selected_learner" : "") : ""
        selected_learner_or_message = (params["message_id"] == message["message-id"]) ? "selected_message" : selected_learner_or_message
        chat_data << {
          :learner                     => learner,
          :other_participant           => learner ? "#{learner.first_name} #{learner.last_name}" : "Studio Coach",
          :date_time                   => TimeUtils.format_time(message["message-time"].to_time, "%m/%d/%Y %I:%M:%S %p"),
          :message                     => message["message"],
          :selected_message_or_learner => selected_learner_or_message
        }
      end
    end
    total_pages = (chat_history && chat_history["pagination"]) ? chat_history["pagination"]["total-pages"].to_i : nil
    current_page = (chat_history && chat_history["pagination"]) ? chat_history["pagination"]["current-page"].to_i : nil
    render :locals => {:chat_data => chat_data, :total_pages => total_pages, :current_page => current_page}
  end

  def logged_in_history
    @login_history = @learner.user_session_log.collect{|d| TimeUtils.format_time(d.session_start_time, "%A %b %d, %Y %H:%M:%S")}
    render :partial => 'extranet/learners/logged_in_history'
  end

  def student_evaluation_feedback
    feedback_array_json = params[:feedback_array_json]
    feedback_obj = {}
    no_feed_back = true
    feedback_array_json && feedback_array_json.each do |feedback_element|
      feedback = feedback_element[1]['feedback']
      label = feedback["label"]
      if feedback["value"] != 'n/a'
      feedback_obj[label] = {}
      feedback_obj[label][:label] = label
      feedback_obj[label][:comments] =  feedback["notes"]
      feedback_obj[label][:score] =  feedback["score"]
      feedback_obj[label][:value] =  feedback["value"]
      no_feed_back = false
      end
    end
    render(:partial => "learners_feedback_rating",:locals => {:feedback_obj => feedback_obj, :coach_name => params[:coach_name],:coach_id => params[:coach_id],:start_time => params[:start_time],:language_name => params[:language_name],:no_feed_back => no_feed_back})
  end

  def learner_studio_history
    self.page_title =  ""
    render :template  => "extranet/learners/learner_studio_history", :locals => { :student => @learner.studio_history }
  end

  def export_student_history_to_csv
    self.page_title =  ""
    learner_studio_history = Eschool::Learner.studio_history(params[:learner_guid])
    studio_history_report = File.new("/tmp/learner_studio_history.csv", 'w')
    CSV::Writer.generate(studio_history_report , ',') do |title|
      title << ['Date & Time(EST)',"Learner Date & Time #{Time.now.in_time_zone(learner_studio_history.time_zone).zone}","Level", "Unit","Attended","Coach","Duration","Tech Issues","Followup?"]
      learner_studio_history.eschool_sessions.each do |es|
        feedback_for_session = (es.attributes.include?("feedbacks") && !es.feedbacks.blank?) ? es.feedbacks : []
        feedback_hash = {}
        feedback_for_session.each do |fb|
          label_key = fb.label.match("follow") ? "followup" : fb.label
          feedback_hash[label_key] = {}
          feedback_hash[label_key] = fb
        end
        title << [
          es.start_time.to_time.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d/%y %I:%M %p"),
          es.start_time.to_time.in_time_zone(learner_studio_history.time_zone).strftime("%m/%d/%y %I:%M %p"),
          es.level,
          es.unit,
          es.attended == "true" ? "Attended" : es.cancelled == "true" ? "Cancelled" : "Skipped",
          es.attributes.include?("coach") ? es.coach : "n/a",
          es.last_seen_at && es.first_seen_at ? difference_of_time_mmss(es.last_seen_at.to_time, es.first_seen_at.to_time) : "--",
          es.technical_issues == "true" ? "YES" : "NO",
          !feedback_for_session.blank? ? (feedback_hash["followup"] ? (feedback_hash["followup"].value ? feedback_hash["followup"].value[0..2].upcase : "N/A") :  "N/A") : "N/A"
        ]
      end
    end
    studio_history_report.close
    send_file("/tmp/learner_studio_history.csv", :type => "text/csv", :charset=>"utf-8")
  end

  private

  #License Methods
  def ls_api
    RosettaStone::ActiveLicensing::Base.instance
  end

  def learners_data_from_learners(learners)
    learners_data = []
    learners && learners.each_with_index do |l, index|
      learners_data[index] = {}
      learners_data[index]['learner'] = l
    end
    learners_data
  end

end