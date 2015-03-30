require 'ms_utils'

module MsBulkModifications
  class BulkCreate
    class << self
      
      def perform(sm, start_time, end_time)
        handle_local_sessions(sm, start_time, end_time)
        handle_recurring_sessions(sm, start_time, end_time)
        handle_sessions_created_on_timeoff(sm, start_time, end_time)
      end

      def handle_local_sessions(sm, start_time, end_time)
        sessions = LocalSession.for_language_and_action(sm.language.id, 'create', start_time, end_time)
        sessions.each do |session|
          if session.recurring_schedule
            handle_edited_recurring_session(session)
          else
            handle_created_local_session(session)
          end
          session.destroy
          ConfirmedSession.create_one_off(session.to_hash)
        end
        sm.update_completed_count(sessions.size)
      end

      private

      def handle_sessions_created_on_timeoff(sm, start_time, end_time)
        sessions = CoachSession.get_sessions_made_on_time_off(sm.language, start_time, end_time, sm.created_at)
        sessions.each do |session|
          session.coach.update_time_off(session)
        end
      end

      def handle_edited_recurring_session(session)
        session.recurring_schedule.update_attributes(:external_village_id => session.external_village_id, :number_of_seats => session.number_of_seats)
        MsUtils.remove_recurring_sessions_and_schedules(session) unless session.session_metadata.recurring
      end
        
      def handle_created_local_session(session)
        if session.session_metadata.recurring
          if (recurring_schedule = CoachRecurringSchedule.for_coach_and_datetime(session.coach.id, session.session_start_time))
            session.update_attribute(:recurring_schedule_id, recurring_schedule.id)
            MsUtils.remove_recurring_sessions_and_schedules(session)
          end
          MsUtils.create_recurring_schedule_and_sessions_for_totale(session)
        end
      end

      def handle_recurring_sessions(sm, start_time, end_time)
        CoachRecurringSchedule.fetch_for(start_time, end_time, sm.language.id).each_slice(MS_BLOCK_SIZE) do |block_of_schedules|
          csp_sessions, sessions = create_sessions_in_ccs(block_of_schedules, sm.language.is_lotus? || sm.language.is_tmm_phone? || sm.language.is_tmm_live?)
          if sm.language.is_totale?
            push_session_to_eschool(sm.language, csp_sessions, sessions)
          elsif sm.language.is_supersaas?
            push_session_to_supersaas(csp_sessions)
          end    
          sm.update_completed_count(sessions.size)
        end
      end

      def push_session_to_supersaas(csp_sessions)
        csp_sessions.each do |key, session|
          next if session.appointment?
          params = {
            :session_start_time     => session.session_start_time,
            :coach_id               => session.coach_id,
            :topic_id               => session.topic_id,
            :external_village_id    => session.external_village_id,
            :lang_identifier        => session.language_identifier,
            :number_of_seats        => session.number_of_seats,
            :session_status         => COACH_SESSION_STATUS["Created Locally"],
            :recurring_schedule_id  => session.recurring_schedule_id
          }
          if params[:number_of_seats] > 1 && session.aria?
            topic = Topic.find(params[:topic_id])
            params[:title] = topic["title"]
            params[:description] = topic["description"]
            params[:location] = topic["cefr_level"]
          elsif session.tmm_phone? || session.tmm_michelin?
            params[:title]      = session.tmm_michelin? ? 'Michelin Session' : 'CSP-BookingApp'
            desc = {
                    "c" => params[:number_of_seats] + 1,
                    "st" => session.language.supersaas_session_type,
                    "ch" => {
                        "pid" => session.coach.coach_guid,
                        "n"   => session.coach.full_name,
                        "l"   => TEACH_LANGUAGE[params[:lang_identifier]],
                        "ml"  => ""
                    }     
            }
            desc["ch"]["wbx"]={"hid" => session.coach.email, "hpwd" => "4*nU\>=?BBJv;Kt", "em" => session.coach.email} if session.tmm_michelin?
            params[:description] = desc
          end
          external_session_id = ExternalHandler::HandleSession.create_sessions(session.language, params)
          if !external_session_id 
            next if session.destroy
          end  
          session.update_attributes(:eschool_session_id => external_session_id, :session_status => COACH_SESSION_STATUS["Created in Eschool"])
        end
      end

      def push_session_to_eschool(language, csp_sessions, sessions)
        response = ExternalHandler::HandleSession.create_sessions(language, sessions)
        # The next block is gona handle all da eschool failure scenarios ! \m/
        if !response
          ids = sessions.collect{|cs| {:external_session_id => cs[:external_session_id], :eschool_session_id => cs[:eschool_session_id]}}
          response = ExternalHandler::HandleSession.get_session_details(language, {:ids => ids })
          sessions = EschoolResponseParser.new(response.read_body).parse if response
          response = ExternalHandler::HandleSession.create_sessions(language, {:sessions => sessions}) if sessions.blank?
        end
        
        if response && (response_xml = REXML::Document.new response.read_body)
          created_eschool_sessions = response_xml.elements.to_a( "//eschool_session" )
          unless created_eschool_sessions.blank?
            created_eschool_sessions.each do |es|
              cs = csp_sessions[es.get_tag_value('external_session_id').to_i]
              cs.update_attributes(:eschool_session_id => es.get_tag_value('eschool_session_id'), :session_status => COACH_SESSION_STATUS["Created in Eschool"])
              if es.get_tag_value('teacher_id').blank?
                logger.info "Coach #{cs.coach.full_name} is not present in eschool, sub requesting the session."
                cs.request_substitute
              end
            end
          end
          
          error_sessions = response_xml.elements.to_a( "//error_session" )
          unless error_sessions.blank?
            error_sessions.each do |es|
              cs = csp_sessions[es.get_tag_value('external_session_id').to_i]
              if cs
                sessions.delete(cs)
                cs.destroy
                logger.info "Session could not be created at #{cs.session_start_time} for coach #{cs.coach.full_name} due to error : #{es.get_tag_value('message')}"
              end
            end
          end
        else
          CoachSession.delete(csp_sessions.keys)
          raise "Eschool is not responding properly now. Please try after sometime."
        end
      end

      def create_sessions_in_ccs(block_of_schedules, is_reflex)
        csp_sessions_hash = {}
        sessions = []
        overall_status = is_reflex ? COACH_SESSION_STATUS["Created in Eschool"] : COACH_SESSION_STATUS["Created Locally"]
        block_of_schedules.each do |recurring_schedule|
          session_status = recurring_schedule.recurring_type == "recurring_appointment" ? COACH_SESSION_STATUS["Created in Eschool"] : overall_status
          create_map = { :recurring_session => 'ConfirmedSession', :recurring_appointment => 'Appointment' }
          cs = create_map[recurring_schedule.recurring_type.to_sym].constantize.create(:coach_id => recurring_schedule.coach.id,
            :session_start_time => recurring_schedule.schedule_time.to_time,
            :session_end_time => recurring_schedule.schedule_time.to_time + (recurring_schedule.recurring_type == 'recurring_appointment' ? 30.minutes : recurring_schedule.language.duration_in_seconds),
            :language_identifier => recurring_schedule.language.identifier,
            :external_village_id => recurring_schedule.external_village_id,
            :session_status => session_status,
            :number_of_seats => recurring_schedule.number_of_seats,
            :topic_id => recurring_schedule.topic_id,
            :recurring_schedule_id => recurring_schedule.id,
            :appointment_type_id => recurring_schedule.appointment_type_id)
          if cs.errors.blank?
            csp_sessions_hash[cs.id] = cs
            sessions << cs.to_hash
          else
            logger.info "Session could not be created at #{cs.session_start_time} due to error : #{cs.errors.full_messages}"
          end
        end
        return csp_sessions_hash, sessions
      end

    end
  end
end
