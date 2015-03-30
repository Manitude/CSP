require File.expand_path('../../test_helper', __FILE__)
require File.expand_path('../../test_data', __FILE__)
require 'background_controller'

class BackgroundControllerTest < ActionController::TestCase
  def test_background_tasks
    login_as_custom_user(AdGroup.coach_manager, 'hello')
    BackgroundTask.delete_all
    BackgroundTask.create(:referer_id => 1, :state => 'completed', :error => nil, :background_type => 'Coach Activation', :triggered_by => 'test21', :locked => 0, :message => 'Done' )
    post :background_tasks, :bt_triggered_by=>"All", :filter=>"FILTER", :bt_state=>"All", :bt_type=>"All"
    bt_pag = BackgroundTask.paginate(:per_page => 30, :page => nil, :conditions => "", :order => 'updated_at asc')
    assert_equal assigns(:background_tasks),bt_pag
    post :background_tasks, :bt_state=>"Started"
    assert_equal [], assigns(:background_tasks)
    post :background_tasks, :bt_type=>"Coach Activation"
    assert_equal bt_pag.first, assigns(:background_tasks).first
    post :background_tasks, :bt_triggered_by => "cm"
    assert_equal [], assigns(:background_tasks)
  end
end
