require 'ms_utils'

module MsBulkModifications
  class BulkEdit
    class << self

      def perform(sm, start_time, end_time)
        #sessions_update_one => updated for current week alone
        sessions_update_one = LocalSession.for_language_and_action(sm.language.id, 'edit_one', start_time, end_time)
        #sessions_update_all => updated for all recurrences
        sessions_update_all = LocalSession.for_language_and_action(sm.language.id, 'edit_all', start_time, end_time)
        unless sessions_update_one.blank?
          sessions_edited_in_eschool = edit_sessions_in_eschool(sm,sessions_update_one)
          if !sm.language.is_totale? || sessions_edited_in_eschool
            edit_sessions_in_local(sessions_update_one,true)
          end
        end
        unless sessions_update_all.blank?
          sessions_edited_in_eschool = edit_sessions_in_eschool(sm,sessions_update_all)
          if !sm.language.is_totale? || sessions_edited_in_eschool
            edit_sessions_in_local(sessions_update_all,false)
          end
        end
        sm.update_completed_count(sessions_update_all.size + sessions_update_one.size)
      end

      private
      
      def edit_sessions_in_eschool(sm,sessions)
        if sm.language.is_totale?
            sessions_edited_in_eschool = ExternalHandler::HandleSession.edit_sessions(sm.language, {:sessions => sessions.collect(&:to_hash)})
            if !sessions_edited_in_eschool
              ids = sessions.collect{|session| {:external_session_id => session.id, :eschool_session_id => session.eschool_session_id}}
              sessions_edited_in_eschool = ExternalHandler::HandleSession.get_session_details(sm.language, {:ids => ids})
            end
        end
        return sessions_edited_in_eschool
      end

      def edit_sessions_in_local(sessions,update_one)
        #update_one parameter determines whether the current session alone to be affected or all the sessions in recurrence
        sessions.each do |session|
          coach_altered = false
          if (assigned_coach_id = session.session_metadata.new_coach_id)
            new_coach = Coach.find_by_id(assigned_coach_id) 
            coach_altered = MsUtils.handle_reassignment(session,new_coach)
          end
          handle_change_in_topic(session) if session.topic_id != session.session_metadata.topic_id
          handle_tmm_changes(session) if session.session_metadata.details || session.details
          if !update_one
            handle_recurring_changes(session,coach_altered)
          end
          if update_one
            handle_one_off_changes(session)
          end
          session.convert_to_standard_session
        end
      end

      def handle_change_in_topic(session)
        session.topic_id = session.session_metadata.topic_id
        topic = Topic.find(session.session_metadata.topic_id)
        options = {
          :id                     => session.eschool_session_id,
          :topic_id               => session.topic_id,
          :lang_identifier    => session.language_identifier,
          :number_of_seats        => session.number_of_seats,
          :title                  => topic.title,
          :description            => topic.description,
          :location               => topic.cefr_level,
          :start_time             => session.session_start_time
        }
        sess = options.merge({:coach_username => session.coach.user_name})
        sess[:eschool_session_id] = session.eschool_session_id
        sess[:start_time]= session.session_start_time.utc
        options[:sessions] = [sess]
        ExternalHandler::HandleSession.update_sessions(session.language, options, session)
        session.save
      end

      def handle_tmm_changes(session)
        if session.details
          session.session_details.update_attributes(:details => session.session_metadata.details.to_s)
        else
          session.create_session_details(:details => session.session_metadata.details)
        end
      end

      def make_it_one_off?(session)
        return_val = !(session.session_metadata.recurring && !(session.recurring_schedule.present?))
        if session.reflex?
          if !session.session_metadata.coach_reassigned
            return_val = false
          else
            session.reassigned = true
            session.save
          end            
        end
        return return_val
      end

      def handle_one_off_changes(session)
        if session.session_metadata.recurring && !(session.recurring_schedule.present?)
          session.reload
          MsUtils.create_recurring_schedule_and_sessions_for_totale(session) if session.session_metadata.recurring
        end
        if make_it_one_off?(session)
          session.update_attributes(:recurring_schedule_id => nil) if !session.recurring_schedule_id.blank?
          session.save
        end
      end

      def handle_recurring_changes(session,coach_altered)
        # For TMM, do not destroy the recurring and create a new one, if the TMM session details is the only thing that is being changed
        # That is, unless the TMM session is being reassigned, or changed from one-off to recurring ( or vice versa ), dont remove the old recuring and create a new one
        session.reload #requires latest session and associations while passing obj for creating recurring schedules
        unless session.tmm? && !session.session_metadata.new_coach_id && (session.session_metadata.recurring == session.recurring_schedule.present?)
          #update the recurrences if the recurrence is still maintained and even for the change in coach
          if session.session_metadata.recurring == session.recurring_schedule.present?
            MsUtils.update_recurring_sessions(session,coach_altered)
          else
            #if recurrence is unchecked then remove the existing recurrence alone
            MsUtils.remove_recurring_sessions_and_schedules(session) if session.recurring_schedule
          end
        end
      end
    end
  end
end
