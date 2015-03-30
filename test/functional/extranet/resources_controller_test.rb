require File.dirname(__FILE__) + '/../../test_helper'
require 'extranet/resources_controller'

class Extranet::ResourcesControllerTest < ActionController::TestCase

	def setup
	    login_as_custom_user(AdGroup.coach_manager,'test32')
  	end

	def test_index
		resource1 = FactoryGirl.create(:resource, :title => 'Resource-1', :description => 'Test description', 
			:filename => "2.doc", :size => 43520, :content_type => 'application/msword', :db_file_id => 25)
		get :index
		assert_response :success
		resources = assigns(:resources)
		assert_equal resources[0][:title], resource1.title
		assert_equal resources[0][:description], resource1.description
		assert_equal resources[0][:filename], resource1.filename
		assert_resource_row_in_index(resource1)
		assert_equal 'Listing resources', assigns(:page_title)		
	end

	def test_show
		resource1 = FactoryGirl.create(:resource, :title => 'Resource-1', :description => 'Test description', 
			:filename => "2.doc", :size => 43520, :content_type => 'application/msword', :db_file_id => 25)
		get :show, {:id => resource1.id}
		assert_response :success
		assert_equal 'Resource Details', assigns(:page_title)
	end

	def test_new
		get :new
	    assert_response :success
	    assert_new_page_elements
	    assert_equal 'New resource', assigns(:page_title)
	end

	def test_edit
		resource1 = FactoryGirl.create(:resource, :title => 'Resource-1', :description => 'Test description', 
			:filename => "2.doc", :size => 43520, :content_type => 'application/msword', :db_file_id => 25)
		get :edit, {:id => resource1.id}
		assert_response :success
	    assert_edit_page_elements(resource1)
	    assert_equal 'Editing resource', assigns(:page_title)
	end

	def test_create
		params = {:resource => {:title => 'Resource-1', :description => 'Test description', 
			:filename => "2.doc", :size => 43520, :content_type => 'application/msword', :db_file_id => 25}}
		post :create, params
  		assert_response :redirect
  		assert_equal "Resource was successfully created.", flash[:notice]
  		params_incomplete = {:resource => {:title => 'Resource-1', :description => 'Test description'}}
  		post :create, params_incomplete
  		assert_response :success
	end

	def test_update
  		resource1 = FactoryGirl.create(:resource, :title => 'Resource-1', :description => 'Test description', 
			:filename => "2.doc", :size => 43520, :content_type => 'application/msword', :db_file_id => 25)
  		resource1.save
  		params = {:resource => {:title => 'Resource-1', :description => 'Test description modified', 
			:filename => "2.doc", :size => 43520, :content_type => 'application/msword', :db_file_id => 25}, :id => resource1.id }
	    put :update, params
	    assert_response :redirect
  		assert_equal "Resource was successfully updated.", flash[:notice]
  		params_incomplete = {:resource => {:title => '', :description => 'Test description'}, :id => resource1.id }
  		put :update, params_incomplete
	    assert_response :success
  	end

  	def test_destroy
  		resource1 = FactoryGirl.create(:resource, :title => 'Resource-1', :description => 'Test description', 
			:filename => "2.doc", :size => 43520, :content_type => 'application/msword', :db_file_id => 25)
  		resource1.save
	    delete :destroy, {:id => resource1.id}
	    assert_response :redirect
  		assert_equal "Resource was successfully deleted.", flash[:notice]
  	end
	
	def test_allow_access
		login_as_custom_user(AdGroup.coach,'testcoach')
		get :new
	    assert_response :redirect
  		assert_equal "Sorry, you are not authorized to access the requested page.", flash[:error]
	end

	def test_download_file
		resource1 = FactoryGirl.create(:resource, :title => 'Resource-1', :description => 'Test description', 
			:filename => "2.doc", :size => 43520, :content_type => 'application/msword', :db_file_id => 25)
		post :download_file, {:path => "/images/ajax-loader.gif"}
		File.stubs(:expand_path).returns(nil)
		assert_response :success
	end

	def assert_resource_row_in_index(resource)
	    assert_select "td", resource.title
	    assert_select "td[class='links']" do
	      assert_select "a[href='/resources/#{resource.id}']"
	      assert_select "img[alt='Show'][title='Show']"
	    end
	    assert_select "td[class='links']" do
	      assert_select "a[href='/resources/#{resource.id}/edit']"
	      assert_select "img[alt='Edit'][title='Edit']"
	    end
	    assert_select "td[class='links']" do
	      assert_select "a[href='/resources/#{resource.id}']"
	      assert_select "img[alt='Delete'][title='Delete']"
	    end
	    assert_select "a[href='/resources/new']", "Add a new resource"
  	end

	def assert_new_page_elements
	    assert_select "p[class='subnote']"
	    assert_select "input[id='resource_title']"
	    assert_select "textarea[id='resource_description']"
	    assert_select "input[id='resource_uploaded_data']"
	    assert_select "input[id='resource_submit']"
	    assert_select "a[href='/resources']", "Back"
  	end

  	def assert_edit_page_elements(resource)
	    assert_select "input[id='resource_title'][value='Resource-1']"
	    assert_select "textarea[id='resource_description']", "Test description"
	    assert_select "a[href='/resources/#{resource.id}']", "Show"
	    assert_select "a[href='/resources']", "Resources List"
  	end
end