require File.expand_path('../../../../test_helper', __FILE__)

class LearnerSearchFactoryTest < ActiveSupport::TestCase

  test "should search by primary search params" do
		param = {:fname => 'mohit'}
		search_object = LearnerSearchFactory.create(param)
		assert_equal 'PrimarySearch', search_object.class.to_s
	end

  test "should search by advanced search params" do
		param = {:search_id => '1234-5678'}
		search_object = LearnerSearchFactory.create(param)
		assert_equal 'AdvancedSearch', search_object.class.to_s
	end

  test "should return nil with no params" do
    param = {}
    search_object = LearnerSearchFactory.create(param)
		assert_equal 'NilClass', search_object.class.to_s
  end
  
end