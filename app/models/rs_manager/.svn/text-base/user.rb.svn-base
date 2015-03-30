module RsManager
  class User < RsManagerConnection

    belongs_to :role, :class_name => "RsManager::Role"
    belongs_to :namespace, :class_name => "RsManager::Namespace"
    delegate :creation_account_identifier, :to => :namespace, :class_name => "RsManager::Namespace"

    # Gives the equivalent learner object
    def user
      Learner.find_by_guid(guid)
    end

    def self.rs_manager_license_identifier?(license_identifier)
      #license_identifer could be CE::rockinghamcountyva/sublicenses/OLLC::827cb902-d21f-42b7-a6e9-453e4798307e (or) rockinghamcountyva/sublicenses/OLLC::827cb902-d21f-42b7-a6e9-453e4798307e
      license_identifier =~ /^(?!Ollc).*?\/sublicenses/
    end

    def self.find_by_license_identifier(license_identifier)
      guid = guid_from_license_identifier(license_identifier)
      find_by_guid(guid)
    end

    def self.guid_from_license_identifier(license_identifier)
      license_identifier =~ /.*::(.*?)$/
      $1
    end

    def super_admin?
      administrator? && role.super_admin?
    end

    def administrator?
      !self.role_id.nil?
    end

    def license_identifier
      "#{creation_account_identifier}/sublicenses/OLLC::#{guid}"
    end

  end
end
