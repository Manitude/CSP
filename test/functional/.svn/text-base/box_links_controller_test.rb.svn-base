require File.dirname(__FILE__) + '/../test_helper'

class BoxLinksControllerTest < ActionController::TestCase

  setup do
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    @box_link = build_a_box_link
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:box_links)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create box_link" do
    assert_difference('BoxLink.count') do
      post :create, :box_link => {:title => @box_link.title, :url => @box_link.url}
    end

    assert_redirected_to box_links_path
  end


  test "should get edit" do
    @box_link.save
    get :edit, :id => @box_link.to_param
    assert_response :success
  end

  test "should update box_link" do
    @box_link.save
    put :update, :id => @box_link.to_param, :box_link => @box_link.attributes
    assert_redirected_to box_links_path
  end

  test "should destroy box_link" do
    @box_link.save
    assert_difference('BoxLink.count', -1) do
      delete :destroy, :id => @box_link.to_param
    end
    assert_response :success
  end

  test "CM should get create new button in index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:box_links)
    assert_select "input[id='create_new_box_widget']", :count => 1
  end

  test "coach should get create new button in index" do
    login_as_custom_user(AdGroup.coach, 'test22')
    get :index
    assert_response :success
    assert_not_nil assigns(:box_links)
    assert_select "input[id='create_new_box_widget']", :count => 0
  end

  private
  def build_a_box_link(title = "Folder_#{Time.now}", url = "https://app.box.com/embed_widget/eafbff29c305/s/oi3tq6j#{Time.now}f0mcl8j8ai?view=list&sort=name&direction=ASC&theme=blue")
    FactoryGirl.build(:box_link, :title => title, :url => url)
  end

end
