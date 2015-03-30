class BackgroundController < ApplicationController

  def authenticate
    access_denied unless manager_logged_in?
  end

  def background_tasks
    conditions = ""
    conditions = "background_type='#{params[:bt_type]}'" unless params[:bt_type].blank? || params[:bt_type] == "All"
    unless params[:bt_triggered_by].blank? || params[:bt_triggered_by] == "All"
      conditions += " AND " if conditions != ""
      conditions += "triggered_by='#{params[:bt_triggered_by]}'"
    end
    unless params[:bt_state].blank? || params[:bt_state] == "All"
      conditions += " AND " if conditions != ""
      conditions += "state ='#{params[:bt_state]}'"
    end
    @background_tasks = BackgroundTask.paginate(:per_page => 30, :page => params[:page], :conditions => conditions, :order => 'updated_at asc')
    background_task_filters
  end

  private
    
  def background_task_filters
    options_for_state = ["All"]
    options_for_triggered_by = ["All"]
    options_for_background_type = ["All"]

    formatted_state   = []
    formatted_triggered_by   = []
    formatted_background_type   = []

    background_tasks_filter = BackgroundTask.find(:all)
    if background_tasks_filter
      background_tasks_filter.each do |obj|
        formatted_state << obj.state
        formatted_triggered_by << obj.triggered_by
        formatted_background_type << obj.background_type
      end
    end

    formatted_state.uniq!
    formatted_state.sort!{|a,b| a <=> b}
    formatted_state.each { |item| options_for_state << item }

    formatted_triggered_by.uniq!
    formatted_triggered_by.sort!{|a,b| a <=> b}
    formatted_triggered_by.each { |item| options_for_triggered_by << item }

    formatted_background_type.uniq!
    formatted_background_type.sort!{|a,b| a <=> b}
    formatted_background_type.each { |item| options_for_background_type << item }

    @state  =  options_for_state
    @triggered_by  =  options_for_triggered_by
    @background_type  =  options_for_background_type
  end
end