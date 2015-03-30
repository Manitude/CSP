class AppointmentTypesController < ApplicationController

  layout 'default', :only => [:index]

  def authenticate
    access_denied unless manager_logged_in?
  end
  
  def index
    self.page_title = "Appointment Types"
    @appointment_types = AppointmentType.order('active DESC').order('title')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @appointment_types }
    end
  end

  def edit
    @new_appointment_type = AppointmentType.find(params[:id])
  end

  def new
    @new_appointment_type = AppointmentType.new
  end

  def create
    @appointment_type = AppointmentType.new(params[:appointment_type])
    if @appointment_type.save
      render :text => 'success'
    else
      render :text => 'failure'
    end
    # respond_to do |format|
    #   if @appointment_type.save
    #     format.html { redirect_to(appointment_types_path) }
    #     format.xml  { render :xml => appointment_types_path, :status => :created, :location => appointment_types_path }
    #   else
    #     format.html { redirect_to(appointment_types_path) }
    #     format.xml  { render :xml => @appointment_type.errors, :status => :unprocessable_entity }
       
    #   end
    # end
  end

  def update
    @appointment_type = AppointmentType.find(params[:id])
    if @appointment_type.update_attributes(params[:appointment_type])
      render :partial => 'appointment_row', :locals => {:appointment_row => @appointment_type}
    else
      render :text => 'failure'
    end
  end

  def destroy
    @appointment_type = AppointmentType.find(params[:id])
    @appointment_type.destroy

    respond_to do |format|
      format.html { redirect_to(appointment_types_url) }
      format.xml  { head :ok }
    end
  end
end