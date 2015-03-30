class SchedulingThresholdsController < ApplicationController
  
  def show
    language_scheduling_threshold = LanguageSchedulingThreshold.find_by_language_id(params[:id])
    render :json => language_scheduling_threshold.to_json, :status => 200
  end

  def index
    self.page_title = 'Manage Scheduling Thresholds'
    if manager_logged_in?
      @languages = current_manager.languages.sort_by(&:display_name)
    elsif admin_logged_in?
      @languages = Language.all.sort_by(&:display_name)
    end
  end

  def update
    scheduling_threshold = LanguageSchedulingThreshold.find_by_language_id(params[:id])
    if scheduling_threshold.update_attributes(params[:scheduling_thresholds])
      render :json => scheduling_threshold, :status => 200
    else
      render :json => {:errors => scheduling_threshold.errors.full_messages}, :status => 412
    end
    
  end

  def authenticate
    access_denied unless(manager_logged_in? || admin_logged_in?)
  end
end
