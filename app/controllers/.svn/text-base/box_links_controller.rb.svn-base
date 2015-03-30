class BoxLinksController < ApplicationController
  
  def index
    @box_links = BoxLink.all
    self.page_title ="Studio Library"
  end

  def new
    @box_link = BoxLink.new
    render :layout => false
  end

  def edit
    @box_link = BoxLink.find(params[:id])
    render :layout => false
  end

  def create
    @box_link = BoxLink.new(params[:box_link])
    if @box_link.save
      redirect_to(box_links_path, :notice => 'Box Widget successfully created.') 
    else
      redirect_to(box_links_path, :flash => { :error => @box_link.errors.full_messages.join('. ')}) 
    end
  end

  def update
    @box_link = BoxLink.find(params[:id])
    if @box_link.update_attributes(params[:box_link])
      redirect_to(box_links_path, :notice => 'Box widget successfully updated.') 
    else
      redirect_to(box_links_path, :flash => { :error => @box_link.errors.full_messages.join('. ')}) 
    end
  end

  def destroy
    @box_link = BoxLink.find(params[:id])
    @box_link.destroy
    render :text => "Success"
  end

  private

  def authenticate
    return true if(manager_logged_in? && [:index, :new, :edit, :create, :update, :destroy].include?(params[:action].to_sym))
    return true if(coach_logged_in? && params[:action].to_sym == :index )
    access_denied
  end

end
