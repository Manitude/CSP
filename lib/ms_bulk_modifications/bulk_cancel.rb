module MsBulkModifications
  class BulkCancel
    class << self

      def perform(sm, start_time, end_time)
        sessions_cancel = LocalSession.for_language_and_action(sm.language.id, 'cancel', start_time, end_time)
        sessions_with_recurrence = LocalSession.for_language_and_action(sm.language.id, 'cancel_with_recurrence', start_time, end_time)
        sessions_cancel.each do |session|
          cancel_sessions(session,false)
        end
        sessions_with_recurrence.each do |session|
          cancel_sessions(session,true)
        end
        sm.update_completed_count(sessions_cancel.size + sessions_with_recurrence.size)
      end

      private

      def cancel_sessions(session,with_recurrence)
        if session.coach.blank?
          substitution = session.substitution
          substitution.update_attribute(:cancelled, true) if substitution
        end
        session.cancel_and_stop_recurrence(with_recurrence, session.session_metadata.cancellation_reason)
        session.convert_to_standard_session
      end
  
    end
  end
end

