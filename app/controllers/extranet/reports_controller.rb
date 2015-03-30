class Extranet::ReportsController < ApplicationController

  def index
  end

  def profile
    @profile_type = params[:type]
  end

  private

  def authenticate
    access_denied unless community_moderator_logged_in?
  end

end
