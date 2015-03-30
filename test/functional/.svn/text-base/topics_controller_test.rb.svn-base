require File.expand_path('../../test_helper', __FILE__)

class TopicsControllerTest < ActionController::TestCase

  def test_index
      login_as_custom_user(AdGroup.coach_manager, 'test21')
      get :index
      assert_equal "Topics", assigns(:page_title)
      assert_response :success
  end

  def test_show
      topics = FactoryGirl.create(:topic, :guid => "GUID_for test1", :title => "TITLE_for test1", :cefr_level => "B1", :description => "DESCRIPTION_for_test1", :language => 33, :selected => false)
      params = {:id => topics.id}
      get :show, params
      assert_response :redirect
  end

  def test_new
      login_as_custom_user(AdGroup.coach_manager,'test21')
      get :new
      assert_response :success
  end

  def test_edit
      topics = FactoryGirl.create(:topic, :guid => "GUID_for test1", :title => "TITLE_for test1", :cefr_level => "B1", :description => "DESCRIPTION_for_test1", :language => 33, :selected => false)
      login_as_custom_user(AdGroup.coach_manager,'test21')
      get :edit, {:id => topics.id}
      assert_response :success
  end

  def test_create
      topics = FactoryGirl.create(:topic, :guid => "GUID_for test1", :title => "TITLE_for test1", :cefr_level => "B1", :description => "DESCRIPTION_for_test1", :language => 33, :selected => false)
      login_as_custom_user(AdGroup.coach_manager,'test21')
      get :create, {:topic => topics}
      assert_equal "Topic was successfully created.", flash[:notice]
      assert_response :redirect
    #  topics_invalid = FactoryGirl.create(:topic, :guid => "GUID_for test1", :title => "TITLE_for test1", :cefr_level => "B1", :description => "DESCRIPTION_for_test1", :language => "AUK", :selected => "NO")
    #  post :create, {:topic => topics_invalid}
    #  assert_equal "Something went wrong. Topic is not created. Please try again.", flash[:notice]
    #  assert_response :redirect
  end

  def test_update
      topics = FactoryGirl.create(:topic, :guid => "GUID_for test1", :title => "TITLE_for test1", :cefr_level => "B1", :description => "DESCRIPTION_for_test1", :language => 33, :selected => false)
      login_as_custom_user(AdGroup.coach_manager,'test21')
      params = {:id => topics.id, :topic => topics}
      get :update, params
      assert_equal "Topic was successfully updated.", flash[:notice]
      assert_response :redirect
    #  params_incorrect = {:id => nil, :topic => nil}
    #  post :update, params_incorrect
    #  assert_equal "Something went wrong. Topic is not updated. Please try again.", flash[:notice]
    #  assert_response :redirect
  end

  def test_destroy
     topics = FactoryGirl.create(:topic, :guid => "GUID_for test1", :title => "TITLE_for test1", :cefr_level => "B1", :description => "DESCRIPTION_for_test1", :language => 33, :selected => false)
     login_as_custom_user(AdGroup.coach_manager,'test21')
     topics.save
     delete :destroy, {:id => topics.id}
     assert_response :redirect
     assert_equal "Topic has been hidden.", flash[:notice]
  #   delete :destroy, {:id => nil}
  #   assert_response :redirect
  #   assert_equal "Something went wrong. Topic is not hidden. Please try again.", flash[:notice]
  end

  def test_update_topics
  	login_as_custom_user(AdGroup.coach_manager, 'test21')
  	biblio_topics = [{"id"=>"test id 1","learningLang"=>"en-US", "product"=>"Product:Aria", "description"=>"test Description 1", "title"=>"test Title 1", "awsPath"=>"assets/9ab275ad-6c68-4b3a-bb9e-d71d28edbfb4", "cefrLevel"=>"C1","revision"=>"revision test 2"},{"id"=>"test ID 2","cefrLevel"=>"B1","title"=>"test title 2","learningLang"=>"en-GB","description"=>"This is a test.","revision"=>"revision test 1"}]
  	Callisto::Base.stubs(:get_all_topics).returns(biblio_topics)
  	get :update_topics
    assert_not_nil flash[:notice]
  end

  def test_update_topics_for_nil_topics
  	login_as_custom_user(AdGroup.coach_manager, 'test21')
  	biblio_topics = nil
  	Callisto::Base.stubs(:get_all_topics).returns(biblio_topics)
  	get :update_topics
    assert_equal "Sorry, we were unable to update the Topics list. Please try again later." , flash[:error]
  end

  def test_fetch_topics
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    params = {:cefr_level => 'B1', :language => 'AUK'}
    get :fetch_topics, params
    assert_template "topics/_topics_list"
  end

  def test_fetch_topics_for_erroneus_params
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    params = {:cefr_level => 'All', :language => ''}
    get :fetch_topics, params
    assert_template "topics/_topics_list"
  end

  def test_save_topics
    topics_list = [];
    active_topics = [];
    Topic.delete_all
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    active_topics << FactoryGirl.create(:topic, :guid => "GUID_for test1", :title => "TITLE_for test1", :cefr_level => "B1", :description => "DESCRIPTION_for_test1", :language => 33, :selected => false)
    topics_list << FactoryGirl.create(:topic, :guid => "GUID_for test2", :title => "TITLE_for test2", :cefr_level => "B2", :description => "DESCRIPTION_for_test2", :language => 33, :selected => false)
    topics_list << active_topics
    params = {:active_topics => active_topics, :topics_list => topics_list}
    get :save_topics, params
    assert_equal 1, Topic.where("selected = 1").count
  end

  def test_save_topics_for_nil_params
    topics_list = [];
    Topic.delete_all
    login_as_custom_user(AdGroup.coach_manager, 'test21')
    params = {:topics_list => topics_list}
    get :save_topics, params
    assert_equal 0, Topic.where("selected = 1").count
  end
end