class Extranet::EventsController < ApplicationController

  before_filter :find_event,  :only => [:show, :edit, :update, :destroy]
  before_filter :set_languages, :only => [:new, :edit, :create, :update]
  
  # GET /events
  # GET /events.xml
  def index
    self.page_title = "Calendar Events"
    events_data
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
    end
  end


   def show_events_by_date
     events_data
    if @events.size == 1
      @event = @events.first
      render "show"
    else
      render "index"
    end
  end

  def calendar
    events_data(true)
    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
  		    page.replace_html 'calendar', :partial => 'shared/extranet/calendar'
  		    page.replace_html 'month_events', :partial => 'shared/extranet/events'
        end
      } if request.xhr?
    end
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    self.page_title = "Show Calendar Event"
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/new
  # GET /events/new.xml
  def new
    self.page_title = "New Calendar Event"
    @event = Event.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/1/edit
  def edit
    self.page_title = "Editing Calendar Event"
  end

  # POST /events
  # POST /events.xml
  def create
    @event = Event.new(params[:event])
    respond_to do |format|
      if @event.save
        format.html { redirect_to(@event, :notice => 'Event was successfully created.') }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
        mail_calendar_notifications_immediately_to_coaches @event
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to(@event, :notice => 'Event was successfully updated.') }
        format.xml  { head :ok }
        mail_calendar_notifications_immediately_to_coaches @event
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to(events_url, :notice => 'Event was successfully deleted.') }
      format.xml  { head :ok }
    end
  end

  private

  def mail_calendar_notifications_immediately_to_coaches(event)
    recipients = Account.email_recipients("calendar_notices_email", event.language_id,event.region_id) 
    GeneralMailer.calendar_notifications_email(event, recipients).deliver if recipients.any? && !Language.find_by_id(event.language_id).try(:is_lotus?)
  end

  def find_event
    @event = Event.find(params[:id])
  end

  def set_languages
    @languages = Language.options
    @languages.delete_at(2) #reflex sunset
  end

end
