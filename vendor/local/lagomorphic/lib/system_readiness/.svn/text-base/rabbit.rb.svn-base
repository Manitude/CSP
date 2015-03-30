# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

class SystemReadiness::Rabbit < SystemReadiness::Base
  class << self
    def verify
      configuration = nil
      configurations_to_verify = (defined?(RABBIT_CONFIGURATIONS_TO_VERIFY_FOR_SYSTEM_READINESS) && RABBIT_CONFIGURATIONS_TO_VERIFY_FOR_SYSTEM_READINESS) || [nil]
      configurations_to_verify.each do |configuration|
        ::Rabbit::Helpers.test_connection(configuration)
      end
      return true, ''
    rescue ::Rabbit::ConnectionError => rabbit_connection_error
      return false, "Rabbit::ConnectionError for #{configuration || 'default connection'}: #{rabbit_connection_error.message}"
    rescue Rabbit::AuthenticationError => rabbit_auth_error
      return false, rabbit_auth_error.to_s
    end
  end
end
