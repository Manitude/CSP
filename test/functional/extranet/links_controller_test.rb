$:.unshift File.join(File.dirname(__FILE__),'..','lib')
require File.expand_path('../../../test_helper', __FILE__)
require 'extranet/links_controller'

class Extranet::LinksControllerTest < ActionController::TestCase
  
  def setup
    login_as_coach_manager
  end
    def test_index_page
    link1 = FactoryGirl.create(:link, :name => "Link-A",:url => "https://timesaver.adp.com/i20/fb6s/TS/login.php")
    link2 = FactoryGirl.create(:link, :name => "Link-B",:url =>"https://webmail.trstone.com")
    login_as_custom_user(AdGroup.coach_manager,'rramesh')
    get :index
    assert_response :success
    assert_link_row_in_index(link1)
    assert_link_row_in_index(link2)
  end
  def test_new
    link1 = FactoryGirl.create(:link, :name => "Link-A",:url => "https://timesaver.adp.com/i20/fb6s/TS/login.php")
    login_as_custom_user(AdGroup.coach_manager,'rramesh')
    get :new ,{:id => link1.id}
    assert_new_link_elements
    assert_response :success
  end

  def test_edit
    link1 = FactoryGirl.create(:link, :name => "Link-A",:url => "https://timesaver.adp.com/i20/fb6s/TS/login.php")
    login_as_custom_user(AdGroup.coach_manager,'rramesh')
    get :edit,{:id => link1.id} 
    assert_edit_link_elements(link1)
    assert_response :success
  end

  def test_destroy
    link1 = FactoryGirl.create(:link, :name => "Link-A",:url => "https://timesaver.adp.com/i20/fb6s/TS/login.php")
     link1.save
     delete :destroy, {:id => link1.id}
     assert_response :redirect
     assert_equal "Link was successfully deleted.", flash[:notice]
  end

  def test_create
      params = {:link => {:name => "Link-A",:url => "http://www.tutorialspoint.com/ruby/ruby_operators.htm" }}      
      post :create, params
      assert_response :redirect
      assert_equal "Link was successfully created.", flash[:notice]
      params_incorrect = {:link => {:url => "http://www.tutorialspoint.com/ruby/ruby_operators.htm" }}
      post :create, params_incorrect
      assert_response :success
    end

    def test_update
      link1 = FactoryGirl.create(:link, :name => "Link-A",:url => "https://timesaver.adp.com/i20/fb6s/TS/login.php")
      link1.save
      params = {:link1 => {:name => "Link-A Modified",:url => "http://www.tutorialspoint.com/ruby/ruby_operators.htm" }, :id => link1.id}
      put :update, params
      assert_response :redirect
      assert_equal "Link was successfully updated.", flash[:notice]
      params_incorrect = {:link => {:url => "http://www.tutorialspoint.com/ruby/ruby_operators.htm" }}
      post :create, params_incorrect
      assert_response :success
    end

  def test_show
    link1 = FactoryGirl.create(:link, :name => "Link-A",:url => "https://timesaver.adp.com/i20/fb6s/TS/login.php")
    params = {:id => link1.id}
    get :show, params
    assert_response :success
    assert_show_link_elements(link1)
    assert_equal 'Show link', assigns(:page_title)
  end

private
  def assert_link_row_in_index(link)
     #assert_select "td", link.link_end_date
    # assert_select "td", link2.link_end_date 
    assert_select "td[class='links']" do
      assert_select "a[href='/links/#{link.id}']"
      assert_select "img[alt='Show'][title='Show']"
    end
    assert_select "td[class='links']" do
      assert_select "a[href='/links/#{link.id}/edit']"
      assert_select "img[alt='Edit'][title='Edit']"
    end
    assert_select "td[class='links']" do
      assert_select "a[href='/links/#{link.id}']"
      assert_select "img[alt='Delete'][title='Delete']"
    end
  end
  def assert_show_link_elements(link1)
    assert_select "h2", "Show link"
    assert_select "p" do
      assert_select "b", "Name:"
    end
    assert_select "a[href='/links/#{link1.id}/edit']", "Edit"
    assert_select "a[href='/links']", "Back"
  end
  def assert_new_link_elements
    assert_select "h2", "New link"
    assert_select "input[id='link_name']"
    assert_select "input[id='link_url']"
    assert_select "input[id='link_submit']"
  end
  def assert_edit_link_elements(link1)
    assert_select "h2", "Editing link"
    assert_select "input[id='link_name'][value='Link-A']"
    assert_select "input[id='link_submit'][value='Save']"
  end
end