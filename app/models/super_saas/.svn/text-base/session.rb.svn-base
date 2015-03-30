module SuperSaas
  class Session < Base
    METHODS_TO_BE_EXCLUDED_FOR_URI_FORMATION = [ :get_slot_id ]
    class << self
      #fetches sessions of a language
      # def find_by_identifier(identifier)
      #   within_rescuer do
      #     find(:all, :from => "/api/bookings", :params => {:schedule_id => get_schedule_id(identifier), :slot => true})
      #   end
      # end
      
      def find_by_id(id,lang,number_of_seats)
        reservations = []
        cookie = SuperSaas::User.login_as_admin
        path = "/ajax/cap_slot/#{get_schedule_id(lang,number_of_seats)}?slot=#{id}"
        resp = get_connection.get(path, {"Cookie" => cookie})
        return nil if (resp.body === "Already deleted")
        begin
          if Language[lang].is_aria? 
            reservations,count = SaasResponseParser.parse_reservations(resp.body)
            if count > 5
              path = "/ajax/cap_slot/#{get_schedule_id(lang,number_of_seats)}?slot=#{id}&page=2"
              reservations << SaasResponseParser.parse_reservations(get_connection.get(path, {"Cookie" => cookie}).body)[0]
            end 
          elsif Language[lang].is_tmm? && !Language[lang].is_tmm_live?
            reservations,count = SaasResponseParser.parse_rsa_reservations(resp.body)
          end
        rescue Exception => e
          return nil
        end
        return nil if reservations.flatten.blank?
        reservations.flatten
      end  

      def custom_method_collection_url(method_name, options = {})
        prefix_options, query_options = split_options(options)
        if METHODS_TO_BE_EXCLUDED_FOR_URI_FORMATION.include?(method_name)
          "/api/free/#{options[:schedule_id]}.#{format.extension}#{query_string(query_options)}"
        else
          "#{prefix(prefix_options)}#{collection_name}/#{method_name}.#{format.extension}#{query_string(query_options)}"
        end
      end

      #get details from booking
      def get_booking_details(booking_id,schedule_id)
        path = "/api/bookings/"+booking_id+".xml?schedule_id="+schedule_id+"&account=#{user}&password=#{password}"
        LibXML::XML::Document.string(get_connection.get(path).read_body).find("//booking").first.find("//created-by").first.content.split(" ").first
      end

      # Gets schedules of <user_guid> for all the languages if language_identifier is not passed
      def get_slot_id_for_session(guid, identifier, start_time,number_of_seats)
        res = within_rescuer do
          path = "/api/agenda/#{get_schedule_id(identifier,number_of_seats)}.xml"
          find(:one, :from => path, :params => {:user => guid, :from => (start_time-1.minute).to_s(:db), :slot => true, :checksum => get_md5_checksum(guid), :account => self.user}).booking
        end

        [res].flatten.detect{|ses| TimeUtils.format_time(ses.slot.start,"%Y-%m-%d %H:%M:%S") == start_time.to_s(:db) } if res
      end

      #As of now being used to find the slot id to add booking while creating the session. This retrieves the slots having free reservations > 1
      def get_free_slot_id(guid, start_time, identifier, number_of_seats)
        response = post :get_slot_id, :schedule_id => get_schedule_id(identifier,number_of_seats), :user => guid, :checksum => get_md5_checksum(guid), :from => (start_time - 1.second).to_s(:db)
        sessions = SaasResponseParser.new(response.body).parse
        created_session = sessions.select{|ses| (ses.session_start_time == start_time.to_s(:db)) && (ses.count == (number_of_seats.to_i+1))}.sort_by(&:slot_id).last
        created_session.try(:slot_id)
      end

      def create(params)
        coach_id = (params[:coach_id].nil? && params[:type]=='ExtraSession') ? ::Coach.unscoped.find_by_rs_email(FALSE_COACH_EMAIL).id : params[:coach_id]
        coach    = ::Coach.unscoped.find_by_id(coach_id)
        create_session_in_saas(params[:session_start_time], params)
        slot_id = get_free_slot_id(coach.coach_guid, params[:session_start_time], params[:lang_identifier], params[:number_of_seats].to_i)
        create_booking_in_saas(slot_id, coach, params[:lang_identifier], params[:number_of_seats]) if slot_id
      end  

      def cancel(slot_id, session_start_time, language, number_of_seats)
        cookie = SuperSaas::User.login_as_admin
        data_map =  { "oldslot[id]"=> slot_id, "destroy"=>"Delete Slot", "oldslot[title]"=>"  ", "oldslot[repeater]"=>"0", "oldslot[price]"=>"1", "oldslot[finish_time]"=>(session_start_time + 1.hour).strftime("%Y-%m-%d %H:%M"), "oldslot[capacity]"=>"2", "utf8"=>"%E2%9C%93", "oldslot[start_time]"=> session_start_time.strftime("%Y-%m-%d %H:%M")} 
        path = "/schedule/#{user}/#{get_schedule_name(language,number_of_seats)}"
        get_connection.post(path, data_map.to_query,{"Cookie" => cookie}).code
      end   

      def create_session_in_saas(session_start_time, options)
        cookie = SuperSaas::User.login_as_admin
        options[:title] = options[:title] || "Live Tutoring"
        data_map =  { "commit"=>"Create Slot", "slot[title]"=>options[:title], "slot[description]"=>options[:description], "slot[location]"=>options[:location], "slot[repeater]"=>"0", "slot[price]"=>"1", "slot[finish_time]"=>(session_start_time + 1.hour).strftime("%Y-%m-%d %H:%M"), "slot[capacity]"=>options[:number_of_seats].to_i + 1, "utf8"=>"%E2%9C%93", "slot[start_time]"=> session_start_time.strftime("%Y-%m-%d %H:%M")} if Language[options[:lang_identifier]].is_aria?
        data_map =  { "commit"=>"Create Slot", "slot[title]"=>options[:title], "slot[description]"=>options[:description].to_json, "slot[repeater]"=>"0", "slot[price]"=>"1", "slot[finish_time]"=>(session_start_time + Language[options[:lang_identifier]].duration_in_seconds).strftime('%Y-%m-%dT%H:%M:%S.000Z'), "slot[capacity]"=>options[:number_of_seats].to_i + 1, "utf8"=>"%E2%9C%93", "slot[start_time]"=> session_start_time.strftime('%Y-%m-%dT%H:%M:%S.000Z')} if Language[options[:lang_identifier]].is_tmm_phone? ||  Language[options[:lang_identifier]].is_tmm_michelin?
        path = "/schedule/#{user}/#{get_schedule_name(options[:lang_identifier],options[:number_of_seats])}"
        get_connection.post(path, data_map.to_query,{"Cookie" => cookie}).code
      end

      def update_session_in_saas(session_start_time, options)
        cookie = SuperSaas::User.login_as_admin
        data_map =  { "edit"=>"Update Slot", "oldslot[id]"=>options[:id], "oldslot[title]"=>options[:title], "oldslot[description]"=>options[:description], "oldslot[location]"=>options[:location], "oldslot[repeater]"=>"0", "oldslot[price]"=>"1", "oldslot[finish_time]"=>(session_start_time + 1.hour).strftime("%Y-%m-%d %H:%M"), "oldslot[capacity]"=>options[:number_of_seats].to_i + 1, "utf8"=>"%E2%9C%93", "oldslot[start_time]"=> session_start_time.strftime("%Y-%m-%d %H:%M")} 
        path = "/schedule/#{user}/#{get_schedule_name(options[:lang_identifier],options[:number_of_seats])}"
        get_connection.post(path, data_map.to_query,{"Cookie" => cookie}).code
      end

      def create_booking_in_saas(slot_id, coach, language, number_of_seats)
        path = "/schedule/#{user}/#{get_schedule_name(language,number_of_seats)}"
        cookie = SuperSaas::User.login_as_coach(coach)
        data_map = {
            'utf8' => '%E2%9C%93',
            'booking[slot_id]' => slot_id,
            'commit' => 'Create Reservation',
        } if Language[language].is_aria? || Language[language].is_tmm_phone? || Language[language].is_tmm_michelin?
        return slot_id if get_connection.post(path, data_map.to_query,{"Cookie" => cookie}).code == "200"
      end 

      # def substitute( session, grabber_coach, coach ,trigger_event) Trigger event not used as supersass substitute is only called when immediately subbing
      def substitute( session, grabber_coach, coach)
        coach = session.substitution.coach if coach.nil?
        res = delete_booking_in_saas(session.eschool_session_id, coach, session.language_identifier , session.number_of_seats)
        res = create_booking_in_saas(session.eschool_session_id, grabber_coach, session.language_identifier, session.number_of_seats ) if res=='200'
        res = update_supersaas_description(session, grabber_coach, coach, res) if !res.nil? && !session.aria?
        response = res.nil? ? '': res
      end

      def update_supersaas_description(session, grabber_coach, coach, slot_id)
        supersaas_desc = fetch_slot_description(grabber_coach.coach_guid, session.language_identifier, session.session_start_time, session.number_of_seats)
        supersaas_desc["ch"]["n"]=grabber_coach.full_name
        supersaas_desc["ch"]["pid"]=grabber_coach.coach_guid
        supersaas_desc["ch"]["wbx"]={"hid" => grabber_coach.email, "hpwd" => "4*nU\>=?BBJv;Kt", "em" => grabber_coach.email} if session.tmm_michelin?
        options = { 
          :id => slot_id,
          :title => session.tmm_michelin? ? 'Michelin Session' : 'CSP-BookingApp',
          :description => supersaas_desc.to_json,
          :lang_identifier => session.language_identifier,
          :session_start_time => (session.session_start_time).strftime('%Y-%m-%dT%H:%M:%S.000Z'),
          :session_end_time => (session.tmm_michelin? ? (session.session_start_time + 1.hour) : (session.session_start_time + 30.minutes)).strftime('%Y-%m-%dT%H:%M:%S.000Z'),
          :number_of_seats => session.number_of_seats,
        }
        update_booking_in_saas(options)
      end

      def update_booking_in_saas(options)
        cookie = SuperSaas::User.login_as_admin
        data_map =  { "edit"=>"Update Slot", "oldslot[id]"=>options[:id], "oldslot[title]"=>options[:title], "oldslot[description]"=>options[:description], "oldslot[repeater]"=>"0", "oldslot[price]"=>"1", "oldslot[finish_time]"=>options[:session_end_time], "oldslot[capacity]"=>options[:number_of_seats].to_i + 1, "utf8"=>"%E2%9C%93", "oldslot[start_time]"=> options[:session_start_time]} 
        path = "/schedule/#{user}/#{get_schedule_name(options[:lang_identifier],options[:number_of_seats])}"
        get_connection.post(path, data_map.to_query,{"Cookie" => cookie}).code
      end

      def delete_booking_in_saas(slot_id, coach, language, number_of_seats)
        booking_id =  find_by_id(slot_id,language,number_of_seats).select{|booking| booking[:email] == coach.rs_email}.first.try(:fetch,:booking_id)
        path = "/schedule/#{user}/#{get_schedule_name(language,number_of_seats)}"
        cookie = SuperSaas::User.login_as_coach(coach)
        data_map = {
            'utf8' => '%E2%9C%93',
            'oldbooking[slot_id]' => slot_id,
            'destroy' => 'Delete Reservation',
            'oldbooking[id]' => booking_id,
            'oldbooking[change]'=> '0'
        }
        get_connection.post(path, data_map.to_query,{"Cookie" => cookie}).code if booking_id
      end 

      def fetch_slot_description(guid, identifier, start_time, number_of_seats)
        resp = get_slot_id_for_session(guid, identifier, start_time, number_of_seats)
        resp.attributes["slot"].attributes["description"]
        JSON.parse(resp.attributes["slot"].attributes["description"]) if Language[identifier].is_tmm_phone? || Language[identifier].is_tmm_michelin?
      end
       
    end
  end
end
