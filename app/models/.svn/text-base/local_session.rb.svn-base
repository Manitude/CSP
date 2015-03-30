# == Schema Information
#
# Table name: coach_sessions
#
#  id                  :integer(4)      not null, primary key
#  coach_user_name     :string(255)
#  eschool_session_id  :integer(4)
#  session_start_time  :datetime
#  created_at          :datetime
#  updated_at          :datetime
#  cancelled           :boolean(1)
#  external_village_id :integer(4)
#  language_identifier :string(255)
#  single_number_unit  :integer(4)
#  number_of_seats     :integer(4)
#  attendance_count    :integer(4)
#  coach_showed_up     :boolean(1)
#  seconds_prior_to_session :boolean(1) # seconds before session_start_time the coach launched the session
#  session_status      :integer(4) # 0- if created in coach session but not in eschool 1- created in both and for all reflex sessions.
#  coach_id            :integer
#  type                :String

class LocalSession < CoachSession
  belongs_to :coach, :foreign_key => 'coach_id'

  def convert_to_standard_session
    session_metadata.destroy
    sub = substitution
    sub.update_attributes(:grabber_coach_id => coach_id, :grabbed => true, :grabbed_at => Time.now, :was_reassigned => true) if sub && !sub.grabbed && !sub.cancelled
    self.update_attribute(:type, 'ConfirmedSession')
  end

  def self.find_for(start_time, end_time, language_identifier,classroom_type, village = nil)
    village_condition = (village.nil? or village == "all") ? "" : (village == "none")? "AND IFNULL(external_village_id, 0) = 0" : "AND external_village_id = #{village}"
    condition = "session_start_time >= ? and session_start_time <= ? and language_identifier = ? #{village_condition} "
    if(classroom_type == "solo")
      condition = condition+"and number_of_seats=1"
    elsif(classroom_type == "group")
      condition = condition+"and number_of_seats !=1"
      condition = condition + " and number_of_seats !=4" if (language_identifier != "AUK" && language_identifier != "AUS")
    else
      condition
    end
    where(condition, start_time, end_time, language_identifier).includes(:session_metadata).all
  end
  
  def self.create_one_off(params)
    unless params.blank?
      coach_session = self.create(:coach_id => params[:coach_id],
        :number_of_seats => params[:number_of_seats],
        :single_number_unit => params[:single_number_unit],
        :external_village_id => params[:external_village_id],
        :session_start_time => params[:session_start_time],
        :language_identifier => params[:language_identifier],
        :recurring_schedule_id => params[:recurring_id])
      coach_session.create_session_details(:details => params[:details]) if params[:details]
      coach_session.create_session_metadata(:teacher_confirmed => params[:teacher_confirmed],
        :lessons => params[:lessons],
        :recurring => params[:recurring],
        :topic_id => params[:topic_id],
        :details => params[:details],
        :action => "create") if coach_session.errors.blank?
    end
    coach_session
  end

  def self.all_session_in_a_time_slot(start_time, language_identifier, external_village_id)
    condition = "session_start_time = ? and language_identifier = ? and session_metadata.action = 'create'" + village_condition(external_village_id)
    where(condition, start_time, language_identifier).includes([:session_metadata, :coach])
  end

  def self.all_edited_and_cancelled(language_identifier, start_time, external_village_id)
    condition = "session_start_time = ? and language_identifier = ? and session_metadata.action != 'create'" + village_condition(external_village_id)
    where(condition, start_time, language_identifier).includes([:session_metadata, :coach])
  end

  def self.edited_for_week_and_coach(start_of_week, coach_id)
    edited_between_time_boundries(coach_id, start_of_week, start_of_week+7.days)
  end

  def self.edited_between_time_boundries(coach_id, start_time, end_time = nil)
    condition = ["coach_id = ? and session_start_time >= ? and action != 'create'", coach_id, start_time]
    if end_time
      condition[0] += " AND session_start_time < ?"
      condition << end_time
    end
    where(condition).joins(:session_metadata)
  end

  def self.created_between_time_boundries(coach_id, start_time, end_time)
    condition = "coach_id = ? and session_start_time >= ? and session_start_time < ? and session_metadata.action = 'create'"
    where(condition, coach_id, start_time, end_time).includes(:session_metadata)
  end

  def eligible_alternate_coaches
    (new_coach_id = session_metadata.new_coach_id) ? [[Coach.find_by_id(new_coach_id)],[]] : [[coach],[]]
  end

  def self.for_language_and_action(language_id, action, start_time, end_time)
    condition = "language_id = ? AND session_metadata.action = ? AND session_start_time BETWEEN ? AND ? AND cancelled = 0"
    where([condition, language_id, action, start_time, end_time]).includes([:session_metadata, :language, :coach])
  end
  
end
