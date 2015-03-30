require File.expand_path('../../test_helper', __FILE__)

class AdGroupTest < ActiveSupport::TestCase

	test "should return account_type for adGroup" do 
		assert_equal 'Coach', AdGroup.account_type(AdGroup.coach)
	end

	test "should return nil for adGroup hello" do 
		assert_nil AdGroup.account_type('hello')
	end
end
