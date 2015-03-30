require File.expand_path('test_helper', File.dirname(__FILE__))

# TODO - test against an AD style ldap server
class SpecialUser < RosettaStone::LDAPUserAuthentication::User
end

class LdapUserAuthenticationTest < Test::Unit::TestCase

  def setup
    port = YAML.load_file(RosettaStone::LDAPUserAuthentication::User.configuration_file_path).recursively_symbolize_keys[:test][:port]
    RosettaStone::MockLDAP.start(:port => port)
  end

  def teardown
    RosettaStone::MockLDAP.stop
  end

  # I can't test encryption and such unless I write a more advanced mock ldap server. This tests
  # the basics right now.
  def test_basic_ldap_authentication
    assert !RosettaStone::LDAPUserAuthentication::User.authenticate(:user_name => 'ggironda', :password => 'adsgasgasag')
    assert RosettaStone::LDAPUserAuthentication::User.authenticate(:user_name => 'ggironda', :password => 'ldappass')
  end

  def test_ldap_configuration_override
    RosettaStone::LDAPUserAuthentication::User.configuration = {:host => 'hocus.pocus'}

    # We shouldnt be able to connect to the non existent host hocus.pocus. This also asserts that
    # we have actually overridden the details with the bad ones.
    assert_raises(RosettaStone::LDAPUserAuthentication::ConnectionError) do
      RosettaStone::LDAPUserAuthentication::User.authenticate(:user_name => 'ggironda', :password => 'blah')
    end

    # Classes that extend User should still have a valid connection
    assert SpecialUser.authenticate(:user_name => 'ggironda', :password => 'ldappass')
  end

end
