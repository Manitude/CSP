module Eschool
  class Student < Base
    class << self

      def get_completed_reflex_sessions_count_for_learner(guid)
        within_eschool_rescuer do
          response = find(:one, :from => "/api/se/students/get_completed_reflex_sessions_count_for_learner", :params => {:guid => guid})
          return response.number_of_completed_sessions
        end
      end

      def cancel_future_sessions(guid, language = nil)
        within_eschool_rescuer do
          find(:one, :from => "/api/se/students/cancel_future_sessions", :params => {:guid => guid, :language => language, :force_destroy => true})
        end
      end
      
    end
  end
end