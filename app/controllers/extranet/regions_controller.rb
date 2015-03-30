class Extranet::RegionsController < ApplicationController

  before_filter :find_region,  :only => [:show, :edit, :update, :destroy]

  # GET /regions
  # GET /regions.xml
  def index
    self.page_title = "Listing regions"
    #@regions = Region.search(params[:search] ? params[:search] : '')
    @regions = Region.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @regions }
    end
  end

  # GET /regions/1
  # GET /regions/1.xml
  def show
    self.page_title = "Show region"
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @region }
    end
  end

  # GET /regions/new
  # GET /regions/new.xml
  def new
    self.page_title = "New region"
    @region = Region.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @region }
    end
  end

  # GET /regions/1/edit
  def edit
    self.page_title = "Editing region"
  end

  # POST /regions
  # POST /regions.xml
  def create
    @region = Region.new(params[:region])
    respond_to do |format|
      if @region.save
        flash[:notice] = 'Region was successfully created.'
        format.html { redirect_to(@region) }
        format.xml  { render :xml => @region, :status => :created, :location => @region }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @region.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /regions/1
  # PUT /regions/1.xml
  def update

    respond_to do |format|
      if @region.update_attributes(params[:region])
        flash[:notice] = 'Region was successfully updated.'
        format.html { redirect_to(@region) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @region.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /regions/1
  # DELETE /regions/1.xml
  def destroy
    if @region.announcements.any? or @region.events.any? or @region.coaches.any?
      flash[:notice] = 'Region is associated with one or many announcments/events/coaches'
    else
      @region.destroy
      flash[:notice] = 'Region was successfully deleted.'
    end

    respond_to do |format|
      format.html { redirect_to(regions_url) }
      format.xml  { head :ok }
    end
  end

  private

  def find_region
    @region = Region.find(params[:id])
  end

end
