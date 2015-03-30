require File.expand_path('../../test_helper', __FILE__)

class AvailabilityControllerTest < ActionController::TestCase
  fixtures :trigger_events, :notifications, :notification_recipients
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    #login_as_custom_user(AdGroup.coach_manager, 'hello')
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_index

    #test for a valid coach/manager
     login_as_custom_user(AdGroup.coach_manager, 'hello')
     coach = create_coach_with_qualifications
     template = FactoryGirl.create(:coach_availability_template, :effective_start_date => Time.now + 10.days, :coach_id => coach.id, :label => 'Preethi')
     get :index , :template_id => template.id , :coach_id => coach.id
     assert_select "title" , "Customer Success Portal: Coach Availability Template - Preethi"
    #test for an invalid coach
    template2 = FactoryGirl.create(:coach_availability_template, :effective_start_date => Time.now + 14.days, :coach_id => coach.id, :label => 'pbaskar')
    get :delete_template , :template_id => template2.id 
    get :index , :template_id => template2.id
    assert_equal "Sorry, you are not authorized to view the requested page. Please contact the IT Help Desk.", flash[:error]

  end

  def test_load_template
    coach = login_as_coach()

    #test load template without a valid template id
    template = FactoryGirl.create(:coach_availability_template, :effective_start_date => Time.now + 1.day, :coach_id => coach.id, :label => 'Fall')
    get :load_template 
    assert_equal response.body,"There is some error, please try again."

    #test load template with a valid template id
    get :load_template , :template_id => template.id
    template_data = JSON.parse(@response.body)
    assert_nil template_data[:availabilities]
  end

  def test_save_template
    login_as_custom_user(AdGroup.coach_manager, 'hello')
    coach = create_a_coach
    FactoryGirl.create(:trigger_event, :name => "CM_CREATED_NEW_TEMPLATE", :description => "Coach Manager creates a new template for the coach.")
    FactoryGirl.create(:trigger_event, :name => "PROCESS_NEW_TEMPLATE", :description => "System processes a new template for review by a Coach Manager.")
    #test save template as draft
    template1 = FactoryGirl.create(:coach_availability_template, :effective_start_date => Time.now + 1.day, :coach_id => coach.id, :label => 'Fall')
    post :save_template , :template_id => template1.id , :availabilities => [],:requested_action => "Save"
    template_data = JSON.parse(@response.body)
    assert_equal "Availability template 'Fall' was saved as draft." , template_data["notice"]
    
    #test save template as 'save and submit'
    template2 = FactoryGirl.create(:coach_availability_template, :effective_start_date => Time.now + 2.days, :coach_id => coach.id, :label => 'Summer')
    post :save_template , :template_id => template2.id , :availabilities => [],:requested_action => "Save and Submit"
    template_data = JSON.parse(@response.body)
    assert_equal " Changes to Summer have been saved successfully." , flash[:notice]

    #test save template with substitute required
    template3 = FactoryGirl.create(:coach_availability_template, :effective_start_date => Time.now + 5.days, :coach_id => coach.id, :label => 'Winter')
    CoachAvailabilityTemplate.any_instance.expects(:substitute_required_if_approved?).returns true
    post :save_template , :template_id => template3.id , :availabilities => [],:requested_action => "Save and Submit"
    template_data = JSON.parse(@response.body)
    assert_equal template_data["sub_required"] , "true"
  end

  def test_delete_template
    coach = login_as_coach()
    
    #test for cannot delete an 'only available template'
    template1 = FactoryGirl.create(:coach_availability_template, :effective_start_date => Time.now + 1.day, :coach_id => coach.id, :label => 'Fall')
    AvailabilityController.any_instance.stubs(:manager_logged_in?).returns true
    get :delete_template , :template_id => template1.id
    assert_equal response.body,"ONLY AVAILABLE TEMPLATE"
    
    #test for delete template when there exists more than one template for coach
    template2 = FactoryGirl.create(:coach_availability_template, :effective_start_date => Time.now + 2.days, :coach_id => coach.id, :label => 'Summer')
    get :delete_template , :template_id => template2.id
    assert_equal "The availability template Summer has been deleted." , flash[:notice]
    
    #test for cannot delete invalid template
    get :delete_template
    assert_equal response.body,"There is some error, please try again."
  end

  def test_approve_template
    coach = login_as_coach()
    template = FactoryGirl.create(:coach_availability_template, :effective_start_date => Time.now + 1.day, :coach_id => coach.id, :label => 'Fall')
    AvailabilityController.any_instance.stubs(:manager_logged_in?).returns true
    FactoryGirl.create(:trigger_event, :name => "CM_CREATED_NEW_TEMPLATE", :description => "Coach Manager creates a new template for the coach.")
    FactoryGirl.create(:trigger_event, :name => "PROCESS_NEW_TEMPLATE", :description => "System processes a new template for review by a Coach Manager.")
    #Approve a valid template test
    get :approve_template , :template_id => template.id
    assert_equal " Changes to Fall have been saved successfully.", flash[:notice]
   
    #Cannot delete template when it is invalid
    get :approve_template
    assert_equal response.body,"There is some error, please try again."
  end

  
  def test_load_availability_templates
    coach = login_as_coach()
    FactoryGirl.create(:coach_availability_template, :effective_start_date => Time.now + 1.day, :coach_id => coach.id, :label => 'Fall')
    availability_controller = Kernel.const_get("AvailabilityController").new               #Using Reflection, as the private methods cannot be called directly.
    AvailabilityController.any_instance.stubs(:manager_logged_in?).returns false
    availability_controller.instance_variable_set(:@availability_templates, coach.availability_templates)    #Sets instance variable. Though its bad, its required in the private method. Need to refactor the way its written, after the release.
    assert_equal availability_controller.send(:load_availability_templates), [["SELECT TEMPLATE", 0], [coach.availability_templates.first.label, coach.availability_templates.first.id]]

    AvailabilityController.any_instance.stubs(:manager_logged_in?).returns true
    availability_controller.send(:load_availability_templates)
    assert_equal availability_controller.instance_variable_get(:@template_list_for_select), [[coach.availability_templates.first.label, coach.availability_templates.first.id]] #This is bad too in the controller part.
  end

end