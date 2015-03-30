require File.expand_path('../../test_helper', __FILE__)
require 'scheduling_thresholds_controller'

class SchedulingThresholdsControllerTest < ActionController::TestCase
	def test_admin_allowed_to_view_page
		login_as_custom_user(AdGroup.admin, 'test21')
		get :index
		assert_response 200
	end
	
	def test_manager_allowed_to_view_page
		login_as_custom_user(AdGroup.coach_manager, 'test21')
		get :index
		assert_response 200
	end
	
	def test_coach_not_allowed_to_view_page
		login_as_custom_user(AdGroup.coach, 'test21')
		get :index
		assert_response 302
	end
	def test_showing_all_languages_for_admin
		login_as_custom_user(AdGroup.admin, 'test21')
		get :index
		count = Language.all.count
		assert_select 'select[id="language_dropdown_threshold"]', :count => 1 do
			assert_select 'option', :count => count + 1
		end
	end
end