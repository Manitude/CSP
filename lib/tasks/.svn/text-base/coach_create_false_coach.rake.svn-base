namespace :false_coach do
  desc "create a false coach for AEB and RSA extra session "
  task :create_coach => :environment do
      phone_dialect = Language["TMM-ENG-P"].dialects.first
      live_dialect = Language["TMM-ENG-L"].dialects.first
      quals = {}
      (AriaLanguage.all+TMMLiveLanguage.all+TMMPhoneLanguage.all+TMMMichelinLanguage.all).each_with_index do |lang,i|
        if lang == Language["TMM-ENG-P"]
          dialect_id = phone_dialect.id.to_s
        elsif lang == Language["TMM-ENG-L"]
          dialect_id = live_dialect.id.to_s
        else
          dialect_id = ""
        end
        quals[i.to_s] = {"max_unit"=>"","language_id"=>"#{lang.id}","dialect_id"=>"#{dialect_id}"}
      end
      params = {  
        :commit=>"Save",
        :coach=>{"primary_phone"=>"1234567890", "mobile_phone"=>"", "birth_date(2i)"=>"1", "hire_date(1i)"=>"2015", "birth_date(3i)"=>"7", "full_name"=>"Tutor TBD", "bio"=>"", "secondary_phone"=>"", "personal_email"=>"", "hire_date(2i)"=>"1", "skype_id"=>"", "rs_email"=>FALSE_COACH_EMAIL, "preferred_name"=>"TutorTBD", "user_name"=>"TutorTBD", "region_id"=>"", "primary_country_code"=>"91", "birth_date(1i)"=>"1985", "mobile_country_code"=>"", "hire_date(3i)"=>"7"},
        :action=>"create_coach",
        :coach_contact=>{"coach_manager"=>"", "supervisor"=>""}, 
        :controller=>"coach", 
        :qualifications=>quals,
        :remove_profile_picture=>"false", 
        :authenticity_token=>"xu/i2uAh3r8OJC0Q+kYYhOd1etGdhoWtzk7iGdewcsM=", 
        :utf8=>"✓"
      }

      @coach = Coach.new(params[:coach])
      @coach_contact = CoachContact.new(params[:coach_contact])
      @coach.manager_id = nil #current_manager.id
      @coach.coach_contact = @coach_contact
      #Adding Michelin to the qualifications if it contains French Live
      params[:qualifications][params[:qualifications].size]={"language_id"=>Language["TMM-MCH-L"].id} if params[:qualifications].values.collect{|q| q["language_id"].to_i}.include?(Language["TMM-FRA-L"].id)
      params[:qualifications].each_value do |qual|
            lang = Language.find_by_id(qual["language_id"])
            qual["max_unit"] = "1" unless lang.is_totale?
            qual["dialect_id"] = nil if lang.dialects.empty?
            @coach.qualifications << Qualification.new(qual)
      end
      rs_email_valid =  !(Account.where(:rs_email => @coach.rs_email).count > 0)
      # csp921 avoid creating outside csp if tmm
      if (@coach.save && rs_email_valid)
          @coach.create_or_update_outside_csp("create")
      else
          @coach.errors.add("RS email", _("has_already_been_taken3059C68E")) unless rs_email_valid
      end

      
      if @coach.errors.blank?
        puts 'Coach was successfully created.'
      else
        puts "#{ @coach.errors.inspect }"
        @coach.destroy
        puts 'Coach creation failure'
      end
  end
end
