# lame, but this doesn't get auto-required in 2.x it seems
require 'active_support/version'

module RosettaStone
  module LDAPUserAuthentication
    CONNECTION_TIMEOUT_IN_SECONDS = 10

    class ConnectionError < Exception; end
    class ConfigurationError < Exception; end

    class User
      if ActiveSupport::VERSION::MAJOR > 2 && ActiveSupport::VERSION::MINOR > 0
        class_attribute :configuration
        class_attribute :configuration_file_path
        class_attribute :connection
      else
        class_inheritable_accessor :configuration
        class_inheritable_accessor :configuration_file_path
        class_inheritable_accessor :connection
      end

      self.configuration_file_path = Pathname.new(File.join(Rails.root, 'config', 'ldap.yml')).cleanpath

      class << self
        include RosettaStone::PrefixedLogger

        # Authenticates a user against an LDAP server. Valid options are:
        #   :user - The username that should be matched against the identifier defined in ldap.yml
        #   :password - A password this user must match
        def authenticate(credentials = {}, options = {})
          connect
          entry = find_by_identifier(credentials[:user_name])
          return false unless entry
          log_benchmark("authenticating user #{credentials[:user_name]}") do
            connection.auth(entry.dn, credentials[:password])
            connection.bind ? entry : false
          end
        end

        def find_by_identifier(identifier)
          connect
          find_first_entry_for_attribute(configuration[:identifier_attribute], identifier, :treebase => corporate_treebase)
        end

        def fetch_configuration
          setup_configuration
          return configuration
        end

        def find_by_distinguishedname(distinguishedname)
          connect
          find_first_entry_for_attribute(:distinguishedname, distinguishedname, :treebase => corporate_treebase)
        end

      private

        def connect
          return true if connected?
          setup_configuration
          # Makes the connection object
          self.connection = Net::LDAP.new(attributes_for_net_ldap_configuration)
          connected?
        end

        def connected?
          # If the host in the config has changed since we made the connection, reconnect. Should probably
          # just override configuration= to keep track of config changes and reconnect. FIXME
          begin
            Timeout::timeout(CONNECTION_TIMEOUT_IN_SECONDS) do
              connection && (configuration[:host] == connection.host) && log_benchmark("connecting to LDAP server") { connection.bind }
            end
          rescue Timeout::Error => timeout_error
            raise ConnectionError, "Connection timeout: Timeout::Error after #{CONNECTION_TIMEOUT_IN_SECONDS}s: #{timeout_error.message}"
          rescue Net::LDAP::LdapError => ldap_error
            raise ConnectionError, "Net::LDAP::LdapError: #{ldap_error.message}"
          rescue OpenSSL::SSL::SSLError => openssl_error
            raise ConnectionError, "OpenSSL::SSL::SSLError: #{openssl_error.message}"
          end
        end

        def setup_configuration
          environment = Framework.env.to_sym
          config_hash = read_configuration[environment]
          if config_hash.nil?
            raise ConfigurationError, "Configuration file #{configuration_file_path} did not specify configuration details for the \"#{environment}\" environment."
          end
          config_hash[:encryption] = config_hash[:encryption].to_sym if config_hash[:encryption]
          config_hash[:auth][:method] = config_hash[:auth][:method].to_sym if config_hash[:auth]
          self.configuration = config_hash if configuration.nil?
        end

        def attributes_for_net_ldap_configuration
          config_hash = configuration.dup
          config_hash.delete(:treebase)
          config_hash.delete(:identifier_attribute)
          config_hash.delete(:group_identifier_attribute)
          config_hash
        end

        def read_configuration
          YAML.load_file(configuration_file_path).recursively_symbolize_keys
        rescue Errno::ENOENT
          raise ConfigurationError, "Configuration file #{configuration_file_path} couldn't be loaded."
        end

        def find_first_entry_for_attribute(attribute_name, value, options = {})
          log_benchmark("find_first_entry_for_attribute '#{value}'") do
            filter = equality_filter(attribute_name, value)
            search_tree(:first, filter, options)
          end
        end

        def search_tree(first_or_all, filter, options = {})
          treebase = options[:treebase] || configuration[:treebase]
          case first_or_all
          when :first
            ldap_entry = connection.search(:base => treebase, :filter => filter) { |entry| break entry }
            return (ldap_entry.is_a?(Array) && ldap_entry.empty?) ? nil : ldap_entry
          when :all
            return connection.search(:base => treebase, :filter => filter)
          end
        end

        def equality_filter(attribute, value)
          Net::LDAP::Filter.eq(attribute, value)
        end

        def corporate_treebase
          configuration[:corporate_treebase] || configuration[:treebase]
        end
      end

    end # User
  end   # LDAPUserAuthentication
end
