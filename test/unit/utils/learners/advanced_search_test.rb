require File.expand_path('../../../../test_helper', __FILE__)

class AdvancedSearchTest < ActiveSupport::TestCase

	test "should search by activation id" do
    learner1 = FactoryGirl.create(:learner, :guid => '455f480b-8c07-47eb-9c3b-bb89d753faa6', :first_name => 'rajkumar')
    RosettaStone::ActiveLicensing::ProductRight.any_instance.stubs(:find_by_activation_id).returns([{"license"=>{"identifier"=>"beta910@rs.com", "guid"=>"455f480b-8c07-47eb-9c3b-bb89d753faa6"}}])
    result = AdvancedSearch.new('activation_id','1234-5678').search
		assert_equal 1, result.size
    assert_equal 'rajkumar', result[:result][0].first_name
    assert_equal '455f480b-8c07-47eb-9c3b-bb89d753faa6', result[:result][0].guid
  end

  test "should search by product guid" do
    learner1 = FactoryGirl.create(:learner, :first_name => 'mohit')
    learner1.learner_product_rights[0].update_attribute(:product_guid, '1234-56789')

    result = AdvancedSearch.new('product_guid','1234-56789').search
		assert_equal 1, result.size
    assert_equal 'mohit', result[:result][0].first_name
  end

  test "should search by license guid" do
    learner1 = FactoryGirl.create(:learner, :first_name => 'mohit', :guid => '1234-56789')

    result = AdvancedSearch.new('license_guid','1234-56789').search
		assert_equal 1, result.size
    assert_equal 'mohit', result[:result][0].first_name
  end

  test "should return no result on empty id" do
    RosettaStone::ActiveLicensing::ProductRight.any_instance.stubs(:find_by_activation_id).returns([])
    result = AdvancedSearch.new('activation_id','').search
		assert_equal 0, result[:result].size
  end

  test "should return no result on empty id type" do
    result = AdvancedSearch.new('','1234-56789').search
		assert_equal 0, result[:result].size
  end

end