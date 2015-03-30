require File.expand_path('../../../test_helper', __FILE__)

class UserTest < ActiveSupport::TestCase

  def test_birth_date_for_adults
    Time.expects(:now).returns("Fri Jul 08 15:02:47 +0530 2011".to_time).at_least_once
    user = Community::User.new(:birth_date => "1979-05-01")
    assert_equal "05-01-1979", user.get_birth_date
  end

  def test_birth_date_for_kid
    Time.expects(:now).returns("Fri Jul 08 15:02:47 +0530 2011".to_time).at_least_once
    user = Community::User.new(:birth_date => "2005-05-01")
    assert_nil user.get_birth_date
  end

  def test_user_for_user_with_no_birth_date
    user = Community::User.new(:birth_date => nil)
    assert_nil user.get_birth_date
  end

  def test_getting_age_for_adult
    Time.expects(:now).returns("Fri Jul 08 15:02:47 +0530 2011".to_time).at_least_once
    user = Community::User.new(:birth_date => "1979-05-01")
    assert_equal 32, user.age
  end

  def test_getting_age_for_kid
    Time.expects(:now).returns("Fri Jul 08 15:02:47 +0530 2011".to_time).at_least_once
    user = Community::User.new(:birth_date => "2007-05-01")
    assert_equal 4, user.age
  end

  def test_getting_age_for_user_with_no_birth_date
    user = Community::User.new(:birth_date => nil)
    assert_nil user.age
  end

end