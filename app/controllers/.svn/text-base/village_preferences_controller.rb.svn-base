class VillagePreferencesController < ApplicationController
  layout 'default', :only => [:index]

  def authenticate
    access_denied unless manager_logged_in?
  end
  
  def index

    self.page_title     = "Villages"
    @villages           = Community::Village.order("name asc")
    
    disabled_villages   = VillagePreference.where("status='disabled'")

    @disabled_village_ids = {}
    disabled_villages.each do |village|
       @disabled_village_ids[village.village_id] = village.village_id
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @topics }
    end
  end

  # to be used only to post values from ajax.
  def save_village_preferences
      village_id      = params[:hidden_village]
      village_status  = params[:status]

      disabled_village = VillagePreference.find_or_create_by_village_id(village_id.to_i)
      disabled_village.update_attributes({:status => village_status})
      
      render :nothing => true

  end
end