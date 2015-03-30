require File.dirname(__FILE__) + '/../utils/lotus_real_time_data'

class LotusController < ApplicationController

  def learners_waiting_details
    @learners_waiting = LotusRealTimeData.lotus_real_time_data["learners_waiting"]
    render :partial => 'learners_waiting_details'
  end

  def lotus_real_time_data
    render(:partial => 'lotus_real_time_data', :locals => {:real_time_lotus_data_global => LotusRealTimeData.lotus_real_time_data,
        :coach_details_viewable => params[:coach_details_viewable]} )
  end

  def about_lotus_data
    render :partial => 'about_lotus_data'
  end

  def reflex_coach_details
    lotus_data = LotusRealTimeData.lotus_real_time_data
    @coach_names = lotus_data[params[:details_for]].sort.collect{|c| {:name => c}}
    if params[:details_for] == "paused"
      @coach_names.each do | coach |
        duration_in_seconds = (Time.now - ReflexActivity.where('coach_id = ? and event = "coach_paused"',Coach.find_by_full_name(coach[:name]).id).last.timestamp).round
        coach[:time] = "#{duration_in_seconds / 60} Min #{duration_in_seconds % 60} Secs"
      end  
    elsif params[:details_for] == "total_in_player"
      coach_scheduled = lotus_data['teachers_scheduled']
      @coach_names.each do |coach|
        coach[:not_scheduled] = !coach_scheduled.include?(coach[:name])
      end
    end  
    render :partial => 'reflex_coach_details'
  end

  def reflex_coach_scheduled_details
    coach_scheduled = LotusRealTimeData.lotus_real_time_data['teachers_scheduled']
    coach_in_player = LotusRealTimeData.lotus_real_time_data["total_in_player"]
    coach_not_in_player = coach_scheduled - coach_in_player
    coach_scheduled_in_player = coach_scheduled - coach_not_in_player
    @coaches = []
    coach_scheduled_in_player.each do |coach|
      #ReflexActivity.for_coaches(@coach_ids, @start_date, @end_date)
      coach_object = Coach.find_by_full_name(coach)
      last_logins = ReflexActivity.last_login_attempts(coach_object.id, 1)
      @coaches << {:name => coach, :in_player => true, :logins => last_logins, :coach_id => coach_object.id}
    end
    coach_not_in_player.each do |coach|
     @coaches << {:name => coach, :in_player => false}
    end
    @coaches = @coaches.sort_by{|coach| coach[:name]}
    render :partial => 'reflex_coach_scheduled_details'
  end

  def reflex_learner_details
    render :partial => 'reflex_learner_details', :locals => {:learners => LotusRealTimeData.lotus_real_time_data[params[:details_for]]}
  end

  def last_5_logins
    @last_logins = ReflexActivity.last_login_attempts(params[:coach_id])
    render :partial => "/lotus/last_5_logins"
  end

end