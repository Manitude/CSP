require File.expand_path('../../test_helper', __FILE__)

class UserTest < ActiveSupport::TestCase

  test "check find or create account flow" do
    auth_sequence=sequence(:user_find_or_create_account)
    user=User.new('test_user')
    acc=Account.new
    acc.user_name='test_user'
    acc.type = "Coach"
    Account.stubs(:find_or_initialize_by_user_name).with('test_user').returns(acc).in_sequence(auth_sequence)
    User.any_instance.stubs(:groups).returns(["@RS NonProduction Coach Access"])
    assert_send([user,:find_or_create_account,{'name'=>'test_user','givenname'=>'test_user','mailnickname'=>'test_user'}])
  end

  def test_ldap_user_object_with_valid_user_name_should_return_user_name_for_to_s_method
    user = User.new('test21')
    user.groups = AdGroup.all_names
    assert_equal "User: #{user.user_name}, Groups: [#{user.groups.join(', ') if user.groups}], Time Zone: #{user.time_zone ? user.time_zone : 'Eastern Time (US & Canada)'}", user.to_s
  end

  def test_ldap_user_object_with_nil_user_name_should_return_nil_for_to_s_method
    user = User.new(nil)
    assert_equal "User: #{user.user_name}, Groups: [#{user.groups.join(', ') if user.groups}], Time Zone: #{user.time_zone ? user.time_zone : 'Eastern Time (US & Canada)'}", user.to_s
  end

  def test_time_zone_for_to_s_method
    user = User.new('test1')
    user.time_zone = Time.now.zone
    assert_equal "User: #{user.user_name}, Groups: [#{user.groups.join(', ') if user.groups}], Time Zone: #{user.time_zone ? user.time_zone : 'nil'}", user.to_s
  end
  
  def test_nil_and_valid_objects_for_to_s_method
    user = nil
    assert_equal "", user.to_s
    user = "string"
    assert_equal "string", user.to_s
  end

  def test_spoof_authentication_with_blank_and_wrong_password
    User.stubs(:bypass_authentication?).returns(false)
    User.stubs(:spoof_authentication?).returns(true)
    User.stubs(:spoof_password).returns('D3f@ult')
    user = User.authenticate('psubramanian', '')
    assert_equal nil, user
    user = User.authenticate('psubramanian', 'test')
    assert_equal nil, user
  end

end
