require File.expand_path('../../../test_helper', __FILE__)
require File.expand_path('../../../../app/utils/reflex_session_details.rb', __FILE__)

class ReflexSessionDetailsTest < ActiveSupport::TestCase

  test "should convert seconds to minutes" do
    assert_equal 5, ReflexSessionDetails.new(nil).seconds_to_minutes(5 * 1000 * 60)
  end

end