class CoachController < ApplicationController
  # Not to be confused with CoachPortal controller!!
  # For crud operations on coach.
  # Manager uses it.

  layout 'manager_portal'

  def authenticate
    access_denied unless manager_logged_in?
  end

  def create_coach
    @coach_type = params["coach_type"].to_i
    @coach_type_visible = true
    if request.post? && params[:coach]
      @coach = Coach.new(params[:coach])
      @coach_contact = CoachContact.new(params[:coach_contact])
      @coach.manager_id = current_manager.id
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
        flash[:notice] = 'Coach was successfully created.'
        redirect_to '/create-coach'
      else
        @coach.destroy
      end
    else
      @coach = Coach.new
      @coach.qualifications << Qualification.new # to keep qualification partial happy
    end
  end

  def edit_coach
    @coach = Coach.find_by_id(params[:id])
    @coach_contact = (@coach.coach_contact ||= CoachContact.new)
    
    if request.post? && params[:coach]
      @coach_contact.update_attributes(params[:coach_contact])
      if params[:remove_profile_picture] == "true"
        @coach.photo = nil
        ActiveRecord::Base.connection.execute("UPDATE accounts SET photo_file = null WHERE id = #{@coach.id}")
      end
      action = getActionType
      @coach.update_attributes(params[:coach])
      # Adding Michelin to the qualifications if it contains French Live
      params[:qualifications][params[:qualifications].size]={"language_id"=>Language["TMM-MCH-L"].id} if params[:qualifications].values.collect{|q| q["language_id"].to_i}.include?(Language["TMM-FRA-L"].id)
      removed_language_ids = @coach.qualifications.collect{|q| q.language_id} - params[:qualifications].values.collect{|q| q["language_id"].to_i}
      
      if removed_language_ids.any?
        condition = "coach_id = #{@coach.id} AND language_id IN (#{removed_language_ids.join(", ")})"
        CoachSession.where("#{condition} AND cancelled = 0 AND session_start_time >= NOW()").each do |session|
          session.cancel_or_subsitute!
        end
        CoachRecurringSchedule.update_all("recurring_end_date = NOW()", "#{condition} AND (recurring_end_date IS NULL OR recurring_end_date >= NOW())")
        Qualification.delete_all("#{condition} AND max_unit IS NOT NULL")
        @coach.qualifications.reload
      end
      
      # update/add qualifications
      params[:qualifications].values.each do |qual|
        lang = Language.find_by_id(qual["language_id"])
        qual["max_unit"] = 1 unless lang.is_totale?
        qual["dialect_id"] = nil if lang.dialects.empty?
        @coach.update_or_create_qualification(qual["language_id"].to_i, qual["max_unit"].to_i, qual["dialect_id"].to_i)
      end
      
      @coach.create_or_update_outside_csp(action) if @coach.errors.blank?
      if @coach.errors.blank?
        flash[:notice] = "Profile has been updated successfully."
        redirect_to view_coach_profiles_path(:coach_id => @coach.id)
      end
    end
    if !@coach.qualifications.any? then
      @coach.qualifications << Qualification.new
    end
  end

  def getActionType
    action = nil
    @coach.qualifications.each do |qual|
      action = "update" if qual.language.is_aria?
    end
    if !action
      params[:qualifications].values.each do |qual|
        action = "create" if Language.find_by_id(qual["language_id"].to_i).is_aria?
      end
    end
    action
  end
  
end
