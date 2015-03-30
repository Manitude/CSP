class LotusRealTimeData

  def self.lotus_real_time_data
    MemcacheService.cache('real_time_lotus_data_global') do 
      data = {}
      learners_waiting = Eschool::StudentQueue.learners_waiting_details
      data["learners_waiting"] = learners_waiting ? learners_waiting["waiting_students"] : []
      data["average_learners_waiting_time_sec_for_both"] = Eschool::LotusSession.average_learners_waiting_time_sec.to_f.round(2)
      data["longest_learners_waiting_time_sec_for_both"] = Eschool::LotusSession.longest_waiting_time.to_f.round(2)
      current_slot =  TimeUtils.current_slot
      data["teachers_scheduled"] = CoachSession.find_coaches_between(current_slot, current_slot + 30.minutes).collect(&:full_name)
      data["teachers_scheduled_in_next_hour"] = CoachSession.find_coaches_between(current_slot + 30.minutes, current_slot + 60.minutes).collect(&:full_name)
      data.merge!(get_coach_status_details)
      data.merge!(get_locos_details)
      data
    end
  end
 
  private

  def self.get_locos_details
    locos_data = {"skills"=> [], "conversations"=> []}
    learners_locos_details = Locos::Lotus.find_active_session_details_by_activity
    if learners_locos_details && learners_locos_details != 'N/A'
      locos_data.each do |activity, learners|
        guids = learners_locos_details[activity].collect{|learner| learner["user_guid"]}.uniq
        guids.each do |guid|
          local_learner = Learner.find_by_guid(guid)
          learners << {"first_name" => local_learner.first_name, "last_name" => local_learner.last_name, "" => local_learner.preferred_name} if local_learner
        end
      end
    end
    locos_data["skills_or_rehearsal"] = locos_data["skills"] + locos_data["conversations"]
    locos_data["learners_in_dts"] = Locos::Lotus.find_learners_in_dts.to_i
    locos_data
  end

  def self.get_coach_status_details
    coach_status_hash = {"paused" => [], "initializing" => [], "calibrating" => [], "in_support" => [], "polling" => [], "teaching" => []}
    coaches_statuses = Eschool::CoachCurrentStatus.current_statuses
    if coaches_statuses
      coaches_statuses.each do |coach_status|
        coach = Coach.find_by_id(coach_status["external_coach_id"])
        coach_status_hash[coach_status["status"]]  << coach.full_name if coach
      end
    end
    coach_status_hash["paused"].reject! {| name | ((Time.now - ReflexActivity.where('coach_id = ? and event = "coach_paused"',Coach.find_by_full_name(name).id).last.try(:timestamp)).to_i).to_i/60 > 15}
    coach_status_hash["not_teaching"] = coach_status_hash["initializing"] + coach_status_hash["paused"] + coach_status_hash["in_support"] + coach_status_hash["calibrating"]
    coach_status_hash["total_in_player"] = coach_status_hash["not_teaching"] + coach_status_hash["polling"] + coach_status_hash["teaching"]
    coach_status_hash
  end
  
end
