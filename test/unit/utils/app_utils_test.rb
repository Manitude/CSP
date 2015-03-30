require File.expand_path('../../../test_helper', __FILE__)

class AppUtilsTest < Test::Unit::TestCase
  def test_array_to_single_quotes
    assert_equal  AppUtils.array_to_single_quotes(["one","two","three"]), "'one','two','three'"
    assert_equal  AppUtils.array_to_single_quotes([1,2,3]), "'1','2','3'"
    assert_equal  AppUtils.array_to_single_quotes([]),"''"
  end
end
