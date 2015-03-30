class AdGroup

  include RosettaStone::YamlSettings
  yaml_settings(:config_file => 'ldap.yml', :hash_reader => false)

  class << self
    attr_accessor :csp_ldap_map, :ldap_csp_map
    
    def all_groups
      if self.csp_ldap_map.blank?
        self.csp_ldap_map = settings[:groups][RosettaStone::ProductionDetection.could_be_on_production? ? :prod : :test]
        self.ldap_csp_map = {}
        self.csp_ldap_map.each{|csp, ldap| self.ldap_csp_map[ldap] = csp}
      end
      self.csp_ldap_map
    end

    def all_names
      all_groups.values
    end

    def account_type(name)
      self.ldap_csp_map[name].present? ? self.ldap_csp_map[name].camelize : nil
    end

    def ldap_type(name)
      self.csp_ldap_map[name]
    end
  end

  # def self.coach
  # def self.coach_manager
  # def self.admin
  self.all_groups.each do |method, name|
    AdGroup.class_eval("def self.#{method};'#{name}';end;")
  end
    
end

