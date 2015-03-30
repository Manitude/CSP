class MsUtils
  class << self

    def remove_recurring_sessions_and_schedules(session)
      session.future_recurring_sessions.each do |sess|
        sess.cancel_or_subsitute_as_per_language(false)
      end
      session.stop_recurring
      session.update_attribute(:recurring_schedule_id, nil)
    end

    def create_recurring_schedule_and_sessions_for_totale(session)
      if session.coach.having_availability_at?(session.session_start_time)
        session.recurring_schedule = CoachRecurringSchedule.create_for(session.session_start_time, session.coach_id, session.language_id, session.number_of_seats, session.external_village_id, session.session_metadata.topic_id)
        session.save
        session.create_sessions_till_last_pushed_week
      end
    end

    # @input confirmed_session
    # @return nil
    # Updates all the future committed recurring sessions with the edited values without cancelling them
    # the existing recurring schedule will be ended and a new recurring schedule will be created with updated values
    # all the recurring sessions will bear the new recurring id
    def update_recurring_sessions(coach_session,coach_altered)
      error_msgs=""
      level_unit = AppUtils.form_level_unit(coach_session.single_number_unit)
      data = {
        :teacher => {:user_name => coach_session.coach.user_name},
        :teacher_id => coach_session.coach.id,
        :lang_identifier => coach_session.language_identifier,
        :wildcard => coach_session.single_number_unit.nil? ? "true" : "false",
        :level => level_unit[:level],
        :unit => level_unit[:unit],
        :lesson => coach_session.eschool_session.try(:lesson),
        :max_unit => coach_session.coach.qualification_for_language(coach_session.language_id).max_unit,
        :duration_in_seconds => coach_session.duration_in_seconds,
        :number_of_seats => coach_session.number_of_seats || 4,
        :external_village_id => coach_session.external_village_id,
        :teacher_confirmed => "true",
        :topic_id => coach_session.topic_id,
        :start_time => coach_session.session_start_time.utc,
        :session_type => "session"
      }
      #make a check whether the recurrence should be cancelled or substitute when the coach is altered
      coach_session.stop_recurring
      data[:recurring_schedule_id] = CoachRecurringSchedule.create_for(data[:start_time], data[:teacher_id], coach_session.language_id, data[:number_of_seats], data[:external_village_id], data[:topic_id], data[:session_type]).id
      all_sessions = coach_session.future_recurring_sessions
      #current session is not included in handle_reassignment as it would have been done already
      if coach_altered
        all_sessions.each do |sess|
          handle_reassignment(sess,coach_session.coach)
        end
      end

      all_sessions << coach_session
      no_learner_sessions = all_sessions.reject{|sess| sess.learners_signed_up > 0}
      if coach_session.totale? || coach_session.aria?
        data, result, error_msgs = handle_external_update(no_learner_sessions,coach_session,data,coach_altered)
      end
      if error_msgs.blank?
        all_sessions.each do |sess|
          sess.update_attributes({
              :language_identifier => data[:lang_identifier],
              :external_village_id => sess.eschool_session.try(:learners_signed_up).to_i>0 ? sess.external_village_id : data[:external_village_id],
              :number_of_seats    => sess.learners_signed_up > 0 ? sess.number_of_seats : data[:number_of_seats],
              :recurring_schedule_id => data[:recurring_schedule_id],
              :topic_id => sess.learners_signed_up > 0 ? sess.topic_id : data[:topic_id]
            })
        end
      end
    end

    def handle_reassignment(session,new_coach)
        coach_altered = true
        #SuperSaas::Session.substitute(session, new_coach, session.coach, session.coach_id ? "MANUALLY_ASSIGNED" : "MANUALLY_REASSIGNED" ) if session.supersaas?
        ExternalHandler::HandleSession.substitute_session(session.language, {:session => session, :grabber_coach => new_coach, :coach => session.coach} ) if session.supersaas?
        substitute_session(session,new_coach) #create a substitution in order to skip the recurrence creation for the current
        session.reassigned = "true"
        session.save
        return coach_altered
    end

    private

    def handle_external_update(all_sessions,coach_session,data,coach_altered)
        session = data.merge({:coach_username => coach_session.coach.user_name})
        data[:sessions] = []
        all_sessions.each do |sess|
          session[:eschool_session_id] = sess.eschool_session_id
          session[:coach_username] = coach_altered ? coach_session.coach.user_name : sess.coach.try(:user_name)
          session[:start_time]= sess.session_start_time.utc
          data[:sessions] << session.clone
        end
        data[:supersaas_check] = data[:number_of_seats].to_i>1 && data[:recurring_schedule_id] && coach_session.learners_signed_up == 0
        data, result, error_msgs = ExternalHandler::HandleSession.update_sessions(coach_session.language, data, coach_session)
    end

    def substitute_session(session,new_coach)
        substitution = session.substitution
        trigger_event_type = 'MANUALLY_REASSIGNED'
        if substitution.blank? || substitution.grabber_coach_id
          substitution = Substitution.create(:coach_id => session.coach_id, :grabbed => false, :coach_session_id => session.id)
          trigger_event_type = 'MANUALLY_ASSIGNED'
          modification = session.modify_coach_availability(5)
        end
        substitution.update_attributes(:grabber_coach_id => new_coach.id, :grabbed => true, :grabbed_at => Time.now, :was_reassigned => true)
        session.update_attributes(:coach_id => new_coach.id)
        new_coach.update_time_off(session)
        if(trigger_event_type == 'MANUALLY_REASSIGNED')
          TriggerEvent[trigger_event_type].notification_trigger!(substitution)
        else
          new_coach.system_notifications.create(:raw_message => "You have been assigned a <b>#{session.language.display_name}</b> session on <b>#{TimeUtils.format_time(session.session_start_time, "%B %d, %Y %I:%M %p")}</b>.")
        end
    end
  end
end