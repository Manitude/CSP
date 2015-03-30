# Copyright:: Copyright (c) 2009 Rosetta Stone
# License:: All rights reserved.

# See usage of this in the community rails app. You will likely need to override in your subclasses:
# def production_ad_group
# def non_production_ad_group
#
# Note: use of this module depends on the following other plugins being present in your app:
#  * ldap_user_authentication
#  * what_instance_am_i
module RosettaStone
  class ActiveDirectoryAuthenticatedUser
    class MissingConfigException < StandardError; end
    class UserEntryNotFoundException < StandardError; end
    class GroupIdentifierNotFoundException < StandardError; end
    class << self
      include RosettaStone::PrefixedLogger # for log_benchmark

      def authenticate(user_name, password)
        if auto_authorized? || (ldap_entry = RosettaStone::LDAPUserAuthentication::ActiveDirectoryUser.authenticate(:user_name => user_name, :password => password, :group => group_name))
          if auto_authorized?
            logger.info("Auto-authorization enabled; bypassed authentication for user '#{user_name}'")
          else
            logger.info("Successfully authenticated user '#{user_name}' against AD group '#{group_name}'")
          end
          OpenStruct.new(:user_name => user_name, :email => ldap_entry.if_hot {|e| e.respond_to?(:[]) && e[:mail].to_s }) # to_s to convert from Net::BER::BerIdentifiedArray to string. if auto_authorized, the entry will be nil, hence the if_hot. in tests we sometimes return just true from the auth call, so check to see if the thing looks like an ldap_entry
        else
          logger.info("Failed to authenticate user '#{user_name}' against AD group '#{group_name}'")
          nil
        end
      end

      def production_security?
        RosettaStone::ProductionDetection.could_be_on_production?
      end
      
      def group_name
        production_security? ? production_ad_group : non_production_ad_group
      end

      def is_in_group?(user_name, identifier)
        return user_name.to_s.include?(identifier.to_s) if auto_authorized?
        user_entry = RosettaStone::LDAPUserAuthentication::User.find_by_identifier(user_name)
        raise UserEntryNotFoundException.new("No user entry found") if user_entry.nil?
        roles = instance_specific_role_mappings
        raise GroupIdentifierNotFoundException.new("No role mapping found for #{identifier}") if !roles.has_key?(identifier)
        ad_group_name = roles[identifier]
        !!RosettaStone::LDAPUserAuthentication::ActiveDirectoryUser.user_in_group?(user_entry, ad_group_name)
      end
      
      def appropriate_instance_key
        (production_security?) ? :production : :non_production
      end

    private
      def auto_authorized?
        return @auto_authorized unless @auto_authorized.nil? # this is cacheable per-process
        @auto_authorized = Rails.test? || (Rails.development? && File.exists?(File.join(Rails.root, 'config', 'editor_user_auto_authorize.yml')))
      end


      # Define production_ad_group in your subclasses!
      #def production_ad_group; '~RS Community Editors'; end

      def non_production_ad_group
        mappings = instance_specific_role_mappings
        if mappings && mappings.has_key?(:basic_access)
          mappings[:basic_access]
        else
          '@RS NonProduction Editor Access'
        end
      end


      def production_ad_group
        mappings = instance_specific_role_mappings
        if mappings && mappings.has_key?(:basic_access)
          mappings[:basic_access]
        else
          raise MissingConfigException.new("No production AD group defined. You can either add it to ldap.yml or override production_ad_group in your subclass.")
        end
      end

      def instance_specific_role_mappings
        mappings = RosettaStone::LDAPUserAuthentication::ActiveDirectoryUser.fetch_configuration
        instance_key = self.appropriate_instance_key
        if mappings && mappings.is_a?(Hash) && mappings[:role_mappings] && mappings[:role_mappings][instance_key]
          mappings[:role_mappings][instance_key]
        else
          nil
        end
      end
    end
  end
end
