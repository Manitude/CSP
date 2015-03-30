class Extranet::HomesController < ApplicationController
  include AuthenticatedSystem

  def index
    Ambient.init
    Ambient.current_user = session[:user]
    self.page_title = ""
    @substitutions = current_user.manage_substitutions
    @announcements = current_user.announcements
    @notifications = current_user.system_notifications_not_reassigned_or_grabbed
    grabbed_notification_count = current_user.get_preference.no_of_home_substitutions - @substitutions[:data].size
    @notifications_grabbed = (grabbed_notification_count > 0) ? current_user.system_notifications_reassigned_or_grabbed(grabbed_notification_count) : []
    events_data(true)
  end

  def audit_logs
    @table_names       = {}
    table_names        = ActiveRecord::Base.connection.tables
    table_names.each{|table| @table_names[table.gsub(/_/," ").capitalize] = table.gsub(/\s/, '_').camelize.chomp('s') if table != "product_language_logs"} unless table_names.blank?
    @table_names = @table_names.sort.uniq
    @table_names.insert(0, ["All", "all"])

    @record_actions     = {"All" => "all", "Created" => "create", "Updated" => "update", "Destroyed" => "destroy"}
    @date_ranges        = {"All" => "all"}

    @record_id          =  params[:record_id]
    @table_name         =  params[:table_name]
    @record_action      =  params[:record_action]
    @duration           =  params[:duration]
    @start_date         =  params[:start_date] || Time.now - 1.month
    @end_date           =  params[:end_date] || Time.now
    @from_will_paginate =  params[:from] || false
    @show_message       =  false
    @show_cta_links_with_notification =  ""

    if request.post? || @from_will_paginate
      @show_message = true
      conditions    = ""

      unless @table_name.blank? || @table_name == "all"
        conditions = "loggable_type='#{@table_name}'"
      end

      unless @record_action.blank? || @record_action == "all"
        if conditions != ""
          conditions = conditions+" AND "
        end
        conditions = conditions + "action='#{@record_action}'"
      end

      unless @record_id.blank?
        if conditions != ""
          conditions = conditions+" AND "
        end
        conditions = conditions + "loggable_id='#{@record_id}'"
      end

      case @duration
      when 'Last month'
        unless @start_date.blank?
          if conditions != ""
            conditions = conditions+" AND "
          end
          conditions = conditions + "timestamp >= '#{(Time.now.utc - 1.month).beginning_of_day.to_s(:db)}'"
        end

        unless @end_date.blank?
          if conditions != ""
            conditions = conditions+" AND "
          end
          conditions = conditions + "timestamp <= '#{Time.now.utc.end_of_day.to_s(:db)}'"
        end

      when 'Last week'
        unless @start_date.blank?
          if conditions != ""
            conditions = conditions+" AND "
          end
          conditions = conditions + "timestamp >= '#{(Time.now.utc - 1.week).beginning_of_day.to_s(:db)}'"
        end

        unless @end_date.blank?
          if conditions != ""
            conditions = conditions+" AND "
          end
          conditions = conditions + "timestamp <= '#{Time.now.utc.end_of_day.to_s(:db)}'"
        end

      when 'Yesterday'
        unless @start_date.blank?
          if conditions != ""
            conditions = conditions+" AND "
          end
          conditions = conditions + "timestamp >= '#{(Time.now.utc - 1.day).beginning_of_day.to_s(:db)}'"
        end

        unless @end_date.blank?
          if conditions != ""
            conditions = conditions+" AND "
          end
          conditions = conditions + "timestamp <= '#{(Time.now.utc - 1.day).end_of_day.to_s(:db)}'"
        end

      when 'Today'
        unless @start_date.blank?
          if conditions != ""
            conditions = conditions+" AND "
          end
          conditions = conditions + "timestamp >= '#{Time.now.utc.beginning_of_day.to_s(:db)}'"
        end

        unless @end_date.blank?
          if conditions != ""
            conditions = conditions+" AND "
          end
          conditions = conditions + "timestamp <= '#{Time.now.utc.end_of_day.to_s(:db)}'"
        end

      when 'Custom'
        unless @start_date.blank?
          if conditions != ""
            conditions = conditions+" AND "
          end
          conditions = conditions + "timestamp >= '#{@start_date.to_time.utc.beginning_of_day.to_s(:db)}'"
        end

        unless @end_date.blank?
          if conditions != ""
            conditions = conditions+" AND "
          end
          conditions = conditions + "timestamp <= '#{@end_date.to_time.utc.end_of_day.to_s(:db)}'"
        end
      end

      @audit_log_records = AuditLogRecord.paginate(:per_page => 30, :page => params[:page], :conditions => conditions, :order => 'timestamp asc')

    end
  end

  def track_users
    conditions = ""
    conditions = "user_name='#{params[:user_name]}'" unless params[:user_name].blank? || params[:user_name] == "All"

    if !params[:user_role].blank? && params[:user_role] != "All"
      if conditions != ""
        conditions = conditions+" AND "
      end
      conditions = conditions + "user_role='#{params[:user_role]}'"
    end

    @users_actions = UserAction.paginate(:per_page => 30, :page => params[:page], :conditions => conditions, :order => 'updated_at asc')
    track_users_filters
  end

  def admin_dashboard
    self.page_title = "Admin Dashboard"
    @master_scheduler_sessions_data = SchedulerMetadata.where("locked = 1")
    @delayed_job_data = DelayedJob.all
    @global_settings  = {}
    @errors = params[:errors].nil? ? [] : params[:errors]
    GlobalSetting.all.map {|gs| @global_settings[gs.attribute_name] = gs.attribute_value }
  end

  def simulate_delayed_job
    Delayed::Job.enqueue(MailingJob.new)
    redirect_to home_admin_dashboard_path
  end

  def release_lock
    begin
      record = SchedulerMetadata.find(params[:session_record_id])
      record.destroy if record.present?
      render(:update){|page| page.replace_html( "sess_id#{params[:session_record_id]}", :partial => "lock_released", :locals => {:succeeded => true })}
    rescue ActiveRecord::RecordNotFound
      render(:update){|page| page.replace_html( "sess_id#{params[:session_record_id]}", :partial => "lock_released", :locals => {:succeeded => false, :message => "The lock has been released already"})}
    end
  end

  def trigger_sms_with_thread
    coach = CoachManager.find_by_user_name('test21')
    Thread.new{coach.test_send_sms('Hello')}
    #flash[:notice] = 'SMS Triggered Succesfully'
    render(:partial => "lock_released", :locals => {
        :succeeded => true })
  end

  def trigger_sms_wo_thread
    coach = CoachManager.find_by_user_name('test21')
    coach.test_send_sms('Hello')
    render(:partial => "lock_released", :locals => {
        :succeeded => true })
  end

  def set_global_settings
    value_changed = (params[:minutes_before_session_for_sending_email_alert] != GlobalSetting.find_by_attribute_name("minutes_before_session_for_sending_email_alert").attribute_value)
    GlobalSetting.reset_errors
    GlobalSetting.set_attributes(params.except("controller", "action", "commit"))
    if GlobalSetting.errors.any?
      @errors = GlobalSetting.errors.values.collect{ |ele| "»"+ele }
    else
      flash[:notice] = "Settings saved successfully"
    end
    GlobalSetting.execute_update_crontab if value_changed && GlobalSetting.email_alert_value_saved?
    redirect_to home_admin_dashboard_url(:errors => @errors)
  end

  private

  def track_users_filters
    options_for_user_name = ["All"]
    options_for_user_role = ["All"]
    formatted_user_name   = []
    formatted_user_role   = []

    user_tracks_filter = UserAction.all
    if user_tracks_filter
      user_tracks_filter.each do |obj|
        formatted_user_name  << obj.user_name
        formatted_user_role  << obj.user_role
      end
    end

    formatted_user_name.uniq!
    formatted_user_name.sort!{|a,b| a <=> b}

    formatted_user_name.each { |item| options_for_user_name << item }

    formatted_user_role.uniq!
    formatted_user_role.sort!{|a,b| a <=> b}

    formatted_user_role.each { |item| options_for_user_role << item }

    @user_name  =  options_for_user_name
    @user_role  =  options_for_user_role
  end

  def authenticate
    if (params[:action] == "admin_dashboard")
      access_denied unless manager_logged_in? || admin_logged_in?
    else
      access_denied unless manager_logged_in? || coach_logged_in?
    end
  end

end
