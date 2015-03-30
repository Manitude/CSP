class Extranet::ResourcesController < ApplicationController

  before_filter :allow_access, :only => [ :new, :create, :edit, :update, :destroy]

  # GET /resources
  # GET /resources.xml
  def index
    self.page_title = "Listing resources"
    @resources = Resource.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @resources }
    end
  end

  # GET /resources/1
  # GET /resources/1.xml
  def show
    self.page_title = "Resource Details"
    @resource = Resource.find(params[:id])
    respond_to do |format|
      format.html do
        send_data(@resource.db_file.data, :type => @resource.content_type) if params[:download]
      end
      format.xml  { render :xml => @resource }
    end
  end

  # GET /resources/new
  # GET /resources/new.xml
  def new
    self.page_title = "New resource"
    @resource = Resource.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @resource }
    end
  end

  # GET /resources/1/edit
  def edit
    self.page_title = "Editing resource"
    @resource = Resource.find(params[:id])
  end

  # POST /resources
  # POST /resources.xml
  def create
    @resource = Resource.new(params[:resource])
    respond_to do |format|
      if @resource.save
        format.html { redirect_to(@resource, :notice => 'Resource was successfully created.') }
        format.xml  { render :xml => @resource, :status => :created, :location => @resource }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @resource.errors, :status => :unprocessable_entity }
      end
    end

  end

  # PUT /resources/1
  # PUT /resources/1.xml
  def update
    @resource = Resource.find(params[:id])
    respond_to do |format|
      if @resource.update_attributes(params[:resource])
        format.html { redirect_to(@resource, :notice => 'Resource was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @resource.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /resources/1
  # DELETE /resources/1.xml
  def destroy
    @resource = Resource.find(params[:id])
    @resource.destroy
    respond_to do |format|
      format.html { redirect_to(resources_url, :notice => 'Resource was successfully deleted.' ) }
      format.xml  { head :ok }
    end
  end

  # for downloading the resource document
  def download_file
    path = params['path']
    file_path = File.expand_path(Rails.root + 'public' + path[1..-1]) #path[1..-1] removes the '/' in the beginning
    send_file(file_path)
  end

  private

  def allow_access
    if coach_logged_in?
      redirect_back_or_default resources_url
      flash[:error] = "Sorry, you are not authorized to access the requested page."
    end
  end

end
