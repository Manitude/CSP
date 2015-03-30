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

class ExtraSession < CoachSession

  has_many :excluded_coaches_sessions, :foreign_key => 'coach_session_id'
  has_many :excluded_coaches, :through => :excluded_coaches_sessions, :foreign_key => 'coach_session_id'


def self.create_one_off(params, excluded_coach_list)
    params.merge!({:teacher_confirmed => nil, :teacher => {:user_name => ''}, :type => "ExtraSession"})
    options = {
          :coach_id               => nil,
          :session_start_time     => params[:start_time],
          :external_village_id    => params[:external_village_id],
          :topic_id               => params[:topic_id],
          :language_identifier    => params[:lang_identifier],
          :name                   => params[:name],
          :number_of_seats        => params[:number_of_seats].to_i
        }
    cs = self.create(options)
    params[:external_session_id] = cs.id
    if cs.language.is_supersaas?
      params[:session_start_time]  = params[:start_time]
      # If the session is of AEB type
      if (cs.language.is_aria?)
        if (options[:number_of_seats] > 1)
          topic = Topic.find_by_id(options[:topic_id])
          params[:title] = topic["title"]
          params[:description] = topic["description"]
          params[:location] = topic["cefr_level"]
        else
          params[:title] = params[:description] = params[:location] = ''
        end
      # If the session is of RSA type
      elsif (cs.language.is_tmm_phone? || cs.language.is_tmm_michelin?)
        dummy_coach = Coach.unscoped.find_by_rs_email (FALSE_COACH_EMAIL)
        cs.create_session_details(:details => params[:details])
        desc = {
          "c"  => options[:number_of_seats]+1,
          "st" => Language[params[:lang_identifier]].supersaas_session_type,
          "ch" => {
            "pid" => dummy_coach.coach_guid,
            "n" => dummy_coach.full_name,
            "l" => TEACH_LANGUAGE[params[:lang_identifier]],
            "ml" => ""
          }
        }
        desc["ch"]["wbx"]={"hid" => dummy_coach.email, "hpwd" => "4*nU\>=?BBJv;Kt", "em" => dummy_coach.email} if cs.language.is_tmm_michelin?
        params[:title] = params[:location] = ''
        params[:description] = desc
      end
    end
    response = ExternalHandler::HandleSession.create_sessions(cs.language, params)
    if !response
        ids = [{:eschool_session_id => cs.eschool_session_id,:external_session_id => cs.id}]
        response = ExternalHandler::HandleSession.get_session_details(cs.language, {:ids => ids })
    end
    if response
        if cs.language.is_supersaas?
          cs.update_attribute(:eschool_session_id,response.to_i)
        else
          es_session = EschoolResponseParser.new(response.read_body).parse
          cs.update_attribute(:eschool_session_id,es_session[0].eschool_session_id) if !es_session.blank?
        end
    end

    if !cs.eschool_session_id.blank?
        sub_record = cs.enable_substitute!(excluded_coach_list.split(','))
        sub_record.update_attribute('session_type', 'ExtraSession')
        sub_record.update_attribute('reason', 'Created-ExtraSession')
        cs.exclude_coaches_from_the_session(excluded_coach_list.split(','))
        result = {:notice => "Session was successfully created." , :session => cs}
    else
      cs.destroy
      result = {:error => "Session failed to create"}
    end
    result
  end

  def self.create_one_off_reflex(params, excluded_coach_list)
    begin
      cs = self.create(
        :coach_id => nil,
        :session_start_time => params[:start_time],
        :language_identifier=> params[:lang_identifier],
        :name               => params[:name]
      )
      cs.enable_substitute!(excluded_coach_list)
      sub_record = Substitution.find_by_coach_session_id(cs.id)
      sub_record.update_attribute('session_type', 'ExtraSession')
      cs.exclude_coaches_from_the_session(excluded_coach_list)
      result = {:notice => "Session was successfully created." , :session => cs}
    rescue Exception => e
      result = {:error => "Session cannot be created."}
      HoptoadNotifier.notify(e)
    end
    result
  end

  def update_session_details(session_name, number_of_seats,level, unit, village_id, excluded_coach_list, topic_id = nil, details = nil)
    self.update_attributes(:name => session_name, :number_of_seats => number_of_seats, :external_village_id => village_id)
    self.update_attributes(:topic_id => topic_id) if !(topic_id.nil?)
    unless details.nil? && details.blank?
      if self.details
        self.session_details.update_attributes(:details => details)
      else
        self.create_session_details(:details => details)
      end
    end
    new_excluded_coach_list = excluded_coach_list.split(',')
    old_excluded_coach_list = self.excluded_coaches.collect{|coach| coach.id.to_s}
    coaches_to_be_excluded = new_excluded_coach_list - (new_excluded_coach_list & old_excluded_coach_list)
    coaches_to_be_included = old_excluded_coach_list - (new_excluded_coach_list & old_excluded_coach_list)
    self.exclude_coaches_from_the_session(coaches_to_be_excluded)
    self.include_coaches_to_the_session(coaches_to_be_included)
  end

  def exclude_coach_for_the_session(coach_id)
    excluded_coach_pair = ExcludedCoachesSession.create({:coach_id => coach_id.to_i, :coach_session_id => self.id})
    excluded_coach_pair.save!
  end

  def include_coach_to_the_session(coach_id)
    coach_to_include = self.excluded_coaches_sessions.find_by_coach_id(coach_id.to_i)
    coach_to_include.destroy if coach_to_include
  end

  def exclude_coaches_from_the_session(coach_ids)
    coach_ids.each do |coach_id|
      self.exclude_coach_for_the_session(coach_id)
    end
  end

  def include_coaches_to_the_session(coach_ids)
    coach_ids.each do |coach_id|
      self.include_coach_to_the_session(coach_id)
    end
  end

  def self.get_extra_session_count_for_a_language_on_a_slot(slot_time, language)
    ExtraSession.where("language_identifier = ? AND session_start_time = ? AND cancelled = 0", language, slot_time).count()
  end

  def self.get_total_extra_session_count_for_reflex_on_a_slot(slot_time)
    get_extra_session_count_for_a_language_on_a_slot(slot_time, 'KLE')
  end

  def self.get_grabbed_extra_session_count_for_reflex_on_a_slot(slot_time)
    ExtraSession.joins(' INNER JOIN substitutions ON coach_sessions.id = substitutions.coach_session_id ').where("language_identifier = 'KLE' AND session_start_time = ? AND session_type = 'ExtraSession' AND grabbed = 1 AND coach_sessions.cancelled != 1", slot_time).count()
  end

  def supersaas_learner
    @learner ||= supersaas_session.present? ? (supersaas_session.reject{|ses| ses[:email] == false_coach.rs_email}) : []
  end

  def false_coach
    false_coach    = Coach.unscoped.find_by_rs_email(FALSE_COACH_EMAIL)
  end

end
