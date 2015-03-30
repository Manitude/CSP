module Eschool
  class Session < Base
    
    self.element_name = ""
    class << self
      #Eschool::Session.find_between("July 1, 2010", "August 12, 2010", "ESP") - All sessions
      def find_between(from_time, to_time, lang_identifier)
        within_eschool_rescuer do
          find(:all, :from => "/api/cs/get_eschool_sessions", :params => {:from_time => from_time, :to_time => to_time, :lang_identifier => lang_identifier } )
        end
      end

      #Eschool::Session.find_by_ids([123,345,1656])
      def find_by_ids(ids, handle_eschool_down = false)
        within_eschool_rescuer(handle_eschool_down) do
          self.prefix = "/api/cs/find_eschool_sessions_by_ids"
          response = post :ids, nil, {:ids => ids.compact.join(',')}.to_xml(:root => "sessions")
          parser = EschoolResponseParser.new(response.read_body)
          parser.parse
        end
      end

      #Eschool::Session.find_by_id(123)
      def find_by_id(id, handle_eschool_down = false)
        within_eschool_rescuer(handle_eschool_down) do
          find(:one, :from => "/api/cs/get_eschool_session_by_id", :params => {:id => id } )
        end
      end

      # POST
      # /api/cs/get_session_details
      def get_session_details(params)
        within_eschool_rescuer do
          self.prefix = "/api/cs/get_session_details"
           post :details, nil, params[:ids].to_xml(:root => "ids")
        end
      end  

      #Eschool::Session.bulk_create_sessions({:sessions=>[
      # {:start_time=>"Tue Jul 20 04:00:00 UTC 2010", :duration_in_seconds=>3600, :teacher=>{:user_name=>'david'}, :number_of_seats=>4, :lang_identifier=>"ESP", :max_unit => 3},
      # {:start_time=>"Wed Jul 21 09:30:00 UTC 2010", :duration_in_seconds=>3600, :teacher=>{:user_name=>'victoria'}, :number_of_seats=>6, :lang_identifier=>"ARA", :max_unit => 2}]})
      def bulk_create_sessions(params)
        within_eschool_rescuer do
          self.prefix = "/api/cs/bulk_create_eschool_sessions"
          post :sessions, nil, params[:sessions].flatten.to_xml(:root => "sessions")
        end
      end

      #Eschool::Session.create(:start_time=>"Tue Jul 20 04:00:00 UTC 2010", :duration_in_seconds=>3600, :teacher=>{:user_name=>'david'}, :number_of_seats=>4, :lang_identifier=>"ESP", :max_unit => 3)
      def create(params)
        self.bulk_create_sessions(:sessions => [params])
      end

      # Eschool::Session.cancel(:eschool_session_id => 12345)
      def cancel(params)
        params[:cancelled] ||= "CSP"
        within_eschool_rescuer do
          self.prefix = "/api/cs/cancel_eschool_session"
          post :cancel, {:eschool_session_id => params[:eschool_session_id], :cancelled_by => params[:cancelled_by]}
        end
      end
      # Eschool::Session.assign_extra_session(12345, 161)
      def assign_extra_session(eschool_session_id, coach_id)
        within_eschool_rescuer do
          self.prefix = "/api/cs/assign_extra_session"
          post :assign_extra_session, {:eschool_session_id => eschool_session_id, :coach_id => coach_id}
        end
      end

      # Eschool::Session.bulk_cancel([123,345,1656])
      # Use CoachSession.bulk_cancel_sessions([123,345,1656]) if you want to cancel in eSchool AND local
      def bulk_cancel(ids)
        within_eschool_rescuer do
          self.prefix = "/api/cs/bulk_cancel_eschool_sessions_by_ids"
          response = post :ids, nil, {:ids => ids.compact.join(',')}.to_xml(:root => "sessions")
          parser = EschoolResponseParser.new(response.read_body)
          parser.parse
        end
      end

      # Eschool::Session.bulk_uncancel([123,345,1656])
      def bulk_uncancel(ids)
        within_eschool_rescuer do
          self.prefix = "/api/cs/bulk_uncancel_eschool_sessions_by_ids"
          response = post :ids, nil, {:ids => ids.compact.join(',')}.to_xml(:root => "sessions")
          parser = EschoolResponseParser.new(response.read_body)
          parser.parse
        end
      end

      #Eschool::Session.bulk_create_sessions({:sessions=>[
      # [{"max_unit"=>"4", "level"=>"2", "coach_name"=>"italian1", "wildcard"=>"false", "unit"=>"2", "coach_confirmed"=>"true", "wildcard_locked"=>"false", "number_of_seats"=>"1", "coach_username"=>"ita1", "start_time"=>"Wed Feb 09 08:00:00 UTC 2011", "eschool_session_id"=>"45547"}]
      def bulk_edit_sessions(params)
        within_eschool_rescuer do
          self.prefix = "/api/cs/bulk_edit_eschool_sessions"
          response = post :sessions, nil, params[:sessions].to_xml(:root => "sessions")
          parser = EschoolResponseParser.new(response.read_body)
          parser.parse
        end
      end

      # Eschool::Session.delete_session(:user_name => 'jramanathan', :from_time => 'Tue Jul 20 04:00:00 UTC 2010', :to_time => 'Tue Jul 20 04:00:00 UTC 2010')
      def delete_session(params)
        within_eschool_rescuer do
          self.prefix = "/api/cs/delete_eschool_sessions"
          post :delete, {:user_name => params[:user_name], :from_time => params[:from_time], :to_time => params[:to_time]}
        end
      end

      # Eschool::Session.substitute(:eschool_session_id => 12345, :user_name => 'ssitoke' )
      def substitute(params)
        within_eschool_rescuer do
          self.prefix = "/api/cs/substitute_eschool_session"
          post :substitute, {:eschool_session_id => params[:eschool_session_id], :teacher => {:user_name => params[:user_name]}}
        end
      end

      #Eschool::Session.find_upcoming_sessions_for_language_and_levels("ESP","1,2,3") - All sessions
      def find_upcoming_sessions_for_language_and_levels(lang_identifier,level_string,start_date,end_date,page_num,village_ids, number_of_seats)
        within_eschool_rescuer do
          find(:one, :from => "/api/se/get_upcoming_sessions_for_language_and_levels", :params => {:language_identifier => lang_identifier,:level_string=> level_string,:start_date => start_date.utc, :end_date => end_date.utc,:page_num => page_num ,:records_per_page => SESSIONS_PER_PAGE_FROM_ESCHOOL ,:village_ids => village_ids, :number_of_seats => number_of_seats } )
        end
      end

      def find_upcoming_sessions_for_language_and_levels_without_pagination(lang_identifier,level_string,start_date,end_date,page_num,village_ids, number_of_seats)
        within_eschool_rescuer do
          find(:one, :from => "/api/se/get_upcoming_sessions_for_language_and_levels", :params => {:language_identifier => lang_identifier,:level_string=> level_string,:start_date => start_date.utc, :end_date => end_date.utc,:page_num => page_num ,:records_per_page => 500 ,:village_ids => village_ids, :number_of_seats => number_of_seats } )
        end
      end

      #Eschool::Session.find_registered_and_unregistered_learners_for_session(1234,123)
      def find_registered_and_unregistered_learners_for_session(session_id,class_id,email)
        within_eschool_rescuer do
          find(:one,:from => "/api/se/get_registered_and_unregistered_learners_for_session", :params => {:session_id=>session_id,:class_id=>class_id,:email=>email } )
        end
      end

      #Eschool::Session.add_student_to_session(1234,123,5)
      def add_student_to_session(session_id,student_id,single_number_unit, lesson, one_on_one)
        within_eschool_rescuer do
          find(:one, :from => "/api/se/add_student_to_session", :params => {:session_id => session_id,:student_id => student_id, :single_number_unit => single_number_unit, :lesson => lesson, :one_on_one => one_on_one } )
        end
      end

      #Eschool::Session.remove_student_from_session(123)
      def remove_student_from_session(attendance_id)
        within_eschool_rescuer do
          self.prefix = "/api/se"
          delete :remove_student_from_session , {:attendance_id => attendance_id }
        end
      end

      # Eschool::Session.get_sessions_in_next_x_minutes(14)
      # Minutes range from 0 to 15
      def get_sessions_in_next_x_minutes(x)
        within_eschool_rescuer do
          find(:all, :from => "/api/cs/get_eschool_sessions_in_next_x_minutes", :params => {:x => x} )
        end
      end

      def dashboard_data(dashboard_user_name, records_per_page, page_num, start_time, end_time, session_language, support_language, native_language, dashboard_future_session, get_non_assistable_sessions)
        within_eschool_rescuer do
          find(:one, :from => "/api/le/get_eschool_sessions/#{dashboard_user_name}", :params => {:dashboard_future_session=>dashboard_future_session, :page_num => page_num, :records_per_page => records_per_page, :start_time => start_time, :end_time => end_time, :session_language => session_language, :support_language => support_language, :locale_id => native_language, :get_non_assistable_sessions => get_non_assistable_sessions} )
        end
      end

      def set_has_technical_problem(eschool_session_id, student_guid, has_technical_problem)
        within_eschool_rescuer do
          self.prefix = "/api/le"
          post :set_has_technical_problem, {:eschool_session_id => eschool_session_id, :student_guid => student_guid, :has_technical_problem => has_technical_problem}
        end
      end

      # Eschool::Session.update_wildcard_units_for_eschool_sessions(:external_coach_id => 12345, :language_identifier =>'ESP', :max_unit => 8 )
      def update_wildcard_units_for_eschool_sessions(qualification)
        within_eschool_rescuer do
          self.prefix = "/api/cs/update_wildcard_units_for_eschool_sessions"
          request_params = {:external_coach_id => qualification.coach_id, :language_identifier => qualification.identifier, :max_unit => qualification.max_unit}
          (request_params[:lesson] = DEFAULT_LESSON_VALUE) if qualification.language.is_totale?
          post :update, request_params
        end
      end

      # Eschool::Session.get_reflex_studio_recording_enabled
      def get_reflex_studio_recording_enabled
        within_eschool_rescuer do
          response = find( :one, :from => "/api/cs/get_reflex_studio_recording_enabled" )
          response.status
        end
      end

      #Eschool::Session.find_by_id(123)
      def sessions_count_for_ms_week(start_time, end_time, language_identifier, classroom_type, village_id, handle_eschool_down = false)
        within_eschool_rescuer(handle_eschool_down) do
          find(:all, :from => "/api/cs/get_eschool_sessions_count_for_ms_week", :params => {:start_time => start_time, :end_time => end_time, :language => language_identifier, :classroom_type => classroom_type, :village_id => village_id} )
        end
      end
    end
    
  end
end

