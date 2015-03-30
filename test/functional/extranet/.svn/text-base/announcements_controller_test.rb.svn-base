require File.dirname(__FILE__) + '/../../test_helper'
require 'extranet/announcements_controller'

class Extranet::AnnouncementsControllerTest < ActionController::TestCase

	def setup
	    login_as_custom_user(AdGroup.coach_manager,'test32')
  	end

	def test_index
		am1 = FactoryGirl.create(:announcement, :subject => 'Sprint 20 Launch', 
	    	:body => 'Sprint 20 launch is scheduled on June 13, 2013, 10.30 AM EDT')
		am2 = FactoryGirl.create(:announcement, :subject => 'Code coverage', 
			:body => 'Many new features were implemented in Sprint 20.')
		params = {:search => 'Sprint'}
		get :index, params
		announcements = assigns(:announcements)
		assert_response :success
		assert_equal announcements[0][:body], am1.body
		assert_equal announcements[0][:subject], am1.subject
		assert_equal announcements[1][:body], am2.body
		assert_equal announcements[1][:subject], am2.subject
		assert_announcement_row_in_index(am1)
		assert_announcement_row_in_index(am2)
		assert_equal 'Announcements', assigns(:page_title)
	end

	def test_show
		am1 = FactoryGirl.create(:announcement, :subject => 'Sprint 20 Launch', 
	    	:body => 'Sprint 20 launch is scheduled on June 13, 2013, 10.30 AM EDT')
		params = {:id => am1.id}
		get :show, params
		assert_response :success
		assert_show_page_elements(am1)
		assert_equal 'Show Announcement', assigns(:page_title)
	end

	def test_new
		get :new
	    assert_response :success
	    assert_new_page_elements
	    assert_equal 'New announcement', assigns(:page_title)
	end

	def test_edit
	    am1 = FactoryGirl.create(:announcement, :subject => 'Sprint 20 Launch', 
	    	:body => 'Sprint 20 launch is scheduled on June 13, 2013, 10.30 AM EDT')
	    get :edit, {:id => am1.id}
	    assert_response :success
	    assert_edit_page_elements(am1)
	    assert_equal 'Editing announcement', assigns(:page_title)
  	end

  	def test_create
    	params = {:announcement => {:body => 'testing', :subject => 'test', :expires_on => Time.now.utc + 2.days, 
    	:language_id => -1, :region_id => -1, :language_name => 'English' }}
  		post :create, params
  		assert_response :redirect
  		assert_equal "Announcement was successfully created.", flash[:notice]
  		params_incorrect = {:announcement => {:body => 'testing', :expires_on => Time.now.utc + 2.days, 
    	:language_id => -1, :region_id => -1, :language_name => 'English' }}
    	post :create, params_incorrect
  		assert_response :success
  	end

  	def test_update
  		am1 = FactoryGirl.create(:announcement, :subject => 'test', :body => 'testing')
  		am1.save
  		params = {:announcement => {:body => 'testing-modified', :subject => 'test', :expires_on => Time.now.utc + 2.days, 
    	:language_id => -1, :region_id => -1, :language_name => 'English' }, :id => am1.id}
	    put :update, params
	    assert_response :redirect
  		assert_equal "Announcement was successfully updated.", flash[:notice]
  		params_incorrect = {:announcement => {:subject => 'test', :body => '', :expires_on => Time.now.utc + 2.days }, :id => am1.id}
    	put :update, params_incorrect
  		assert_response :success
  	end

  	def test_destroy
  		am1 = FactoryGirl.create(:announcement, :subject => 'test', :body => 'testing')
  		am1.save
	    delete :destroy, {:id => am1.id}
	    assert_response :redirect
  		assert_equal "Announcement was successfully deleted.", flash[:notice]
  	end

	private
  	
  	def assert_announcement_row_in_index(announcement)
	    assert_select "td", announcement.subject
	    assert_select "td[class='links']" do
	      assert_select "a[href='/announcements/#{announcement.id}']"
	      assert_select "img[alt='Show'][title='Show']"
	    end
	    assert_select "td[class='links']" do
	      assert_select "a[href='/announcements/#{announcement.id}/edit']"
	      assert_select "img[alt='Edit'][title='Edit']"
	    end
	    assert_select "td[class='links']" do
	      assert_select "a[href='/announcements/#{announcement.id}']"
	      assert_select "img[alt='Delete'][title='Delete']"
	    end
  	end

  	def assert_show_page_elements(announcement)
	    assert_select "p" do
	    	assert_select "b", "Subject:"
	     	assert_select "b", "Body:"
			assert_select "b", "Language:"
			assert_select "b", "Region:"	    	
	    end
	    assert_select "p", "Subject:\n  #{announcement.subject}"
	    assert_select "p", "Body:\n  #{announcement.body}"
	    assert_select "p", "Language:\n  All"
	    assert_select "p", "Region:\n  All"
	    assert_select "a[href='/announcements/#{announcement.id}/edit']", "Edit"
	    assert_select "a[href='/announcements']", "Back"
  	end

  	def assert_new_page_elements
	    assert_select "h2", "New announcement"
	    assert_select "input[id='announcement_subject']"
	    assert_select "textarea[id='announcement_body']"
	    assert_select "input[id='announcement_expires_on']"
	    assert_select "select[id='announcement_language_id']"
	    assert_select "input[id='announcement_submit']"
  	end

  	def assert_edit_page_elements(announcement)
	    assert_select "h2", "Editing announcement"
	    assert_select "input[id='announcement_subject'][value='Sprint 20 Launch']"
	    assert_select "textarea[id='announcement_body']", "Sprint 20 launch is scheduled on June 13, 2013, 10.30 AM EDT"
  	end
end