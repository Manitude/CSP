module Eschool
  class Coach < Base

    self.element_name = ""
    #Eschool::Coach.create_coach_profile(:coach => {:id => 134, :user_name => "abc", :full_name => "abc, :rs_email => "abc@rs.com", :active => true, :time_zone => Time.zone.now}, :level_number => level_number,:language_identifier => language_identifier)
    #will update fields based on user_name: full name, email, active,timezone
    # if no record available in eSchool, a new record is created
    def self.create_or_update_coach_profile(coach,language_identifier,level_number)
      within_eschool_rescuer do
        self.prefix = "/api/cs/create_or_update_teacher_profile"
        post :teachers,{:id => coach.id,
          :user_name => coach.user_name,
          :full_name => coach.full_name,
          :email => coach.rs_email,
          :active => coach.active,
          :time_zone => coach.time_zone,
          :level_number => level_number,
          :language_identifier => language_identifier
        }
      end
    end

    # Eschool::Coach.create_or_update_coach_profile_with_multiple_qualifications(:coach => {:id => 134, :user_name => "abc", :full_name => "abc, :rs_email => "abc@rs.com", :active => true, :time_zone => Time.zone.now}, :level_number => level_number,:language_identifier => language_identifier)
    # will update fields based on external_coach_id: full name, email, active,timezone, preferred_name,manager_id, qualifications
    # if no record available in eSchool, a new record is created
    def self.create_or_update_teacher_profile_with_multiple_qualifications(teacher)
      within_eschool_rescuer do
        self.prefix = "/api/cs/create_or_update_teacher_profile_with_multiple_qualifications"
        post :teachers,{:id => teacher.id,
          :user_name => teacher.user_name,
          :full_name => teacher.full_name,
          :email => teacher.rs_email,
          :active => teacher.active,
          :time_zone => teacher.time_zone,
          :preferred_name => teacher.preferred_name,
          :coach_manager_id => (teacher.is_manager? || teacher.manager.nil?) ? nil: teacher.manager.id,
          :qualifications => teacher.is_manager? ? teacher.all_managed_language_identifier : teacher.all_languages_and_max_unit,
          :is_manager => teacher.is_manager?

        }
      end
    end

    #Eschool::Coach.feed_external_coach_ids({:coaches=>[
    # {:id => 54, :user_name => 'becks', :email => 'david@beckham.com'}, {:id => 87, :user_name => 'posh', :email => 'victoria@beckham.com'}]})
    def self.feed_external_coach_ids(params)
      within_eschool_rescuer do
        self.prefix = "/api/cs/feed_external_coach_ids"
        post :coaches, nil, params[:coaches].to_xml(:root => "coaches")
      end
    end

    #Eschool::Coach.find_teacher_profile_conflicts([3,56,76,200,207,234,289])
    def self.find_teacher_profile_conflicts(ids)
      within_eschool_rescuer do
        self.prefix = "/api/cs/compare_teacher_profiles"
        post :external_coach_ids, nil, {:ids => ids.compact.join(',')}.to_xml(:root => "external_coach_ids")
      end
    end

    #Eschool::Coach.find_teachers_with_auto_generated_external_coach_id()
    def self.find_teachers_with_auto_generated_external_coach_id
      within_eschool_rescuer do
        find(:all, :from => "/api/cs/find_teachers_with_auto_generated_external_coach_id")
      end
    end

    def self.update_manager_for_coaches(coach_ids,manager_id)
      within_eschool_rescuer do
        self.prefix = "/api/cs/update_manager_for_coaches"
        post :coaches, {:coach_ids => coach_ids, :manager_id => manager_id}
      end
    end

    def self.get_session_feedback_per_teacher_counts(ids, from, to)
      within_eschool_rescuer do
        self.prefix = "/api/cs/get_session_feedback_per_teacher_counts"
        post :feedback, nil, {:ids => ids.compact.join(','), :from => from, :to => to}.to_xml(:root => "feedback")
      end
    end

  end
end
