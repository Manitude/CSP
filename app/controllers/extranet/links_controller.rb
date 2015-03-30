class Extranet::LinksController < ApplicationController
  before_filter :find_link,  :only => [:show, :edit, :update, :destroy]
  # GET /links
  # GET /links.xml
  def index
    self.page_title = "Listing links"
    @links = Link.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @links }
    end
  end

  # GET /links/1
  # GET /links/1.xml
  def show
    self.page_title = "Show link"
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @link }
    end
  end

  # GET /links/new
  # GET /links/new.xml
  def new
    self.page_title ="New link"
    @link = Link.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @link }
    end
  end

  # GET /links/1/edit
  def edit
    self.page_title = "Editing link"
  end

  # POST /links
  # POST /links.xml
  def create
    @link = Link.new(params[:link])
    respond_to do |format|
      if @link.save
        format.html { redirect_to(@link, :notice => 'Link was successfully created.') }
        format.xml  { render :xml => @link, :status => :created, :location => @link }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @link.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /links/1
  # PUT /links/1.xml
  def update
    respond_to do |format|
      if @link.update_attributes(params[:link])
        format.html { redirect_to(@link, :notice => 'Link was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @link.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /links/1
  # DELETE /links/1.xml
  def destroy
    @link.destroy
    respond_to do |format|
      format.html { redirect_to(links_url, :notice => 'Link was successfully deleted.')}
      format.xml  { head :ok }
    end
  end


  private

  def find_link
    @link = Link.find(params[:id])
  end

  def authenticate
    (logged_in? && (tier1_support_lead_logged_in? || tier1_support_harrisonburg_user_logged_in? || tier1_support_concierge_user_logged_in? || community_moderator_logged_in? || manager_logged_in? || coach_logged_in?) && !led_user_logged_in?) || access_denied
  end

end
