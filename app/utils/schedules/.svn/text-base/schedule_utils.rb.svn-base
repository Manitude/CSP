module ScheduleUtils
  class SlotInfo
  end
  class SlotInfoLotus
    class << self ; attr_accessor :shift_details, :language_id, :session_start_time, :local_sessions
    end
    @shift_details ||= []
    @language_id ||= ""
    @session_start_time ||= ""
    @local_session ||= []

    def self.create_shift_details(external_village_id, village,coach_session_id, recurring, recurring_text, coach_id, is_extra_session , session_name, sub_req_coach, sub_req_coach_id , coach_full_name)
      shift_details_lotus = ShiftDetailsLotus.new(external_village_id, village,coach_session_id, recurring, recurring_text, coach_id, is_extra_session , session_name, sub_req_coach, sub_req_coach_id , coach_full_name)
    end

    def self.insert_into_shift_details(external_village_id, village,coach_session_id, recurring, recurring_text, coach_id, is_extra_session , session_name, sub_req_coach, sub_req_coach_id , coach_full_name)
      @shift_details << create_shift_details(external_village_id, village,coach_session_id, recurring, recurring_text, coach_id, is_extra_session , session_name, sub_req_coach, sub_req_coach_id , coach_full_name)
    end
  end
  class ShiftDetailsLotus
    attr_accessor :external_village_id, :village, :coach_session_id, :recurring, :recurring_text,:coach_id, :is_extra_session, :session_name,:sub_req_coach, :sub_req_coach_id, :coach_full_name
    def intialize (external_village_id = 0, village="", coach_session_id="", recurring = false, recurring_text="", coach_id=0, is_extra_session = false, session_name = "", sub_req_coach = "", sub_req_coach_id ="", coach_full_name = "" )
      @external_village_id = external_village_id
      @village = village
      @coach_session_id = coach_session_id
      @recurring = recurring
      @recurring_text = recurring_text
      @coach_id = coach_id
      @is_extra_session = is_extra_session
      @session_name = session_name
      @sub_req_coach = sub_req_coach
      @sub_req_coach_id = sub_req_coach_id
      @coach_full_name = coach_full_name
    end
  end
  class LocalSessionLotus

  end
end
