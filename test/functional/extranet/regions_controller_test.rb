require File.dirname(__FILE__) + '/../../test_helper'
require 'extranet/regions_controller'



class Extranet::RegionsControllerTest < ActionController::TestCase

  def test_index_page
    region1 = FactoryGirl.create(:region, :name => "Region-A")
    region2 = FactoryGirl.create(:region, :name => "Region-B")
    login_as_custom_user(AdGroup.coach_manager,'rramesh')
    get :index
    assert_response :success
    assert_region_row_in_index(region1)
    assert_region_row_in_index(region2)
  end

  def test_show
    region1 = FactoryGirl.create(:region, :name => "Region-A")
    login_as_custom_user(AdGroup.coach_manager,'rramesh')
    get :show, {:id => region1.id}
    assert_show_page_elements(region1)
    assert_response :success
  end

  def test_new
    login_as_custom_user(AdGroup.coach_manager,'rramesh')
    get :new
    assert_new_page_elements
    assert_response :success
  end

  def test_edit
    region1 = FactoryGirl.create(:region, :name => "Region-A")
    login_as_custom_user(AdGroup.coach_manager,'rramesh')
    get :edit, {:id => region1.id}
    assert_edit_page_elements(region1)
    assert_response :success
  end

  private
  def assert_region_row_in_index(region)
    assert_select "td", region.name
    assert_select "td[class='links']" do
      assert_select "a[href='/regions/#{region.id}']"
      assert_select "img[alt='Show'][title='Show']"
    end
    assert_select "td[class='links']" do
      assert_select "a[href='/regions/#{region.id}/edit']"
      assert_select "img[alt='Edit'][title='Edit']"
    end
    assert_select "td[class='links']" do
      assert_select "a[href='/regions/#{region.id}']"
      assert_select "img[alt='Delete'][title='Delete']"
    end
  end
  def assert_show_page_elements(region)
    assert_select "h2", "Show region"
    assert_select "p" do
      assert_select "b", "Name:"
    end
    assert_select "a[href='/regions/#{region.id}/edit']", "Edit"
    assert_select "a[href='/regions']", "Back"
  end
  def assert_new_page_elements
    assert_select "h2", "New region"
    assert_select "input[id='region_name']"
    assert_select "input[id='region_submit']"
  end
  def assert_edit_page_elements(region)
    assert_select "h2", "Editing region"
    assert_select "input[id='region_name'][value='Region-A']"
    assert_select "input[id='region_submit'][value='Save']"
  end
end