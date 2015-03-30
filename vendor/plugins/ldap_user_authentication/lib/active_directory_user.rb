module RosettaStone
  module LDAPUserAuthentication

    class ActiveDirectoryUser < User

      # Authenticates a user against an LDAP server. Valid credentials are:
      #   :user - The username that should be matched against the identifier defined in ldap.yml
      #   :password - A password this user must match
      #   :group - Something that should be in memberof in the ActiveDirectory server. If nil, user can auth without being in a group.
      # Options are
      #   :recurse - Defaults to true, set to false if you don't want it to recurse the groups to
      #   check if the user can authenticate
      #   :treebase - override treebase in which to search
      def self.authenticate(credentials = {}, options = {})
        # short cut for user's password is empty case, because
        # 1. it is impossbile for AD user to have an empty password
        # 2. connection.bind method always return true for any user 
        # with an empty password (even though the user's password is not empty), this messes up
        # the ldap library code and our code which uses connection.bind to check for connection status
        return false if credentials[:password] == ""
        options = options.dup
        options[:recurse] = true if options[:recurse].nil?
        entry = super
        check_group_membership(entry, credentials[:group], options)
      end

      # expects the given user to support the method "[:member_of]", and
      # the method "memberof" which should return exactly what the user
      # object from self.authenticate will return.
      # this method will check the full group tree of the user, not just
      # the groups the user is directly related to.
      def self.user_in_group?(user_entry, group_name)
        setup_configuration
        connect
        options = {}
        options[:recurse] = true
        check_group_membership(user_entry, group_name, options)
      end

      def self.build_member_group_tree_for(group_entry, options = {:include_self => true})
        valid_groups = []
        valid_groups << group_entry if options[:include_self]
        member_groups_for_entry(group_entry).each { |member_group| valid_groups += build_member_group_tree_for(member_group) }
        valid_groups
      end

      def self.build_parent_group_tree_for(group_entry)
        valid_groups = []
        valid_groups << group_entry
        parent_groups_for_entry(group_entry).each { |member_group| valid_groups += build_parent_group_tree_for(member_group) }
        valid_groups
      end

      def self.parent_groups_for_entry(group_entry)
        return [] if group_entry[:memberof].blank?
        parent_filter = group_entry[:memberof].inject(nil) do |filter, parent_dn|
          parent_dn_filter = equality_filter('distinguishedname', parent_dn)
          (filter.nil?) ? parent_dn_filter : Net::LDAP::Filter.new(:or, parent_dn_filter, filter)
        end
        group_only_filter = parent_filter & group_filter
        search_tree(:all, group_only_filter)
      end

    private
      def self.check_group_membership(user_entry, group_name, options = {})
        return user_entry if group_name.blank? || !user_entry || user_entry.blank?
        group = find_first_entry_for_attribute(configuration[:group_identifier_attribute], group_name)
        return false if group.blank?
        log_benchmark("check_if_user_is_in_group '#{group_name}'") do
          check_if_user_is_in_group(user_entry, group, options)
        end
      end

      def self.check_if_user_is_in_group(user_entry, group_entry, options)
        if options[:recurse]
          deep_check_if_user_is_in_group(user_entry, group_entry, user_entry[:memberof], {})
        else
          group_distinguishedname = group_entry.distinguishedname.first
          return user_entry.memberof.include?(group_distinguishedname) ? user_entry : false
        end
      end

      def self.deep_check_if_user_is_in_group(user_entry, group_entry, user_groups, cache)
        return false if cache[group_entry.distinguishedname] # we already tried this group, and the user is not a member
        return user_entry if user_groups.include?(group_entry.distinguishedname.first)
        member_groups_for_entry(group_entry).each do |member_group|
          return user_entry if deep_check_if_user_is_in_group(user_entry, member_group, user_groups, cache)
        end
        cache[group_entry.distinguishedname] = true # if we're here, the user is not part of the group. mark it.
        false
      end

      def self.member_groups_for_entry(group_entry)
        return [] if group_entry[:member].blank?
        member_filter = group_entry[:member].inject(nil) do |filter, member_dn|
          member_dn_filter = equality_filter('distinguishedname', member_dn)
          (filter.nil?) ? member_dn_filter : Net::LDAP::Filter.new(:or, member_dn_filter, filter)
        end
        group_only_filter = member_filter & group_filter
        search_tree(:all, group_only_filter)
      end

      def self.group_filter
        @group_filter ||= equality_filter('objectclass', 'group')
      end

    end # ActiveDirectoryUser

  end
end
