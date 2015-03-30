$:.unshift File.join(File.dirname(__FILE__),'..','lib')
require File.expand_path('../../../test_helper', __FILE__)
require 'extranet/events_controller'

class Extranet::EventsControllerTest < ActionController::TestCase
  
  def setup
    login_as_coach_manager
  end
  
  def test_show_events_by_date_single
    event = FactoryGirl.create(:event)
    get :show_events_by_date, {:event_date => event.event_start_date.to_date.to_s}
    assert_equal 1, assigns(:events).size
    assert_not_nil assigns(:event)
  end

  def test_show_events_by_date_multiple
    event_date = Time.now.utc + 1.day
    FactoryGirl.create(:event, :event_start_date => event_date, :event_end_date => event_date + 1.day)
    FactoryGirl.create(:event, :event_start_date => event_date, :event_end_date => event_date + 2.days)
    get :show_events_by_date, {:event_date => event_date.to_date.to_s}
    assert_equal 2, assigns(:events).size
    assert_nil assigns(:event)
  end
  def test_index_page
    event_date = Time.now.utc + 1.day
    event1 = FactoryGirl.create(:event, :event_start_date => event_date, :event_end_date => event_date + 1.day)
    event2 = FactoryGirl.create(:event, :event_start_date => event_date, :event_end_date => event_date + 2.days)
    get :index
    assert_response :success
    assert_event_row_in_index(event1)
    assert_event_row_in_index(event2)
    assert_equal 2, assigns(:events).size
    assert_nil assigns(:event)
   end 
   def test_show_events_by_date
    event_date = Time.now.utc + 1.day
    event1 = FactoryGirl.create(:event, :event_start_date => event_date, :event_end_date => event_date + 1.day)
    login_as_custom_user(AdGroup.coach_manager,'rramesh')
    get :show, {:id => event1.id}
    assert_show_page_elements(event1)
    assert_response :success
  end

  def test_new
    event_date = Time.now.utc + 1.day
    event1 = FactoryGirl.create(:event, :event_start_date => event_date, :event_end_date => event_date + 1.day)
    login_as_custom_user(AdGroup.coach_manager,'rramesh')
    get :new
    assert_new_page_elements
    assert_response :success
  end

  def test_edit
    event_date = Time.now.utc + 1.day
    event1 = FactoryGirl.create(:event, :event_start_date => event_date, :event_end_date => event_date + 1.day)
    login_as_custom_user(AdGroup.coach_manager,'rramesh')
    get :edit, {:id => event1.id}
    assert_edit_page_elements(event1)
    assert_response :success
  end
   
   def test_destroy
     event_date = Time.now.utc + 1.day
     event1 = FactoryGirl.create(:event, :event_start_date => event_date, :event_end_date => event_date + 1.day)
     event1.save
     delete :destroy, {:id => event1.id}
     assert_response :redirect
     assert_equal "Event was successfully deleted.", flash[:notice]
  end

  def test_create
      event_date = Time.now.utc + 1.day
      params = {:event => {:event_name => "Coach Portal Sucess", :event_description=> "Coach Portal Sucess",:event_start_date => event_date , :event_end_date => event_date + 1.day,:language_id => 5, :region_id =>4}}      
      post :create, params
      assert_response :redirect
      assert_equal "Event was successfully created.", flash[:notice]
      params_incorrect = {:event => {:event_name => "Coach Portal Sucess" }}
      post :create, params_incorrect
      assert_response :success
    end

    def test_update
      event_date = Time.now.utc + 1.day
      event1 = FactoryGirl.create(:event, :event_start_date => event_date, :event_end_date => event_date + 1.day)
      event1.save
      params = {:event1 => {:event_start_date => event_date + 1.day, :event_end_date => event_date + 3.day }, :id => event1.id}
      put :update, params
      assert_response :redirect
      assert_equal "Event was successfully updated.", flash[:notice]
      params_incorrect = {:event => {:event_name => "Coach Portal Sucess"}}
      post :create, params_incorrect
      assert_response :success
    end

    def test_calendar_without_events
      prev_month_date = (Time.now - 1.month + 1.day).strftime("%Y-%m-%d")
      next_month_date = (Time.now + 1.month + 1.day).strftime("%Y-%m-%d")
      xhr :get, :calendar
      assert @response.body.index('<a href=\"/events/calendar?date=' + prev_month_date + '\" data-remote=\"true\">')
      assert @response.body.index('<a href=\"/events/calendar?date=' + next_month_date + '\" data-remote=\"true\">')
      assert @response.body.index('<h6>No events for this month.</h6>')
    end

    def test_calendar_with_events
      event_date = Time.now + 1.day
      event1 = FactoryGirl.create(:event, :event_start_date => event_date, :event_end_date => event_date + 1.day)
      prev_month_date = (Time.now - 1.month + 1.day).strftime("%Y-%m-%d")
      next_month_date = (Time.now + 1.month + 1.day).strftime("%Y-%m-%d")
      new_date = (event_date - TimeUtils.offset(event_date)).strftime("%B %d, %Y")
      xhr :get, :calendar
      assert @response.body.index('<a href=\"/events/calendar?date=' + prev_month_date + '\" data-remote=\"true\">')
      assert @response.body.index('<a href=\"/events/calendar?date=' + next_month_date + '\" data-remote=\"true\">')
      assert @response.body.index('<p class=\"ent_list\">'+"#{new_date}"+'<br />\n          Test event</p>')
    end

private
  def assert_event_row_in_index(event)
     #assert_select "td", event.event_end_date
    # assert_select "td", event2.event_end_date 
    assert_select "td[class='links']" do
      assert_select "a[href='/events/#{event.id}']"
      assert_select "img[alt='Show'][title='Show']"
    end
    assert_select "td[class='links']" do
      assert_select "a[href='/events/#{event.id}/edit']"
      assert_select "img[alt='Edit'][title='Edit']"
    end
    assert_select "td[class='links']" do
      assert_select "a[href='/events/#{event.id}']"
      assert_select "img[alt='Delete'][title='Delete']"
    end
  end
  def assert_show_page_elements(event1)
    assert_select "h2", "Show Calendar Event"
    assert_select "p" do
      assert_select "b", "Event Name:"
    end
    assert_select "a[href='/events/#{event1.id}/edit']", "Edit"
    assert_select "a[href='/events']", "Back"
  end
  def assert_new_page_elements
    assert_select "h2", "New Calendar Event"
    assert_select "input[id='event_event_name']"
    assert_select "input[id='event_submit']"
  end
  def assert_edit_page_elements(event1)
    assert_select "h2", "Editing Calendar Event"
    assert_select "input[id='event_event_name'][value='Test event']"
    assert_select "input[id='event_submit'][value='Save']"
  end
end
