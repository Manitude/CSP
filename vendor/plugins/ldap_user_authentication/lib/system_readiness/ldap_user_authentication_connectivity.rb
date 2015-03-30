class SystemReadiness::LdapUserAuthenticationConnectivity < SystemReadiness::Base
  class << self
    def verify
      return true, "Untested in test environment" if Rails.test?
      RosettaStone::LDAPUserAuthentication::ActiveDirectoryUser.authenticate(:user_name => 'asdf', :password => 'asdf', :group => 'asdf')
      return true
    rescue Exception
      return false, "Unable to connect to LDAP server.  Check settings in ldap.yml!"
    end
  end
end