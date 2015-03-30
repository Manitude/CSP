class ConfirmedSession < CoachSession
  
  before_destroy :check_for_aria_emergency_session

    def self.confirmed_actual_sessions(language_identifier, start_time, end_time, village = nil, number_of_seats = (1..10).entries)
      village_condition = (village.nil? or village == "all") ? "" : (village == "none")? "AND IFNULL(external_village_id, 0) = 0" : "AND external_village_id = #{village}"
      totale_condition = ProductLanguages.reflex_language_codes.include?(language_identifier) ? '' : 'AND eschool_session_id IS NOT NULL'
      CoachSession.all(:select => 'session_start_time, coach_id, eschool_session_id, type',
            :conditions => [%Q(language_identifier = ? AND session_start_time >= ? AND session_start_time < ? AND
              cancelled = 0 #{village_condition} #{totale_condition} AND (type = 'ConfirmedSession' OR type = 'ExtraSession') AND (number_of_seats in (?) OR number_of_seats is NULL)),
            language_identifier, start_time, end_time, number_of_seats])
    end

    def self.find_historical_sessions_between(from_time, to_time, language_identifier)
      find_by_sql([%Q(select session_start_time, count(session_start_time) count_of_sessions from coach_sessions
        WHERE language_identifier = ? AND session_start_time >= ? AND session_start_time <= ? AND cancelled = 0 and type = 'ConfirmedSession'
        group by dayofweek(session_start_time), date(session_start_time), hour(session_start_time), minute(session_start_time)
        order by session_start_time),
          language_identifier, from_time, to_time])
    end

    def count_of_sessions
      self['count_of_sessions'].to_i
    end

    def check_for_aria_emergency_session
      return false if aria? && ((session_start_time - Time.now.utc)/1.hour < EMERGENCY_SESSION_LIMITATION[get_type_for_emergency_session.to_sym])
    end 

    def get_type_for_emergency_session
      if aria?
        "aria"
      end
    end
    
    def self.create_one_off(params)
      is_reflex = ProductLanguages.is_reflex_language_code?(params[:lang_identifier]) || Language[params[:lang_identifier]].is_tmm_live?
      is_aria = Language[params[:lang_identifier]].is_aria?
      is_tmm = Language[params[:lang_identifier]].is_tmm?
      is_tmm_michelin = Language[params[:lang_identifier]].is_tmm_michelin?
      is_tmm_phone = Language[params[:lang_identifier]].is_tmm_phone?
      is_tmm_live = Language[params[:lang_identifier]].is_tmm_live?
      options = {
          :coach_id               => params[:teacher_id],
          :session_start_time     => params[:start_time],
          :external_village_id    => params[:external_village_id],
          :language_identifier    => params[:lang_identifier],
          :number_of_seats        => params[:number_of_seats].to_i,
          :session_status => is_reflex ? COACH_SESSION_STATUS["Created in Eschool"] : COACH_SESSION_STATUS["Created Locally"],
          :topic_id               => params[:topic_id],
          :recurring_schedule_id  => params[:recurring_schedule_id],
          :reassigned             => params[:reassigned]
        }
      session = self.create(options)
      session.create_session_details(:details => params[:details]) if !params[:details].blank? && is_tmm
      options.merge!({:lang_identifier => params[:lang_identifier]})
      if session.errors.blank?
        if session.supersaas? 
          if is_aria && options[:number_of_seats] > 1
            topic = Topic.find(options[:topic_id])
            options[:title] = topic["title"]
            options[:description] = topic["description"]
            options[:location] = topic["cefr_level"]
          elsif is_tmm && !is_tmm_live
            options[:title] = is_tmm_michelin ? 'Michelin Session' : 'CSP-BookingApp'
            desc = {
                    "c" => options[:number_of_seats]+1,
                    "st" => Language[params[:lang_identifier]].supersaas_session_type,
                    "ch" => {
                          "pid" => session.coach.coach_guid,
                          "n" => session.coach.full_name,
                          "l" => TEACH_LANGUAGE[params[:lang_identifier]],
                          "ml" => ""
                    }     
            }
            desc["ch"]["wbx"]={"hid" => session.coach.email, "hpwd" => "4*nU\>=?BBJv;Kt", "em" => session.coach.email} if is_tmm_michelin
            options[:description] = desc
          end
          external_session_id = ExternalHandler::HandleSession.create_sessions(Language[params[:lang_identifier]], options)
          if !external_session_id 
            return nil if session.destroy
            return session
          end  
          session.update_attributes(:eschool_session_id => external_session_id, :session_status => COACH_SESSION_STATUS["Created in Eschool"])
        elsif !is_reflex && !is_tmm
          params[:external_session_id] = session.id
          response = ExternalHandler::HandleSession.create_sessions(Language[params[:lang_identifier]], params)
          if !response
            ids = [{:eschool_session_id => session.eschool_session_id,:external_session_id => session.id}]
            response = ExternalHandler::HandleSession.get_session_details(Language[params[:lang_identifier]], {:ids => ids })
          end  
          if response
            es_session = EschoolResponseParser.new(response.read_body).parse
            session.update_attributes(:eschool_session_id => es_session[0].eschool_session_id, :session_status => COACH_SESSION_STATUS["Created in Eschool"]) if !es_session.blank?
          end
          if session.eschool_session_id.blank?
            session.destroy
            session = nil
          end
        end
        session
      end
    end
    
end
