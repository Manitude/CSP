# -*- encoding : utf-8 -*-

class SystemReadiness::ActiveLicensingConnectivity < SystemReadiness::Base
  class << self
    def verify
      return true, "Untested in test environment" if Rails.test?
      begin
        RosettaStone::ActiveLicensing::Base.instance.license.details(:license => 'kstarling')
      rescue RosettaStone::ActiveLicensing::ConnectionException => connection_error
        return false, "Unable to connect to license server: #{connection_error}"
      rescue RosettaStone::ActiveLicensing::AccessDeniedException => access_error
        return false, "Access denied from license server: #{access_error}"
      rescue RosettaStone::ActiveLicensing::LicenseNotFound
        return true if Rails.development? #If you're in dev mode, who cares
        return false, "We expected to find a license for kstarling, but didn't find it.  Should probably investigate."
      rescue => exception
        return false, "There's some problem with the LS connection: #{exception}"
      end
    end
  end
end
