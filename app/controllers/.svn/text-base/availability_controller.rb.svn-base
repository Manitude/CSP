class AvailabilityController < ApplicationController
  layout 'schedules', :only => :index
  
  def authenticate
    access_denied unless coach_logged_in? or manager_logged_in?
  end

  def index
    self.page_title = "New Template"
    @is_manager = manager_logged_in?
    @coach = current_user.is_coach? ? current_user : Coach.find_by_id(params[:coach_id])
    self.page_title = "Coach Availability" if @is_manager
    if @coach
      @view_schedule_url = @is_manager ? "/coach_scheduler/#{@coach.languages.first.identifier}/#{@coach.id}" : "/my_schedule"
      @availability_templates = @coach.availability_templates
      currently_active_template = @coach.active_template_on_the_time(Time.now.utc)
      if params[:template_id].present?
        @selected_template = CoachAvailabilityTemplate.find_by_id(params[:template_id].to_i)
        if @selected_template.deleted
          flash[:error] = "The Availability template, #{@selected_template.label}, has been deleted and is no longer accessible"
          @selected_template = currently_active_template
        end
      else
        @selected_template = (@availability_templates.present? && currently_active_template.blank?) ? @availability_templates.first : currently_active_template
      end
      load_availability_templates
      @availabilities_hash = [].to_json
      @template_start_date = TimeUtils.time_in_user_zone 
      if @selected_template
        self.page_title = "Coach Availability Template - <span id=\"sub_title\">#{@selected_template.label}</span>".html_safe
        @template_start_date = @selected_template.effective_start_date
        @availabilities_hash = @selected_template.template_availabilities_data.to_json
      end
    else
      access_denied
    end
  end

  def load_template
    selected_template = CoachAvailabilityTemplate.find_by_id(params[:template_id])
    if selected_template
      result= {}
      result[:availabilities] = selected_template.template_availabilities_data
      result[:template_start_date] = format_time(selected_template.effective_start_date)
      result[:template_status] = selected_template.status
      result[:removable] = selected_template.removable_info[:status]
      result[:show_delete_button] = selected_template.removable_info[:show_delete_button]
      result[:template_name] = selected_template.label
      render :json => result.to_json, :status => 200
    else
      render :text => "There is some error, please try again.", :status => 400
    end
  end

  def save_template
    is_manager = manager_logged_in?
    availability_template = CoachAvailabilityTemplate.find_by_id(params[:template_id].to_i)
    coach = Coach.find_by_id(params[:coach_id])
    availability_template = CoachAvailabilityTemplate.create({
        :deleted => false,
        :coach_id => params[:coach_id],
        :effective_start_date => TimeUtils.time_in_user_zone(params[:template_start_date]).utc,
        :status => TEMPLATE_STATUS.index('Draft'),
        :label => params[:label]
      }) if availability_template.nil?
    
    errors = availability_template.errors.full_messages
    if errors.blank?
      result = {}
      availability_template.create_availability_entries_for_template(params[:availabilities], is_manager)     
      if params[:requested_action] == 'Save and Submit'
        if availability_template.substitute_required_if_approved? 
          result['sub_required'] = "true"
          result['template_id'] = availability_template.id
        else
          availability_template.approve_and_notify(is_manager)
          flash[:notice] = " Changes to #{availability_template.label} have been saved successfully." if manager_logged_in?
          result['sub_required'] = "false"
          result['template_label'] = availability_template.label
        end
      elsif params[:requested_action] == 'Save'
        result['notice'] = "Availability template '#{availability_template.label}' was saved as draft."
        result['template_id'] = availability_template.id
        result['template_label'] = availability_template.label
      end
      render :json => result.to_json, :status => 200
    else
      render :text => errors.join(', '), :status => 400
    end
  end

  def approve_template
    availability_template = CoachAvailabilityTemplate.find_by_id(params[:template_id])
    if availability_template
      coach = Coach.find_by_id(availability_template.coach_id)  
      availability_template.approve_and_notify(manager_logged_in?)
      availability_template.trigger_substitutions_for_template_change
      flash[:notice] = " Changes to #{availability_template.label} have been saved successfully." if manager_logged_in?
      render :text => availability_template.label, :status => 200
    else
      render :text => "There is some error, please try again.", :status => 400
    end
  end

  def delete_template
    availability_template = CoachAvailabilityTemplate.find_by_id(params[:template_id])
    if availability_template
      validate_status = availability_template.removable_info
      if validate_status[:status]
        availability_template.update_attributes(:deleted => true)
        
        #Trigger notification and email if CM is deleting a template
        if manager_logged_in?
          TriggerEvent['CM_DELETED_TEMPLATE'].notification_trigger!(availability_template)         #Trigger template deletion
          availability_template.send_template_deleted_notification_mail         #send an email to the coach when the template is deleted by the manager
          flash[:notice] = "The availability template #{availability_template.label} has been deleted." 
        end

        render :text => availability_template.label, :status => 200

      else
        render :text => validate_status[:message], :status => 400
      end
    else
      render :text => "There is some error, please try again.", :status => 400
    end
  end

  private

  def load_availability_templates
    @availability_templates.delete_if{|template| template.status == TEMPLATE_STATUS.index('Draft')} if manager_logged_in?
    @template_list_for_select = @availability_templates.inject([]) {|template_hash, template| template_hash << [template.label, template.id]}
    @template_list_for_select = [["SELECT TEMPLATE",0]] + @template_list_for_select unless manager_logged_in?
  end

end
