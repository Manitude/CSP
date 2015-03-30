class Extranet::AnnouncementsController < ApplicationController

  before_filter :find_announcement,  :only => [:show, :edit, :update, :destroy]
  before_filter :set_languages, :only => [:new, :create, :edit, :update]

  # GET /announcements
  # GET /announcements.xml
  def index
    self.page_title = "Announcements"
    @announcements = params[:search].blank? ? current_user.announcements(false) : Announcement.search(params[:search])
    @total_records = @announcements.length
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @announcements }
    end
  end

  # GET /announcements/1
  # GET /announcements/1.xml
  def show
    self.page_title = "Show Announcement"
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @announcement }
    end
  end

  # GET /announcements/new
  # GET /announcements/new.xml
  def new
    self.page_title = "New announcement"
    @announcement = Announcement.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @announcement }
    end
  end

  # GET /announcements/1/edit
  def edit
    self.page_title = "Editing announcement"
  end

  # POST /announcements
  # POST /announcements.xml
  def create
    @announcement = Announcement.new(params[:announcement])
    respond_to do |format|
      if @announcement.save
        @announcement.update_attribute(:language_name, !@announcement.language.nil? ? @announcement.language.display_name : 'ALL')
        format.html { redirect_to(@announcement, :notice => 'Announcement was successfully created.') }
        format.xml  { render :xml => @announcement, :status => :created, :location => @announcement }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @announcement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /announcements/1
  # PUT /announcements/1.xml
  def update
    respond_to do |format|
      if @announcement.update_attributes(params[:announcement])
        @announcement.update_attribute(:language_name, !@announcement.language.nil? ? @announcement.language.display_name : 'ALL')
        format.html { redirect_to(@announcement, :notice => 'Announcement was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @announcement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /announcements/1
  # DELETE /announcements/1.xml
  def destroy
    @announcement.destroy
    respond_to do |format|
      format.html { redirect_to(announcements_url, :notice => 'Announcement was successfully deleted.') }
      format.xml  { head :ok }
    end
  end

  private

  def find_announcement
    @announcement = Announcement.find(params[:id])
  end

  def set_languages
    @languages = Language.options
    @languages.delete_at(2) #reflex sunset
  end
end
