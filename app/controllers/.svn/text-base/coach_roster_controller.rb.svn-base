require 'faster_csv'

class CoachRosterController < ApplicationController
  
  before_filter :authenticate_manager, :only => [:edit_management_team, :management_team_form, :save_member_details, :delete_member, :hide_member, :save_order_of_members]
  downloads_files_for :management_team_member, :image

  def coach_roster
    @language = Language.find_by_identifier(params[:language]) if params[:language]
    region = params[:region].to_s
    @coach_list = @language ? Coach.coach_list_for_language_and_region(params[:language], region) : Coach.coach_list_for_language_and_region("", region)
    populate_languages_for_coaches unless @coach_list.blank?
    populate_managers_list
  end

  def edit_management_team
    populate_managers_list(false)
  end

  def management_team_form
    @team_member = params[:member_id] ? ManagementTeamMember.find_by_id(params[:member_id]) : ManagementTeamMember.new()
    render_to_facebox
  end

  def save_member_details
    member_from_params = ManagementTeamMember.find_by_id(params[:member_id])
    if member_from_params
      if params[:remove_profile_picture] == "true"
        member_from_params.image = nil
        ActiveRecord::Base.connection.execute("UPDATE management_team_members SET image_file = null WHERE id = #{member_from_params.id}")
      end
      member_from_params.update_attributes(params[:management_team_member])
      errors = member_from_params.errors
    else
      member = ManagementTeamMember.create(params[:management_team_member])
      member.update_attribute('position', ManagementTeamMember.maximum(:position).to_i + 1) unless member.errors.any?
      errors = member.errors
    end
    if errors.any?
      render :text => " Following errors were found : <br/> * "+errors.full_messages.join('<br/> * '), :status => 500
    else
      render :text => (member_from_params ? "Member updated successfully" : "Member added successfully")
    end
  end

  def delete_member
    member = ManagementTeamMember.find_by_id(params[:member_id])
    if member && member.destroy
      render :text => "Member deleted successfully"
    else
      render :text => "Something went wrong. Please report this problem.", :status => 500
    end
  end

  def hide_member
    member = ManagementTeamMember.find_by_id(params[:member_id])
    hide = params[:hide] == "true"
    if member && member.update_attribute("hide", hide)
      render :text => "Member updated successfully"
    else
      render :text => "Something went wrong. Please report this problem.", :status => 500
    end
  end

  def save_order_of_members
    new_order = params[:new_order]
    new_order.each_with_index do |member_id, i| 
      member = ManagementTeamMember.find_by_id(member_id)
      member.update_attribute('position', i+1) if member
    end
    render :text => "Success"
  end

  def export_coach_list_as_csv
    language = Language.find_by_identifier(params[:language]) if params[:language]
    region = params[:region].to_s
    @coach_list = language ? Coach.coach_list_for_language_and_region(params[:language], region) : Coach.coach_list_for_language_and_region("", region)
    populate_languages_for_coaches unless @coach_list.blank?
    file_name = "Coach List - #{language ? language.display_name : "All Languages"}#{!region.blank? ? ' - ' +Region.find(region.to_i).name : ''}.csv"
    csv_content = []
    @coach_list.each do |coach|
      csv_content << [coach.full_name, (coach.preferred_name.blank? ? "--" : coach.preferred_name), coach.lang_list, 
        (coach.hub_city.blank? ? "--" : coach.hub_city), (coach.primary_phone.blank? ? "--" : coach.primary_phone), coach.rs_email ]
    end
    csv_generator = CsvGenerator.new(['Name','Preferred Name', 'Languages', 'Hub City', 'Phone', 'Email'], csv_content)
    send_data(csv_generator.to_csv,:type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment", :filename => file_name)
  end

  def export_mgmt_list_as_csv
    manager_list = populate_managers_list
    file_name = "Management Team List.csv"
    csv_content = []
    manager_list.each do |mgr|
      csv_content << [mgr.name, (mgr.title.blank? ? "--" : mgr.title), (mgr.phone_cell.blank? ? "--" : mgr.phone_cell), 
        (mgr.phone_desk.blank? ? "--" : mgr.phone_desk), mgr.email ]
    end
    csv_generator = CsvGenerator.new(['Name', 'Title', 'Phone (cell)', 'Phone (desk)', 'Email'], csv_content)
    send_data(csv_generator.to_csv,:type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment", :filename => file_name)
  end

  def authenticate
    access_denied unless (manager_logged_in? or coach_logged_in?)
  end

  def authenticate_manager
    access_denied unless manager_logged_in?
  end

  private

  def populate_managers_list(filter_hidden = true)
    @manager_list = filter_hidden ? ManagementTeamMember.where("hide = ?", false).order("position") : ManagementTeamMember.order("position")
  end

  def populate_languages_for_coaches
    @coach_list.each do |coach|
      coach.lang_list = coach.lang_list ? coach.lang_list.split(',').collect {|lang| Language.find_by_identifier(lang).display_name }.join(", ") : "--"
    end
  end

end