module RosettaStone
  module LDAPUserAuthentication
    class MailingList < ActiveDirectoryUser

      # override class inheritable accessor to avoid sharing with parents
      cattr_accessor :configuration

      attr_accessor :entry

      def initialize(entry)
        self.entry = entry
      end

      class << self
        def find_all
          setup_ldap_connection_for_class
          groups = find_all_entries_for_attribute(:cn, "@*") + find_all_entries_for_attribute(:cn, "~*")
          groups.map {|e| e && new(e) }.select {|m| m.name !~ /Everyone/}
        end

        def find_by_name(name)
          setup_ldap_connection_for_class
          entry = find_first_by_attribute(:cn, name)
          return nil if entry.nil?
          new(entry)
        end

        def build_global_hash
          $mailing_lists = {}
          find_all.each do |group|
            $mailing_lists[group.entry.cn.first] = group.members
          end
        end

        def setup_ldap_connection_for_class
          send(:setup_configuration)
          send(:connect)
        end

        # overriden here so we don't get just the corporate treebase. we want the more inclusive treebase.
        def find_by_distinguishedname(distinguishedname)
          setup_ldap_connection_for_class
          find_first_by_attribute(:distinguishedname, distinguishedname)
        end

        def find_first_by_attribute(attribute, value)
          send(:find_first_entry_for_attribute, attribute, value)
        end
      end

      def name
        entry.name.to_s # same as entry.cn.to_s
      end

      def email
        entry[:mail].first
      end
      
      def managed_by
        dn = entry[:managedby].first
        return nil if dn.nil?
        User.find_by_distinguishedname(dn)
      end

      def members
        klass.setup_ldap_connection_for_class

        group_entries = klass.build_member_group_tree_for(entry)
        members = group_entries.inject([]) {|members, group_entry| members += group_entry[:member]}

        logins = []
        members.uniq.each do |dn|
          begin
            entry = self.klass.find_by_distinguishedname(dn)
            if entry.cn.first.starts_with?('@') || entry.cn.first.starts_with?('~')
              logins << entry.cn.first
            else
              logins << entry.samaccountname.first
            end
          rescue NoMethodError => e
            # no samaccountname method for some ldap entries...ignore them...
            # puts "Ouch. died trying to get a user: #{dn}. error: #{e.inspect}"
          end
        end
        logins
      end

      private

      def self.setup_configuration
        config_hash = read_configuration[RAILS_ENV.to_sym]
        config_hash[:encryption] = config_hash[:encryption].to_sym if config_hash[:encryption]
        config_hash[:auth][:method] = config_hash[:auth][:method].to_sym if config_hash[:auth]

        # these lines are different from parent class
        config_hash[:treebase] = "dc=rosettastone,dc=local" # straight override
        self.configuration = config_hash if self.configuration.nil?
      end

    end
  end
end
